import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/features/settings/models/user_settings_model.dart';

/// Enum para representar o status das operações de configuração
enum SettingsStatus {
  initial,
  loading,
  success,
  failure,
}

/// Estado para o BLoC de configurações
class SettingsState extends Equatable {
  /// Status atual da operação
  final SettingsStatus status;
  
  /// Configurações do usuário
  final UserSettingsModel settings;
  
  /// Mensagem de erro (se houver)
  final String? errorMessage;
  
  /// Mensagem de sucesso (se houver)
  final String? successMessage;
  
  /// Status específicos para diferentes operações
  final bool isChangePasswordLoading;
  final bool isChangePasswordSuccess;
  final bool isResetPasswordLoading;
  final bool isResetPasswordSuccess;
  final bool isDeleteAccountLoading;
  
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = const UserSettingsModel(),
    this.errorMessage,
    this.successMessage,
    this.isChangePasswordLoading = false,
    this.isChangePasswordSuccess = false,
    this.isResetPasswordLoading = false,
    this.isResetPasswordSuccess = false,
    this.isDeleteAccountLoading = false,
  });
  
  /// Estado inicial para o BLoC
  factory SettingsState.initial() {
    return const SettingsState();
  }
  
  /// Verifica se o estado contém erro
  bool get hasError => errorMessage != null;
  
  /// Verifica se está carregando
  bool get isLoading => status == SettingsStatus.loading;
  
  /// Verifica se a operação foi bem-sucedida
  bool get isSuccess => status == SettingsStatus.success;
  
  /// Cria uma cópia do estado com valores opcionalmente substituídos
  SettingsState copyWith({
    SettingsStatus? status,
    UserSettingsModel? settings,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool? isChangePasswordLoading,
    bool? isChangePasswordSuccess,
    bool? isResetPasswordLoading,
    bool? isResetPasswordSuccess,
    bool? isDeleteAccountLoading,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isChangePasswordLoading: isChangePasswordLoading ?? this.isChangePasswordLoading,
      isChangePasswordSuccess: isChangePasswordSuccess ?? this.isChangePasswordSuccess,
      isResetPasswordLoading: isResetPasswordLoading ?? this.isResetPasswordLoading,
      isResetPasswordSuccess: isResetPasswordSuccess ?? this.isResetPasswordSuccess,
      isDeleteAccountLoading: isDeleteAccountLoading ?? this.isDeleteAccountLoading,
    );
  }
  
  @override
  List<Object?> get props => [
    status,
    settings,
    errorMessage,
    successMessage,
    isChangePasswordLoading,
    isChangePasswordSuccess,
    isResetPasswordLoading,
    isResetPasswordSuccess,
    isDeleteAccountLoading,
  ];
}
