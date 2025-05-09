import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/features/auth/models/auth_state.dart' as legacy;
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';

/// Estados possíveis no fluxo de autenticação
enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

/// Estado de autenticação para o BLoC
class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  /// Estado inicial - quando o app está verificando se o usuário está autenticado
  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      isLoading: true,
    );
  }

  /// Estado não autenticado - quando o usuário não está logado
  factory AuthState.unauthenticated() {
    return const AuthState(
      status: AuthStatus.unauthenticated,
      isLoading: false,
    );
  }

  /// Estado durante o processo de autenticação
  factory AuthState.authenticating() {
    return const AuthState(
      status: AuthStatus.authenticating,
      isLoading: true,
    );
  }

  /// Estado autenticado - quando o usuário está logado
  factory AuthState.authenticated(UserModel user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      isLoading: false,
    );
  }

  /// Estado de erro - quando ocorre um erro no processo de autenticação
  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
      isLoading: false,
    );
  }

  /// Criar uma cópia com novos valores
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Converter do estado legado para o novo estado
  factory AuthState.fromLegacy(legacy.AuthState legacyState) {
    return AuthState(
      status: _mapLegacyStatus(legacyState.status),
      user: legacyState.user,
      errorMessage: legacyState.errorMessage,
      isLoading: legacyState.isLoading,
    );
  }

  /// Mapear o status legado para o novo status
  static AuthStatus _mapLegacyStatus(legacy.AuthStatus legacyStatus) {
    switch (legacyStatus) {
      case legacy.AuthStatus.initial:
        return AuthStatus.initial;
      case legacy.AuthStatus.unauthenticated:
        return AuthStatus.unauthenticated;
      case legacy.AuthStatus.authenticating:
        return AuthStatus.authenticating;
      case legacy.AuthStatus.authenticated:
        return AuthStatus.authenticated;
      case legacy.AuthStatus.error:
        return AuthStatus.error;
    }
  }

  /// Verificar se o usuário está autenticado
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// Verificar se há um erro
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  @override
  List<Object?> get props => [status, user, errorMessage, isLoading];
}