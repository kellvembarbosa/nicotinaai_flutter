import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class CompletionScreen extends StatefulWidget {
  const CompletionScreen({super.key});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final onboarding = provider.state.onboarding;
    
    if (onboarding == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Calcular economia mensal
    final cigarettesPerDay = onboarding.cigarettesPerDayCount ?? 0;
    final packPrice = onboarding.packPrice ?? 0;
    final cigarettesPerPack = onboarding.cigarettesPerPack ?? 20;
    
    // Calcular o gasto diário em centavos
    final dailyCost = cigarettesPerDay * (packPrice / cigarettesPerPack);
    // Calcular o gasto mensal em reais
    final monthlyCost = (dailyCost * 30) / 100;
    
    // Texto para o objetivo
    final goalText = onboarding.goal == GoalType.reduce 
        ? "reduzir o consumo" 
        : "parar de fumar";
    
    // Texto para o prazo
    String timelineText = "ao seu próprio ritmo";
    if (onboarding.goalTimeline == GoalTimeline.sevenDays) {
      timelineText = "nos próximos 7 dias";
    } else if (onboarding.goalTimeline == GoalTimeline.fourteenDays) {
      timelineText = "nas próximas 2 semanas";
    } else if (onboarding.goalTimeline == GoalTimeline.thirtyDays) {
      timelineText = "no próximo mês";
    }

    return OnboardingContainer(
      title: "Tudo pronto!",
      subtitle: "Sua jornada personalizada começa agora",
      showBackButton: false,
      nextButtonText: "Iniciar Minha Jornada",
      content: Column(
        children: [
          const SizedBox(height: 24),
          
          // Imagem de sucesso com glassmorphism
          _buildSuccessIcon(context),
          
          const SizedBox(height: 32),
          
          // Layout switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isGridView = false;
                    });
                  },
                  icon: Icon(
                    Icons.view_list,
                    color: !_isGridView 
                        ? context.primaryColor 
                        : context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  tooltip: "Visualização em lista",
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isGridView = true;
                    });
                  },
                  icon: Icon(
                    Icons.grid_view,
                    color: _isGridView 
                        ? context.primaryColor 
                        : context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  tooltip: "Visualização em grade",
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Texto explicativo
          Text(
            "Parabéns pelo primeiro passo!",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Resumo personalizado
          Text(
            "Criamos um plano personalizado com base em suas respostas para ajudá-lo a $goalText $timelineText.",
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.subtitleColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Painel de resumo
          _buildSummaryPanel(context, cigarettesPerDay, monthlyCost, goalText, onboarding),
          
          const SizedBox(height: 32),
          
          // Lista ou grade de benefícios
          _isGridView
              ? _buildBenefitsGrid(context)
              : _buildBenefitsList(context),
          
          // Ajustar para deixar espaço para o botão no bottom
          const SizedBox(height: 40),
        ],
      ),
      onNext: () async {
        // Mostrar indicador de carregamento
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(
              color: context.primaryColor,
            ),
          ),
        );
        
        try {
          // Completar onboarding e redirecionar para a tela principal
          await provider.completeOnboarding();
          
          // Fechar o diálogo de carregamento
          if (context.mounted) {
            Navigator.of(context).pop();
            
            // Usar GoRouter para navegar
            context.go(AppRoutes.main.path);
          }
        } catch (e) {
          // Fechar o diálogo de carregamento
          if (context.mounted) {
            Navigator.of(context).pop();
            
            // Mostrar erro
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao finalizar: ${e.toString()}'),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }
  
  // Widget para o ícone de sucesso com fundo blur
  Widget _buildSuccessIcon(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: context.isDarkMode 
                ? context.primaryColor.withOpacity(0.15) 
                : context.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.isDarkMode 
                  ? context.primaryColor.withOpacity(0.3)
                  : context.primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.check_circle_outline,
              size: 100,
              color: context.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
  
  // Painel de resumo com suporte a dark mode
  Widget _buildSummaryPanel(BuildContext context, int cigarettesPerDay, double monthlyCost, String goalText, OnboardingModel onboarding) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode 
            ? const Color(0xFF1A1A1A)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.isDarkMode 
              ? const Color(0xFF333333)
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Seu resumo personalizado",
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.contentColor,
            ),
          ),
          const SizedBox(height: 12),
          
          // Consumo
          _buildInfoItem(
            context,
            Icons.smoking_rooms,
            "Consumo diário",
            "$cigarettesPerDay cigarros por dia",
          ),
          
          _buildDivider(context),
          
          // Economia financeira
          _buildInfoItem(
            context,
            Icons.savings,
            "Economia mensal potencial",
            "R\$ ${monthlyCost.toStringAsFixed(2)}",
          ),
          
          _buildDivider(context),
          
          // Objetivo
          _buildInfoItem(
            context,
            onboarding.goal == GoalType.reduce ? Icons.trending_down : Icons.smoke_free,
            "Seu objetivo",
            onboarding.goal == GoalType.reduce ? "Reduzir o consumo" : "Parar de fumar",
          ),
          
          _buildDivider(context),
          
          // Desafio principal
          _buildInfoItem(
            context,
            _getChallengeIcon(onboarding.quitChallenge),
            "Seu desafio principal",
            _getChallengeText(onboarding.quitChallenge),
          ),
        ],
      ),
    );
  }
  
  // Divider adaptado para dark mode
  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: context.isDarkMode ? const Color(0xFF333333) : Colors.grey[200],
      height: 24,
    );
  }
  
  // Lista de benefícios
  Widget _buildBenefitsList(BuildContext context) {
    return Column(
      children: [
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
      ],
    );
  }
  
  // Grid de benefícios
  Widget _buildBenefitsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        _buildBenefitCard(
          context,
          Icons.monitor_heart,
          "Monitoramento personalizado",
          "Acompanhe seu progresso com base nos seus hábitos",
        ),
        _buildBenefitCard(
          context,
          Icons.emoji_events,
          "Conquistas importantes",
          "Celebre cada marco na sua jornada",
        ),
        _buildBenefitCard(
          context,
          Icons.support_agent,
          "Suporte quando precisar",
          "Dicas e estratégias para os momentos difíceis",
        ),
        _buildBenefitCard(
          context,
          Icons.trending_up,
          "Resultado garantido",
          "Com nossa tecnologia baseada em ciência",
        ),
      ],
    );
  }
  
  // Card para o layout de grid
  Widget _buildBenefitCard(BuildContext context, IconData icon, String title, String description) {
    return Card(
      elevation: context.isDarkMode ? 0 : 2,
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.isDarkMode ? const Color(0xFF333333) : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: context.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.contentColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.subtitleColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getChallengeIcon(QuitChallenge? challenge) {
    switch (challenge) {
      case QuitChallenge.stress:
        return Icons.mood_bad;
      case QuitChallenge.habit:
        return Icons.access_time;
      case QuitChallenge.social:
        return Icons.people;
      case QuitChallenge.addiction:
        return Icons.medication;
      default:
        return Icons.help_outline;
    }
  }
  
  String _getChallengeText(QuitChallenge? challenge) {
    switch (challenge) {
      case QuitChallenge.stress:
        return "Estresse e ansiedade";
      case QuitChallenge.habit:
        return "Força do hábito";
      case QuitChallenge.social:
        return "Influência social";
      case QuitChallenge.addiction:
        return "Dependência física";
      default:
        return "Não especificado";
    }
  }
  
  Widget _buildInfoItem(BuildContext context, IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: context.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.subtitleColor,
                  ),
                ),
                Text(
                  value,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.contentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              color: context.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              color: context.primaryColor,
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
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.contentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.subtitleColor,
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