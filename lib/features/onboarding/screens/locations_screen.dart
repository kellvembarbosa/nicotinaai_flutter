import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/multi_select_option_card.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

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
    // Load saved data if available
    final state = context.read<OnboardingBloc>().state;
    final currentOnboarding = state.onboarding;
    
    if (currentOnboarding != null && 
        currentOnboarding.additionalData.containsKey('smoke_locations')) {
      final locations = currentOnboarding.additionalData['smoke_locations'];
      if (locations is List) {
        _selectedLocations.addAll(List<String>.from(locations));
      }
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
          title: localizations.locationsQuestion,
          subtitle: localizations.selectCommonPlaces,
          contentType: OnboardingContentType.scrollable,
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  localizations.locationsExplanation,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Location options
              MultiSelectOptionCard(
                selected: _selectedLocations.contains('home'),
                onPress: () {
                  setState(() {
                    _toggleLocation('home');
                  });
                },
                label: localizations.atHome,
                description: localizations.atHomeDescription,
                child: Icon(Icons.home, color: context.primaryColor),
              ),
              
              const SizedBox(height: 12),
              
              MultiSelectOptionCard(
                selected: _selectedLocations.contains('work'),
                onPress: () {
                  setState(() {
                    _toggleLocation('work');
                  });
                },
                label: localizations.atWork,
                description: localizations.atWorkDescription,
                child: Icon(Icons.work, color: context.primaryColor),
              ),
              
              const SizedBox(height: 12),
              
              MultiSelectOptionCard(
                selected: _selectedLocations.contains('car'),
                onPress: () {
                  setState(() {
                    _toggleLocation('car');
                  });
                },
                label: localizations.inCar,
                description: localizations.inCarDescription,
                child: Icon(Icons.directions_car, color: context.primaryColor),
              ),
              
              const SizedBox(height: 12),
              
              MultiSelectOptionCard(
                selected: _selectedLocations.contains('social'),
                onPress: () {
                  setState(() {
                    _toggleLocation('social');
                  });
                },
                label: localizations.socialGatherings,
                description: localizations.socialGatheringsDescription,
                child: Icon(Icons.people, color: context.primaryColor),
              ),
              
              const SizedBox(height: 12),
              
              MultiSelectOptionCard(
                selected: _selectedLocations.contains('nightlife'),
                onPress: () {
                  setState(() {
                    _toggleLocation('nightlife');
                  });
                },
                label: localizations.nightlife,
                description: localizations.nightlifeDescription,
                child: Icon(Icons.nightlife, color: context.primaryColor),
              ),
              
              const SizedBox(height: 12),
              
              MultiSelectOptionCard(
                selected: _selectedLocations.contains('stress'),
                onPress: () {
                  setState(() {
                    _toggleLocation('stress');
                  });
                },
                label: localizations.whenStressed,
                description: localizations.whenStressedDescription,
                child: Icon(Icons.psychology, color: context.primaryColor),
              ),
              
              const SizedBox(height: 24),
              
              // Informational text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  localizations.locationsHelp,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.subtitleColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          onNext: () {
            // Update the model with selected locations
            final updatedData = Map<String, dynamic>.from(currentOnboarding.additionalData);
            updatedData['smoke_locations'] = _selectedLocations;
            
            final updated = currentOnboarding.copyWith(
              additionalData: updatedData,
            );
            
            // Usando o BLoC para atualizar o onboarding e avançar para o próximo passo
            context.read<OnboardingBloc>().add(UpdateOnboarding(updated));
            context.read<OnboardingBloc>().add(NextOnboardingStep());
          },
          canProceed: true, // Can proceed even without selecting (not mandatory)
        );
      },
    );
  }
  
  void _toggleLocation(String location) {
    if (_selectedLocations.contains(location)) {
      _selectedLocations.remove(location);
    } else {
      _selectedLocations.add(location);
    }
  }
}