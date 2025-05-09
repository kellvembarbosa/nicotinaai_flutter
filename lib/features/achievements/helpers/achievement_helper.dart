import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/achievement_provider.dart';
import '../triggers/achievement_triggers.dart';
import '../models/user_achievement.dart';
import '../services/achievement_notification_service.dart';
import '../../../core/routes/app_routes.dart';

/// Helper class to integrate achievement checks into app events
class AchievementHelper {
  // Static flag to prevent multiple initializations
  static bool _isInitializing = false;
  static bool _isInitialized = false;

  /// Initialize achievements on app start with safeguards against multiple calls
  static Future<void> initializeAchievements(BuildContext context) async {
    // Strong check to prevent multiple initializations or loops
    if (_isInitializing || _isInitialized) {
      debugPrint('🔄 AchievementHelper: Skipping initialization (already initialized)');
      return;
    }
    
    _isInitializing = true;
    debugPrint('✅ AchievementHelper: Starting initialization');
    
    try {
      final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
      
      // Only load if not already loaded
      if (achievementProvider.state.status == AchievementStatus.initial) {
        debugPrint('🔄 AchievementHelper: Loading achievements from provider');
        await achievementProvider.loadAchievements();
      } else {
        debugPrint('🔄 AchievementHelper: Achievements already loaded, skipping load');
      }
      
      // Create triggers and check for new achievements
      final triggers = AchievementTriggers(achievementProvider);
      final newAchievements = await triggers.onAppStart();
      
      // Display notifications if needed and context is still valid
      if (context.mounted) {
        _showAchievementNotifications(context, newAchievements);
      }
      
      _isInitialized = true;
      debugPrint('✅ AchievementHelper: Initialization completed successfully');
    } catch (e) {
      debugPrint('❌ Error initializing achievements: $e');
    } finally {
      _isInitializing = false;
    }
  }
  
  /// Check for achievements after a smoking record is added or updated
  static Future<void> checkAfterSmokingRecord(BuildContext context) async {
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
    final triggers = AchievementTriggers(achievementProvider);
    
    final newAchievements = await triggers.onSmokingRecordChanged();
    _showAchievementNotifications(context, newAchievements);
  }
  
  /// Check for achievements after a craving is recorded
  static Future<void> checkAfterCravingRecorded(BuildContext context, bool wasResisted) async {
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
    final triggers = AchievementTriggers(achievementProvider);
    
    final newAchievements = await triggers.onCravingRecorded(wasResisted);
    _showAchievementNotifications(context, newAchievements);
  }
  
  /// Check for achievements after a health recovery is achieved
  static Future<void> checkAfterHealthRecovery(BuildContext context) async {
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
    final triggers = AchievementTriggers(achievementProvider);
    
    final newAchievements = await triggers.onHealthRecoveryAchieved();
    _showAchievementNotifications(context, newAchievements);
  }
  
  /// Check for achievements on login
  static Future<void> checkOnLogin(BuildContext context) async {
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
    final triggers = AchievementTriggers(achievementProvider);
    
    final newAchievements = await triggers.onLogin();
    _showAchievementNotifications(context, newAchievements);
  }
  
  /// Perform daily check for time-based achievements
  static Future<void> performDailyCheck(BuildContext context) async {
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
    final triggers = AchievementTriggers(achievementProvider);
    
    final newAchievements = await triggers.onDailyCheck();
    _showAchievementNotifications(context, newAchievements);
  }
  
  /// Show notifications for newly unlocked achievements
  static void _showAchievementNotifications(BuildContext context, List<UserAchievement> newAchievements) {
    if (newAchievements.isEmpty) return;
    
    // Ensure context is still valid
    if (!context.mounted) return;
    
    for (final achievement in newAchievements) {
      // Check if this is a major milestone achievement that deserves a full celebration
      if (_isVerySignificantAchievement(achievement)) {
        // For major milestone achievements, show the fullscreen celebration
        AchievementNotificationService.showCelebrationScreen(context, achievement);
      }
      // For significant achievements, show a dialog
      else if (_isSignificantAchievement(achievement)) {
        AchievementNotificationService.showAchievementDialog(context, achievement);
      } 
      // For regular achievements, show a snackbar
      else {
        AchievementNotificationService.showAchievementSnackBar(context, achievement);
      }
    }
  }
  
  /// Determine if an achievement is significant enough to show a dialog
  static bool _isSignificantAchievement(UserAchievement achievement) {
    // Show dialog for achievements with XP reward >= 50
    if (achievement.definition.xpReward >= 50) return true;
    
    // Show dialog for time-based milestones (weekly, monthly)
    if (achievement.definition.requirementType == 'DAYS_SMOKE_FREE') {
      final days = achievement.definition.requirementValue as int;
      if (days >= 7 && days < 30) return true; // 1-4 weeks (dialog)
    }
    
    // Show dialog for health-related achievements
    if (achievement.definition.category.toLowerCase() == 'health') {
      return true;
    }
    
    return false;
  }
  
  /// Check if this is a major milestone achievement deserving fullscreen celebration
  static bool _isVerySignificantAchievement(UserAchievement achievement) {
    // Major time milestones (1 month, 3 months, 6 months, 1 year)
    if (achievement.definition.requirementType == 'DAYS_SMOKE_FREE') {
      final days = achievement.definition.requirementValue as int;
      return days >= 30; // 1 month or more (fullscreen)
    }
    
    // Very high XP achievements
    if (achievement.definition.xpReward >= 100) return true;
    
    return false;
  }
}