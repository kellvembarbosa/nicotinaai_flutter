import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';
import 'package:nicotinaai_flutter/features/tracking/models/craving.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/models/smoking_log.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';

enum TrackingStatus { initial, loading, loaded, saving, error }

class TrackingState extends Equatable {
  // Global state
  final TrackingStatus status;
  final UserStats? userStats;
  final String? errorMessage;
  final int? lastUpdated; // Timestamp to force state changes
  
  // Original tracking models
  final List<SmokingLog> smokingLogs;
  final List<Craving> cravings;
  final List<HealthRecovery> healthRecoveries;
  final List<UserHealthRecovery> userHealthRecoveries;
  
  // Loading states
  final bool isStatsLoading;
  final bool isLogsLoading;
  final bool isCravingsLoading;
  final bool isRecoveriesLoading;
  
  // Added for CravingBloc unification
  final List<CravingModel> unifiedCravings;
  final int? cravingCount;
  
  // Added for SmokingRecordBloc unification
  final List<SmokingRecordModel> smokingRecords;
  final int? recordCount;

  const TrackingState({
    // Global state
    this.status = TrackingStatus.initial,
    this.userStats,
    this.errorMessage,
    this.lastUpdated,
    
    // Original tracking models
    this.smokingLogs = const [],
    this.cravings = const [],
    this.healthRecoveries = const [],
    this.userHealthRecoveries = const [],
    
    // Loading states
    this.isStatsLoading = false,
    this.isLogsLoading = false,
    this.isCravingsLoading = false,
    this.isRecoveriesLoading = false,
    
    // Added for CravingBloc unification
    this.unifiedCravings = const [],
    this.cravingCount,
    
    // Added for SmokingRecordBloc unification
    this.smokingRecords = const [],
    this.recordCount,
  });

  // Global helper getters
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
  List<UserHealthRecovery> get achievedRecoveries => userHealthRecoveries.where((r) => r.isAchieved).toList();
  List<UserHealthRecovery> get pendingRecoveries => userHealthRecoveries.where((r) => !r.isAchieved).toList();
  double get healthRecoveryProgress => userHealthRecoveries.isEmpty ? 0 : achievedRecoveries.length / userHealthRecoveries.length;

  // CravingModel getters (from CravingBloc)
  List<CravingModel> get pendingCravings => unifiedCravings.where((c) => c.syncStatus == SyncStatus.pending).toList();
  List<CravingModel> get failedCravings => unifiedCravings.where((c) => c.syncStatus == SyncStatus.failed).toList();
  List<CravingModel> get resistedCravings => unifiedCravings.where((c) => c.resisted).toList();
  List<CravingModel> get yieldedCravings => unifiedCravings.where((c) => !c.resisted).toList();
  
  // SmokingRecordModel getters (from SmokingRecordBloc)
  List<SmokingRecordModel> get pendingRecords => smokingRecords.where((r) => r.syncStatus == SyncStatus.pending).toList();
  List<SmokingRecordModel> get failedRecords => smokingRecords.where((r) => r.syncStatus == SyncStatus.failed).toList();

  // Copy with
  TrackingState copyWith({
    // Global state
    TrackingStatus? status,
    UserStats? userStats,
    String? errorMessage,
    int? lastUpdated,
    
    // Original tracking models
    List<SmokingLog>? smokingLogs,
    List<Craving>? cravings,
    List<HealthRecovery>? healthRecoveries,
    List<UserHealthRecovery>? userHealthRecoveries,
    
    // Loading states
    bool? isStatsLoading,
    bool? isLogsLoading,
    bool? isCravingsLoading,
    bool? isRecoveriesLoading,
    
    // Added for CravingBloc unification
    List<CravingModel>? unifiedCravings,
    int? cravingCount,
    
    // Added for SmokingRecordBloc unification
    List<SmokingRecordModel>? smokingRecords,
    int? recordCount,
  }) {
    return TrackingState(
      // Global state
      status: status ?? this.status,
      userStats: userStats ?? this.userStats,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      
      // Original tracking models
      smokingLogs: smokingLogs ?? this.smokingLogs,
      cravings: cravings ?? this.cravings,
      healthRecoveries: healthRecoveries ?? this.healthRecoveries,
      userHealthRecoveries: userHealthRecoveries ?? this.userHealthRecoveries,
      
      // Loading states
      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      isLogsLoading: isLogsLoading ?? this.isLogsLoading,
      isCravingsLoading: isCravingsLoading ?? this.isCravingsLoading,
      isRecoveriesLoading: isRecoveriesLoading ?? this.isRecoveriesLoading,
      
      // Added for CravingBloc unification
      unifiedCravings: unifiedCravings ?? this.unifiedCravings,
      cravingCount: cravingCount ?? this.cravingCount,
      
      // Added for SmokingRecordBloc unification
      smokingRecords: smokingRecords ?? this.smokingRecords,
      recordCount: recordCount ?? this.recordCount,
    );
  }

  @override
  List<Object?> get props => [
    // Global state
    status,
    userStats,
    errorMessage,
    lastUpdated,
    
    // Original tracking models
    smokingLogs,
    cravings,
    healthRecoveries,
    userHealthRecoveries,
    
    // Loading states
    isStatsLoading,
    isLogsLoading,
    isCravingsLoading,
    isRecoveriesLoading,
    
    // Added for CravingBloc unification
    unifiedCravings,
    cravingCount,
    
    // Added for SmokingRecordBloc unification
    smokingRecords,
    recordCount,
  ];
}
