import 'package:flutter/foundation.dart';
import '../providers/achievement_provider.dart';
import '../models/user_achievement.dart';

/// Utility class to handle achievement check triggers at various app events
class AchievementTriggers {
  final AchievementProvider _achievementProvider;
  
  // Flag to prevent too frequent checks
  DateTime? _lastCheckTime;
  static const Duration _minimumCheckInterval = Duration(minutes: 5);
  
  AchievementTriggers(this._achievementProvider);
  
  // Flag to prevent concurrent checks
  bool _isChecking = false;

  /// Check for new achievements and return any newly unlocked ones
  /// with improved throttling and error handling
  Future<List<UserAchievement>> _checkAchievements() async {
    // Prevent concurrent checks and throttle requests
    final now = DateTime.now();
    if (_isChecking || (_lastCheckTime != null && 
        now.difference(_lastCheckTime!) < _minimumCheckInterval)) {
      return [];
    }
    
    _isChecking = true;
    _lastCheckTime = now;
    
    try {
      // This might trigger a state update via the achievement provider
      return await _achievementProvider.checkForNewAchievements();
    } catch (e) {
      debugPrint('Error checking achievements: $e');
      return [];
    } finally {
      _isChecking = false;
    }
  }
  
  /// Trigger achievement check when app starts or resumes
  Future<List<UserAchievement>> onAppStart() async {
    return await _checkAchievements();
  }
  
  /// Trigger achievement check when a smoking record is added or updated
  Future<List<UserAchievement>> onSmokingRecordChanged() async {
    return await _checkAchievements();
  }
  
  /// Trigger achievement check when a craving is recorded
  Future<List<UserAchievement>> onCravingRecorded(bool wasResisted) async {
    // If the craving was not resisted, we don't need to check for CRAVINGS_RESISTED achievements
    if (!wasResisted) return [];
    
    return await _checkAchievements();
  }
  
  /// Trigger achievement check when a health recovery is achieved
  Future<List<UserAchievement>> onHealthRecoveryAchieved() async {
    return await _checkAchievements();
  }
  
  /// Trigger achievement check on login
  Future<List<UserAchievement>> onLogin() async {
    return await _checkAchievements();
  }
  
  /// Trigger achievement check daily
  Future<List<UserAchievement>> onDailyCheck() async {
    // No throttling for daily checks
    _lastCheckTime = DateTime.now();
    return await _achievementProvider.checkForNewAchievements();
  }
  
  /// Helper to print debug info about newly unlocked achievements
  void _debugPrintNewAchievements(List<UserAchievement> newAchievements) {
    if (!kDebugMode) return;
    
    if (newAchievements.isEmpty) {
      print('No new achievements unlocked');
      return;
    }
    
    print('🎉 New achievements unlocked:');
    for (final achievement in newAchievements) {
      print('  - ${achievement.definition.name}');
    }
  }
}