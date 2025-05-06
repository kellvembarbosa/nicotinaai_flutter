import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/core/routes/app_router.dart';
import 'package:nicotinaai_flutter/core/theme/theme_provider.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';

void main() async {
  // Garante que os widgets estão iniciados antes de chamar código nativo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configura a aparência da barra de status
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  
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
        // Provider de tema
        ChangeNotifierProvider(
          create: (_) {
            final themeProvider = ThemeProvider();
            // Inicializa o provider de tema
            themeProvider.initialize();
            return themeProvider;
          },
        ),
        
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
                
            // Inicializa apenas se o usuário estiver autenticado
            if (authProvider.isAuthenticated) {
              // Agende a inicialização para o próximo ciclo de frame
              // para evitar chamadas múltiplas durante a construção
              print('👤 [MyApp] Usuário autenticado. Agendando inicialização do onboarding');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                print('🔄 [MyApp] Iniciando onboarding após autenticação');
                provider.initialize();
                
                // Verificar explicitamente o status de conclusão no banco de dados
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  print('🔍 [MyApp] Verificando status de onboarding no banco de dados');
                  await provider.checkCompletionStatus();
                });
              });
            } else {
              print('🔒 [MyApp] Usuário não autenticado. Onboarding não inicializado');
            }
            
            return provider;
          },
        ),
      ],
      child: Consumer3<ThemeProvider, AuthProvider, OnboardingProvider>(
        builder: (context, themeProvider, authProvider, onboardingProvider, _) {
          // Criamos o router dentro do Consumer para reconstruir quando o estado mudar
          final appRouter = AppRouter(
            authProvider: authProvider,
            onboardingProvider: onboardingProvider,
          );
          
          return MaterialApp.router(
            title: 'NicotinaAI',
            debugShowCheckedModeBanner: false,
            
            // Configuração de temas
            themeMode: themeProvider.themeMode,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}