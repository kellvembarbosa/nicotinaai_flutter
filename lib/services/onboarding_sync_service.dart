import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/features/tracking/repositories/tracking_repository.dart';

/// Service responsible for synchronizing onboarding data to UserStats
/// This ensures that user-provided values during onboarding (such as pack price, 
/// cigarettes per pack, cigarettes per day) are properly transferred to UserStats
class OnboardingSyncService {
  final OnboardingRepository _onboardingRepository;
  final TrackingRepository _trackingRepository;

  OnboardingSyncService({
    OnboardingRepository? onboardingRepository,
    TrackingRepository? trackingRepository,
  }) : _onboardingRepository = onboardingRepository ?? OnboardingRepository(),
       _trackingRepository = trackingRepository ?? TrackingRepository();

  /// Syncs onboarding data to UserStats to ensure user preferences are used instead of defaults
  Future<bool> syncOnboardingDataToUserStats() async {
    try {
      // Get onboarding data
      final onboarding = await _onboardingRepository.getOnboarding();
      if (onboarding == null) {
        debugPrint('❌ [OnboardingSyncService] No onboarding data found');
        return false;
      }
      
      // Get current user stats
      final userStats = await _trackingRepository.getUserStats();
      
      if (userStats == null) {
        // Create new user stats from onboarding data
        await _createUserStatsFromOnboarding(onboarding);
        return true;
      }
      
      // Update existing user stats with onboarding data
      await _updateUserStatsFromOnboarding(userStats, onboarding);
      return true;
    } catch (e) {
      debugPrint('❌ [OnboardingSyncService] Error syncing onboarding data: $e');
      return false;
    }
  }

  /// Creates a new UserStats entry based on onboarding data
  Future<void> _createUserStatsFromOnboarding(OnboardingModel onboarding) async {
    // Map cigarettes per day from enum to int if needed
    int? cigarettesPerDay = onboarding.cigarettesPerDayCount;
    if (cigarettesPerDay == null && onboarding.cigarettesPerDay != null) {
      cigarettesPerDay = _mapConsumptionLevelToCigarettesPerDay(onboarding.cigarettesPerDay!);
    }
    
    try {
      // Instead of creating a new UserStats directly, we'll use the updateUserStats method
      // which will trigger the backend function to generate the proper UserStats record
      
      // First, update the UserStats record with the server-side function
      await _trackingRepository.updateUserStats();
      
      // Then retrieve the created UserStats to verify it now exists
      final stats = await _trackingRepository.getUserStats();
      
      if (stats != null) {
        debugPrint('✅ [OnboardingSyncService] UserStats created via updateUserStats: ${stats.id}');
      } else {
        debugPrint('⚠️ [OnboardingSyncService] UserStats not found after updateUserStats call');
      }
    } catch (e) {
      debugPrint('❌ [OnboardingSyncService] Error creating UserStats: $e');
      rethrow;
    }
  }

  /// Updates existing UserStats with onboarding data
  Future<void> _updateUserStatsFromOnboarding(UserStats userStats, OnboardingModel onboarding) async {
    try {
      // Map cigarettes per day from enum to int if needed
      int? cigarettesPerDay = onboarding.cigarettesPerDayCount;
      if (cigarettesPerDay == null && onboarding.cigarettesPerDay != null) {
        cigarettesPerDay = _mapConsumptionLevelToCigarettesPerDay(onboarding.cigarettesPerDay!);
      }
      
      // Check if onboarding has any values that could be added to UserStats
      bool needsUpdate = false;
      
      // Check if onboarding data could enhance UserStats
      if ((userStats.cigarettesPerDay == null && cigarettesPerDay != null) ||
          (userStats.cigarettesPerPack == null && onboarding.cigarettesPerPack != null) ||
          (userStats.packPrice == null && onboarding.packPrice != null) ||
          (userStats.currencyCode == null && onboarding.packPriceCurrency.isNotEmpty)) {
        needsUpdate = true;
      }
      
      if (needsUpdate) {
        // If we have values that should be synced, force a server-side recalculation
        // This will incorporate the onboarding data stored in the user_onboarding table
        await _trackingRepository.updateUserStats();
        
        // Re-fetch the user stats to see the updated values
        final updatedStats = await _trackingRepository.getUserStats();
        
        // Print details for debug
        if (kDebugMode && updatedStats != null) {
          final changes = <String>[];
          if (userStats.cigarettesPerDay != updatedStats.cigarettesPerDay) {
            changes.add('cigarettesPerDay: ${userStats.cigarettesPerDay} -> ${updatedStats.cigarettesPerDay}');
          }
          if (userStats.cigarettesPerPack != updatedStats.cigarettesPerPack) {
            changes.add('cigarettesPerPack: ${userStats.cigarettesPerPack} -> ${updatedStats.cigarettesPerPack}');
          }
          if (userStats.packPrice != updatedStats.packPrice) {
            changes.add('packPrice: ${userStats.packPrice} -> ${updatedStats.packPrice}');
          }
          if (userStats.currencyCode != updatedStats.currencyCode) {
            changes.add('currencyCode: ${userStats.currencyCode} -> ${updatedStats.currencyCode}');
          }
          
          if (changes.isNotEmpty) {
            debugPrint('✅ [OnboardingSyncService] Updated UserStats with onboarding data');
            debugPrint('🔄 [OnboardingSyncService] Changed fields: ${changes.join(', ')}');
          } else {
            debugPrint('ℹ️ [OnboardingSyncService] UserStats updated but no visible field changes detected');
          }
        }
      } else {
        debugPrint('✅ [OnboardingSyncService] No updates needed - UserStats already has onboarding data');
      }
    } catch (e) {
      debugPrint('❌ [OnboardingSyncService] Error updating UserStats: $e');
      rethrow;
    }
  }

  /// Maps ConsumptionLevel enum to specific cigarettes per day count
  int _mapConsumptionLevelToCigarettesPerDay(ConsumptionLevel level) {
    switch (level) {
      case ConsumptionLevel.low:
        return 5;  // 1-5 cigarettes per day
      case ConsumptionLevel.moderate:
        return 10; // 6-10 cigarettes per day
      case ConsumptionLevel.high:
        return 20; // 11-20 cigarettes per day
      case ConsumptionLevel.veryHigh:
        return 30; // 20+ cigarettes per day
    }
  }
}