import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';

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
    
    if (currentOnboarding == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return OnboardingContainer(
      title: "Qual é o seu objetivo?",
      subtitle: "Selecione o que você deseja alcançar",
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Definir um objetivo claro é essencial para o seu sucesso. Queremos ajudar você a alcançar o que deseja.',
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
            label: 'Reduzir o consumo',
            description: 'Quero fumar menos cigarros e ter mais controle sobre o hábito',
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
                            'Reduzir',
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
            label: 'Parar de fumar',
            description: 'Quero largar completamente o cigarro e viver livre do tabaco',
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
                            'Parar',
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
              'Adaptaremos nossos recursos e recomendações com base em seu objetivo. Você poderá modificá-lo mais tarde se mudar de ideia.',
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
            const SnackBar(
              content: Text('Por favor, selecione um objetivo'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      canProceed: _selectedGoal != null,
    );
  }
}