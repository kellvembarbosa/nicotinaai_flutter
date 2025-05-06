import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({Key? key}) : super(key: key);

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  GoalType? _selectedGoal;
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final currentOnboarding = provider.state.onboarding;
    
    if (currentOnboarding?.goal != null) {
      _selectedGoal = currentOnboarding!.goal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final currentOnboarding = provider.state.onboarding;
    final localizations = AppLocalizations.of(context);
    
    if (currentOnboarding == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return OnboardingContainer(
      title: localizations.goalQuestion,
      subtitle: localizations.selectGoal,
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              localizations.goalExplanation,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Opção de reduzir
          OptionCard(
            selected: _selectedGoal == GoalType.reduce,
            onPress: () {
              setState(() {
                _selectedGoal = GoalType.reduce;
              });
            },
            label: localizations.reduceConsumption,
            description: localizations.reduceDescription,
            child: _selectedGoal == GoalType.reduce ? Padding(
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
                      child: Column(
                        children: [
                          Icon(
                            Icons.trending_down,
                            color: const Color(0xFF2962FF),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.reduce,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2962FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ) : null,
          ),
          
          const SizedBox(height: 16),
          
          // Opção de parar
          OptionCard(
            selected: _selectedGoal == GoalType.quit,
            onPress: () {
              setState(() {
                _selectedGoal = GoalType.quit;
              });
            },
            label: localizations.quitSmoking,
            description: localizations.quitDescription,
            child: _selectedGoal == GoalType.quit ? Padding(
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
                      child: Column(
                        children: [
                          Icon(
                            Icons.smoke_free,
                            color: const Color(0xFF2962FF),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.quit,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2962FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ) : null,
          ),
          
          const SizedBox(height: 32),
          
          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              localizations.goalHelp,
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
        if (_selectedGoal != null) {
          final updated = currentOnboarding.copyWith(
            goal: _selectedGoal,
          );
          
          provider.updateOnboarding(updated).then((_) {
            provider.nextStep();
          });
        } else {
          // Mostrar mensagem de erro se nenhum objetivo for selecionado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.pleaseSelectGoal),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      canProceed: _selectedGoal != null,
    );
  }
}