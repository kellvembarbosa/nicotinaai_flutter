import 'package:nicotinaai_flutter/features/tracking/models/craving.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/models/smoking_log.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';

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