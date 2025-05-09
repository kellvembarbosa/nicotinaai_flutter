import 'package:flutter/foundation.dart';

import '../models/achievement_definition.dart';
import '../models/user_achievement.dart';
import '../models/time_period.dart';
import '../services/achievement_service.dart';

/// Status states for Achievement Provider
enum AchievementStatus {
  initial,
  loading,
  loaded,
  error
}

/// Manages the state for achievements
class AchievementState {
  final AchievementStatus status;
  final List<AchievementDefinition> allDefinitions;
  final List<UserAchievement> userAchievements;
  final String? errorMessage;
  final TimePeriod selectedTimePeriod;
  
  const AchievementState({
    this.status = AchievementStatus.initial,
    this.allDefinitions = const [],
    this.userAchievements = const [],
    this.errorMessage,
    this.selectedTimePeriod = TimePeriod.allTime,
  });
  
  AchievementState copyWith({
    AchievementStatus? status,
    List<AchievementDefinition>? allDefinitions,
    List<UserAchievement>? userAchievements,
    String? errorMessage,
    TimePeriod? selectedTimePeriod,
  }) {
    return AchievementState(
      status: status ?? this.status,
      allDefinitions: allDefinitions ?? this.allDefinitions,
      userAchievements: userAchievements ?? this.userAchievements,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedTimePeriod: selectedTimePeriod ?? this.selectedTimePeriod,
    );
  }
  
  /// Filter achievements by both category and time period
  List<UserAchievement> getAchievementsByCategory(String category, {TimePeriod? timePeriod}) {
    timePeriod ??= selectedTimePeriod;
    
    // First filter by time period, if it's not all time
    List<UserAchievement> filteredByTime = userAchievements;
    if (timePeriod != TimePeriod.allTime) {
      filteredByTime = userAchievements.where((a) {
        // For unlocked achievements, check if they were unlocked in the specified time period
        if (a.isUnlocked && a.unlockedAt != DateTime(9999)) {
          return timePeriod!.contains(a.unlockedAt);
        }
        
        // Always include in-progress achievements for better user experience
        return a.progress > 0;
      }).toList();
    }
    
    // Then filter by category
    if (category.toLowerCase() == 'all') {
      return filteredByTime;
    }
    
    return filteredByTime.where(
      (a) => a.definition.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }
  
  /// Helper methods for the UI that consider time period filtering
  
  /// Get the number of unlocked achievements
  int get unlockedCount {
    if (selectedTimePeriod == TimePeriod.allTime) {
      return userAchievements.where((a) => a.isUnlocked).length;
    }
    
    return userAchievements.where((a) => 
      a.isUnlocked && 
      a.unlockedAt != DateTime(9999) &&
      selectedTimePeriod.contains(a.unlockedAt)
    ).length;
  }
  
  /// Get the number of in-progress achievements
  int get inProgressCount => userAchievements.where((a) => a.progress > 0 && a.progress < 1.0).length;
  
  /// Get the completion percentage
  String get completionPercentage {
    if (allDefinitions.isEmpty) return "0%";
    return "${((unlockedCount / allDefinitions.length) * 100).round()}%";
  }
}

/// Provider to manage achievement state and interactions
class AchievementProvider extends ChangeNotifier {
  final AchievementService _service;
  AchievementState _state = AchievementState();
  
  // Flags para controle de loops infinitos
  bool _isLoadingAchievements = false;
  DateTime? _lastLoadTime;
  static const _minLoadIntervalMs = 1000; // 1 segundo entre carregamentos
  
  AchievementProvider(this._service);
  
  AchievementState get state => _state;
  
  /// Verifica se podemos recarregar achievements baseado no tempo decorrido
  bool get _canReloadAchievements {
    if (_lastLoadTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(_lastLoadTime!).inMilliseconds;
    return difference > _minLoadIntervalMs;
  }
  
  /// Load all achievements and user progress
  Future<void> loadAchievements() async {
    // Impede carregamentos múltiplos ou muito frequentes
    if (_isLoadingAchievements || !_canReloadAchievements) {
      debugPrint('Skipping duplicate achievement load');
      return;
    }
    
    _isLoadingAchievements = true;
    _lastLoadTime = DateTime.now();
    
    try {
      _state = _state.copyWith(status: AchievementStatus.loading);
      notifyListeners();
      
      final allDefinitions = _service.getAllAchievementDefinitions();
      
      // First, force persist any unlocked achievements to ensure database consistency
      await _service.forcePersistUnlockedAchievements();
      
      // Then load all achievements including those from the database
      final userAchievements = await _service.calculateUserAchievements();
      
      debugPrint('📊 Loaded ${userAchievements.length} achievements, ${userAchievements.where((a) => a.isUnlocked).length} unlocked');
      
      _state = _state.copyWith(
        status: AchievementStatus.loaded,
        allDefinitions: allDefinitions,
        userAchievements: userAchievements,
      );
      notifyListeners();
      
      // Check for new achievements after loading, but only if this is the first load
      if (userAchievements.isNotEmpty && _state.status == AchievementStatus.initial) {
        debugPrint('🔍 Checking for new achievements after first load');
        // Use a small delay to avoid UI jank
        Future.delayed(const Duration(milliseconds: 500), () {
          checkForNewAchievements();
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading achievements: $e');
      _state = _state.copyWith(
        status: AchievementStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    } finally {
      _isLoadingAchievements = false;
    }
  }
  
  /// Change the time period for achievement filtering
  void setTimePeriod(TimePeriod period) {
    if (period != _state.selectedTimePeriod) {
      _state = _state.copyWith(selectedTimePeriod: period);
      notifyListeners();
    }
  }
  
  /// Get the currently selected time period
  TimePeriod get selectedTimePeriod => _state.selectedTimePeriod;
  
  /// Mark an achievement as viewed by the user
  Future<void> markAchievementAsViewed(String achievementId) async {
    await _service.markAchievementAsViewed(achievementId);
    
    // Update local state
    final updatedAchievements = _state.userAchievements.map((ua) {
      if (ua.id == achievementId) {
        return UserAchievement(
          id: ua.id,
          definition: ua.definition,
          unlockedAt: ua.unlockedAt,
          isViewed: true,
          progress: ua.progress,
        );
      }
      return ua;
    }).toList();
    
    _state = _state.copyWith(userAchievements: updatedAchievements);
    notifyListeners();
  }
  
  // Add a flag to prevent concurrent achievement checks
  bool _isCheckingAchievements = false;
  DateTime? _lastCheckTime;
  static const _minCheckIntervalMs = 2000; // 2 segundos entre verificações

  /// Verifica se podemos verificar achievements baseado no tempo decorrido
  bool get _canCheckAchievements {
    if (_lastCheckTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(_lastCheckTime!).inMilliseconds;
    return difference > _minCheckIntervalMs;
  }

  // Counter for consecutive check failures
  int _consecutiveCheckFailures = 0;
  static const _maxConsecutiveFailures = 3;
  
  /// Check for newly unlocked achievements with safeguards against concurrent checks
  Future<List<UserAchievement>> checkForNewAchievements() async {
    // Prevent concurrent checks and limit check frequency
    if (_isCheckingAchievements || !_canCheckAchievements) {
      debugPrint('Skipping duplicate achievement check');
      return [];
    }
    
    // If we've had too many consecutive failures, stop checking temporarily
    if (_consecutiveCheckFailures >= _maxConsecutiveFailures) {
      debugPrint('⚠️ Too many achievement check failures, skipping checks temporarily');
      return [];
    }
    
    _isCheckingAchievements = true;
    _lastCheckTime = DateTime.now();
    
    try {
      final newlyUnlocked = await _service.checkForNewAchievements();
      
      // Reset failure counter on success
      _consecutiveCheckFailures = 0;
      
      if (newlyUnlocked.isNotEmpty) {
        // Only refresh if we're not already loading and enough time has passed
        if (_state.status != AchievementStatus.loading && _canReloadAchievements) {
          // No need for full reload, just update the viewed status
          debugPrint('✅ Found ${newlyUnlocked.length} newly unlocked achievements');
          
          // Update the user achievements in state to mark these as viewed
          final updatedAchievements = _state.userAchievements.map((ua) {
            // If this achievement is in the newly unlocked list, mark it as viewed
            if (newlyUnlocked.any((nu) => nu.id == ua.id)) {
              return UserAchievement(
                id: ua.id,
                definition: ua.definition,
                unlockedAt: ua.unlockedAt,
                isViewed: true,
                progress: 1.0,
              );
            }
            return ua;
          }).toList();
          
          _state = _state.copyWith(userAchievements: updatedAchievements);
          notifyListeners();
        } else {
          debugPrint('Skipping achievement reload due to state or recent reload');
        }
      }
      
      return newlyUnlocked;
    } catch (e) {
      debugPrint('Error checking for new achievements: $e');
      // Increment failure counter
      _consecutiveCheckFailures++;
      return [];
    } finally {
      _isCheckingAchievements = false;
    }
  }
  
  /// Get an achievement by ID
  UserAchievement? getAchievementById(String id) {
    try {
      return _state.userAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}