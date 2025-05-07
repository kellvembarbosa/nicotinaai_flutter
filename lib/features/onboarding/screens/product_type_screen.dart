import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/option_card.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
    
    if (currentOnboarding == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return OnboardingContainer(
      title: localizations.productTypeQuestion,
      subtitle: localizations.selectApplicable,
      contentType: OnboardingContentType.regular,
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              localizations.helpPersonalizeStrategy,
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
            label: localizations.cigaretteOnly,
            description: localizations.traditionalCigarettes,
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
            label: localizations.vapeOnly,
            description: localizations.electronicDevices,
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
            label: localizations.both,
            description: localizations.useBoth,
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
              localizations.productTypeHelp,
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
            SnackBar(
              content: Text(localizations.pleaseSelectProductType),
              duration: const Duration(seconds: 2),
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