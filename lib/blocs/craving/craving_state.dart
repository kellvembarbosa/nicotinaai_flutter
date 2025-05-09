import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';

/// Status dos cravings
enum CravingStatus {
  initial,
  loading,
  loaded,
  saving,
  error,
}

/// Estado do BLoC de cravings
class CravingState extends Equatable {
  final CravingStatus status;
  final List<CravingModel> cravings;
  final String? errorMessage;
  final bool isLoading;
  final int? cravingCount;

  const CravingState({
    this.status = CravingStatus.initial,
    this.cravings = const [],
    this.errorMessage,
    this.isLoading = false,
    this.cravingCount,
  });

  /// Estado inicial
  factory CravingState.initial() {
    return const CravingState(
      status: CravingStatus.initial,
      cravings: [],
    );
  }

  /// Estado de carregamento
  factory CravingState.loading() {
    return const CravingState(
      status: CravingStatus.loading,
      isLoading: true,
    );
  }

  /// Estado carregado
  factory CravingState.loaded(List<CravingModel> cravings) {
    return CravingState(
      status: CravingStatus.loaded,
      cravings: cravings,
      isLoading: false,
    );
  }

  /// Estado de salvamento
  factory CravingState.saving(List<CravingModel> cravings) {
    return CravingState(
      status: CravingStatus.saving,
      cravings: cravings,
      isLoading: true,
    );
  }

  /// Estado de erro
  factory CravingState.error(String message, {List<CravingModel> cravings = const []}) {
    return CravingState(
      status: CravingStatus.error,
      errorMessage: message,
      cravings: cravings,
      isLoading: false,
    );
  }

  /// Getters auxiliares
  bool get hasCravings => cravings.isNotEmpty;
  bool get hasError => status == CravingStatus.error && errorMessage != null;
  
  /// Filtros de cravings
  List<CravingModel> get pendingCravings => 
      cravings.where((c) => c.syncStatus == SyncStatus.pending).toList();
  
  List<CravingModel> get failedCravings => 
      cravings.where((c) => c.syncStatus == SyncStatus.failed).toList();
  
  /// Análise de cravings
  List<CravingModel> get resistedCravings => 
      cravings.where((c) => c.resisted == true).toList();
  
  List<CravingModel> get yieldedCravings => 
      cravings.where((c) => c.resisted == false).toList();
  
  double get resistanceRate => 
      cravings.isEmpty ? 0 : resistedCravings.length / cravings.length;
  
  /// Métricas
  int get cravingsInLastDay {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return cravings.where((c) => c.timestamp.isAfter(yesterday)).length;
  }
  
  int get cravingsInLastWeek {
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    return cravings.where((c) => c.timestamp.isAfter(lastWeek)).length;
  }
  
  /// Método para criar uma cópia com novos valores
  CravingState copyWith({
    CravingStatus? status,
    List<CravingModel>? cravings,
    String? errorMessage,
    bool? isLoading,
    int? cravingCount,
  }) {
    return CravingState(
      status: status ?? this.status,
      cravings: cravings ?? this.cravings,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      cravingCount: cravingCount ?? this.cravingCount,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    cravings, 
    errorMessage, 
    isLoading,
    cravingCount,
  ];
}