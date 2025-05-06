import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/multi_select_option_card.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({Key? key}) : super(key: key);

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final List<String> _selectedLocations = [];
  
  @override
  void initState() {
    super.initState();
    
    // Carregar dados salvos se disponíveis
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final onboarding = provider.state.onboarding;
    
    if (onboarding != null && onboarding.additionalData.containsKey('smoking_locations')) {
      final savedLocations = onboarding.additionalData['smoking_locations'] as List<dynamic>;
      _selectedLocations.addAll(savedLocations.cast<String>());
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
      title: "Onde você geralmente fuma?",
      subtitle: "Selecione os lugares onde você mais costuma fumar",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Instruções
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Conhecer seus locais habituais nos ajuda a identificar padrões e criar estratégias específicas.',
              style: context.textTheme.bodyMedium!.copyWith(
                color: context.subtitleColor,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Opções de locais
          _buildLocationOption(
            'casa',
            'Em casa', 
            'Varanda, sala, escritório',
            Icons.home_outlined,
          ),
          
          const SizedBox(height: 12),
          
          _buildLocationOption(
            'trabalho',
            'No trabalho/escola', 
            'Durante intervalos ou pausas',
            Icons.work_outline,
          ),
          
          const SizedBox(height: 12),
          
          _buildLocationOption(
            'carro',
            'No carro/transporte', 
            'Durante deslocamentos',
            Icons.directions_car_outlined,
          ),
          
          const SizedBox(height: 12),
          
          _buildLocationOption(
            'social',
            'Em eventos sociais', 
            'Bares, festas, restaurantes',
            Icons.people_outline,
          ),
          
          const SizedBox(height: 12),
          
          _buildLocationOption(
            'exterior',
            'Ao ar livre', 
            'Parques, calçadas, áreas externas',
            Icons.nature_people_outlined,
          ),
          
          const SizedBox(height: 12),
          
          _buildLocationOption(
            'outros',
            'Outros lugares', 
            'Quando estou ansioso, independente do local',
            Icons.more_horiz,
          ),
          
          const SizedBox(height: 24),
          
          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Identificar os locais mais comuns ajuda a evitar gatilhos e criar estratégias para mudança de hábito.',
              style: context.textTheme.bodySmall!.copyWith(
                color: context.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      canProceed: _selectedLocations.isNotEmpty,
      onNext: () {
        // Salvar dados e avançar
        final updatedData = Map<String, dynamic>.from(onboarding.additionalData);
        updatedData['smoking_locations'] = _selectedLocations;
        
        provider.updateOnboarding(
          onboarding.copyWith(additionalData: updatedData),
        ).then((_) {
          provider.nextStep();
        });
      },
    );
  }
  
  Widget _buildLocationOption(String id, String label, String description, IconData icon) {
    return MultiSelectOptionCard(
      selected: _selectedLocations.contains(id),
      onPress: () {
        setState(() {
          if (_selectedLocations.contains(id)) {
            _selectedLocations.remove(id);
          } else {
            _selectedLocations.add(id);
          }
        });
      },
      label: label,
      description: description,
      child: _selectedLocations.contains(id) ? _buildLocationIcon(icon) : null,
    );
  }
  
  Widget _buildLocationIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: context.primaryColor,
        size: 24,
      ),
    );
  }
}