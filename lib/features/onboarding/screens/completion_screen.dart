import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

class CompletionScreen extends StatelessWidget {
  const CompletionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    return OnboardingContainer(
      title: "Tudo pronto!",
      subtitle: "Sua jornada personalizada começa agora",
      showBackButton: false,
      nextButtonText: "Iniciar Minha Jornada",
      content: Column(
        children: [
          const SizedBox(height: 24),
          
          // Imagem de sucesso
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.green,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Texto explicativo
          Text(
            "Parabéns pelo primeiro passo!",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Criamos um plano personalizado com base em suas respostas. Sua jornada para uma vida sem fumo começa agora!",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Lista de benefícios
          _buildBenefitItem(
            context,
            "Monitoramento personalizado",
            "Acompanhe seu progresso com base nos seus hábitos"
          ),
          
          _buildBenefitItem(
            context,
            "Conquistas importantes",
            "Celebre cada marco na sua jornada"
          ),
          
          _buildBenefitItem(
            context,
            "Suporte quando precisar",
            "Dicas e estratégias para os momentos difíceis"
          ),
          
          // Ajustar para deixar espaço para o botão no bottom
          const SizedBox(height: 40),
        ],
      ),
      onNext: () async {
        // Completar onboarding e redirecionar para a tela principal
        await provider.completeOnboarding();
        
        // Verifica se o widget ainda está montado
        if (context.mounted) {
          // Usar GoRouter para navegar
          context.go(AppRoutes.main.path);
        }
      },
    );
  }
  
  Widget _buildBenefitItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1), // Verde para sucessos
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: Color(0xFF4CAF50), // Verde para sucessos
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}