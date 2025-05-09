import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Status do modo desenvolvedor
enum DeveloperModeStatus {
  /// Estado inicial antes da carregamento das preferências
  initial,
  
  /// Carregando as preferências
  loading,
  
  /// Preferências carregadas com sucesso
  loaded,
  
  /// Erro ao carregar as preferências
  error
}

/// Estado de gerenciamento do modo desenvolvedor
class DeveloperModeState extends Equatable {
  /// Status atual do modo desenvolvedor
  final DeveloperModeStatus status;
  
  /// Indica se o modo desenvolvedor está ativado
  final bool isDeveloperModeEnabled;
  
  /// Indica se o aplicativo está inicializado
  final bool isInitialized;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;

  /// Construtor
  const DeveloperModeState({
    required this.status,
    required this.isDeveloperModeEnabled,
    required this.isInitialized,
    this.errorMessage,
  });

  /// Estado inicial
  factory DeveloperModeState.initial() => const DeveloperModeState(
        status: DeveloperModeStatus.initial,
        isDeveloperModeEnabled: false,
        isInitialized: false,
      );

  /// Verifica se o aplicativo está em modo de desenvolvimento
  bool get isInDevelopmentMode => kDebugMode || kProfileMode;

  /// Cria uma cópia deste estado com os campos especificados alterados
  DeveloperModeState copyWith({
    DeveloperModeStatus? status,
    bool? isDeveloperModeEnabled,
    bool? isInitialized,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeveloperModeState(
      status: status ?? this.status,
      isDeveloperModeEnabled: isDeveloperModeEnabled ?? this.isDeveloperModeEnabled,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isDeveloperModeEnabled,
        isInitialized,
        errorMessage,
      ];
}