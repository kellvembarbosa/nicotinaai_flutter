import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';

class DailyMotivationCard extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onRewardClaimed;
  
  const DailyMotivationCard({
    super.key,
    required this.notification,
    this.onRewardClaimed,
  });

  @override
  State<DailyMotivationCard> createState() => _DailyMotivationCardState();
}

class _DailyMotivationCardState extends State<DailyMotivationCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isRewardClaimed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );
    
    // Verifica se a recompensa já foi visualizada
    _isRewardClaimed = widget.notification['viewed_at'] != null;
    
    // Iniciar animação de pulsação se a recompensa não foi reivindicada
    if (!_isRewardClaimed) {
      _startPulseAnimation();
    }
  }
  
  void _startPulseAnimation() {
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _claimReward() async {
    if (_isLoading || _isRewardClaimed) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final notificationService = NotificationService();
      // Mark the notification as read instead of claiming a reward
      // This is a temporary fix until the backend API is implemented
      await notificationService.markNotificationAsRead(
        widget.notification['id'],
      );
      
      // Simulate a response for UI purposes
      final mockResponse = {
        'xp_gained': widget.notification['xp_reward'] ?? 5,
        'unlocked_achievements': []
      };
      
      // Parar animação de pulsação
      _animationController.stop();
      
      setState(() {
        _isRewardClaimed = true;
      });
      
      // Mostrar efeito de confete e animação de XP
      _showXpAnimation(mockResponse['xp_gained']);
      
      // Notificar o widget pai (se necessário)
      if (widget.onRewardClaimed != null) {
        widget.onRewardClaimed!();
      }
      
      // Future implementation can handle unlocked achievements
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reivindicar recompensa: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showXpAnimation(int xpAmount) {
    // Mostrar animação de XP ganhado - implementação a ser feita
    // Pode usar um overlay para mostrar um "+XP" flutuando para cima
  }
  
  // Commented out as it's currently unused but may be implemented in the future
  // void _showUnlockedAchievements(List<dynamic> achievements) {
  //   // Implementar lógica para mostrar conquistas desbloqueadas
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Nova Conquista Desbloqueada!', 
  //         style: TextStyle(color: context.primaryColor),
  //       ),
  //       content: SizedBox(
  //         height: 200,
  //         width: 300,
  //         child: ListView.builder(
  //           itemCount: achievements.length,
  //           itemBuilder: (context, index) {
  //             final achievement = achievements[index];
  //             return ListTile(
  //               leading: Icon(Icons.emoji_events, color: Colors.amber),
  //               title: Text(achievement['title'] ?? 'Conquista desbloqueada'),
  //               subtitle: Text(achievement['description'] ?? ''),
  //             );
  //           },
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('Ótimo!'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final xpReward = widget.notification['xp_reward'] ?? 
                    (widget.notification['data'] != null ? 
                      widget.notification['data']['xp_reward'] ?? 5 : 5);
                      
    final title = widget.notification['title'];
    final message = widget.notification['message'];
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRewardClaimed ? 1.0 : _scaleAnimation.value,
          child: child,
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.primaryColor.withAlpha((255 * 0.8).round()),
                context.primaryColor,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone de motivação
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((255 * 0.2).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Título
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Mensagem
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Botão de recompensa
                if (!_isRewardClaimed)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _claimReward,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: context.primaryColor,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.primaryColor,
                            ),
                          )
                        : const Icon(Icons.star),
                    label: Text('Ganhar $xpReward XP'),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((255 * 0.3).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recompensa recebida: $xpReward XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}