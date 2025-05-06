import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/multi_select_option_card.dart';

class PersonalizeScreen extends StatefulWidget {
  const PersonalizeScreen({Key? key}) : super(key: key);

  @override
  State<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  final List<String> _selectedTimes = [];
  
  @override
  void initState() {
    super.initState();
    
    // Carregar dados salvos se disponíveis
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final onboarding = provider.state.onboarding;
    
    if (onboarding != null && onboarding.additionalData.containsKey('smoking_times')) {
      final savedTimes = onboarding.additionalData['smoking_times'] as List<dynamic>;
      _selectedTimes.addAll(savedTimes.cast<String>());
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
      title: "Quando você costuma fumar mais?",
      subtitle: "Selecione o momento em que você sente mais vontade de fumar",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Opções de momento de fumar
          _buildOptionCard(
            "Depois das refeições", 
            "after_meals",
          ),
          
          const SizedBox(height: 12),
          
          _buildOptionCard(
            "Durante pausas no trabalho", 
            "work_breaks",
          ),
          
          const SizedBox(height: 12),
          
          _buildOptionCard(
            "Em eventos sociais", 
            "social_events",
          ),
          
          const SizedBox(height: 12),
          
          _buildOptionCard(
            "Quando estou estressado", 
            "stress",
          ),
          
          const SizedBox(height: 12),
          
          _buildOptionCard(
            "Quando bebo café ou álcool", 
            "drinking",
          ),
          
          const SizedBox(height: 12),
          
          _buildOptionCard(
            "Quando estou entediado", 
            "boredom",
          ),
          
          const SizedBox(height: 40),
        ],
      ),
      disableNextButton: _selectedTimes.isEmpty,
      onNext: () {
        // Salvar dados e avançar
        final updatedData = Map<String, dynamic>.from(onboarding.additionalData);
        updatedData['smoking_times'] = _selectedTimes;
        
        provider.updateOnboarding(
          onboarding.copyWith(additionalData: updatedData),
        ).then((_) {
          provider.nextStep();
        });
      },
    );
  }
  
  Widget _buildOptionCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: MultiSelectOptionCard(
        selected: _selectedTimes.contains(value),
        onPress: () {
          setState(() {
            if (_selectedTimes.contains(value)) {
              _selectedTimes.remove(value);
            } else {
              _selectedTimes.add(value);
            }
          });
        },
        label: label,
      ),
    );
  }
}