import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/multi_select_option_card.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // List of available help options
  final List<String> _availableHelp = [
    'dicas_diarias',
    'lembretes',
    'monitoramento',
    'comunidade',
    'substitutos',
    'economia',
  ];
  
  // List of selected options
  List<String> _selectedHelp = [];
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final currentOnboarding = provider.state.onboarding;
    
    if (currentOnboarding != null && currentOnboarding.helpPreferences.isNotEmpty) {
      _selectedHelp = List.from(currentOnboarding.helpPreferences);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final currentOnboarding = provider.state.onboarding;
    // Adding localization
    final localizations = AppLocalizations.of(context);
    
    if (currentOnboarding == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return OnboardingContainer(
      title: localizations.helpScreenTitle,
      subtitle: localizations.selectAllInterests,
      contentType: OnboardingContentType.scrollable,
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              localizations.helpScreenExplanation,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Help resource options
          MultiSelectOptionCard(
            selected: _selectedHelp.contains('dicas_diarias'),
            onPress: () {
              setState(() {
                _toggleOption('dicas_diarias');
              });
            },
            label: localizations.dailyTips,
            description: localizations.dailyTipsDescription,
            child: _selectedHelp.contains('dicas_diarias') 
                ? _buildHelpIcon(Icons.tips_and_updates) 
                : null,
          ),
          
          const SizedBox(height: 12),
          
          MultiSelectOptionCard(
            selected: _selectedHelp.contains('lembretes'),
            onPress: () {
              setState(() {
                _toggleOption('lembretes');
              });
            },
            label: localizations.customReminders,
            description: localizations.customRemindersDescription,
            child: _selectedHelp.contains('lembretes') 
                ? _buildHelpIcon(Icons.notifications_active) 
                : null,
          ),
          
          const SizedBox(height: 12),
          
          MultiSelectOptionCard(
            selected: _selectedHelp.contains('monitoramento'),
            onPress: () {
              setState(() {
                _toggleOption('monitoramento');
              });
            },
            label: localizations.progressMonitoring,
            description: localizations.progressMonitoringDescription,
            child: _selectedHelp.contains('monitoramento') 
                ? _buildHelpIcon(Icons.insert_chart) 
                : null,
          ),
          
          const SizedBox(height: 12),
          
          MultiSelectOptionCard(
            selected: _selectedHelp.contains('comunidade'),
            onPress: () {
              setState(() {
                _toggleOption('comunidade');
              });
            },
            label: localizations.supportCommunity,
            description: localizations.supportCommunityDescription,
            child: _selectedHelp.contains('comunidade') 
                ? _buildHelpIcon(Icons.people) 
                : null,
          ),
          
          const SizedBox(height: 12),
          
          MultiSelectOptionCard(
            selected: _selectedHelp.contains('substitutos'),
            onPress: () {
              setState(() {
                _toggleOption('substitutos');
              });
            },
            label: localizations.cigaretteAlternatives,
            description: localizations.cigaretteAlternativesDescription,
            child: _selectedHelp.contains('substitutos') 
                ? _buildHelpIcon(Icons.swap_horiz) 
                : null,
          ),
          
          const SizedBox(height: 12),
          
          MultiSelectOptionCard(
            selected: _selectedHelp.contains('economia'),
            onPress: () {
              setState(() {
                _toggleOption('economia');
              });
            },
            label: localizations.savingsCalculator,
            description: localizations.savingsCalculatorDescription,
            child: _selectedHelp.contains('economia') 
                ? _buildHelpIcon(Icons.savings) 
                : null,
          ),
          
          const SizedBox(height: 24),
          
          // Informational text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              localizations.modifyPreferencesAnytime,
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
          helpPreferences: _selectedHelp,
        );
        
        provider.updateOnboarding(updated).then((_) {
          provider.nextStep();
        });
      },
      canProceed: true, // Can proceed even without selecting (not mandatory)
    );
  }
  
  void _toggleOption(String option) {
    if (_selectedHelp.contains(option)) {
      _selectedHelp.remove(option);
    } else {
      _selectedHelp.add(option);
    }
  }
  
  Widget _buildHelpIcon(IconData icon) {
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