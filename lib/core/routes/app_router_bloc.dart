import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart' as bloc_state;
import 'package:nicotinaai_flutter/features/auth/screens/forgot_password_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/login_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/login_screen_bloc.dart';
import 'package:nicotinaai_flutter/features/auth/screens/register_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/splash_screen.dart';
import 'package:nicotinaai_flutter/features/main/screens/main_screen.dart';
import 'package:nicotinaai_flutter/features/home/screens/home_screen.dart';
import 'package:nicotinaai_flutter/features/achievements/screens/updated_achievements_screen.dart' as updated;
import 'package:nicotinaai_flutter/features/achievements/screens/achievement_detail_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/settings_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/language_selection_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/currency_selection_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/currency_selection_screen_bloc.dart';
import 'package:nicotinaai_flutter/features/settings/screens/theme_selection_screen_bloc.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/dashboard_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/dashboard_screen_with_bloc.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/statistics_dashboard_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/add_smoking_log_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/add_craving_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/health_recovery_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/health_recovery_detail_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/widgets/health_recovery_test.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';

/// Classe de refresh para GoRouter usar com BLoC
class AuthBlocRefreshListener extends ChangeNotifier {
  final AuthBloc _authBloc;
  bloc_state.AuthState _authState;

  AuthBlocRefreshListener(this._authBloc) : _authState = _authBloc.state {
    _authBloc.stream.listen((newState) {
      if (newState != _authState) {
        _authState = newState;
        notifyListeners();
      }
    });
  }
}

/// Router para configuração de rotas da aplicação com proteção de autenticação
/// Versão adaptada para usar BLoC em vez de Provider
class AppRouterBloc {
  final AuthBloc authBloc;
  final OnboardingProvider onboardingProvider; // Mantido por enquanto
  
  AppRouterBloc({
    required this.authBloc,
    required this.onboardingProvider,
  });
  
  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: AuthBlocRefreshListener(authBloc),
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
        builder: (context, state) => const LoginScreenBloc(),
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
        builder: (context, state) => const DashboardScreenWithBloc(),
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
      GoRoute(
        path: AppRoutes.currencyBloc.path,
        builder: (context, state) => const CurrencySelectionScreenBloc(),
      ),
      GoRoute(
        path: AppRoutes.themeBloc.path,
        builder: (context, state) => const ThemeSelectionScreenBloc(),
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
    // Página atual
    final currentLocation = state.uri.path;
    
    // REGRA CRÍTICA: JAMAIS interferir na navegação da SplashScreen
    if (currentLocation == SplashScreen.routeName) {
      print('🛑 [AppRouterBloc] Na tela de splash, NUNCA interferir');
      return null;
    }
    
    // Obter estado de autenticação do BLoC
    final isAuthenticated = authBloc.state.isAuthenticated;
    final onboardingCompleted = onboardingProvider.state.isCompleted;
    
    // Log detalhado para diagnosticar problemas de redirecionamento
    print('🧭 [AppRouterBloc] Navegação para: $currentLocation - Auth: $isAuthenticated, Onboarding completo: $onboardingCompleted');
    
    // REGRA 1: NUNCA interferir em navegações para MainScreen
    if (currentLocation == MainScreen.routeName) {
      print('✅ [AppRouterBloc] Indo para MainScreen, permitindo navegação');
      _hasCompletedInitialNavigation = true;
      return null;
    }
    
    // REGRA 2: Permitir navegação irrestrita após primeira navegação bem-sucedida
    if (_hasCompletedInitialNavigation) {
      print('✅ [AppRouterBloc] Navegação inicial já concluída, permitindo todas as navegações');
      return null;
    }
    
    // REGRA 3: Proteger rotas autenticadas se o usuário não estiver logado
    if (!isAuthenticated) {
      // Se não está autenticado, permitir acesso apenas às rotas de autenticação
      final isAuthRoute = currentLocation == LoginScreen.routeName || 
                          currentLocation == RegisterScreen.routeName || 
                          currentLocation == ForgotPasswordScreen.routeName;
                          
      if (!isAuthRoute) {
        print('🔒 [AppRouterBloc] Usuário não autenticado, redirecionando para login');
        return LoginScreen.routeName;
      }
      
      return null;
    }
    
    // REGRA 4: Proteger contra acesso a telas de autenticação quando já autenticado
    final isAuthRoute = currentLocation == LoginScreen.routeName || 
                        currentLocation == RegisterScreen.routeName || 
                        currentLocation == ForgotPasswordScreen.routeName;
                        
    if (isAuthenticated && isAuthRoute) {
      print('🔄 [AppRouterBloc] Usuário já autenticado tentando acessar tela de autenticação');
      
      // Se o onboarding está completo, ir para tela principal
      if (onboardingCompleted) {
        print('✅ [AppRouterBloc] Onboarding completo, redirecionando para MainScreen');
        _hasCompletedInitialNavigation = true;
        return MainScreen.routeName;
      }
      
      // Se onboarding não está completo, ir para onboarding
      print('⏩ [AppRouterBloc] Onboarding incompleto, redirecionando para OnboardingScreen');
      return OnboardingScreen.routeName;
    }
    
    // Para todas as outras rotas, permitir navegação normal
    return null;
  }
}