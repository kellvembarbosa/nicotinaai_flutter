import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final localizations = AppLocalizations.of(context);

    return OnboardingContainer(
      title: localizations.welcomeToNicotinaAI,
      subtitle: localizations.personalAssistant,
      showBackButton: false,
      nextButtonText: localizations.start,
      content: Column(
        children: [
          const SizedBox(height: 24),
          
          // Imagem ilustrativa
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF2962FF).withOpacity(0.1), // Azul primário com opacidade
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Image(
                image: AssetImage('assets/images/smoke-one.png'),
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Texto explicativo
          Text(
            localizations.breatheFreedom,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2962FF), // Azul primário
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            localizations.personalizeExperience,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Ajustar para deixar espaço para o botão no bottom
          const SizedBox(height: 40),
        ],
      ),
      onNext: () {
        // Avançar para a próxima tela
        provider.nextStep();
      },
    );
  }
}