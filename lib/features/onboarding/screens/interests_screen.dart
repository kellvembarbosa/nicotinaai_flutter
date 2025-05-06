import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';

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
    // Carregar dados salvos se disponíveis
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
    
    if (onboarding == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return OnboardingContainer(
      title: "O que torna difícil parar de fumar para você?",
      subtitle: "Identificar seu principal desafio nos ajuda a fornecer melhor suporte",
      content: Column(
        children: [
          const SizedBox(height: 16),
          
          // Opção: Estresse
          OptionCard(
            selected: _selectedChallenge == 'stress',
            onPress: () {
              setState(() {
                _selectedChallenge = 'stress';
              });
            },
            label: 'Lidar com o estresse',
            description: 'Fumar me ajuda a relaxar quando estou estressado',
          ),
          
          const SizedBox(height: 12),
          
          // Opção: Hábito
          OptionCard(
            selected: _selectedChallenge == 'habit',
            onPress: () {
              setState(() {
                _selectedChallenge = 'habit';
              });
            },
            label: 'Quebrar o hábito',
            description: 'É parte da minha rotina diária',
          ),
          
          const SizedBox(height: 12),
          
          // Opção: Social
          OptionCard(
            selected: _selectedChallenge == 'social',
            onPress: () {
              setState(() {
                _selectedChallenge = 'social';
              });
            },
            label: 'Pressão social',
            description: 'Meus amigos/familiares fumam',
          ),
          
          const SizedBox(height: 12),
          
          // Opção: Dependência
          OptionCard(
            selected: _selectedChallenge == 'addiction',
            onPress: () {
              setState(() {
                _selectedChallenge = 'addiction';
              });
            },
            label: 'Dependência física',
            description: 'Sinto sintomas de abstinência quando não fumo',
          ),
          
          const SizedBox(height: 24),
          
          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Essas informações nos ajudam a personalizar estratégias mais eficazes para seu caso específico.',
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
        // Mapear a seleção para o enum correspondente
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
        
        // Atualizar o modelo
        if (challenge != null) {
          final updated = onboarding.copyWith(
            quitChallenge: challenge,
          );
          
          provider.updateOnboarding(updated).then((_) {
            provider.nextStep();
          });
        }
      },
    );
  }
}