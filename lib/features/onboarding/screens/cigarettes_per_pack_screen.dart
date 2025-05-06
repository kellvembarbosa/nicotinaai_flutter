import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/number_selector.dart';

class CigarettesPerPackScreen extends StatefulWidget {
  const CigarettesPerPackScreen({Key? key}) : super(key: key);

  @override
  State<CigarettesPerPackScreen> createState() => _CigarettesPerPackScreenState();
}

class _CigarettesPerPackScreenState extends State<CigarettesPerPackScreen> {
  int _cigarettesPerPack = 20;
  bool _useCustomCount = false;
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final currentOnboarding = provider.state.onboarding;
    
    if (currentOnboarding?.cigarettesPerPack != null) {
      _cigarettesPerPack = currentOnboarding!.cigarettesPerPack!;
      _useCustomCount = _cigarettesPerPack != 10 && _cigarettesPerPack != 20;
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
      title: "Quantos cigarros vêm em um maço?",
      subtitle: "Selecione a quantidade padrão para seus maços de cigarros",
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Maços de cigarros geralmente vêm com 10 ou 20 unidades. Selecione a quantidade que corresponde aos maços que você compra.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Opções padrão
          OptionCard(
            selected: _cigarettesPerPack == 10 && !_useCustomCount,
            onPress: () {
              setState(() {
                _cigarettesPerPack = 10;
                _useCustomCount = false;
              });
            },
            label: '10 cigarros',
            description: 'Maço pequeno/compacto',
          ),
          
          const SizedBox(height: 12),
          
          OptionCard(
            selected: _cigarettesPerPack == 20 && !_useCustomCount,
            onPress: () {
              setState(() {
                _cigarettesPerPack = 20;
                _useCustomCount = false;
              });
            },
            label: '20 cigarros',
            description: 'Maço padrão/tradicional',
          ),
          
          const SizedBox(height: 12),
          
          // Opção personalizada
          OptionCard(
            selected: _useCustomCount,
            onPress: () {
              setState(() {
                _useCustomCount = true;
              });
            },
            label: 'Outra quantidade',
            description: 'Selecione um valor personalizado',
            child: _useCustomCount ? Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Quantidade: ',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    NumberSelector(
                      value: _cigarettesPerPack,
                      min: 1,
                      max: 50,
                      onChanged: (value) {
                        setState(() {
                          _cigarettesPerPack = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ) : null,
          ),
          
          const SizedBox(height: 24),
          
          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Essa informação nos ajuda a calcular com precisão seu consumo e os benefícios de reduzir ou parar de fumar.',
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
        final updated = currentOnboarding.copyWith(
          cigarettesPerPack: _cigarettesPerPack,
        );
        
        provider.updateOnboarding(updated).then((_) {
          provider.nextStep();
        });
      },
      canProceed: true, // Sempre pode avançar pois há valores padrão selecionados
    );
  }
}