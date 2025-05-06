import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/core/routes/app_router.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  // Garante que os widgets estão iniciados antes de chamar código nativo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carrega as variáveis de ambiente
  await dotenv.load();
  
  // Inicializa o Supabase
  await SupabaseConfig.initialize();
  
  // Cria os repositórios
  final authRepository = AuthRepository();
  final onboardingRepository = OnboardingRepository();
  
  runApp(MyApp(
    authRepository: authRepository,
    onboardingRepository: onboardingRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  
  const MyApp({
    required this.authRepository,
    required this.onboardingRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider de autenticação
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: authRepository,
          ),
        ),
        
        // Provider de onboarding que depende do estado de autenticação
        ChangeNotifierProxyProvider<AuthProvider, OnboardingProvider>(
          create: (_) => OnboardingProvider(
            repository: onboardingRepository,
          ),
          update: (_, authProvider, previousOnboardingProvider) {
            final provider = previousOnboardingProvider ?? 
                OnboardingProvider(repository: onboardingRepository);
                
            // Inicializa apenas se o usuário estiver autenticado e ainda não inicializou
            if (authProvider.isAuthenticated && 
                provider.state.isInitial && 
                !provider.state.isLoading) {
              // Agende a inicialização para o próximo ciclo de frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.initialize();
              });
            }
            
            return provider;
          },
        ),
      ],
      child: Consumer2<AuthProvider, OnboardingProvider>(
        builder: (context, authProvider, onboardingProvider, _) {
          // Criamos o router dentro do Consumer para reconstruir quando o estado mudar
          final appRouter = AppRouter(
            authProvider: authProvider,
            onboardingProvider: onboardingProvider,
          );
          
          return MaterialApp.router(
            title: 'NicotinaAI',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              // Paleta de cores baseada em azul para transmitir confiança
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2962FF), // Azul vibrante
                primary: const Color(0xFF2962FF),
                secondary: const Color(0xFF0D47A1),
                tertiary: const Color(0xFF82B1FF),
                background: Colors.white,
                surface: Colors.white,
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Colors.black,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(
                Theme.of(context).textTheme,
              ),
              appBarTheme: AppBarTheme(
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.black),
                titleTextStyle: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF), // Azul primário
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2962FF), // Azul primário
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                labelStyle: GoogleFonts.poppins(
                  color: Colors.grey[800],
                ),
                floatingLabelStyle: GoogleFonts.poppins(
                  color: Color(0xFF2962FF), // Azul primário
                ),
              ),
              // Estilo de botões de texto
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2962FF), // Azul primário
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              // Estilo de botões outlined
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2962FF), // Azul primário
                  side: const BorderSide(color: Color(0xFF2962FF), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}