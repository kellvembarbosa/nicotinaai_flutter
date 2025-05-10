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
      // Usando o tipo list é mais seguro para garantir que o conteúdo seja scrollável
      contentType: OnboardingContentType.list,
      content: Column(
        // Centralizando o conteúdo para melhor visualização em telas pequenas
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              localizations.helpPersonalizeStrategy,
              style: GoogleFonts.poppins(
                fontSize: 13, // Reduzido para 13
                color: Colors.grey[700],
                height: 1.2, // Linha mais compacta
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 10), // Reduzido para 10
          
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
          
          const SizedBox(height: 10), // Reduzido para 10
          
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
          
          const SizedBox(height: 10), // Reduzido para 10
          
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
                      const SizedBox(width: 8), // Reduzido para 8
                      _buildProductIcon(Icons.air),
                    ],
                  ) 
                : null,
          ),
          
          const SizedBox(height: 12), // Reduzido para 12
          
          // Texto informativo - reduzido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8), // Reduzido para 8
            child: Text(
              localizations.productTypeHelp,
              style: GoogleFonts.poppins(
                fontSize: 11, // Reduzido para 11
                color: Colors.grey[600],
                height: 1.1, // Linha super compacta
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Espaço adicional no final para evitar sobreposição com os botões
          const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(8), // Reduzido para 8
      decoration: BoxDecoration(
        color: const Color(0xFF2962FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6), // Reduzido para 6
      ),
      child: Icon(
        icon,
        color: const Color(0xFF2962FF),
        size: 20, // Reduzido para 20
      ),
    );
  }
}