import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_bloc.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_event.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_state.dart';
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
      final achievementBloc = context.read<AchievementBloc>();
      final achievementState = achievementBloc.state;
      
      // Only load if not already loaded
      if (achievementState.status == AchievementStatus.initial) {
        debugPrint('🔄 AchievementHelper: Loading achievements from bloc');
        achievementBloc.add(InitializeAchievements());
        
        // Wait a bit for the event to process
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        debugPrint('🔄 AchievementHelper: Achievements already loaded, skipping load');
      }
      
      // Create triggers and check for new achievements
      final triggers = AchievementTriggers(achievementBloc);
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
    final achievementBloc = context.read<AchievementBloc>();
    final triggers = AchievementTriggers(achievementBloc);
    
    final newAchievements = await triggers.onSmokingRecordChanged();
    _showAchievementNotifications(context, newAchievements);
  }
  
  /// Check for achievements after a craving is recorded
  /// Use this method without requiring a BuildContext
  static Future<void> checkAfterCravingRecorded(AchievementBloc achievementBloc, bool wasResisted) async {
    final triggers = AchievementTriggers(achievementBloc);
    
    final newAchievements = await triggers.onCravingRecorded(wasResisted);
    // Return achievements for later handling since we don't have context here
    return;
  }
  
  /// Check for achievements after a craving is recorded with context for notifications
  /// This method should only be called when context is guaranteed to be valid
  static Future<void> checkAfterCravingRecordedWithNotifications(BuildContext context, bool wasResisted) async {
    if (!context.mounted) return;
    
    final achievementBloc = context.read<AchievementBloc>();
    final triggers = AchievementTriggers(achievementBloc);
    
    final newAchievements = await triggers.onCravingRecorded(wasResisted);
    
    if (context.mounted) {
      _showAchievementNotifications(context, newAchievements);
    }
  }
  
  /// Check for achievements after a health recovery is achieved
  static Future<void> checkAfterHealthRecovery(BuildContext context) async {
    final achievementBloc = context.read<AchievementBloc>();
    final triggers = AchievementTriggers(achievementBloc);
    
    final newAchievements = await triggers.onHealthRecoveryAchieved();
    _showAchievementNotifications(context, newAchievements);
  }
  
  /// Check for achievements on login
  static Future<void> checkOnLogin(BuildContext context) async {
    final achievementBloc = context.read<AchievementBloc>();
    final triggers = AchievementTriggers(achievementBloc);
    
    final newAchievements = await triggers.onLogin();
    _showAchievementNotifications(context, newAchievements);
  }
  
  /// Perform daily check for time-based achievements
  static Future<void> performDailyCheck(BuildContext context) async {
    final achievementBloc = context.read<AchievementBloc>();
    final triggers = AchievementTriggers(achievementBloc);
    
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