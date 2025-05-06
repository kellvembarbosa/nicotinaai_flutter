import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/features/tracking/models/craving.dart';
import 'package:nicotinaai_flutter/features/tracking/models/smoking_log.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/features/tracking/repositories/tracking_repository.dart';

enum TrackingStatus {
  initial,
  loading,
  loaded,
  saving,
  error,
}

class TrackingState {
  final TrackingStatus status;
  final List<SmokingLog> smokingLogs;
  final List<Craving> cravings;
  final UserStats? userStats;
  final String? errorMessage;
  final bool isStatsLoading;
  final bool isLogsLoading;
  final bool isCravingsLoading;

  const TrackingState({
    this.status = TrackingStatus.initial,
    this.smokingLogs = const [],
    this.cravings = const [],
    this.userStats,
    this.errorMessage,
    this.isStatsLoading = false,
    this.isLogsLoading = false,
    this.isCravingsLoading = false,
  });

  // Helper getters
  bool get isInitial => status == TrackingStatus.initial;
  bool get isLoading => status == TrackingStatus.loading;
  bool get isLoaded => status == TrackingStatus.loaded;
  bool get isSaving => status == TrackingStatus.saving;
  bool get hasError => status == TrackingStatus.error;

  // Copy with
  TrackingState copyWith({
    TrackingStatus? status,
    List<SmokingLog>? smokingLogs,
    List<Craving>? cravings,
    UserStats? userStats,
    String? errorMessage,
    bool? isStatsLoading,
    bool? isLogsLoading,
    bool? isCravingsLoading,
  }) {
    return TrackingState(
      status: status ?? this.status,
      smokingLogs: smokingLogs ?? this.smokingLogs,
      cravings: cravings ?? this.cravings,
      userStats: userStats ?? this.userStats,
      errorMessage: errorMessage ?? this.errorMessage,
      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      isLogsLoading: isLogsLoading ?? this.isLogsLoading,
      isCravingsLoading: isCravingsLoading ?? this.isCravingsLoading,
    );
  }
}

class TrackingProvider extends ChangeNotifier {
  final TrackingRepository _repository;
  
  TrackingState _state = const TrackingState();
  
  TrackingProvider({
    required TrackingRepository repository,
  }) : _repository = repository;
  
  // Getter for the state
  TrackingState get state => _state;
  
  // Loading flag to prevent multiple simultaneous initializations
  bool _isInitializing = false;

  // Initialize tracking data
  Future<void> initialize() async {
    if (_isInitializing) return;
    
    try {
      _isInitializing = true;
      
      _state = _state.copyWith(
        status: TrackingStatus.loading,
        isStatsLoading: true,
        isLogsLoading: true,
        isCravingsLoading: true,
      );
      notifyListeners();
      
      // Load data in parallel
      await Future.wait([
        _loadUserStats(),
        _loadSmokingLogs(),
        _loadCravings(),
      ]);
      
      _state = _state.copyWith(
        status: TrackingStatus.loaded,
        isStatsLoading: false,
        isLogsLoading: false,
        isCravingsLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
        isStatsLoading: false,
        isLogsLoading: false,
        isCravingsLoading: false,
      );
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refreshAll() async {
    try {
      _state = _state.copyWith(
        isStatsLoading: true,
        isLogsLoading: true,
        isCravingsLoading: true,
      );
      notifyListeners();
      
      // Update stats on the server
      await _repository.updateUserStats();
      
      // Check for new achievements and health recoveries
      await Future.wait([
        _repository.checkAchievements(),
        _repository.checkHealthRecoveries(),
      ]);
      
      // Load data in parallel
      await Future.wait([
        _loadUserStats(),
        _loadSmokingLogs(),
        _loadCravings(),
      ]);
      
      _state = _state.copyWith(
        status: TrackingStatus.loaded,
        isStatsLoading: false,
        isLogsLoading: false,
        isCravingsLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: e.toString(),
        isStatsLoading: false,
        isLogsLoading: false,
        isCravingsLoading: false,
      );
    } finally {
      notifyListeners();
    }
  }

  // Smoking Logs Methods
  Future<void> _loadSmokingLogs() async {
    try {
      final logs = await _repository.getSmokingLogs();
      _state = _state.copyWith(
        smokingLogs: logs,
        isLogsLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: 'Failed to load smoking logs: ${e.toString()}',
        isLogsLoading: false,
      );
    }
  }

  Future<void> refreshSmokingLogs() async {
    try {
      _state = _state.copyWith(isLogsLoading: true);
      notifyListeners();
      
      await _loadSmokingLogs();
    } finally {
      notifyListeners();
    }
  }

  Future<void> addSmokingLog(SmokingLog log) async {
    try {
      _state = _state.copyWith(status: TrackingStatus.saving);
      notifyListeners();
      
      final addedLog = await _repository.addSmokingLog(log);
      
      // Update the local list
      final updatedLogs = [addedLog, ..._state.smokingLogs];
      
      _state = _state.copyWith(
        status: TrackingStatus.loaded,
        smokingLogs: updatedLogs,
      );
      
      // Update stats on the server
      await _repository.updateUserStats();
      
      // Refresh stats locally
      await _loadUserStats();
    } catch (e) {
      _state = _state.copyWith(
        status: TrackingStatus.error,
        errorMessage: 'Failed to add smoking log: ${e.toString()}',
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteSmokingLog(String logId) async {
    try {
      _state = _state.copyWith(status: TrackingStatus.saving);
      notifyListeners();
      
      await _repository.deleteSmokingLog(logId);
      
      // Update the local list
      final updatedLogs = _state.smokingLogs
          .where((log) => log.id != logId)
          .toList();
      
      _state = _state.copyWith(
        status: TrackingStatus.loaded,
        smokingLogs: updatedLogs,
      );
      
      // Update stats on the server
      await _repository.updateUserStats();
      
      // Refresh stats locally
      await _loadUserStats();
    } catch (e) {
      _state = _state.copyWith(
        status: TrackingStatus.error,
        errorMessage: 'Failed to delete smoking log: ${e.toString()}',
      );
    } finally {
      notifyListeners();
    }
  }

  // Cravings Methods
  Future<void> _loadCravings() async {
    try {
      final cravings = await _repository.getCravings();
      _state = _state.copyWith(
        cravings: cravings,
        isCravingsLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: 'Failed to load cravings: ${e.toString()}',
        isCravingsLoading: false,
      );
    }
  }

  Future<void> refreshCravings() async {
    try {
      _state = _state.copyWith(isCravingsLoading: true);
      notifyListeners();
      
      await _loadCravings();
    } finally {
      notifyListeners();
    }
  }

  Future<void> addCraving(Craving craving) async {
    try {
      _state = _state.copyWith(status: TrackingStatus.saving);
      notifyListeners();
      
      final addedCraving = await _repository.addCraving(craving);
      
      // Update the local list
      final updatedCravings = [addedCraving, ..._state.cravings];
      
      _state = _state.copyWith(
        status: TrackingStatus.loaded,
        cravings: updatedCravings,
      );
      
      // Update stats on the server
      await _repository.updateUserStats();
      
      // Check for achievements (might have resisted a craving)
      await _repository.checkAchievements();
      
      // Refresh stats locally
      await _loadUserStats();
    } catch (e) {
      _state = _state.copyWith(
        status: TrackingStatus.error,
        errorMessage: 'Failed to add craving: ${e.toString()}',
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateCraving(Craving craving) async {
    try {
      _state = _state.copyWith(status: TrackingStatus.saving);
      notifyListeners();
      
      final updatedCraving = await _repository.updateCraving(craving);
      
      // Update the local list
      final updatedCravings = _state.cravings.map((c) {
        return c.id == craving.id ? updatedCraving : c;
      }).toList();
      
      _state = _state.copyWith(
        status: TrackingStatus.loaded,
        cravings: updatedCravings,
      );
      
      // Update stats on the server
      await _repository.updateUserStats();
      
      // Refresh stats locally
      await _loadUserStats();
    } catch (e) {
      _state = _state.copyWith(
        status: TrackingStatus.error,
        errorMessage: 'Failed to update craving: ${e.toString()}',
      );
    } finally {
      notifyListeners();
    }
  }

  // User Stats Methods
  Future<void> _loadUserStats() async {
    try {
      final stats = await _repository.getUserStats();
      _state = _state.copyWith(
        userStats: stats,
        isStatsLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: 'Failed to load user stats: ${e.toString()}',
        isStatsLoading: false,
      );
    }
  }

  Future<void> refreshUserStats() async {
    try {
      _state = _state.copyWith(isStatsLoading: true);
      notifyListeners();
      
      // Update stats on the server
      await _repository.updateUserStats();
      
      // Load updated stats
      await _loadUserStats();
    } finally {
      notifyListeners();
    }
  }

  // Error handling
  void clearError() {
    if (_state.hasError) {
      _state = _state.copyWith(
        status: _state.isLoaded ? TrackingStatus.loaded : TrackingStatus.initial,
        errorMessage: null,
      );
      notifyListeners();
    }
  }
}