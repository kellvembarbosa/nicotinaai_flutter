import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nicotinaai_flutter/config/firebase_options.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/core/routes/app_router.dart';
import 'package:nicotinaai_flutter/core/theme/theme_provider.dart';
import 'package:nicotinaai_flutter/core/localization/locale_provider.dart';
import 'package:nicotinaai_flutter/core/providers/developer_mode_provider.dart';
import 'package:nicotinaai_flutter/core/providers/currency_provider.dart';
import 'package:nicotinaai_flutter/core/services/db_check_service.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';
import 'package:nicotinaai_flutter/features/home/providers/craving_provider.dart';
import 'package:nicotinaai_flutter/features/home/providers/smoking_record_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/repositories/tracking_repository.dart';
import 'package:nicotinaai_flutter/features/achievements/providers/achievement_provider.dart';
import 'package:nicotinaai_flutter/features/achievements/services/achievement_service.dart';
import 'package:nicotinaai_flutter/features/achievements/services/achievement_notification_service.dart';
import 'package:nicotinaai_flutter/features/achievements/helpers/achievement_helper.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/analytics_service.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';
import 'package:nicotinaai_flutter/services/supabase_diagnostic.dart';
import 'package:nicotinaai_flutter/services/migration_service.dart';

void main() async {
  // Garante que os widgets estão iniciados antes de chamar código nativo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configura a aparência da barra de status
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  
  // Carrega as variáveis de ambiente primeiro
  await dotenv.load();
  
  // Inicializa o Supabase
  await SupabaseConfig.initialize();
  
  // Inicializa o Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
    // Continue without Firebase if it fails
  }
  
  // Inicializa o serviço de notificações após Supabase e Firebase
  await NotificationService().initialize();
  
  // Inicializa o serviço de analytics (Facebook App Events)
  try {
    await AnalyticsService().initialize();
    debugPrint('✅ Analytics service initialized successfully');
    await AnalyticsService().logAppOpen();
  } catch (e) {
    debugPrint('⚠️ Analytics initialization error: $e');
    // Continue without analytics if it fails
  }
  
  // Garante que a preferência de idioma está definida para inglês
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_locale', 'en_US');
  
  // Verificar a disponibilidade das tabelas do banco de dados
  final dbCheckService = DbCheckService();
  final allTablesAvailable = await dbCheckService.checkAllEssentialTables();
  
  if (!allTablesAvailable) {
    // Exibe logs detalhados em caso de problema com as tabelas
    debugPrint('⚠️ Nem todas as tabelas essenciais estão disponíveis');
    debugPrint(await dbCheckService.getDiagnosticReport());
    
    // Check if tables exist but don't try to create them from the client
    debugPrint('🔍 Checking for essential tables...');
    
    // Check smoking_logs
    try {
      await SupabaseConfig.client.from('smoking_logs').select('*').limit(1);
      debugPrint('✅ Table smoking_logs exists');
    } catch (e) {
      debugPrint('❌ Table smoking_logs does not exist or is not accessible');
      debugPrint('⚠️ SECURITY NOTE: Tables should be created using Supabase migrations or MCP functions');
      
      // Log diagnostic info
      await SupabaseDiagnostic.logDiagnosticReport(tableName: 'smoking_logs');
    }
    
    // Check viewed_achievements
    try {
      await SupabaseConfig.client.from('viewed_achievements').select('*').limit(1);
      debugPrint('✅ Table viewed_achievements exists');
    } catch (e) {
      debugPrint('❌ Table viewed_achievements does not exist or is not accessible');
      debugPrint('⚠️ SECURITY NOTE: Tables should be created using Supabase migrations or MCP functions');
      
      // Log diagnostic info
      await SupabaseDiagnostic.logDiagnosticReport(tableName: 'viewed_achievements');
    }
  } else {
    debugPrint('✅ Todas as tabelas essenciais estão disponíveis');
  }
  
  // Cria os repositórios
  final authRepository = AuthRepository();
  final onboardingRepository = OnboardingRepository();
  final trackingRepository = TrackingRepository();
  
  // Initialize achievement notification service
  final achievementNotifications = AchievementNotificationService(
    FlutterLocalNotificationsPlugin()
  );
  
  runApp(MyApp(
    authRepository: authRepository,
    onboardingRepository: onboardingRepository,
    trackingRepository: trackingRepository,
    achievementNotifications: achievementNotifications,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  final TrackingRepository trackingRepository;
  final AchievementNotificationService achievementNotifications;
  
  const MyApp({
    required this.authRepository,
    required this.onboardingRepository,
    required this.trackingRepository,
    required this.achievementNotifications,
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
        
        // Provider de modo desenvolvedor
        ChangeNotifierProvider(
          create: (_) {
            final developerModeProvider = DeveloperModeProvider();
            developerModeProvider.initialize();
            return developerModeProvider;
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
                
            // NÃO inicializamos o onboarding aqui para evitar corrida com SplashScreen
            // A SplashScreen tem total controle sobre a inicialização e verificação
            // do onboarding para garantir sequência correta de navegação
            print('🔒 [MyApp] Provider criado, mas SplashScreen controlará inicialização');
            
            // Apenas para modo de desenvolvimento, verificar o estado atual
            if (authProvider.isAuthenticated) {
              print('👤 [MyApp] DEBUG: Usuário autenticado, status onboarding: ${provider.state.isCompleted ? "COMPLETO" : "INCOMPLETO"}');
            } else {
              print('🔒 [MyApp] DEBUG: Usuário não autenticado');
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
        
        // Provider para registro de cigarros fumados
        ChangeNotifierProxyProvider2<AuthProvider, TrackingProvider, SmokingRecordProvider>(
          create: (_) => SmokingRecordProvider(),
          update: (_, authProvider, trackingProvider, previousProvider) {
            final provider = previousProvider ?? SmokingRecordProvider();
            
            // Configura a referência ao TrackingProvider para permitir atualizações de última data de fumo
            if (trackingProvider != null) {
              provider.trackingProvider = trackingProvider;
            }
            
            return provider;
          },
        ),
        
        // Provider para o sistema de moedas
        ChangeNotifierProxyProvider<AuthProvider, CurrencyProvider>(
          create: (context) => CurrencyProvider(
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (_, authProvider, previousProvider) {
            final provider = previousProvider ?? 
                CurrencyProvider(authProvider: authProvider);
                
            // Inicializa o provider
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.initialize();
            });
            
            return provider;
          },
        ),
        
        // Provider para o sistema de achievements
        ChangeNotifierProxyProvider2<AuthProvider, TrackingProvider, AchievementProvider>(
          create: (context) => AchievementProvider(
            AchievementService(
              SupabaseConfig.client,
              trackingRepository,
            ),
          ),
          update: (_, authProvider, trackingProvider, previousProvider) {
            // Reutilizar sempre o provider anterior para evitar recriações desnecessárias
            final provider = previousProvider ?? AchievementProvider(
              AchievementService(
                SupabaseConfig.client,
                trackingRepository,
              ),
            );
            
            // Inicializar apenas uma vez e somente se o usuário estiver autenticado
            if (authProvider.isAuthenticated && 
                provider.state.status == AchievementStatus.initial) {
              // Agendar para próximo frame para evitar loops
              Future.microtask(() {
                provider.loadAchievements();
              });
            }
            
            return provider;
          },
        ),
      ],
      builder: (context, child) {
        // Inicializar o router fora do consumer para evitar reconstruções
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
          
        // Criar router apenas uma vez para evitar loop de reconstrução
        final appRouter = AppRouter(
          authProvider: authProvider,
          onboardingProvider: onboardingProvider,
        );
          
        return Consumer2<ThemeProvider, LocaleProvider>(
          builder: (context, themeProvider, localeProvider, _) {
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
        );
      },
    );
  }
}