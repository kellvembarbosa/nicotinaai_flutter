import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart'; // Import for SyncStatus enum
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';

/// Status dos registros de fumo
enum SmokingRecordStatus {
  initial,
  loading,
  loaded,
  saving,
  error,
}

/// Estado do BLoC de registros de fumo
class SmokingRecordState extends Equatable {
  final SmokingRecordStatus status;
  final List<SmokingRecordModel> records;
  final String? errorMessage;
  final bool isLoading;
  final int? recordCount;

  const SmokingRecordState({
    this.status = SmokingRecordStatus.initial,
    this.records = const [],
    this.errorMessage,
    this.isLoading = false,
    this.recordCount,
  });

  /// Estado inicial
  factory SmokingRecordState.initial() {
    return const SmokingRecordState(
      status: SmokingRecordStatus.initial,
      records: [],
    );
  }

  /// Estado de carregamento
  factory SmokingRecordState.loading() {
    return const SmokingRecordState(
      status: SmokingRecordStatus.loading,
      isLoading: true,
    );
  }

  /// Estado carregado
  factory SmokingRecordState.loaded(List<SmokingRecordModel> records) {
    return SmokingRecordState(
      status: SmokingRecordStatus.loaded,
      records: records,
      isLoading: false,
    );
  }

  /// Estado de salvamento
  factory SmokingRecordState.saving(List<SmokingRecordModel> records) {
    return SmokingRecordState(
      status: SmokingRecordStatus.saving,
      records: records,
      isLoading: true,
    );
  }

  /// Estado de erro
  factory SmokingRecordState.error(String message, {List<SmokingRecordModel> records = const []}) {
    return SmokingRecordState(
      status: SmokingRecordStatus.error,
      errorMessage: message,
      records: records,
      isLoading: false,
    );
  }

  /// Getters auxiliares
  bool get hasRecords => records.isNotEmpty;
  bool get hasError => status == SmokingRecordStatus.error && errorMessage != null;
  
  /// Filtros de registros
  List<SmokingRecordModel> get pendingRecords => 
      records.where((r) => r.syncStatus == SyncStatus.pending).toList();
  
  List<SmokingRecordModel> get failedRecords => 
      records.where((r) => r.syncStatus == SyncStatus.failed).toList();
  
  /// Métricas
  int get recordsInLastDay {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return records.where((r) => r.timestamp.isAfter(yesterday)).length;
  }
  
  int get recordsInLastWeek {
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    return records.where((r) => r.timestamp.isAfter(lastWeek)).length;
  }
  
  /// Método para criar uma cópia com novos valores
  SmokingRecordState copyWith({
    SmokingRecordStatus? status,
    List<SmokingRecordModel>? records,
    String? errorMessage,
    bool? isLoading,
    int? recordCount,
  }) {
    return SmokingRecordState(
      status: status ?? this.status,
      records: records ?? this.records,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      recordCount: recordCount ?? this.recordCount,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    records, 
    errorMessage, 
    isLoading,
    recordCount,
  ];
}