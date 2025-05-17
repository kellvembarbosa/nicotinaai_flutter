import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_bloc.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_event.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/widgets/platform_loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Deixar o sistema carregar um pouco antes de verificar status
    Future.delayed(Duration(milliseconds: 1500), () {
      _checkLanguageAndNavigate();
    });
  }

  void _checkLanguageAndNavigate() async {
    if (!mounted) return;

    // Check language selection first
    final localeBloc = context.read<LocaleBloc>();
    
    // Make sure we check the language selection status
    localeBloc.add(CheckLanguageSelectionStatus());
    
    // Give it a moment to process
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!mounted) return;
    
    // Check if language selection is complete
    final isLanguageSelectionComplete = await localeBloc.isLanguageSelectionComplete();
    
    print('🔤 [SplashScreen] Verificando seleção de idioma: ${isLanguageSelectionComplete ? "COMPLETA" : "INCOMPLETA"}');
    
    // If language selection is not complete, go to language selection screen
    if (!isLanguageSelectionComplete) {
      print('🔤 [SplashScreen] Seleção de idioma incompleta, redirecionando para tela de seleção de idioma');
      context.go(AppRoutes.firstLaunchLanguage.path);
      return;
    }
    
    // Otherwise continue with normal flow
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    if (!mounted) return;

    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    final isAuthenticated = authState.isAuthenticated;

    print(
      '🛑 [SplashScreen] Na tela de splash, NUNCA interferir na navegação do Router!',
    );
    print(
      'ℹ️ [SplashScreen] O SplashScreen agora está apenas aguardando o Router decidir para onde ir.',
    );

    if (!isAuthenticated) {
      // Se não estiver autenticado, ir para login
      print(
        '🔒 [SplashScreen] Usuário não autenticado, redirecionando para login',
      );
      context.go(AppRoutes.login.path);
      return;
    }

    print('👤 [SplashScreen] Usuário autenticado, verificando onboarding');

    // Se autenticado, verificar onboarding
    final onboardingBloc = context.read<OnboardingBloc>();

    try {
      // Forçar inicialização do onboarding e aguardar resposta do evento
      print('🔄 [SplashScreen] Inicializando onboarding...');
      onboardingBloc.add(InitializeOnboarding());

      // Aguardar um tempo para o onboarding ser inicializado
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Verificação direta no Supabase para confirmar o status
      print('🔍 [SplashScreen] Verificando status do onboarding');
      onboardingBloc.add(CheckOnboardingStatus());

      // Aguardar verificação
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Obter estado atual do onboarding
      final onboardingState = onboardingBloc.state;
      final isCompleted = onboardingState.isCompleted;

      // Usar a verificação como fonte primária da verdade
      print(
        '✅ [SplashScreen] Status do onboarding: ${isCompleted ? "COMPLETO" : "INCOMPLETO"}',
      );

      if (isCompleted) {
        // Se onboarding completo, ir para tela principal
        print(
          '✅ [SplashScreen] Onboarding completo, redirecionando para tela principal',
        );
        context.go(AppRoutes.main.path);
      } else {
        // Se não, ir para onboarding
        print(
          '⏩ [SplashScreen] Onboarding incompleto, redirecionando para onboarding',
        );
        context.go(AppRoutes.onboarding.path);
      }
    } catch (e) {
      if (!mounted) return;

      print('❌ [SplashScreen] Erro ao verificar onboarding: $e');

      // Em caso de erro, verificar estado atual como fallback
      final onboardingState = onboardingBloc.state;
      final isCompleted = onboardingState.isCompleted;
      print(
        '🔄 [SplashScreen] Fallback: status do onboarding: ${isCompleted ? "COMPLETO" : "INCOMPLETO"}',
      );

      if (isCompleted) {
        context.go(AppRoutes.main.path);
      } else {
        context.go(AppRoutes.onboarding.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Image.asset('assets/images/smoke-one.png', width: 120, height: 120),
            const SizedBox(height: 24),

            // App name
            Text(
              'Nicotina.AI',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Loading indicator
            const PlatformLoadingIndicator(size: 32),
            const SizedBox(height: 16),

            // Loading message
            Text(l10n.loading, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
