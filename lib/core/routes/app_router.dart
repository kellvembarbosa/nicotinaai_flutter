import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/features/auth/models/auth_state.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/auth/screens/forgot_password_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/login_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/register_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/splash_screen.dart';
import 'package:nicotinaai_flutter/features/main/screens/main_screen.dart';
import 'package:nicotinaai_flutter/features/home/screens/home_screen.dart';
import 'package:nicotinaai_flutter/features/achievements/screens/updated_achievements_screen.dart' as updated;
import 'package:nicotinaai_flutter/features/achievements/screens/achievement_detail_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/settings_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/language_selection_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/currency_selection_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/dashboard_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/statistics_dashboard_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/add_smoking_log_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/add_craving_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/health_recovery_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/health_recovery_detail_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/widgets/health_recovery_test.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';

/// Router para configuração de rotas da aplicação com proteção de autenticação
class AppRouter {
  final AuthProvider authProvider;
  final OnboardingProvider onboardingProvider;
  
  AppRouter({
    required this.authProvider,
    required this.onboardingProvider,
  });
  
  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: authProvider,
    initialLocation: SplashScreen.routeName,
    redirect: _handleRedirect,
    routes: [
      // Rota de splash screen
      GoRoute(
        path: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Rotas de autenticação
      GoRoute(
        path: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.routeName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: ForgotPasswordScreen.routeName,
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
        path: AppRoutes.developerDashboard.path,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.statisticsDashboard.path,
        builder: (context, state) => const StatisticsDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.addSmokingLog.path,
        builder: (context, state) => const AddSmokingLogScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCraving.path,
        builder: (context, state) => const AddCravingScreen(),
      ),
      GoRoute(
        path: AppRoutes.currency.path,
        builder: (context, state) => const CurrencySelectionScreen(),
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Erro: Página não encontrada'),
      ),
    ),
  );

  // Flag para evitar loops infinitos
  bool _hasCompletedInitialNavigation = false;
  bool _redirectLoopDetected = false;
  int _redirectCount = 0;
  DateTime? _lastRedirectTime;
  
  /// Gerencia os redirecionamentos com base no estado de autenticação e onboarding
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    // Implementação de controle de loop
    _redirectCount++;
    final now = DateTime.now();
    if (_lastRedirectTime != null) {
      final difference = now.difference(_lastRedirectTime!).inMilliseconds;
      if (difference < 100 && _redirectCount > 5) {
        if (!_redirectLoopDetected) {
          print('⚠️ [AppRouter] Detectado possível loop de redirecionamento! Pausando redirecionamentos.');
          _redirectLoopDetected = true;
        }
        return null; // Bloqueia redirecionamentos quando um loop é detectado
      }
    }
    _lastRedirectTime = now;
    
    // Reset do contador após um período sem redirecionamentos
    Future.delayed(Duration(seconds: 5), () {
      _redirectCount = 0;
      _redirectLoopDetected = false;
    });
    
    // Páginas que não requerem autenticação
    final publicPages = [
      LoginScreen.routeName,
      RegisterScreen.routeName,
      ForgotPasswordScreen.routeName,
    ];
    
    // Página atual
    final currentLocation = state.uri.path;
    final isGoingToSplash = currentLocation == SplashScreen.routeName;
    final isGoingToPublicPage = publicPages.contains(currentLocation);
    final isGoingToOnboarding = currentLocation == OnboardingScreen.routeName;
    final isGoingToMainScreen = currentLocation == MainScreen.routeName;
    
    // Verifica se está autenticado ou verificando autenticação
    final isAuthenticated = authProvider.isAuthenticated;
    final isAuthenticating = authProvider.state.status == AuthStatus.authenticating;
    final isInitializing = authProvider.state.status == AuthStatus.initial;
    
    // Verifica se já completou o onboarding
    final onboardingState = onboardingProvider.state;
    final hasCompletedOnboarding = onboardingState.isCompleted;
    final isOnboardingLoaded = !onboardingState.isInitial && !onboardingState.isLoading;
    
    // Log para depuração (reduzido)
    if (_redirectCount < 10 || _redirectCount % 10 == 0) {
      print('🧭 [AppRouter] Redirecionamento #$_redirectCount - Autenticado: $isAuthenticated, Onboarding: $hasCompletedOnboarding, Rota: $currentLocation');
    }
    
    // PROTEÇÃO CONTRA LOOP: Se já estamos na tela principal, nunca redirecionar
    if (isGoingToMainScreen) {
      _hasCompletedInitialNavigation = true;
      return null;
    }
    
    // PROTEÇÃO CONTRA LOOP: Se já completamos a navegação inicial, só redirecionar para páginas específicas
    if (_hasCompletedInitialNavigation) {
      // Após a primeira navegação completa, permitimos apenas redirecionamentos específicos
      // para evitar loops infinitos
      if (!isAuthenticated && !isGoingToPublicPage && !isGoingToSplash) {
        return RegisterScreen.routeName; // Redirecionar páginas protegidas para login se não autenticado
      }
      return null; // Para todos os outros casos, não redirecionamos mais
    }
    
    // Se estiver inicializando ou autenticando, permite permanecer na tela de splash
    if ((isInitializing || isAuthenticating) && isGoingToSplash) {
      return null;
    }
    
    // Redirecionamento da tela de splash após verificação de autenticação
    if (isGoingToSplash && !isInitializing && !isAuthenticating) {
      if (isAuthenticated) {
        if (!hasCompletedOnboarding) {
          return OnboardingScreen.routeName;
        }
        return MainScreen.routeName;
      } else {
        return RegisterScreen.routeName;
      }
    }
    
    // Se não estiver autenticado e tentando acessar página protegida
    if (!isAuthenticated && !isGoingToPublicPage && !isGoingToSplash) {
      return RegisterScreen.routeName;
    }
    
    // Se estiver autenticado mas não completou onboarding
    if (isAuthenticated && !hasCompletedOnboarding && !isGoingToOnboarding && !isGoingToSplash) {
      return OnboardingScreen.routeName;
    }
    
    // Se estiver autenticado, completou onboarding e está indo para onboarding
    if (isAuthenticated && hasCompletedOnboarding && isGoingToOnboarding) {
      return MainScreen.routeName;
    }
    
    // Se estiver autenticado e tentando acessar página pública
    if (isAuthenticated && isGoingToPublicPage) {
      if (!hasCompletedOnboarding) {
        return OnboardingScreen.routeName;
      }
      return MainScreen.routeName;
    }
    
    // Sem redirecionamento
    return null;
  }
}