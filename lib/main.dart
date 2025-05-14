import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';
import 'package:nicotinaai_flutter/services/app_feedback_service.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';
import 'package:nicotinaai_flutter/services/supabase_diagnostic.dart';
import 'package:nicotinaai_flutter/features/settings/repositories/settings_repository.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart' as sw;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:nicotinaai_flutter/services/revenue_cat_service.dart';
import 'package:nicotinaai_flutter/services/revenue_cat_purchase_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/widgets/connectivity_overlay.dart';

// BLoC imports
import 'package:nicotinaai_flutter/blocs/app_bloc_observer.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_bloc.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_event.dart';
import 'package:nicotinaai_flutter/blocs/connectivity/connectivity_bloc.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_bloc.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_event.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_bloc.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_event.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_state.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/skeleton/skeleton_bloc.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_bloc.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_event.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_state.dart' as theme_state;
import 'package:nicotinaai_flutter/blocs/settings/settings_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_bloc.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_event.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_bloc.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_event.dart';

void main() async {
  // Garante que os widgets estão iniciados antes de chamar código nativo
  WidgetsFlutterBinding.ensureInitialized();

  // Configura a aparência da barra de status
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

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
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      debugPrint('✅ Firebase initialized successfully');
    } else {
      debugPrint('✅ Firebase was already initialized, skipping');
    }
  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
    // Continue without Firebase if it fails
  }

  // Initialize RevenueCat
  try {
    final revenueCatService = RevenueCatService();
    await revenueCatService.initialize(
      apiKey: _getRevenueCatApiKey(),
      observerMode: false, // Definir como false, pois o Superwall precisa que o RevenueCat gerencie as compras
    );
    debugPrint('✅ RevenueCat initialized successfully');
  } catch (e) {
    debugPrint('⚠️ RevenueCat initialization error: $e');
    // Continue without RevenueCat if it fails
  }

  // Initialize Superwall with RevenueCat integration
  try {
    // Create RevenueCat purchase controller
    final purchaseController = RevenueCatPurchaseController();

    // Configure Superwall with purchase controller
    sw.Superwall.configure(_getSuperwallApiKey(), purchaseController: purchaseController);

    // Sync subscription status initially
    await purchaseController.configureAndSyncSubscriptionStatus();

    debugPrint('✅ Superwall initialized with RevenueCat integration');
  } catch (e) {
    debugPrint('⚠️ Superwall initialization error: $e');
    // Continue without Superwall if it fails
  }

  // Inicializa o serviço de notificações após Supabase e Firebase
  await NotificationService().initialize();

  // Inicializa o serviço de analytics (novo sistema com PostHog)
  try {
    // API KEY do PostHog
    const apiKey = 'phc_6p1aoXFElcMePRqaKvhQq7J55xisFMoc0tfQXezeq4c';

    // Primeiro inicializa o serviço (que adicionará Facebook e Superwall por padrão)
    final analyticsService = AnalyticsService();
    await analyticsService.initialize();

    // Depois adiciona o PostHog
    await analyticsService.addAdapter(
      'PostHog',
      config: {
        'apiKey': apiKey,
        'host': 'https://us.i.posthog.com', // Host correto
      },
    );

    // Registrar evento de abertura do app
    await analyticsService.logAppOpen();

    debugPrint('✅ Analytics service with PostHog initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Analytics initialization error: $e');
    // Continue without analytics if it fails
  }

  // Obtém a instância do SharedPreferences para log
  final prefs = await SharedPreferences.getInstance();

  // Adiciona um listener para debugar alterações no SharedPreferences
  print("🔍 SharedPreferences values at startup:");
  prefs.getKeys().forEach((key) {
    print("   📌 $key: ${prefs.get(key)}");
  });

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
  final settingsRepository = SettingsRepository();
  
  // Cria serviços
  final appFeedbackService = AppFeedbackService();
  
  // Initialize achievement notification service
  final achievementNotifications = AchievementNotificationService(FlutterLocalNotificationsPlugin());

  runApp(
    MyApp(
      authRepository: authRepository,
      onboardingRepository: onboardingRepository,
      trackingRepository: trackingRepository,
      achievementNotifications: achievementNotifications,
      settingsRepository: settingsRepository,
      appFeedbackService: appFeedbackService,
    ),
  );
}

// Helper function to get the appropriate RevenueCat API key
String _getRevenueCatApiKey() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'appl_pkpgHbMNmUpYHENUhNpCfhJVxYX'; // Android API key
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    return 'appl_pkpgHbMNmUpYHENUhNpCfhJVxYX'; // iOS API key
  } else {
    throw Exception('Unsupported platform for RevenueCat');
  }
}

String _getSuperwallApiKey() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'pk_8828c0ca657f179fcb24a7532d6cf8d5309d7879506a7e25'; // Android API key
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    return 'pk_8828c0ca657f179fcb24a7532d6cf8d5309d7879506a7e25'; // iOS API key
  } else {
    return 'pk_8828c0ca657f179fcb24a7532d6cf8d5309d7879506a7e25'; // iOS API key
  }
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  final TrackingRepository trackingRepository;
  final AchievementNotificationService achievementNotifications;
  final SettingsRepository settingsRepository;
  final AppFeedbackService appFeedbackService;

  const MyApp({
    required this.authRepository,
    required this.onboardingRepository,
    required this.trackingRepository,
    required this.achievementNotifications,
    required this.settingsRepository,
    required this.appFeedbackService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC
        BlocProvider<AuthBloc>(create: (context) => AuthBloc(authRepository: authRepository)),

        // Connectivity BLoC
        BlocProvider<ConnectivityBloc>(
          create: (context) => ConnectivityBloc()..add(ConnectivityStarted()),
        ),

        // Skeleton BLoC for testing
        BlocProvider<SkeletonBloc>(create: (context) => SkeletonBloc(fetchData: () async => "Test data")),

        // TrackingBloc
        BlocProvider<TrackingBloc>(create: (context) => TrackingBloc(repository: trackingRepository)..add(InitializeTracking())),

        // Unified TrackingBloc now handles both cravings and smoking records

        // Os Providers legados foram removidos, usando apenas BLoCs

        // CurrencyBloc - Substitui o CurrencyProvider
        BlocProvider<CurrencyBloc>(
          create: (context) {
            final authBloc = context.read<AuthBloc>();
            return CurrencyBloc(authBloc: authBloc, authRepository: authRepository)..add(InitializeCurrency());
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

        // OnboardingBloc - Substitui o OnboardingProvider
        BlocProvider<OnboardingBloc>(
          create: (context) {
            // Usar o repositório já criado anteriormente
            final onboardingRepo = onboardingRepository;

            final onboardingBloc = OnboardingBloc(repository: onboardingRepo);
            // A inicialização será controlada pela SplashScreen
            return onboardingBloc;
          },
        ),

        // AchievementBloc - Substitui o AchievementProvider
        BlocProvider<AchievementBloc>(
          create: (context) {
            final achievementService = AchievementService(SupabaseConfig.client, trackingRepository);

            final achievementBloc = AchievementBloc(service: achievementService, notificationService: achievementNotifications);

            // Inicializa o bloc
            achievementBloc.add(InitializeAchievements());

            return achievementBloc;
          },
        ),

        // SettingsBloc
        BlocProvider<SettingsBloc>(
          create: (context) {
            return SettingsBloc(settingsRepository: settingsRepository);
          },
        ),

        // AnalyticsBloc - Novo BLoC para analytics
        BlocProvider<AnalyticsBloc>(create: (context) => AnalyticsBloc()..add(const InitializeAnalyticsEvent())),
        
        // AppFeedbackBloc - Novo BLoC para feedback do usuário
        BlocProvider<AppFeedbackBloc>(
          create: (context) => AppFeedbackBloc(feedbackService: appFeedbackService),
        ),

        // Todos os providers legados foram removidos
      ],
      child: Builder(
        builder: (context) {
          // Inicializar o router usando os BLoCs
          final authBloc = context.read<AuthBloc>();
          final onboardingBloc = context.read<OnboardingBloc>();

          // Criar router usando BLoCs para evitar loop de reconstrução
          final appRouter = AppRouter(authBloc: authBloc, onboardingBloc: onboardingBloc);

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
                    
                    // Envolver toda a aplicação com ConnectivityOverlay
                    builder: (context, child) {
                      return ConnectivityOverlay(child: child!);
                    },
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