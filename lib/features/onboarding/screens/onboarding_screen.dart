import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/introduction_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/cigarettes_per_day_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/pack_price_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/cigarettes_per_pack_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/goal_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/timeline_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/challenge_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/help_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/product_type_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/completion_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/personalize_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/interests_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/locations_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';
  
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    // A inicialização do provider agora é controlada pelo ChangeNotifierProxyProvider no main.dart
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final state = provider.state;
    
    // Se estiver carregando, exibir indicador de progresso
    if (state.isLoading || state.isInitial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Se houver erro, exibir mensagem de erro
    if (state.hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Ocorreu um erro ao carregar o onboarding',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Erro desconhecido',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  provider.clearError();
                  provider.initialize();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Escolher a tela apropriada conforme o passo atual
    switch (state.currentStep) {
      case 1:
        return const IntroductionScreen();
      case 2:
        return const PersonalizeScreen();
      case 3:
        return const InterestsScreen();
      case 4:
        return const LocationsScreen();
      case 5:
        return const HelpScreen();
      case 6:
        return const CigarettesPerDayScreen();
      case 7:
        return const PackPriceScreen();
      case 8:
        return const CigarettesPerPackScreen();
      case 9:
        return const GoalScreen();
      case 10:
        return const TimelineScreen();
      case 11:
        return const ChallengeScreen();
      case 12:
        return const ProductTypeScreen();
      case 13:
        return const CompletionScreen();
      default:
        return const IntroductionScreen();
    }
  }
}