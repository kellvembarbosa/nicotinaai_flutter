import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/number_selector.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';

class CigarettesPerDayScreen extends StatefulWidget {
  const CigarettesPerDayScreen({Key? key}) : super(key: key);

  @override
  State<CigarettesPerDayScreen> createState() => _CigarettesPerDayScreenState();
}

class _CigarettesPerDayScreenState extends State<CigarettesPerDayScreen> {
  int _cigarettesCount = 10;
  ConsumptionLevel? _selectedLevel;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final currentOnboarding = provider.state.onboarding;
    
    if (currentOnboarding != null) {
      _cigarettesCount = currentOnboarding.cigarettesPerDayCount ?? 10;
      _selectedLevel = currentOnboarding.cigarettesPerDay;
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
      title: "Quantos cigarros você fuma por dia?",
      subtitle: "Isso nos ajuda a entender seu nível de consumo",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Selector numérico
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Número exato: ',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              NumberSelector(
                value: _cigarettesCount,
                min: 1,
                max: 100,
                onChanged: (value) {
                  setState(() {
                    _cigarettesCount = value;
                    // Atualizar o nível de consumo com base no número
                    _updateConsumptionLevel(value);
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Ou selecione seu nível de consumo:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Opções de níveis de consumo
          OptionCard(
            selected: _selectedLevel == ConsumptionLevel.low,
            onPress: () {
              setState(() {
                _selectedLevel = ConsumptionLevel.low;
                _cigarettesCount = 5; // Valor médio para consumo baixo
              });
            },
            label: 'Baixo',
            description: 'Até 5 cigarros por dia',
          ),
          
          const SizedBox(height: 12),
          
          OptionCard(
            selected: _selectedLevel == ConsumptionLevel.moderate,
            onPress: () {
              setState(() {
                _selectedLevel = ConsumptionLevel.moderate;
                _cigarettesCount = 10; // Valor médio para consumo moderado
              });
            },
            label: 'Moderado',
            description: '6 a 15 cigarros por dia',
          ),
          
          const SizedBox(height: 12),
          
          OptionCard(
            selected: _selectedLevel == ConsumptionLevel.high,
            onPress: () {
              setState(() {
                _selectedLevel = ConsumptionLevel.high;
                _cigarettesCount = 20; // Valor médio para consumo alto
              });
            },
            label: 'Alto',
            description: '16 a 25 cigarros por dia',
          ),
          
          const SizedBox(height: 12),
          
          OptionCard(
            selected: _selectedLevel == ConsumptionLevel.veryHigh,
            onPress: () {
              setState(() {
                _selectedLevel = ConsumptionLevel.veryHigh;
                _cigarettesCount = 30; // Valor médio para consumo muito alto
              });
            },
            label: 'Muito Alto',
            description: 'Mais de 25 cigarros por dia',
          ),
        ],
      ),
      onNext: () {
        if (_selectedLevel != null) {
          // Atualizar o modelo antes de avançar
          final updated = currentOnboarding.copyWith(
            cigarettesPerDay: _selectedLevel,
            cigarettesPerDayCount: _cigarettesCount,
          );
          
          provider.updateOnboarding(updated).then((_) {
            provider.nextStep();
          });
        } else {
          // Mostrar uma mensagem ou feedback visual caso o usuário não tenha selecionado
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, selecione seu nível de consumo'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      canProceed: _selectedLevel != null,
    );
  }
  
  void _updateConsumptionLevel(int count) {
    if (count <= 5) {
      _selectedLevel = ConsumptionLevel.low;
    } else if (count <= 15) {
      _selectedLevel = ConsumptionLevel.moderate;
    } else if (count <= 25) {
      _selectedLevel = ConsumptionLevel.high;
    } else {
      _selectedLevel = ConsumptionLevel.veryHigh;
    }
  }
}