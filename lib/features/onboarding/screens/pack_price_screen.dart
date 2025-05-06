import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';

class PackPriceScreen extends StatefulWidget {
  const PackPriceScreen({Key? key}) : super(key: key);

  @override
  State<PackPriceScreen> createState() => _PackPriceScreenState();
}

class _PackPriceScreenState extends State<PackPriceScreen> {
  late TextEditingController _priceController;
  bool _isValid = false;
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final currentOnboarding = provider.state.onboarding;
    
    // Inicializa o controller com o valor já salvo se existir
    // Converte centavos para reais (ex: 1200 centavos = R$ 12,00)
    final savedPrice = currentOnboarding?.packPrice;
    final initialPrice = savedPrice != null ? (savedPrice / 100).toStringAsFixed(2) : '';
    
    _priceController = TextEditingController(text: initialPrice);
    _validateInput(initialPrice);
  }
  
  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    // Verifica se o input é um número válido maior que zero
    if (value.isEmpty) {
      setState(() => _isValid = false);
      return;
    }
    
    try {
      final price = double.parse(value.replaceAll(',', '.'));
      setState(() => _isValid = price > 0);
    } catch (_) {
      setState(() => _isValid = false);
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
      title: "Quanto custa um maço de cigarros?",
      subtitle: "Isso nos ajuda a calcular sua economia financeira",
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Informe o valor médio que você paga por um maço de cigarros.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Input de valor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isValid ? const Color(0xFF2962FF) : Colors.grey[300]!,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              onChanged: _validateInput,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0,00',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                prefixText: 'R\$ ',
                prefixStyle: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  // Permitir apenas um ponto decimal ou uma vírgula
                  if (newValue.text.isEmpty) return newValue;
                  
                  String text = newValue.text;
                  // Substitui vírgula por ponto
                  if (text.contains(',')) {
                    text = text.replaceAll('.', '');
                    if (text.indexOf(',') != text.lastIndexOf(',')) {
                      text = text.substring(0, text.lastIndexOf(',')) + 
                            text.substring(text.lastIndexOf(',') + 1);
                    }
                    text = text.replaceFirst(',', '.');
                  } else if (text.split('.').length > 2) {
                    text = text.substring(0, text.lastIndexOf('.')) + 
                          text.substring(text.lastIndexOf('.') + 1);
                  }
                  
                  // Limita a 2 casas decimais
                  final parts = text.split('.');
                  if (parts.length > 1 && parts[1].length > 2) {
                    text = '${parts[0]}.${parts[1].substring(0, 2)}';
                  }
                  
                  return TextEditingValue(
                    text: text,
                    selection: TextSelection.collapsed(offset: text.length),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Essas informações nos ajudam a mostrar quanto você economizará ao reduzir ou parar de fumar.',
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
        if (_isValid) {
          // Converte o valor para centavos para armazenar no modelo
          final priceText = _priceController.text.replaceAll(',', '.');
          final priceInCents = (double.parse(priceText) * 100).round();
          
          final updated = currentOnboarding.copyWith(
            packPrice: priceInCents,
          );
          
          provider.updateOnboarding(updated).then((_) {
            provider.nextStep();
          });
        }
      },
      canProceed: _isValid,
    );
  }
}