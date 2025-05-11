import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_state.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  QuitChallenge? _selectedChallenge;
  
  @override
  void initState() {
    super.initState();
    final state = context.read<OnboardingBloc>().state;
    final currentOnboarding = state.onboarding;
    
    if (currentOnboarding?.quitChallenge != null) {
      _selectedChallenge = currentOnboarding!.quitChallenge;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final currentOnboarding = state.onboarding;
        
        if (currentOnboarding == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Use the goal type to determine the correct question string with placeholder
        final String challengeQuestion = currentOnboarding.goal == GoalType.reduce
            ? localizations.challengeQuestion('reduzir') 
            : localizations.challengeQuestion('parar de fumar');

        return OnboardingContainer(
          title: challengeQuestion,
          subtitle: localizations.identifyChallenge,
          contentType: OnboardingContentType.scrollable,
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  localizations.challengeExplanation,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Opções de desafios
              OptionCard(
                selected: _selectedChallenge == QuitChallenge.stress,
                onPress: () {
                  setState(() {
                    _selectedChallenge = QuitChallenge.stress;
                  });
                },
                label: localizations.stressAnxiety,
                description: localizations.stressDescription,
                child: _selectedChallenge == QuitChallenge.stress ? _buildChallengeIcon(Icons.mood_bad) : null,
              ),
              
              const SizedBox(height: 12),
              
              OptionCard(
                selected: _selectedChallenge == QuitChallenge.habit,
                onPress: () {
                  setState(() {
                    _selectedChallenge = QuitChallenge.habit;
                  });
                },
                label: localizations.habitStrength,
                description: localizations.habitDescription,
                child: _selectedChallenge == QuitChallenge.habit ? _buildChallengeIcon(Icons.access_time) : null,
              ),
              
              const SizedBox(height: 12),
              
              OptionCard(
                selected: _selectedChallenge == QuitChallenge.social,
                onPress: () {
                  setState(() {
                    _selectedChallenge = QuitChallenge.social;
                  });
                },
                label: localizations.socialInfluence,
                description: localizations.socialDescription,
                child: _selectedChallenge == QuitChallenge.social ? _buildChallengeIcon(Icons.people) : null,
              ),
              
              const SizedBox(height: 12),
              
              OptionCard(
                selected: _selectedChallenge == QuitChallenge.addiction,
                onPress: () {
                  setState(() {
                    _selectedChallenge = QuitChallenge.addiction;
                  });
                },
                label: localizations.physicalDependence,
                description: localizations.dependenceDescription,
                child: _selectedChallenge == QuitChallenge.addiction ? _buildChallengeIcon(Icons.medication) : null,
              ),
              
              const SizedBox(height: 24),
              
              // Texto informativo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  localizations.challengeHelp,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          onNext: () {
            if (_selectedChallenge != null) {
              final updated = currentOnboarding.copyWith(
                quitChallenge: _selectedChallenge,
              );
              
              context.read<OnboardingBloc>().add(UpdateOnboarding(updated));
              context.read<OnboardingBloc>().add(NextOnboardingStep());
            } else {
              // Mostrar mensagem de erro se nenhum desafio for selecionado
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.pleaseSelectChallenge),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          canProceed: _selectedChallenge != null,
        );
      },
    );
  }
  
  Widget _buildChallengeIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2962FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2962FF),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}