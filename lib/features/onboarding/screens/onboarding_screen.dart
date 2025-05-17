import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_state.dart';
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
import 'package:nicotinaai_flutter/features/onboarding/screens/currency_selection_screen.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/feedback_onboarding_screen.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/notification_permission_screen.dart';

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
    // A inicialização do BLoC é controlada pelo BlocProvider no main.dart
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
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
                    AppLocalizations.of(context).onboardingLoadError,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? AppLocalizations.of(context).unknownError,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OnboardingBloc>().add(ClearOnboardingError());
                      context.read<OnboardingBloc>().add(InitializeOnboarding());
                    },
                    child: Text(AppLocalizations.of(context).tryAgain),
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
            return const CurrencySelectionScreen(); // Movida para ser a primeira após introdução
          case 3:
            return const PersonalizeScreen();
          case 4:
            return const InterestsScreen();
          case 5:
            return const LocationsScreen();
          case 6:
            return const HelpScreen();
          case 7:
            return const CigarettesPerDayScreen();
          case 8:
            return const PackPriceScreen();
          case 9:
            return const CigarettesPerPackScreen();
          case 10:
            return const GoalScreen();
          case 11:
            return const TimelineScreen();
          case 12:
            return const ChallengeScreen();
          case 13:
            return const ProductTypeScreen();
          case 14:
            return const FeedbackOnboardingScreen();
          case 15:
            return const NotificationPermissionScreen(); // Nova tela de permissão de notificação
          case 16:
            return const CompletionScreen();
          default:
            return const IntroductionScreen();
        }
      },
    );
  }
}