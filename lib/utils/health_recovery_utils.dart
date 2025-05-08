import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:flutter/material.dart';

/// Helper functions for working with health recoveries
class HealthRecoveryUtils {
  static final _client = SupabaseConfig.client;

  /// Check for new health recoveries for the current user
  /// Returns the result from the checkHealthRecoveries edge function
  static Future<Map<String, dynamic>> checkForNewRecoveries() async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Call the edge function to check health recoveries
      final response = await _client.functions.invoke('checkHealthRecoveries', 
        body: {'userId': user.id},
      );
      
      if (response.status != 200) {
        throw Exception('Failed to check health recoveries: Status ${response.status}');
      }
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Log the error but don't crash the app
      print('Error checking health recoveries: $e');
      rethrow;
    }
  }
  
  /// Get the number of days required to achieve all health recoveries
  static Future<List<int>> getHealthRecoveryMilestones() async {
    try {
      final response = await _client
          .from('health_recoveries')
          .select('days_to_achieve')
          .order('days_to_achieve', ascending: true);
      
      return (response as List).map((r) => r['days_to_achieve'] as int).toList();
    } catch (e) {
      // Return some sensible defaults if we can't get the milestones
      print('Error getting health recovery milestones: $e');
      return [1, 2, 3, 7, 14, 30, 90, 365];
    }
  }
  
  /// Get the next health recovery milestone for a given number of days
  static Future<int> getNextMilestone(int currentDays) async {
    final milestones = await getHealthRecoveryMilestones();
    
    // Find the next milestone that's greater than the current days
    for (final days in milestones) {
      if (days > currentDays) {
        return days;
      }
    }
    
    // If there are no more milestones, return the last one or 365 as a fallback
    return milestones.isNotEmpty ? milestones.last : 365;
  }
  
  /// Calculate progress towards the next milestone
  static Future<double> getProgressToNextMilestone(int currentDays) async {
    final milestones = await getHealthRecoveryMilestones();
    
    // If no milestones or already past all milestones
    if (milestones.isEmpty || currentDays >= milestones.last) {
      return 1.0; // 100% progress
    }
    
    // Find the previous and next milestones
    int? previousMilestone;
    int nextMilestone = milestones.first;
    
    for (final days in milestones) {
      if (days <= currentDays) {
        previousMilestone = days;
      } else {
        nextMilestone = days;
        break;
      }
    }
    
    // If no previous milestone, use 0
    previousMilestone ??= 0;
    
    // Calculate progress between previous and next milestones
    final totalDays = nextMilestone - previousMilestone;
    final progressDays = currentDays - previousMilestone;
    
    return totalDays > 0 ? progressDays / totalDays : 0.0;
  }
  
  /// Get detailed information about a user's health recoveries
  /// including those achieved and those still in progress
  static Future<Map<String, dynamic>> getUserHealthRecoveryStatus() async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Get all health recoveries
      final recoveries = await _client
          .from('health_recoveries')
          .select()
          .order('days_to_achieve', ascending: true);
      
      // Get user's achieved health recoveries
      final userRecoveries = await _client
          .from('user_health_recoveries')
          .select('*, recovery:recovery_id(*)')
          .eq('user_id', user.id)
          .order('achieved_at', ascending: false);
      
      // Get user's streak information
      final userStats = await _client
          .from('user_stats')
          .select('current_streak_days, last_smoke_date')
          .eq('user_id', user.id)
          .single();
      
      final currentStreakDays = userStats['current_streak_days'] as int? ?? 0;
      final lastSmokeDate = userStats['last_smoke_date'] != null
          ? DateTime.parse(userStats['last_smoke_date'])
          : null;
      
      // Mark each recovery as achieved or in progress
      final allRecoveries = (recoveries as List).map((r) {
        final recoveryObj = HealthRecovery.fromJson(r);
        final daysToAchieve = recoveryObj.daysToAchieve;
        final isAchieved = userRecoveries.any((ur) => ur['recovery_id'] == recoveryObj.id);
        final progress = daysToAchieve > 0 && daysToAchieve > currentStreakDays
            ? currentStreakDays / daysToAchieve
            : isAchieved ? 1.0 : 0.0;
        
        return {
          ...r,
          'is_achieved': isAchieved,
          'progress': progress,
          'days_remaining': isAchieved ? 0 : (daysToAchieve - currentStreakDays) > 0 ? (daysToAchieve - currentStreakDays) : 0
        };
      }).toList();
      
      return {
        'recoveries': allRecoveries,
        'achieved_recoveries': userRecoveries,
        'current_streak_days': currentStreakDays,
        'last_smoke_date': lastSmokeDate?.toIso8601String(),
      };
    } catch (e) {
      print('Error getting user health recovery status: $e');
      rethrow;
    }
  }
  
  /// Get the next health recovery milestone that is not yet achieved
  /// 
  /// Returns a map with details about the next milestone:
  /// - id: The ID of the health recovery
  /// - name: The name of the health recovery
  /// - description: The description of the health recovery
  /// - daysToAchieve: Days required to achieve this milestone
  /// - daysRemaining: Days remaining until this milestone is achieved
  /// - progress: Progress towards this milestone (0.0 to 1.0)
  /// - isNext: Whether this is the very next milestone to achieve
  /// - icon: Suggested icon for this milestone
  /// 
  /// If all milestones have been achieved, it returns null.
  static Future<Map<String, dynamic>?> getNextHealthRecoveryMilestone(int currentStreakDays) async {
    try {
      // Get all health recoveries and their status
      final status = await getUserHealthRecoveryStatus();
      final recoveries = status['recoveries'] as List;
      
      // Filter to only non-achieved recoveries and sort by days to achieve
      final nonAchievedRecoveries = recoveries
          .where((r) => r['is_achieved'] != true)
          .toList()
        ..sort((a, b) => a['days_to_achieve'].compareTo(b['days_to_achieve']));
      
      // If all recoveries are achieved, return null
      if (nonAchievedRecoveries.isEmpty) {
        return null;
      }
      
      // Find the next recovery - the one with the lowest days_to_achieve that is higher than current streak
      final nextRecovery = nonAchievedRecoveries.firstWhere(
        (r) => r['days_to_achieve'] > currentStreakDays,
        orElse: () => nonAchievedRecoveries.first,
      );
      
      // Get icon based on name or type
      IconData icon = Icons.healing;
      final iconName = nextRecovery['icon_name'] as String?;
      if (iconName != null) {
        final iconMap = {
          'taste': Icons.restaurant,
          'smell': Icons.air,
          'blood_drop': Icons.bloodtype,
          'lungs': Icons.air_rounded,
          'heart': Icons.favorite,
          'chemical': Icons.science,
          'circulation': Icons.bike_scooter,
        };
        
        icon = iconMap[iconName] ?? Icons.healing;
      } else {
        // Try to guess icon from name
        final name = nextRecovery['name'].toString().toLowerCase();
        if (name.contains('taste')) icon = Icons.restaurant;
        else if (name.contains('smell')) icon = Icons.air;
        else if (name.contains('blood')) icon = Icons.bloodtype;
        else if (name.contains('lung') || name.contains('breath')) icon = Icons.air_rounded;
        else if (name.contains('heart')) icon = Icons.favorite;
        else if (name.contains('chemical') || name.contains('nicotin')) icon = Icons.science;
        else if (name.contains('circulation')) icon = Icons.bike_scooter;
      }
      
      // Create result
      return {
        'id': nextRecovery['id'],
        'name': nextRecovery['name'],
        'description': nextRecovery['description'],
        'daysToAchieve': nextRecovery['days_to_achieve'],
        'daysRemaining': nextRecovery['days_remaining'],
        'progress': nextRecovery['progress'],
        'isNext': true,
        'icon': icon,
      };
    } catch (e) {
      print('Error getting next health recovery milestone: $e');
      return null;
    }
  }
}