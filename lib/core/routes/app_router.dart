import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/features/auth/models/auth_state.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/auth/screens/forgot_password_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/login_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/register_screen.dart';
import 'package:nicotinaai_flutter/features/main/screens/main_screen.dart';
import 'package:nicotinaai_flutter/features/home/screens/home_screen.dart';
import 'package:nicotinaai_flutter/features/achievements/screens/achievements_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/settings_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/language_selection_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';

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
    initialLocation: LoginScreen.routeName,
    redirect: _handleRedirect,
    routes: [
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
        path: AchievementsScreen.routeName,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: SettingsScreen.routeName,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: LanguageSelectionScreen.routeName,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Erro: Página não encontrada'),
      ),
    ),
  );

  /// Gerencia os redirecionamentos com base no estado de autenticação e onboarding
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    // Páginas que não requerem autenticação
    final publicPages = [
      LoginScreen.routeName,
      RegisterScreen.routeName,
      ForgotPasswordScreen.routeName,
    ];
    
    // Página atual
    final currentLocation = state.uri.path;
    final isGoingToPublicPage = publicPages.contains(currentLocation);
    final isGoingToOnboarding = currentLocation == OnboardingScreen.routeName;
    
    // Verifica se está autenticado ou verificando autenticação
    final isAuthenticated = authProvider.isAuthenticated;
    final isAuthenticating = authProvider.state.status == AuthStatus.authenticating;
    final isInitializing = authProvider.state.status == AuthStatus.initial;
    
    // Verifica se já completou o onboarding
    // Só considera se o estado já está carregado
    final onboardingState = onboardingProvider.state;
    final hasCompletedOnboarding = onboardingState.isCompleted;
    final isOnboardingLoaded = !onboardingState.isInitial && !onboardingState.isLoading;
    
    // Se estiver inicializando ou autenticando, permite permanecer na página atual
    if (isInitializing || isAuthenticating) {
      return null;
    }
    
    // Se não estiver autenticado e tentando acessar página protegida
    if (!isAuthenticated && !isGoingToPublicPage) {
      return LoginScreen.routeName;
    }
    
    // Se estiver autenticado mas não completou onboarding
    // e não está indo para a página de onboarding
    // Só redireciona se o estado do onboarding já foi carregado
    if (isAuthenticated && isOnboardingLoaded && !hasCompletedOnboarding && !isGoingToOnboarding) {
      return OnboardingScreen.routeName;
    }
    
    // Se estiver autenticado, completou onboarding e está indo para onboarding
    // Só redireciona se o estado do onboarding já foi carregado
    if (isAuthenticated && isOnboardingLoaded && hasCompletedOnboarding && isGoingToOnboarding) {
      return MainScreen.routeName;
    }
    
    // Se estiver autenticado e tentando acessar página pública
    if (isAuthenticated && isGoingToPublicPage) {
      // Só redireciona para onboarding se o estado já foi carregado
      if (isOnboardingLoaded && !hasCompletedOnboarding) {
        return OnboardingScreen.routeName;
      }
      return MainScreen.routeName;
    }
    
    // Sem redirecionamento
    return null;
  }
}