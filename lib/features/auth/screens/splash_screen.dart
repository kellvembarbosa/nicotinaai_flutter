import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';

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
      _checkAuthAndNavigate();
    });
  }
  
  void _checkAuthAndNavigate() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;
    
    if (!isAuthenticated) {
      // Se não estiver autenticado, ir para login
      print('🔒 [SplashScreen] Usuário não autenticado, redirecionando para login');
      context.go(AppRoutes.login.path);
      return;
    }
    
    print('👤 [SplashScreen] Usuário autenticado, verificando onboarding');
    
    // Se autenticado, verificar onboarding de forma síncrona
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    
    try {
      // Forçar inicialização do onboarding e aguardar conclusão
      print('🔄 [SplashScreen] Inicializando onboarding...');
      await onboardingProvider.initialize();
      
      if (!mounted) return;
      
      // Verificação direta no Supabase para confirmar o status
      print('🔍 [SplashScreen] Verificando status diretamente no Supabase');
      final isCompletedInSupabase = await onboardingProvider.checkCompletionStatus();
      
      if (!mounted) return;
      
      // Usar a verificação do Supabase como fonte primária da verdade
      print('✅ [SplashScreen] Status do onboarding no Supabase: ${isCompletedInSupabase ? "COMPLETO" : "INCOMPLETO"}');
      
      if (isCompletedInSupabase) {
        // Se onboarding completo no Supabase, ir para tela principal
        print('✅ [SplashScreen] Onboarding completo, redirecionando para tela principal');
        context.go(AppRoutes.main.path);
      } else {
        // Se não, ir para onboarding
        print('⏩ [SplashScreen] Onboarding incompleto, redirecionando para onboarding');
        context.go(AppRoutes.onboarding.path);
      }
    } catch (e) {
      if (!mounted) return;
      
      print('❌ [SplashScreen] Erro ao verificar onboarding: $e');
      
      // Em caso de erro, verificar estado em memória como fallback
      final isCompletedLocally = onboardingProvider.state.isCompleted;
      print('🔄 [SplashScreen] Fallback: status do onboarding em memória: ${isCompletedLocally ? "COMPLETO" : "INCOMPLETO"}');
      
      if (isCompletedLocally) {
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
            Image.asset(
              'assets/images/smoke-one.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            
            // App name
            Text(
              'NicotinaAI',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Loading indicator
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            
            // Loading message
            Text(
              l10n?.loading ?? 'Loading...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}