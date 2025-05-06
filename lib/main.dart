import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/core/routes/app_router.dart';
import 'package:nicotinaai_flutter/core/theme/theme_provider.dart';
import 'package:nicotinaai_flutter/core/localization/locale_provider.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';
import 'package:nicotinaai_flutter/features/home/providers/craving_provider.dart';
import 'package:nicotinaai_flutter/features/home/providers/smoking_record_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/repositories/tracking_repository.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

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
  
  // Garante que a preferência de idioma está definida para inglês
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_locale', 'en_US');
  
  // Cria os repositórios
  final authRepository = AuthRepository();
  final onboardingRepository = OnboardingRepository();
  final trackingRepository = TrackingRepository();
  
  runApp(MyApp(
    authRepository: authRepository,
    onboardingRepository: onboardingRepository,
    trackingRepository: trackingRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  final TrackingRepository trackingRepository;
  
  const MyApp({
    required this.authRepository,
    required this.onboardingRepository,
    required this.trackingRepository,
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
        
        // Provider de localização
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
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
                // com uma pequena espera para garantir que a conexão está estável
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await Future.delayed(const Duration(milliseconds: 1000));
                  print('🔍 [MyApp] Verificando status de onboarding no banco de dados');
                  final isCompleted = await provider.checkCompletionStatus();
                  print('🔍 [MyApp] Status de conclusão do onboarding: ${isCompleted ? "Completo" : "Incompleto"}');
                });
              });
            } else {
              print('🔒 [MyApp] Usuário não autenticado. Onboarding não inicializado');
            }
            
            return provider;
          },
        ),
        
        // Provider para registro de fissuras
        ChangeNotifierProxyProvider<AuthProvider, CravingProvider>(
          create: (_) => CravingProvider(),
          update: (_, authProvider, previousProvider) {
            final provider = previousProvider ?? CravingProvider();
            return provider;
          },
        ),
        
        // Provider para registro de cigarros fumados
        ChangeNotifierProxyProvider<AuthProvider, SmokingRecordProvider>(
          create: (_) => SmokingRecordProvider(),
          update: (_, authProvider, previousProvider) {
            final provider = previousProvider ?? SmokingRecordProvider();
            return provider;
          },
        ),
        
        // Provider para o sistema de tracking
        ChangeNotifierProxyProvider<AuthProvider, TrackingProvider>(
          create: (_) => TrackingProvider(
            repository: trackingRepository,
          ),
          update: (_, authProvider, previousProvider) {
            final provider = previousProvider ?? 
                TrackingProvider(repository: trackingRepository);
                
            // Inicializa apenas se o usuário estiver autenticado
            if (authProvider.isAuthenticated) {
              // Agenda a inicialização para o próximo ciclo de frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.initialize();
              });
            }
            
            return provider;
          },
        ),
      ],
      child: Consumer4<ThemeProvider, LocaleProvider, AuthProvider, OnboardingProvider>(
        builder: (context, themeProvider, localeProvider, authProvider, onboardingProvider, _) {
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
            
            // Configuração de localização
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: localeProvider.supportedLocales,
            
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}