import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    return OnboardingContainer(
      title: "Bem-vindo ao NicotinaAI",
      subtitle: "Seu assistente pessoal para parar de fumar",
      showBackButton: false,
      nextButtonText: "Começar",
      content: Column(
        children: [
          const SizedBox(height: 24),
          
          // Imagem ilustrativa
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.health_and_safety_outlined,
                size: 100,
                color: Colors.deepPurple,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Texto explicativo
          Text(
            "RESPIRE LIBERDADE. SUA NOVA VIDA COMEÇA AGORA.",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            "Vamos personalizar sua experiência para ajudá-lo a alcançar seus objetivos de parar de fumar. Responda algumas perguntas para começarmos.",
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