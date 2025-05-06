import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/multi_select_option_card.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // Lista de opções de ajuda disponíveis
  final List<String> _availableHelp = [
    'dicas_diarias',
    'lembretes',
    'monitoramento',
    'comunidade',
    'substitutos',
    'economia',
  ];
  
  // Lista de opções selecionadas
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
    
    if (currentOnboarding == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return OnboardingContainer(
      title: "Como podemos ajudar você?",
      subtitle: "Selecione todas as opções que te interessam",
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Oferecemos diferentes recursos para apoiar sua jornada. Selecione todos que acredita que podem ajudar.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Opções de recursos de ajuda
          MultiSelectOptionCard(
            selected: _selectedHelp.contains('dicas_diarias'),
            onPress: () {
              setState(() {
                _toggleOption('dicas_diarias');
              });
            },
            label: 'Dicas diárias',
            description: 'Receba conselhos práticos todos os dias para apoiar sua jornada',
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
            label: 'Lembretes personalizados',
            description: 'Notificações para te manter motivado e no caminho certo',
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
            label: 'Monitoramento de progresso',
            description: 'Acompanhe visualmente sua evolução ao longo do tempo',
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
            label: 'Comunidade de apoio',
            description: 'Conecte-se com outras pessoas em jornada semelhante',
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
            label: 'Alternativas ao cigarro',
            description: 'Sugestões de atividades e produtos para substituir o hábito',
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
            label: 'Calculadora de economia',
            description: 'Veja quanto dinheiro você está economizando ao reduzir ou parar',
            child: _selectedHelp.contains('economia') 
                ? _buildHelpIcon(Icons.savings) 
                : null,
          ),
          
          const SizedBox(height: 24),
          
          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Você pode modificar estas preferências a qualquer momento nas configurações do app.',
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
      canProceed: true, // Pode prosseguir mesmo sem selecionar (não é obrigatório)
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