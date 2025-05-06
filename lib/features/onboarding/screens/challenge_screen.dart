import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';

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
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final currentOnboarding = provider.state.onboarding;
    
    if (currentOnboarding?.quitChallenge != null) {
      _selectedChallenge = currentOnboarding!.quitChallenge;
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
        ? "reduzir" 
        : "parar de fumar";

    return OnboardingContainer(
      title: "O que torna difícil $goalText para você?",
      subtitle: "Identificar seu principal desafio nos ajuda a fornecer melhor suporte",
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Entender o que torna o cigarro difícil de largar é o primeiro passo para superar esse obstáculo.',
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
            label: 'Estresse e ansiedade',
            description: 'Fumo para lidar com situações estressantes e ansiedade',
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
            label: 'Força do hábito',
            description: 'Fumar já faz parte da minha rotina diária',
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
            label: 'Influência social',
            description: 'Pessoas ao meu redor fumam ou me incentivam a fumar',
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
            label: 'Dependência física',
            description: 'Sinto sintomas físicos quando fico sem fumar',
            child: _selectedChallenge == QuitChallenge.addiction ? _buildChallengeIcon(Icons.medication) : null,
          ),
          
          const SizedBox(height: 24),
          
          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Suas respostas nos ajudam a personalizar dicas e estratégias mais eficazes para seu caso específico.',
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
          
          provider.updateOnboarding(updated).then((_) {
            provider.nextStep();
          });
        } else {
          // Mostrar mensagem de erro se nenhum desafio for selecionado
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, selecione um desafio'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      canProceed: _selectedChallenge != null,
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