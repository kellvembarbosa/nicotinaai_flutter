import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_bloc.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_event.dart';
import '../models/user_achievement.dart';

/// Utility class to handle achievement check triggers at various app events
class AchievementTriggers {
  final AchievementBloc _achievementBloc;
  
  // Flag to prevent too frequent checks
  DateTime? _lastCheckTime;
  static const Duration _minimumCheckInterval = Duration(minutes: 5);
  
  AchievementTriggers(this._achievementBloc);
  
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
      // Dispatch event to check for new achievements
      _achievementBloc.add(CheckForNewAchievements());
      
      // Wait a bit for the event to process
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Get the latest state to see if any new achievements were unlocked
      final state = _achievementBloc.state;
      return state.newlyUnlockedAchievements ?? [];
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
    
    // Dispatch daily check event
    _achievementBloc.add(CheckForNewAchievements(forceDailyCheck: true));
    
    // Wait a bit for the event to process
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Get the latest state
    final state = _achievementBloc.state;
    return state.newlyUnlockedAchievements ?? [];
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