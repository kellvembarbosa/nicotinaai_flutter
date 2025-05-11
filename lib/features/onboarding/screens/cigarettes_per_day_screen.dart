import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_state.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/number_selector.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

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
    final bloc = context.read<OnboardingBloc>();
    final currentOnboarding = bloc.state.onboarding;
    
    if (currentOnboarding != null) {
      _cigarettesCount = currentOnboarding.cigarettesPerDayCount ?? 10;
      _selectedLevel = currentOnboarding.cigarettesPerDay;
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

        return OnboardingContainer(
          title: localizations.cigarettesPerDayQuestion,
          subtitle: localizations.cigarettesPerDaySubtitle,
          contentType: OnboardingContentType.scrollable,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Selector numérico
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localizations.exactNumber,
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
                localizations.selectConsumptionLevel,
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
                label: localizations.low,
                description: localizations.upTo5,
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
                label: localizations.moderate,
                description: localizations.sixTo15,
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
                label: localizations.high,
                description: localizations.sixteenTo25,
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
                label: localizations.veryHigh,
                description: localizations.moreThan25,
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
              
              // Enviar evento de atualização do onboarding
              context.read<OnboardingBloc>().add(UpdateOnboarding(updated));
              
              // Avançar para o próximo passo
              context.read<OnboardingBloc>().add(NextOnboardingStep());
            } else {
              // Mostrar uma mensagem ou feedback visual caso o usuário não tenha selecionado
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.selectConsumptionLevelError),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          canProceed: _selectedLevel != null,
        );
      },
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