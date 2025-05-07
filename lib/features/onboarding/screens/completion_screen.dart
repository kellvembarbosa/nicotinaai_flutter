import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/supported_currencies.dart';
import 'package:nicotinaai_flutter/utils/currency_utils.dart';
import 'dart:ui';

class CompletionScreen extends StatefulWidget {
  const CompletionScreen({super.key});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  // Removendo opção de alternância, sempre usando grid
  bool _isGridView = true;
  
  // Formata o valor para exibição de acordo com a moeda
  String _formatCurrency(double value, String? currencyCode) {
    // Garantir que sempre temos um valor válido mesmo se for nulo
    if (value.isNaN || value.isInfinite) {
      value = 0;
    }
    
    // Verificar se temos um código de moeda válido
    if (currencyCode == null || currencyCode.isEmpty) {
      // Se não tivermos, use a moeda padrão
      currencyCode = SupportedCurrencies.defaultCurrency.code;
    }
    
    final currency = SupportedCurrencies.getByCurrencyCode(currencyCode);
    if (currency != null) {
      final valueInCents = (value * 100).round();
      try {
        return CurrencyUtils().format(
          valueInCents, 
          user: null, // Não temos acesso ao usuário aqui, então passamos null
          currencySymbol: currency.symbol,
          currencyLocale: currency.locale
        );
      } catch (e) {
        // Em caso de erro, usar formatação de fallback
        return "${currency.symbol} ${value.toStringAsFixed(2)}";
      }
    }
    // Fallback para formatação padrão
    return "${SupportedCurrencies.defaultCurrency.symbol} ${value.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final onboarding = provider.state.onboarding;
    final localizations = AppLocalizations.of(context);
    
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
        ? localizations.reduceConsumption
        : localizations.quitSmoking;
    
    // Texto para o prazo
    String timelineText = localizations.atYourOwnPace;
    if (onboarding.goalTimeline == GoalTimeline.sevenDays) {
      timelineText = localizations.nextSevenDays;
    } else if (onboarding.goalTimeline == GoalTimeline.fourteenDays) {
      timelineText = localizations.nextTwoWeeks;
    } else if (onboarding.goalTimeline == GoalTimeline.thirtyDays) {
      timelineText = localizations.nextMonth;
    }

    return OnboardingContainer(
      title: localizations.allDone,
      subtitle: localizations.personalizedJourney,
      showBackButton: false,
      nextButtonText: localizations.startMyJourney,
      contentType: OnboardingContentType.scrollable,
      content: Column(
        children: [
          const SizedBox(height: 16), // Reduzido para 16
          
          // Imagem de sucesso com glassmorphism
          _buildSuccessIcon(context),
          
          const SizedBox(height: 20), // Reduzido para 20
          
          // Título centralizado sem alternância de layout
          Text(
            localizations.congratulations,
            style: GoogleFonts.poppins(
              fontSize: 17, // Reduzido para 17
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 10), // Reduzido para 10
          
          // Resumo personalizado - mais compacto
          Text(
            onboarding.goal == GoalType.reduce 
                ? localizations.personalizedPlanReduce(timelineText)
                : localizations.personalizedPlanQuit(timelineText),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.subtitleColor,
              height: 1.3, // Reduzido para 1.3
              fontSize: 14, // Tamanho reduzido
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16), // Reduzido para 16
          
          // Painel de resumo
          _buildSummaryPanel(context, cigarettesPerDay, monthlyCost, goalText, onboarding),
          
          const SizedBox(height: 20), // Reduzido para 20
          
          // Sempre mostra benefícios em grid, sem opção de lista
          _buildBenefitsGrid(context),
          
          // Ajustar para deixar espaço para o botão no bottom
          const SizedBox(height: 24), // Reduzido para 24
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
                content: Text(localizations.loadingError(e.toString())),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }
  
  // Widget para o ícone de sucesso com fundo blur - super compacto
  Widget _buildSuccessIcon(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12), // Reduzido para 12
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Reduzido para 8
        child: Container(
          width: double.infinity,
          height: 120, // Reduzido para 120
          decoration: BoxDecoration(
            color: context.isDarkMode 
                ? context.primaryColor.withOpacity(0.15) 
                : context.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12), // Reduzido para 12
            border: Border.all(
              color: context.isDarkMode 
                  ? context.primaryColor.withOpacity(0.3)
                  : context.primaryColor.withOpacity(0.2),
              width: 1, // Reduzido para 1
            ),
          ),
          child: Center(
            child: Icon(
              Icons.check_circle_outline,
              size: 80, // Reduzido para 80
              color: context.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
  
  // Painel de resumo com suporte a dark mode - otimizado para telas pequenas
  Widget _buildSummaryPanel(BuildContext context, int cigarettesPerDay, double monthlyCost, String goalText, OnboardingModel onboarding) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12), // Reduzido para 12
      decoration: BoxDecoration(
        color: context.isDarkMode 
            ? const Color(0xFF1A1A1A)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(10), // Reduzido para 10
        border: Border.all(
          color: context.isDarkMode 
              ? const Color(0xFF333333)
              : Colors.grey[200]!,
          width: 0.5, // Reduzido para 0.5
        ),
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8, // Reduzido para 8
                  offset: const Offset(0, 1), // Reduzido para 1
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.yourPersonalizedSummary,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.contentColor,
              fontSize: 14, // Tamanho reduzido
            ),
          ),
          const SizedBox(height: 8), // Reduzido para 8
          
          // Consumo
          _buildInfoItem(
            context,
            Icons.smoking_rooms,
            localizations.dailyConsumption,
            localizations.cigarettesPerDayValue(cigarettesPerDay),
          ),
          
          _buildDivider(context),
          
          // Economia financeira
          _buildInfoItem(
            context,
            Icons.savings,
            localizations.potentialMonthlySavings,
            _formatCurrency(monthlyCost, onboarding.packPriceCurrency),
          ),
          
          _buildDivider(context),
          
          // Objetivo
          _buildInfoItem(
            context,
            onboarding.goal == GoalType.reduce ? Icons.trending_down : Icons.smoke_free,
            localizations.yourGoal,
            onboarding.goal == GoalType.reduce ? localizations.reduceConsumption : localizations.quitSmoking,
          ),
          
          _buildDivider(context),
          
          // Desafio principal
          _buildInfoItem(
            context,
            _getChallengeIcon(onboarding.quitChallenge),
            localizations.mainChallenge,
            _getChallengeText(onboarding.quitChallenge),
          ),
        ],
      ),
    );
  }
  
  // Divider adaptado para dark mode - mais compacto
  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: context.isDarkMode ? const Color(0xFF333333) : Colors.grey[200],
      height: 16, // Reduzido para 16
      thickness: 0.5, // Mais fino
    );
  }
  
  // Lista de benefícios
  Widget _buildBenefitsList(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBenefitItem(
          context,
          localizations.personalized,
          localizations.personalizedDescription
        ),
        
        _buildBenefitItem(
          context,
          localizations.importantAchievements,
          localizations.achievementsDescription
        ),
        
        _buildBenefitItem(
          context,
          localizations.supportWhenNeeded,
          localizations.supportDescription
        ),
        
        _buildBenefitItem(
          context,
          localizations.guaranteedResults,
          localizations.resultsDescription
        ),
      ],
    );
  }
  
  // Grid de benefícios otimizado para telas pequenas
  Widget _buildBenefitsGrid(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1, // Ligeiramente mais alto que largo para melhor visualização
      crossAxisSpacing: 6, // Reduzido para 6
      mainAxisSpacing: 6, // Reduzido para 6
      padding: EdgeInsets.zero, // Sem padding extra
      children: [
        _buildBenefitCard(
          context,
          Icons.monitor_heart,
          localizations.personalized,
          localizations.personalizedDescription,
        ),
        _buildBenefitCard(
          context,
          Icons.emoji_events,
          localizations.importantAchievements,
          localizations.achievementsDescription,
        ),
        _buildBenefitCard(
          context,
          Icons.support_agent,
          localizations.supportWhenNeeded,
          localizations.supportDescription,
        ),
        _buildBenefitCard(
          context,
          Icons.trending_up,
          localizations.guaranteedResults,
          localizations.resultsDescription,
        ),
      ],
    );
  }
  
  // Card para o layout de grid - super compacto para telas pequenas
  Widget _buildBenefitCard(BuildContext context, IconData icon, String title, String description) {
    return Card(
      elevation: context.isDarkMode ? 0 : 1,
      color: context.cardColor,
      margin: EdgeInsets.zero, // Sem margens extras
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Reduzido para 8
        side: BorderSide(
          color: context.isDarkMode ? const Color(0xFF333333) : Colors.transparent,
          width: 0.5, // Mais fino
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Reduzido para 8
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone mais compacto
            Container(
              padding: const EdgeInsets.all(6), // Reduzido para 6
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: context.primaryColor,
                size: 20, // Reduzido para 20
              ),
            ),
            const SizedBox(height: 6), // Reduzido para 6
            Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.contentColor,
                fontSize: 13, // Tamanho reduzido
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2), // Reduzido para 2
            Text(
              description,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.subtitleColor,
                fontSize: 11, // Tamanho reduzido
                height: 1.2, // Altura de linha reduzida
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
    final localizations = AppLocalizations.of(context);
    
    switch (challenge) {
      case QuitChallenge.stress:
        return localizations.stressAnxiety;
      case QuitChallenge.habit:
        return localizations.habitStrength;
      case QuitChallenge.social:
        return localizations.socialInfluence;
      case QuitChallenge.addiction:
        return localizations.physicalDependence;
      default:
        return localizations.notSpecified;
    }
  }
  
  Widget _buildInfoItem(BuildContext context, IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Reduzido para 6
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6), // Reduzido para 6
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6), // Reduzido para 6
            ),
            child: Icon(
              icon,
              color: context.primaryColor,
              size: 16, // Reduzido para 16
            ),
          ),
          const SizedBox(width: 8), // Reduzido para 8
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.subtitleColor,
                    fontSize: 12, // Tamanho reduzido
                  ),
                ),
                Text(
                  value,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.contentColor,
                    fontSize: 13, // Tamanho reduzido
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.only(bottom: 10.0), // Reduzido para 10
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6), // Reduzido para 6
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              color: context.primaryColor,
              size: 14, // Reduzido para 14
            ),
          ),
          const SizedBox(width: 8), // Reduzido para 8
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.contentColor,
                    fontSize: 13, // Tamanho reduzido
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), // Reduzido para 2
                Text(
                  description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.subtitleColor,
                    fontSize: 12, // Tamanho reduzido
                    height: 1.2, // Altura de linha reduzida
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}