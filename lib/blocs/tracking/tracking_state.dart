import 'package:equatable/equatable.dart';
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

class TrackingState extends Equatable {
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
  final int? lastUpdated; // Timestamp to force state changes

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
    this.lastUpdated,
  });

  // Helper getters
  bool get isInitial => status == TrackingStatus.initial;
  bool get isLoading => status == TrackingStatus.loading;
  bool get isLoaded => status == TrackingStatus.loaded;
  bool get isSaving => status == TrackingStatus.saving;
  bool get hasError => status == TrackingStatus.error;
  
  // Stats analysis
  int get cravingsResisted => cravings.where((c) => c.outcome == CravingOutcome.resisted).length;
  int get cravingsYielded => cravings.where((c) => c.outcome == CravingOutcome.smoked).length;
  double get resistanceRate => cravings.isEmpty ? 0 : cravingsResisted / cravings.length;
  
  // Recovery progress
  List<UserHealthRecovery> get achievedRecoveries => 
      userHealthRecoveries.where((r) => r.isAchieved).toList();
  
  List<UserHealthRecovery> get pendingRecoveries => 
      userHealthRecoveries.where((r) => !r.isAchieved).toList();
  
  double get healthRecoveryProgress => 
      userHealthRecoveries.isEmpty ? 0 : achievedRecoveries.length / userHealthRecoveries.length;

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
    int? lastUpdated,
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
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
  
  @override
  List<Object?> get props => [
    status, 
    smokingLogs, 
    cravings, 
    healthRecoveries,
    userHealthRecoveries,
    userStats,
    errorMessage,
    isStatsLoading,
    isLogsLoading,
    isCravingsLoading,
    isRecoveriesLoading,
    lastUpdated,
  ];
}