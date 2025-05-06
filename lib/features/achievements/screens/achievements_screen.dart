import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementsScreen extends StatelessWidget {
  static const String routeName = '/achievements';
  
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conquistas',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com contagem de conquistas
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAchievementCountItem(context, '2', 'Desbloqueadas'),
                      Container(height: 40, width: 1, color: Colors.grey[300]),
                      _buildAchievementCountItem(context, '10', 'Bloqueadas'),
                      Container(height: 40, width: 1, color: Colors.grey[300]),
                      _buildAchievementCountItem(context, '17%', 'Concluídas'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Próximos Marcos',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Lista de conquistas
              Expanded(
                child: ListView(
                  children: [
                    _buildAchievementItem(
                      context,
                      'Primeiro Dia',
                      'Complete 24 horas sem fumar',
                      Icons.calendar_today,
                      true,
                    ),
                    _buildAchievementItem(
                      context,
                      'Uma Semana',
                      'Uma semana sem fumar!',
                      Icons.celebration,
                      false,
                    ),
                    _buildAchievementItem(
                      context,
                      'Um Mês',
                      'Um mês inteiro sem fumar!',
                      Icons.calendar_month,
                      false,
                      progress: 0.1,
                    ),
                    _buildAchievementItem(
                      context,
                      'Economia Inicial',
                      'Economize o equivalente a 1 maço de cigarros',
                      Icons.savings,
                      true,
                    ),
                    _buildAchievementItem(
                      context,
                      'Economia Substancial',
                      'Economize o equivalente a 10 maços de cigarros',
                      Icons.attach_money,
                      false,
                      progress: 0.3,
                    ),
                    _buildAchievementItem(
                      context,
                      'Atleta em Treinamento',
                      'Registre 5 dias de exercícios',
                      Icons.fitness_center,
                      false,
                    ),
                    _buildAchievementItem(
                      context,
                      'Respiração Limpa',
                      'Alcance 2 semanas sem fumar',
                      Icons.air,
                      false,
                    ),
                    _buildAchievementItem(
                      context,
                      'Três Meses',
                      'Três meses sem fumar!',
                      Icons.celebration,
                      false,
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
  
  Widget _buildAchievementCountItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementItem(
    BuildContext context, 
    String title, 
    String description, 
    IconData icon, 
    bool unlocked, 
    {double progress = 0.0}
  ) {
    return Card(
      elevation: unlocked ? 2 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: unlocked 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: unlocked ? Colors.white : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: unlocked ? null : Colors.grey[600],
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: unlocked ? Colors.grey[700] : Colors.grey[500],
                    ),
                  ),
                  if (!unlocked && progress > 0) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}% concluído',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (unlocked)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}