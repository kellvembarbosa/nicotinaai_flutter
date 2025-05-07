import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  GoalTimeline? _selectedTimeline;
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final currentOnboarding = provider.state.onboarding;
    
    if (currentOnboarding?.goalTimeline != null) {
      _selectedTimeline = currentOnboarding!.goalTimeline;
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

    // Dynamically set the title based on the goal type
    final String timelineQuestion = currentOnboarding.goal == GoalType.reduce 
        ? localizations.timelineQuestionReduce
        : localizations.timelineQuestionQuit;

    return OnboardingContainer(
      title: timelineQuestion,
      subtitle: localizations.establishDeadline,
      contentType: OnboardingContentType.regular,
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              localizations.timelineExplanation,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Opções de prazo
          OptionCard(
            selected: _selectedTimeline == GoalTimeline.sevenDays,
            onPress: () {
              setState(() {
                _selectedTimeline = GoalTimeline.sevenDays;
              });
            },
            label: localizations.sevenDays,
            description: localizations.sevenDaysDescription,
          ),
          
          const SizedBox(height: 12),
          
          OptionCard(
            selected: _selectedTimeline == GoalTimeline.fourteenDays,
            onPress: () {
              setState(() {
                _selectedTimeline = GoalTimeline.fourteenDays;
              });
            },
            label: localizations.fourteenDays,
            description: localizations.fourteenDaysDescription,
          ),
          
          const SizedBox(height: 12),
          
          OptionCard(
            selected: _selectedTimeline == GoalTimeline.thirtyDays,
            onPress: () {
              setState(() {
                _selectedTimeline = GoalTimeline.thirtyDays;
              });
            },
            label: localizations.thirtyDays,
            description: localizations.thirtyDaysDescription,
          ),
          
          const SizedBox(height: 12),
          
          OptionCard(
            selected: _selectedTimeline == GoalTimeline.noDeadline,
            onPress: () {
              setState(() {
                _selectedTimeline = GoalTimeline.noDeadline;
              });
            },
            label: localizations.noDeadline,
            description: localizations.noDeadlineDescription,
          ),
          
          const SizedBox(height: 24),
          
          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              localizations.timelineHelp,
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
        if (_selectedTimeline != null) {
          final updated = currentOnboarding.copyWith(
            goalTimeline: _selectedTimeline,
          );
          
          provider.updateOnboarding(updated).then((_) {
            provider.nextStep();
          });
        } else {
          // Mostrar mensagem de erro se nenhum prazo for selecionado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.pleaseSelectTimeline),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      canProceed: _selectedTimeline != null,
    );
  }
}