import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({Key? key}) : super(key: key);

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  String? _selectedChallenge;

  @override
  void initState() {
    super.initState();
    // Load saved data if available
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final onboarding = provider.state.onboarding;
    
    if (onboarding != null && onboarding.quitChallenge != null) {
      switch (onboarding.quitChallenge) {
        case QuitChallenge.stress:
          _selectedChallenge = 'stress';
          break;
        case QuitChallenge.habit:
          _selectedChallenge = 'habit';
          break;
        case QuitChallenge.social:
          _selectedChallenge = 'social';
          break;
        case QuitChallenge.addiction:
          _selectedChallenge = 'addiction';
          break;
        default:
          _selectedChallenge = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final onboarding = provider.state.onboarding;
    final localizations = AppLocalizations.of(context);
    
    if (onboarding == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Determine correct goal text for the challenge question
    final String goalText = onboarding.goal == GoalType.reduce
        ? 'reduzir'
        : 'parar de fumar';

    return OnboardingContainer(
      title: localizations.challengeQuestion(goalText),
      subtitle: localizations.identifyChallenge,
      content: Column(
        children: [
          const SizedBox(height: 16),
          
          // Stress option
          OptionCard(
            selected: _selectedChallenge == 'stress',
            onPress: () {
              setState(() {
                _selectedChallenge = 'stress';
              });
            },
            label: localizations.stressAnxiety,
            description: localizations.stressDescription,
          ),
          
          const SizedBox(height: 12),
          
          // Habit option
          OptionCard(
            selected: _selectedChallenge == 'habit',
            onPress: () {
              setState(() {
                _selectedChallenge = 'habit';
              });
            },
            label: localizations.habitStrength,
            description: localizations.habitDescription,
          ),
          
          const SizedBox(height: 12),
          
          // Social option
          OptionCard(
            selected: _selectedChallenge == 'social',
            onPress: () {
              setState(() {
                _selectedChallenge = 'social';
              });
            },
            label: localizations.socialInfluence,
            description: localizations.socialDescription,
          ),
          
          const SizedBox(height: 12),
          
          // Addiction option
          OptionCard(
            selected: _selectedChallenge == 'addiction',
            onPress: () {
              setState(() {
                _selectedChallenge = 'addiction';
              });
            },
            label: localizations.physicalDependence,
            description: localizations.dependenceDescription,
          ),
          
          const SizedBox(height: 24),
          
          // Informational text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              localizations.challengeHelp,
              style: context.textTheme.bodyMedium!.copyWith(
                color: context.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      canProceed: _selectedChallenge != null,
      onNext: () {
        // Map selection to corresponding enum
        QuitChallenge? challenge;
        
        switch (_selectedChallenge) {
          case 'stress':
            challenge = QuitChallenge.stress;
            break;
          case 'habit':
            challenge = QuitChallenge.habit;
            break;
          case 'social':
            challenge = QuitChallenge.social;
            break;
          case 'addiction':
            challenge = QuitChallenge.addiction;
            break;
        }
        
        // Update the model
        if (challenge != null) {
          final updated = onboarding.copyWith(
            quitChallenge: challenge,
          );
          
          provider.updateOnboarding(updated).then((_) {
            provider.nextStep();
          });
        } else {
          // Show error message if no challenge is selected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.pleaseSelectChallenge),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}