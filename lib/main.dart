import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nicotinaai_flutter/config/firebase_options.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/core/routes/app_router.dart';
import 'package:nicotinaai_flutter/core/services/db_check_service.dart';
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';
import 'package:nicotinaai_flutter/features/home/repositories/craving_repository.dart';
import 'package:nicotinaai_flutter/features/home/repositories/smoking_record_repository.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:nicotinaai_flutter/features/tracking/repositories/tracking_repository.dart';
import 'package:nicotinaai_flutter/features/achievements/services/achievement_service.dart';
import 'package:nicotinaai_flutter/features/achievements/services/achievement_notification_service.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/analytics_service.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';
import 'package:nicotinaai_flutter/services/supabase_diagnostic.dart';

// BLoC imports
import 'package:nicotinaai_flutter/blocs/app_bloc_observer.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_event.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_bloc.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_event.dart';
import 'package:nicotinaai_flutter/blocs/craving/craving_bloc.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_bloc.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_event.dart';
import 'package:nicotinaai_flutter/blocs/developer_mode/developer_mode_bloc.dart';
import 'package:nicotinaai_flutter/blocs/developer_mode/developer_mode_event.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_bloc.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_event.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_state.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/blocs/skeleton/skeleton_bloc.dart';
import 'package:nicotinaai_flutter/blocs/smoking_record/smoking_record_bloc.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_bloc.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_event.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_state.dart' as theme_state;
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';

void main() async {
  // Garante que os widgets estão iniciados antes de chamar código nativo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configura a aparência da barra de status
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  
  // Initialize BlocObserver for debugging
  Bloc.observer = AppBlocObserver();
  
  // Carrega as variáveis de ambiente primeiro
  await dotenv.load();
  
  // Inicializa o Supabase
  await SupabaseConfig.initialize();
  
  // Inicializa o Firebase (apenas se ainda não estiver inicializado)
  try {
    // Verifica se o Firebase já está inicializado
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized successfully');
    } else {
      debugPrint('✅ Firebase was already initialized, skipping');
    }
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
  final cravingRepository = CravingRepository();
  final smokingRecordRepository = SmokingRecordRepository();
  
  // Initialize achievement notification service
  final achievementNotifications = AchievementNotificationService(
    FlutterLocalNotificationsPlugin()
  );
  
  runApp(MyApp(
    authRepository: authRepository,
    onboardingRepository: onboardingRepository,
    trackingRepository: trackingRepository,
    cravingRepository: cravingRepository,
    smokingRecordRepository: smokingRecordRepository,
    achievementNotifications: achievementNotifications,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  final TrackingRepository trackingRepository;
  final CravingRepository cravingRepository;
  final SmokingRecordRepository smokingRecordRepository;
  final AchievementNotificationService achievementNotifications;
  
  const MyApp({
    required this.authRepository,
    required this.onboardingRepository,
    required this.trackingRepository,
    required this.cravingRepository,
    required this.smokingRecordRepository,
    required this.achievementNotifications,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          // Auth BLoC
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: authRepository,
            ),
          ),
          
          // Skeleton BLoC for testing
          BlocProvider<SkeletonBloc>(
            create: (context) => SkeletonBloc(
              fetchData: () async => "Test data",
            ),
          ),
          
          // TrackingBloc
          BlocProvider<TrackingBloc>(
            create: (context) => TrackingBloc(
              repository: trackingRepository,
            )..add(InitializeTracking()),
          ),
          
          // CravingBloc
          BlocProvider<CravingBloc>(
            create: (context) {
              // Obtém referência ao TrackingBloc para atualizações
              final trackingBloc = context.read<TrackingBloc>();
              return CravingBloc(
                repository: cravingRepository,
                trackingBloc: trackingBloc,
              );
            },
          ),
          
          // SmokingRecordBloc
          BlocProvider<SmokingRecordBloc>(
            create: (context) {
              // Obtém referência ao TrackingBloc para atualizações
              final trackingBloc = context.read<TrackingBloc>();
              return SmokingRecordBloc(
                repository: smokingRecordRepository,
                trackingBloc: trackingBloc,
              );
            },
          ),
          
          // Os Providers legados foram removidos, usando apenas BLoCs
          
          // CurrencyBloc - Substitui o CurrencyProvider
          BlocProvider<CurrencyBloc>(
            create: (context) {
              final authBloc = context.read<AuthBloc>();
              return CurrencyBloc(
                authBloc: authBloc,
                authRepository: authRepository,
              )..add(InitializeCurrency());
            },
          ),
          
          // ThemeBloc - Substitui o ThemeProvider
          BlocProvider<ThemeBloc>(
            create: (context) {
              final themeBloc = ThemeBloc();
              // Inicializa o tema
              themeBloc.add(InitializeTheme());
              return themeBloc;
            },
          ),
          
          // LocaleBloc - Substitui o LocaleProvider
          BlocProvider<LocaleBloc>(
            create: (context) {
              final localeBloc = LocaleBloc();
              // Inicializa o locale
              localeBloc.add(InitializeLocale());
              return localeBloc;
            },
          ),
          
          // DeveloperModeBloc - Substitui o DeveloperModeProvider
          BlocProvider<DeveloperModeBloc>(
            create: (context) {
              final developerModeBloc = DeveloperModeBloc();
              // Inicializa o modo desenvolvedor
              developerModeBloc.add(InitializeDeveloperMode());
              return developerModeBloc;
            },
          ),
          
          // OnboardingBloc - Substitui o OnboardingProvider
          BlocProvider<OnboardingBloc>(
            create: (context) {
              // Usar o repositório já criado anteriormente
              final onboardingRepo = onboardingRepository;
              
              final onboardingBloc = OnboardingBloc(
                repository: onboardingRepo,
              );
              // A inicialização será controlada pela SplashScreen
              return onboardingBloc;
            },
          ),
          
          // AchievementBloc - Substitui o AchievementProvider
          BlocProvider<AchievementBloc>(
            create: (context) {
              final achievementService = AchievementService(
                SupabaseConfig.client,
                trackingRepository,
              );
              
              final achievementBloc = AchievementBloc(
                service: achievementService,
                notificationService: achievementNotifications,
              );
              
              // Inicializa o bloc 
              achievementBloc.add(InitializeAchievements());
              
              return achievementBloc;
            },
          ),
          
          // Todos os providers legados foram removidos
        ],
        child: Builder(
          builder: (context) {
            // Inicializar o router usando os BLoCs
            final authBloc = context.read<AuthBloc>();
            final onboardingBloc = context.read<OnboardingBloc>();
              
            // Criar router usando BLoCs para evitar loop de reconstrução
            final appRouter = AppRouter(
              authBloc: authBloc,
              onboardingBloc: onboardingBloc,
            );
              
            // Use BlocBuilder para obter o tema e locale atuais
            return BlocBuilder<LocaleBloc, LocaleState>(
              builder: (context, localeState) {
                return BlocBuilder<ThemeBloc, theme_state.ThemeState>(
                  builder: (context, themeState) {
                    return MaterialApp.router(
                      title: 'NicotinaAI',
                      debugShowCheckedModeBanner: false,
                      
                      // Configuração de temas usando ThemeBloc
                      themeMode: themeState.themeMode,
                      theme: themeState.lightTheme,
                      darkTheme: themeState.darkTheme,
                  
                      // Configuração de localização usando LocaleBloc
                      locale: localeState.locale,
                      localizationsDelegates: AppLocalizations.localizationsDelegates,
                      supportedLocales: localeState.supportedLocales,
                      
                      routerConfig: appRouter.router,
                    );
                  },
                );
              },
            );
          },
        ),
      );
  }
}