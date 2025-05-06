import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';

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
    
    if (currentOnboarding == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Ajustar o título com base no objetivo selecionado (reduzir ou parar)
    final goalText = currentOnboarding.goal == GoalType.reduce 
        ? "reduzir o consumo" 
        : "parar de fumar";

    return OnboardingContainer(
      title: "Quando você deseja $goalText?",
      subtitle: "Estabeleça um prazo que pareça alcançável para você",
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Um cronograma realista aumenta suas chances de sucesso. Escolha um prazo com o qual você se sinta confortável.',
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
            label: '7 dias',
            description: 'Quero resultados rápidos e estou comprometido',
          ),
          
          const SizedBox(height: 12),
          
          OptionCard(
            selected: _selectedTimeline == GoalTimeline.fourteenDays,
            onPress: () {
              setState(() {
                _selectedTimeline = GoalTimeline.fourteenDays;
              });
            },
            label: '14 dias',
            description: 'Um prazo equilibrado para mudança de hábito',
          ),
          
          const SizedBox(height: 12),
          
          OptionCard(
            selected: _selectedTimeline == GoalTimeline.thirtyDays,
            onPress: () {
              setState(() {
                _selectedTimeline = GoalTimeline.thirtyDays;
              });
            },
            label: '30 dias',
            description: 'Um mês para mudança gradual e sustentável',
          ),
          
          const SizedBox(height: 12),
          
          OptionCard(
            selected: _selectedTimeline == GoalTimeline.noDeadline,
            onPress: () {
              setState(() {
                _selectedTimeline = GoalTimeline.noDeadline;
              });
            },
            label: 'Sem prazo definido',
            description: 'Prefiro ir no meu próprio ritmo',
          ),
          
          const SizedBox(height: 24),
          
          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Não se preocupe se você não atingir seu objetivo exatamente no prazo. O importante é o progresso contínuo.',
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
            const SnackBar(
              content: Text('Por favor, selecione um prazo'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      canProceed: _selectedTimeline != null,
    );
  }
}