import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/features/tracking/models/craving.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
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
  final List<HealthRecovery> healthRecoveries;
  final List<UserHealthRecovery> userHealthRecoveries;
  final UserStats? userStats;
  final String? errorMessage;
  final bool isStatsLoading;
  final bool isLogsLoading;
  final bool isCravingsLoading;
  final bool isRecoveriesLoading;

  const TrackingState({
    this.status = TrackingStatus.initial,
    this.smokingLogs = const [],
    this.cravings = const [],
    this.healthRecoveries = const [],
    this.userHealthRecoveries = const [],
    this.userStats,
    this.errorMessage,
    this.isStatsLoading = false,
    this.isLogsLoading = false,
    this.isCravingsLoading = false,
    this.isRecoveriesLoading = false,
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
    List<HealthRecovery>? healthRecoveries,
    List<UserHealthRecovery>? userHealthRecoveries,
    UserStats? userStats,
    String? errorMessage,
    bool? isStatsLoading,
    bool? isLogsLoading,
    bool? isCravingsLoading,
    bool? isRecoveriesLoading,
  }) {
    return TrackingState(
      status: status ?? this.status,
      smokingLogs: smokingLogs ?? this.smokingLogs,
      cravings: cravings ?? this.cravings,
      healthRecoveries: healthRecoveries ?? this.healthRecoveries,
      userHealthRecoveries: userHealthRecoveries ?? this.userHealthRecoveries,
      userStats: userStats ?? this.userStats,
      errorMessage: errorMessage ?? this.errorMessage,
      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      isLogsLoading: isLogsLoading ?? this.isLogsLoading,
      isCravingsLoading: isCravingsLoading ?? this.isCravingsLoading,
      isRecoveriesLoading: isRecoveriesLoading ?? this.isRecoveriesLoading,
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
      
      // Atualize o estado primeiro, mas notifique depois para evitar erros durante o build
      _state = _state.copyWith(
        status: TrackingStatus.loading,
        isStatsLoading: true,
        isLogsLoading: true,
        isCravingsLoading: true,
        isRecoveriesLoading: true,
      );
      
      // Adie a notificação para evitar conflitos durante o build
      Future.microtask(() {
        if (!_isInitializing) return; // Verifique se ainda está inicializando
        notifyListeners();
      });
      
      // Primeiro carrega estatísticas do usuário e dados básicos
      await Future.wait([
        _loadUserStats(),
        _loadSmokingLogs(),
        _loadCravings(),
      ]);
      
      // Carrega recuperações de saúde somente se tiver estatísticas do usuário
      if (_state.userStats != null && _state.userStats!.lastSmokeDate != null) {
        try {
          // Primeiro carrega as recuperações de saúde existentes
          await _loadHealthRecoveries();
          
          // Depois verifica novas recuperações de saúde
          try {
            await _repository.checkHealthRecoveries();
          } catch (e) {
            print('Error checking health recoveries: $e');
            // Continue even if there's an error with checking health recoveries
          }
          
          // Recarrega as recuperações após a verificação
          await _loadHealthRecoveries();
        } catch (e) {
          print('Error in health recovery loading process: $e');
          // Continue execution and ensure we have at least empty recoveries list
          _state = _state.copyWith(
            healthRecoveries: _state.healthRecoveries.isEmpty ? [] : _state.healthRecoveries,
            userHealthRecoveries: _state.userHealthRecoveries.isEmpty ? [] : _state.userHealthRecoveries,
            isRecoveriesLoading: false,
          );
        }
      } else {
        // Ainda carrega as recuperações de saúde existentes, mas não verifica novas
        try {
          await _loadHealthRecoveries();
        } catch (e) {
          print('Error loading health recoveries: $e');
          // Ensure we have at least empty recoveries list
          _state = _state.copyWith(
            healthRecoveries: [],
            userHealthRecoveries: [],
            isRecoveriesLoading: false,
          );
        }
        print('Skipping health recovery check: User stats or last smoke date not available');
      }
      
      _state = _state.copyWith(
        status: TrackingStatus.loaded,
        isStatsLoading: false,
        isLogsLoading: false,
        isCravingsLoading: false,
        isRecoveriesLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
        isStatsLoading: false,
        isLogsLoading: false,
        isCravingsLoading: false,
        isRecoveriesLoading: false,
      );
    } finally {
      _isInitializing = false;
      // Use a microtask para adiar a notificação após o ciclo de build atual
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  // Refresh all data
  Future<void> refreshAll() async {
    try {
      _state = _state.copyWith(
        isStatsLoading: true,
        isLogsLoading: true,
        isCravingsLoading: true,
        isRecoveriesLoading: true,
      );
      
      // Adie a notificação para evitar conflitos durante o build
      Future.microtask(() {
        notifyListeners();
      });
      
      // Update stats on the server
      await _repository.updateUserStats();
      
      // Primeiro carrega as estatísticas do usuário
      await _loadUserStats();
      
      // Check for new achievements
      try {
        await _repository.checkAchievements();
      } catch (e) {
        print('Error checking achievements: $e');
        // Continue even if checkAchievements fails
      }
      
      // Verifica se temos estatísticas do usuário e data do último cigarro
      if (_state.userStats != null && _state.userStats!.lastSmokeDate != null) {
        // Check for health recoveries only if we have last smoke date
        try {
          await _repository.checkHealthRecoveries();
        } catch (e) {
          print('Error checking health recoveries: $e');
          // Continue even if checkHealthRecoveries fails
        }
      } else {
        print('Skipping health recovery check: User stats or last smoke date not available');
      }
      
      // Reload user stats once more to get the most updated data
      try {
        await _loadUserStats();
      } catch (e) {
        print('Error refreshing user stats: $e');
      }
      
      // Load remaining data in parallel
      await Future.wait([
        _loadSmokingLogs(),
        _loadCravings(),
        _loadHealthRecoveries(),
      ]);
      
      _state = _state.copyWith(
        status: TrackingStatus.loaded,
        isStatsLoading: false,
        isLogsLoading: false,
        isCravingsLoading: false,
        isRecoveriesLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: e.toString(),
        isStatsLoading: false,
        isLogsLoading: false,
        isCravingsLoading: false,
        isRecoveriesLoading: false,
      );
    } finally {
      // Use a microtask para adiar a notificação após o ciclo de build atual
      Future.microtask(() {
        notifyListeners();
      });
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
  
  // Health Recoveries Methods
  Future<void> _loadHealthRecoveries() async {
    try {
      List<HealthRecovery> recoveries = [];
      List<UserHealthRecovery> userRecoveries = [];
      
      try {
        recoveries = await _repository.getHealthRecoveries();
      } catch (e) {
        print('Error getting health recoveries: $e');
        // Continue with empty recoveries list
        recoveries = [];
      }
      
      try {
        userRecoveries = await _repository.getUserHealthRecoveries();
      } catch (e) {
        print('Error getting user health recoveries: $e');
        // Continue with empty user recoveries list
        userRecoveries = [];
      }
      
      _state = _state.copyWith(
        healthRecoveries: recoveries,
        userHealthRecoveries: userRecoveries,
        isRecoveriesLoading: false,
      );
    } catch (e) {
      print('Error in _loadHealthRecoveries method: $e');
      _state = _state.copyWith(
        errorMessage: 'Failed to load health recoveries: ${e.toString()}',
        isRecoveriesLoading: false,
        // Ensure we have at least empty lists even in case of error
        healthRecoveries: [],
        userHealthRecoveries: [],
      );
    }
  }
  
  Future<void> loadHealthRecoveries() async {
    try {
      _state = _state.copyWith(isRecoveriesLoading: true);
      
      // Adie a notificação para evitar conflitos durante o build
      Future.microtask(() {
        notifyListeners();
      });
      
      // Primeiro verifica se temos estatísticas do usuário e data do último cigarro
      UserStats? userStats;
      try {
        userStats = await _repository.getUserStats();
      } catch (e) {
        print('Error getting user stats: $e');
        // Continue with null user stats, we'll handle this below
      }
      
      // Só verifica recoveries se tivermos as estatísticas do usuário e uma data de último cigarro
      if (userStats != null && userStats.lastSmokeDate != null) {
        // Wrap in try-catch to prevent cascading errors
        try {
          await _repository.checkHealthRecoveries();
        } catch (e) {
          print('Error checking health recoveries: $e');
          // Continue even if checkHealthRecoveries fails
        }
      } else {
        print('Skipping health recovery check: User stats or last smoke date not available');
      }
      
      try {
        await _loadHealthRecoveries();
      } catch (e) {
        print('Error loading health recoveries: $e');
        // Ensure we have at least empty lists
        _state = _state.copyWith(
          healthRecoveries: [],
          userHealthRecoveries: [],
          isRecoveriesLoading: false,
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: 'Failed to load health recoveries: ${e.toString()}',
        isRecoveriesLoading: false,
        // Ensure we have at least empty lists even in case of error
        healthRecoveries: _state.healthRecoveries.isEmpty ? [] : _state.healthRecoveries,
        userHealthRecoveries: _state.userHealthRecoveries.isEmpty ? [] : _state.userHealthRecoveries,
      );
    } finally {
      // Use a microtask para adiar a notificação após o ciclo de build atual
      Future.microtask(() {
        notifyListeners();
      });
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