import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_bloc.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_event.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/core/routes/router_refresh_stream.dart';
import 'package:nicotinaai_flutter/features/auth/screens/first_launch_language_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/forgot_password_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/login_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/register_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/splash_screen.dart';
import 'package:nicotinaai_flutter/features/main/screens/main_screen.dart';
import 'package:nicotinaai_flutter/features/home/screens/home_screen.dart';
import 'package:nicotinaai_flutter/features/achievements/screens/updated_achievements_screen.dart' as updated;
import 'package:nicotinaai_flutter/features/achievements/screens/achievement_detail_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/cigarettes_per_day_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/currency_selection_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/delete_account_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/edit_profile_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/language_selection_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/language_selection_screen_bloc.dart';
import 'package:nicotinaai_flutter/features/settings/screens/pack_price_screen_improved.dart';
import 'package:nicotinaai_flutter/features/settings/screens/quit_date_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/reset_password_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/settings_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/theme_selection_screen_bloc.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/feedback_onboarding_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/statistics_dashboard_screen.dart';
// Removed imports for deleted screens
import 'package:nicotinaai_flutter/features/tracking/screens/health_recovery_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/health_recovery_detail_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/widgets/health_recovery_test.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// Router para configuração de rotas da aplicação com proteção de autenticação
class AppRouter {
  final AuthBloc authBloc;
  final OnboardingBloc onboardingBloc;
  
  AppRouter({
    required this.authBloc,
    required this.onboardingBloc,
  });
  
  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: RouterRefreshStream(authBloc),
    initialLocation: SplashScreen.routeName,
    redirect: _handleRedirect,
    routes: [
      // Rota de splash screen
      GoRoute(
        path: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // First launch language selection route
      GoRoute(
        path: AppRoutes.firstLaunchLanguage.path,
        builder: (context, state) => const FirstLaunchLanguageScreen(),
      ),
      
      // Rotas de autenticação
      GoRoute(
        path: AppRoutes.login.path,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register.path,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword.path,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Rota de onboarding
      GoRoute(
        path: OnboardingScreen.routeName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Rota principal com tabs
      GoRoute(
        path: MainScreen.routeName,
        builder: (context, state) => const MainScreen(),
      ),
      
      // Rotas individuais para as tabs (para navegação direta)
      GoRoute(
        path: HomeScreen.routeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: updated.AchievementsScreen.routeName,
        builder: (context, state) => const updated.AchievementsScreen(),
      ),
      GoRoute(
        path: SettingsScreen.routeName,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: LanguageSelectionScreen.routeName,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      
      // Rotas de tracking e estatísticas
      GoRoute(
        path: AppRoutes.statisticsDashboard.path,
        builder: (context, state) => const StatisticsDashboardScreen(),
      ),
      // Removed routes for AddSmokingLogScreen and AddCravingScreen which have been migrated to BLoC
      GoRoute(
        path: AppRoutes.currency.path,
        builder: (context, state) => const CurrencySelectionScreen(),
      ),
      
      // BLoC screens routes
      GoRoute(
        path: AppRoutes.themeBloc.path,
        builder: (context, state) => const ThemeSelectionScreenBloc(),
      ),
      GoRoute(
        path: AppRoutes.languageBloc.path,
        builder: (context, state) => const LanguageSelectionScreenBloc(),
      ),
      
      // Health recovery routes
      GoRoute(
        path: AppRoutes.healthRecovery.path,
        builder: (context, state) => const HealthRecoveryScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthRecoveryDetail.path,
        builder: (context, state) {
          final recoveryId = state.pathParameters['recoveryId'] ?? '';
          return HealthRecoveryDetailScreen(recoveryId: recoveryId);
        },
      ),
      GoRoute(
        path: AppRoutes.healthRecoveryTest.path,
        builder: (context, state) => const HealthRecoveryTest(),
      ),
      
      // Achievement routes
      GoRoute(
        path: AppRoutes.achievementDetail.path,
        builder: (context, state) {
          final achievementId = state.pathParameters['achievementId'] ?? '';
          return AchievementDetailScreen(achievementId: achievementId);
        },
      ),
      
      // Feedback route
      GoRoute(
        path: AppRoutes.appFeedback.path,
        builder: (context, state) => const FeedbackOnboardingScreen(),
      ),
      
      // Settings routes
      GoRoute(
        path: AppRoutes.packPrice.path,
        builder: (context, state) => const PackPriceScreenImproved(),
      ),
      GoRoute(
        path: AppRoutes.cigarettesPerDay.path,
        builder: (context, state) => const CigarettesPerDayScreen(),
      ),
      GoRoute(
        path: AppRoutes.quitDate.path,
        builder: (context, state) => const QuitDateScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword.path,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.deleteAccount.path,
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile.path,
        builder: (context, state) => const EditProfileScreen(),
      ),
      
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(AppLocalizations.of(context).pageNotFound),
      ),
    ),
  );

  // Flag para evitar loops infinitos
  bool _hasCompletedInitialNavigation = false;
  
  /// Gerencia os redirecionamentos com base no estado de autenticação e onboarding
  /// Versão ultra-simplificada para evitar problemas
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    // Página atual
    final currentLocation = state.uri.path;
    
    // REGRA CRÍTICA: JAMAIS interferir na navegação da SplashScreen
    // A SplashScreen é responsável por direcionar o usuário para o local correto
    if (currentLocation == SplashScreen.routeName) {
      print('🛑 [AppRouter] Na tela de splash, NUNCA interferir');
      return null;
    }
    
    // Não interferir na navegação para a tela de seleção de idioma
    if (currentLocation == AppRoutes.firstLaunchLanguage.path) {
      print('🛑 [AppRouter] Na tela de seleção de idioma, não interferir');
      return null;
    }
    
    // Verificar se a seleção de idioma já foi feita
    // Importante: Isso deve ser feito através do LocaleBloc do contexto
    final localeBloc = BlocProvider.of<LocaleBloc>(context);
    
    // Verificar diretamente com SharedPreferences para maior precisão
    // já que o estado do bloc pode não ter sido atualizado ainda
    bool isLanguageSelectionComplete = localeBloc.state.isLanguageSelectionComplete;
    
    // Log detalhado sobre o estado de seleção de idioma
    print('🔍 [AppRouter] Estado de seleção de idioma - BlocState: $isLanguageSelectionComplete');
    print('🔍 [AppRouter] Current locale: ${localeBloc.state.locale.languageCode}_${localeBloc.state.locale.countryCode ?? ""}');
    
    // Verificar se estamos tentando ir para a tela de login após a seleção de idioma
    if (currentLocation == AppRoutes.login.path && 
        localeBloc.state.isInitialized) {
      print('✅ [AppRouter] Permitindo navegação para login após seleção de idioma');
      return null;
    }
    
    // Se a seleção de idioma não foi feita, redirecionar para a tela de seleção de idioma
    // Mas apenas se não estiver já na tela de seleção de idioma
    if (!isLanguageSelectionComplete && 
        currentLocation != AppRoutes.firstLaunchLanguage.path &&
        currentLocation != SplashScreen.routeName) {
      print('🔤 [AppRouter] Seleção de idioma não foi feita, redirecionando para tela de seleção');
      return AppRoutes.firstLaunchLanguage.path;
    }
    
    final isAuthenticated = authBloc.state.isAuthenticated;
    final onboardingCompleted = onboardingBloc.state.isCompleted;
    
    // Log detalhado para diagnosticar problemas de redirecionamento
    print('🧭 [AppRouter] Navegação para: $currentLocation - Auth: $isAuthenticated, Onboarding completo: $onboardingCompleted, Language selection: $isLanguageSelectionComplete');
    
    // REGRA 1: NUNCA interferir em navegações para MainScreen
    // Se o usuário está indo para MainScreen, devemos sempre permitir
    if (currentLocation == MainScreen.routeName) {
      print('✅ [AppRouter] Indo para MainScreen, permitindo navegação');
      _hasCompletedInitialNavigation = true; // Marca que já concluiu a navegação inicial
      return null;
    }
    
    // REGRA 2: Permitir navegação irrestrita após primeira navegação bem-sucedida
    // Isso evita que o sistema fique preso em loops infinitos de redirecionamento
    if (_hasCompletedInitialNavigation) {
      print('✅ [AppRouter] Navegação inicial já concluída, permitindo todas as navegações');
      return null;
    }
    
    // REGRA 3: Proteger rotas autenticadas se o usuário não estiver logado
    if (!isAuthenticated) {
      // Se não está autenticado, permitir acesso apenas às rotas de autenticação
      final isAuthRoute = currentLocation == AppRoutes.login.path || 
                          currentLocation == AppRoutes.register.path || 
                          currentLocation == AppRoutes.forgotPassword.path;
                          
      if (!isAuthRoute) {
        print('🔒 [AppRouter] Usuário não autenticado, redirecionando para login');
        return AppRoutes.login.path;
      }
      
      return null;
    }
    
    // REGRA 4: Proteger contra acesso a telas de autenticação quando já autenticado
    final isAuthRoute = currentLocation == AppRoutes.login.path || 
                        currentLocation == AppRoutes.register.path || 
                        currentLocation == AppRoutes.forgotPassword.path;
                        
    if (isAuthenticated && isAuthRoute) {
      print('🔄 [AppRouter] Usuário já autenticado tentando acessar tela de autenticação');
      
      // Se o onboarding está completo, ir para tela principal
      if (onboardingCompleted) {
        print('✅ [AppRouter] Onboarding completo, redirecionando para MainScreen');
        _hasCompletedInitialNavigation = true;
        return MainScreen.routeName;
      }
      
      // Se onboarding não está completo, ir para onboarding
      print('⏩ [AppRouter] Onboarding incompleto, redirecionando para OnboardingScreen');
      return OnboardingScreen.routeName;
    }
    
    // Para todas as outras rotas, permitir navegação normal
    return null;
  }
}