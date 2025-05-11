import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_state.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/multi_select_option_card.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

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
    
    // Load saved data if available
    final bloc = context.read<OnboardingBloc>();
    final onboarding = bloc.state.onboarding;
    
    if (onboarding != null && onboarding.additionalData.containsKey('smoking_times')) {
      final savedTimes = onboarding.additionalData['smoking_times'] as List<dynamic>;
      _selectedTimes.addAll(savedTimes.cast<String>());
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final onboarding = state.onboarding;
        
        if (onboarding == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return OnboardingContainer(
          title: localizations.personalizeScreenTitle,
          subtitle: localizations.personalizeScreenSubtitle,
          contentType: OnboardingContentType.scrollable,
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
              
              // Smoking time options
              _buildOptionCard(
                localizations.afterMeals, 
                "after_meals",
              ),
              
              const SizedBox(height: 12),
              
              _buildOptionCard(
                localizations.duringWorkBreaks, 
                "work_breaks",
              ),
              
              const SizedBox(height: 12),
              
              _buildOptionCard(
                localizations.inSocialEvents, 
                "social_events",
              ),
              
              const SizedBox(height: 12),
              
              _buildOptionCard(
                localizations.whenStressed, 
                "stress",
              ),
              
              const SizedBox(height: 12),
              
              _buildOptionCard(
                localizations.withCoffeeOrAlcohol, 
                "drinking",
              ),
              
              const SizedBox(height: 12),
              
              _buildOptionCard(
                localizations.whenBored, 
                "boredom",
              ),
              
              // Espaço extra para evitar que o conteúdo fique atrás dos botões
              const SizedBox(height: 20),
            ],
          ),
          ),
          canProceed: _selectedTimes.isNotEmpty,
          onNext: () {
            // Save data and proceed
            final updatedData = Map<String, dynamic>.from(onboarding.additionalData);
            updatedData['smoking_times'] = _selectedTimes;
            
            // Enviar evento de atualização do onboarding
            context.read<OnboardingBloc>().add(UpdateOnboarding(
              onboarding.copyWith(additionalData: updatedData),
            ));
            
            // Avançar para o próximo passo
            context.read<OnboardingBloc>().add(NextOnboardingStep());
          },
        );
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