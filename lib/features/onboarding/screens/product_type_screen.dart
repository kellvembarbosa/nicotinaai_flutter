import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';

class ProductTypeScreen extends StatefulWidget {
  const ProductTypeScreen({Key? key}) : super(key: key);

  @override
  State<ProductTypeScreen> createState() => _ProductTypeScreenState();
}

class _ProductTypeScreenState extends State<ProductTypeScreen> {
  ProductType? _selectedProductType;
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final currentOnboarding = provider.state.onboarding;
    
    if (currentOnboarding?.productType != null) {
      _selectedProductType = currentOnboarding!.productType;
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
      title: "Que tipo de produto você consome?",
      subtitle: "Selecione o que se aplica a você",
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Isso nos ajuda a personalizar as estratégias e recomendações para o seu caso específico.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Opções de tipos de produto
          OptionCard(
            selected: _selectedProductType == ProductType.cigaretteOnly,
            onPress: () {
              setState(() {
                _selectedProductType = ProductType.cigaretteOnly;
              });
            },
            label: 'Apenas cigarros tradicionais',
            description: 'Cigarros de tabaco convencionais',
            child: _selectedProductType == ProductType.cigaretteOnly 
                ? _buildProductIcon(Icons.smoking_rooms) 
                : null,
          ),
          
          const SizedBox(height: 16),
          
          OptionCard(
            selected: _selectedProductType == ProductType.vapeOnly,
            onPress: () {
              setState(() {
                _selectedProductType = ProductType.vapeOnly;
              });
            },
            label: 'Apenas vape/cigarro eletrônico',
            description: 'Dispositivos eletrônicos para vaporização',
            child: _selectedProductType == ProductType.vapeOnly 
                ? _buildProductIcon(Icons.air) 
                : null,
          ),
          
          const SizedBox(height: 16),
          
          OptionCard(
            selected: _selectedProductType == ProductType.both,
            onPress: () {
              setState(() {
                _selectedProductType = ProductType.both;
              });
            },
            label: 'Ambos',
            description: 'Uso tanto cigarros tradicionais quanto eletrônicos',
            child: _selectedProductType == ProductType.both 
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProductIcon(Icons.smoking_rooms),
                      const SizedBox(width: 16),
                      _buildProductIcon(Icons.air),
                    ],
                  ) 
                : null,
          ),
          
          const SizedBox(height: 24),
          
          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Diferentes produtos contêm diferentes quantidades de nicotina e podem exigir estratégias distintas para redução ou abandono.',
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
        if (_selectedProductType != null) {
          final updated = currentOnboarding.copyWith(
            productType: _selectedProductType,
          );
          
          provider.updateOnboarding(updated).then((_) {
            provider.nextStep();
          });
        } else {
          // Mostrar mensagem de erro se nenhum tipo de produto for selecionado
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, selecione um tipo de produto'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      canProceed: _selectedProductType != null,
    );
  }
  
  Widget _buildProductIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2962FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: const Color(0xFF2962FF),
        size: 24,
      ),
    );
  }
}