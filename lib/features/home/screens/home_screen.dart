import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/core/theme/theme_provider.dart';
import 'package:nicotinaai_flutter/core/theme/theme_switch.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    // Valores fictícios para demonstração - deverão ser substituídos por dados reais
    const daysWithoutSmoking = 7;
    const minutesLifeGained = 1680;
    const breathCapacityPercent = 40;
    const cravingsResisted = 12;
    const dailyMinutesGained = 240;
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          'NicotinaAI',
          style: context.titleStyle,
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        actions: const [
          ThemeSwitch(useIcons: true),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com saudação e contador de dias
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${user?.name?.split(' ')[0] ?? 'Usuário'}! 👋',
                          style: context.headlineStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$daysWithoutSmoking dias sem fumar',
                          style: context.subtitleStyle,
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: context.primaryColor.withOpacity(0.2),
                      child: Text(
                        user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Indicadores de recuperação de saúde
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Recuperação da Saúde',
                  style: context.titleStyle,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Indicadores de saúde em linha horizontal com scroll
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildHealthIndicator(context, 'Paladar', true),
                    _buildHealthIndicator(context, 'Olfato', true),
                    _buildHealthIndicator(context, 'Circulação', true),
                    _buildHealthIndicator(context, 'Pulmões', false),
                    _buildHealthIndicator(context, 'Coração', false),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Cards de estatísticas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatisticCard(
                        context,
                        '$minutesLifeGained',
                        'minutos de vida\nganhos',
                        Colors.green,
                        Icons.access_time,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatisticCard(
                        context,
                        '$breathCapacityPercent%',
                        'capacidade\npulmonar',
                        Colors.blue,
                        Icons.air,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Próximo marco
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: context.isDarkMode 
                    ? _buildGlassMorphicNextMilestone(context)
                    : _buildNextMilestone(context),
              ),
              
              const SizedBox(height: 24),
              
              // Conquistas recentes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Conquistas Recentes',
                      style: context.titleStyle,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navegar para a tela de conquistas
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: context.primaryColor,
                      ),
                      child: Text(
                        'Ver todas',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Cards de conquistas
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildAchievementCard(
                      context,
                      '24h',
                      'Primeiro Dia',
                      'Você passou 24 horas sem fumar!',
                      Colors.amber,
                    ),
                    _buildAchievementCard(
                      context,
                      '3 dias',
                      'Superando',
                      'Níveis de nicotina eliminados do corpo',
                      Colors.green,
                    ),
                    _buildAchievementCard(
                      context,
                      '1 semana',
                      'Persistência',
                      'Uma semana inteira sem cigarros!',
                      context.primaryColor,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Estatísticas diárias
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Estatísticas de Hoje',
                  style: context.titleStyle,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cards de estatísticas diárias
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDailyStatCard(
                        context,
                        '$cravingsResisted',
                        'Desejos \nResistidos',
                        Colors.orange,
                        Icons.smoke_free,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDailyStatCard(
                        context,
                        '$dailyMinutesGained',
                        'Minutos de Vida \nGanhos Hoje',
                        Colors.teal,
                        Icons.favorite,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHealthIndicator(BuildContext context, String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: isActive 
                ? context.primaryColor.withOpacity(0.15) 
                : context.isDarkMode 
                    ? Colors.grey[800] 
                    : Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive 
                  ? context.primaryColor 
                  : context.isDarkMode
                      ? Colors.grey[700]!
                      : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.check_circle,
              color: isActive 
                ? context.primaryColor 
                : context.isDarkMode
                    ? Colors.grey[600]
                    : Colors.grey[400],
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive 
                ? context.primaryColor 
                : context.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatisticCard(BuildContext context, String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(context.isDarkMode ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color.withOpacity(context.isDarkMode ? 0.9 : 1.0),
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: context.contentColor,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall!.copyWith(
              color: context.subtitleColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextMilestone(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primaryColor.withOpacity(0.7), 
            context.primaryColor
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildMilestoneContent(context, Colors.white),
    );
  }
  
  Widget _buildGlassMorphicNextMilestone(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: _buildMilestoneContent(context, Colors.white),
        ),
      ),
    );
  }
  
  Widget _buildMilestoneContent(BuildContext context, Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.flag_rounded,
            color: textColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Próximo Marco',
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Em 3 dias: Fluxo sanguíneo melhora',
                style: context.textTheme.bodyMedium!.copyWith(
                  color: textColor.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementCard(BuildContext context, String milestone, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 160,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(context.isDarkMode ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              milestone,
              style: context.textTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: color.withOpacity(context.isDarkMode ? 0.9 : 1.0),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: context.contentColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: context.textTheme.bodySmall!.copyWith(
              color: context.subtitleColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDailyStatCard(BuildContext context, String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(context.isDarkMode ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color.withOpacity(context.isDarkMode ? 0.9 : 1.0),
                  size: 18,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_upward,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 2),
              Text(
                '8%',
                style: context.textTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: context.contentColor,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall!.copyWith(
              color: context.subtitleColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}