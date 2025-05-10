import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/user_achievement.dart';
import '../providers/achievement_provider.dart';
import '../widgets/achievement_celebration.dart';
import '../../../core/routes/app_routes.dart';

/// Service to handle achievement notifications
class AchievementNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  
  // Notification channel ID for achievements
  static const String _channelId = 'achievements_channel';
  static const String _channelName = 'Achievements';
  static const String _channelDescription = 'Notifications for unlocked achievements';
  
  // Notification IDs
  static const int _achievementUnlockedId = 1000;
  
  AchievementNotificationService(this._notificationsPlugin) {
    _initNotifications();
  }
  
  /// Initialize notification channels
  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Request permissions on iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
  
  /// Handle when user taps on notification
  void _onNotificationTapped(NotificationResponse response) {
    // Extract achievement ID from payload
    final achievementId = response.payload;
    if (achievementId != null && achievementId.isNotEmpty) {
      // We'll need to navigate to the achievement detail screen
      // This needs to be handled at app level since we need BuildContext
    }
  }
  
  /// Show a notification when an achievement is unlocked
  Future<void> showAchievementUnlockedNotification(UserAchievement achievement) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Achievement Unlocked!',
      color: Colors.amber,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      _achievementUnlockedId + achievement.id.hashCode, // Use unique ID for each achievement
      'Unlocked!', // Title without trophy emoji
      // Forçar quebra de linha após cada 20-25 caracteres para garantir visibilidade
      _formatTitleWithLineBreaks(achievement.definition.name),
      details,
      payload: achievement.id, // Pass achievement ID as payload
    );
  }
  
  /// Show a snackbar notification for unlocked achievements
  static void showAchievementSnackBar(
    BuildContext context, 
    UserAchievement achievement,
  ) {
    if (!context.mounted) return;
    
    // Play haptic feedback for achievement
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha((255 * 0.2).round()),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events, color: Colors.amber),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Unlocked!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    achievement.definition.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.teal.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.amber,
          onPressed: () {
            // Navigate to achievement detail with push para manter histórico de navegação
            context.push('/achievement/${achievement.id}');
            
            // Mark as viewed
            context.read<AchievementProvider>().markAchievementAsViewed(achievement.id);
          },
        ),
      ),
    );
  }
  
  /// Show a more prominent dialog for significant achievements
  static Future<void> showAchievementDialog(
    BuildContext context, 
    UserAchievement achievement,
  ) async {
    if (!context.mounted) return;
    
    // Play haptic feedback
    HapticFeedback.heavyImpact();
    
    // Only show dialog for important achievements (e.g., milestones)
    if (!_isSignificantAchievement(achievement)) return;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Unlocked!',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withAlpha((255 * 0.5).round())),
              ),
              child: Icon(
                _getAchievementIcon(achievement),
                color: Colors.amber,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.definition.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible, // Garante que o texto seja totalmente visível
              softWrap: true, // Permite quebra de linha
            ),
            const SizedBox(height: 8),
            Text(
              achievement.definition.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '+${achievement.definition.xpReward} XP',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              // Navigate to achievement detail
              context.push('/achievement/${achievement.id}');
              
              // Mark as viewed
              context.read<AchievementProvider>().markAchievementAsViewed(achievement.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
    
    // Mark as viewed after showing dialog
    context.read<AchievementProvider>().markAchievementAsViewed(achievement.id);
  }
  
  /// Determine if an achievement is significant enough to show a dialog
  static bool _isSignificantAchievement(UserAchievement achievement) {
    // Show dialog for achievements with XP reward >= 50
    if (achievement.definition.xpReward >= 50) return true;
    
    // Show dialog for time-based milestones (weekly, monthly)
    if (achievement.definition.requirementType == 'DAYS_SMOKE_FREE') {
      final days = achievement.definition.requirementValue as int;
      if (days >= 7) return true; // 1 week or more
    }
    
    // Show dialog for health-related achievements
    if (achievement.definition.category.toLowerCase() == 'health') {
      return true;
    }
    
    return false;
  }
  
  /// Show a fullscreen celebration for very important achievements
  static Future<void> showCelebrationScreen(
    BuildContext context, 
    UserAchievement achievement,
  ) async {
    if (!context.mounted) return;
    
    // Play haptic feedback
    HapticFeedback.heavyImpact();
    
    // Only show for very significant achievements
    if (!_isVerySignificantAchievement(achievement)) return;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: AchievementCelebration(
          achievement: achievement,
          onDismiss: () {
            Navigator.of(context).pop();
            
            // Navigate to achievement detail with push para manter histórico de navegação
            context.push('/achievement/${achievement.id}');
            
            // Mark as viewed
            context.read<AchievementProvider>().markAchievementAsViewed(achievement.id);
          },
        ),
      ),
    );
    
    // Mark as viewed
    context.read<AchievementProvider>().markAchievementAsViewed(achievement.id);
  }
  
  /// Check if this is a major milestone achievement
  static bool _isVerySignificantAchievement(UserAchievement achievement) {
    // Major time milestones (1 month, 3 months, 6 months, 1 year)
    if (achievement.definition.requirementType == 'DAYS_SMOKE_FREE') {
      final days = achievement.definition.requirementValue as int;
      return days >= 30; // 1 month or more
    }
    
    // Very high XP achievements
    if (achievement.definition.xpReward >= 100) return true;
    
    return false;
  }
  
  /// Get an appropriate icon for the achievement
  static IconData _getAchievementIcon(UserAchievement achievement) {
    final category = achievement.definition.category.toLowerCase();
    
    switch (category) {
      case 'health':
        return Icons.favorite;
      case 'time':
        return Icons.timer;
      case 'savings':
        return Icons.savings;
      case 'habits':
        return Icons.psychology;
      default:
        return Icons.emoji_events;
    }
  }

  /// Formata o título da conquista com quebras de linha para melhor visualização
  String _formatTitleWithLineBreaks(String title) {
    // Se o título for curto, não precisa formatá-lo
    if (title.length <= 20) return title;

    // Encontrar um bom ponto para quebrar (depois de um espaço, se possível)
    final midPoint = title.length ~/ 2;
    int breakIndex = midPoint;

    // Procurar o espaço mais próximo do meio para quebrar
    for (int i = midPoint; i < title.length; i++) {
      if (title[i] == ' ') {
        breakIndex = i;
        break;
      }
    }
    
    // Se não encontrou um espaço depois do meio, tenta antes
    if (breakIndex == midPoint) {
      for (int i = midPoint; i >= 0; i--) {
        if (title[i] == ' ') {
          breakIndex = i;
          break;
        }
      }
    }
    
    // Se ainda assim não encontrou um espaço, corta no meio mesmo
    if (breakIndex == midPoint && title.length > 25) {
      return '${title.substring(0, breakIndex)}\n${title.substring(breakIndex)}';
    } else if (breakIndex != midPoint) {
      // Se encontrou um espaço, quebra nele
      return '${title.substring(0, breakIndex)}\n${title.substring(breakIndex + 1)}';
    }
    
    // Se o título não é tão longo, apenas retorna ele
    return title;
  }
}