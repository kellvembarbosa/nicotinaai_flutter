// Importações necessárias
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';

/// Estados possíveis de autenticação
enum AuthStatus {
  /// Inicial - verificando se há um usuário autenticado
  initial,
  
  /// Autenticando - processando login/registro
  authenticating,
  
  /// Autenticado - usuário está logado
  authenticated,
  
  /// Não autenticado - usuário não está logado
  unauthenticated,
  
  /// Erro - ocorreu um erro durante a autenticação
  error,
}

/// Modelo para representar o estado atual da autenticação
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isLoading;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  /// Estado inicial da autenticação
  factory AuthState.initial() => AuthState(
        status: AuthStatus.initial,
        isLoading: true,
      );

  /// Estado de autenticando (processando login/registro)
  factory AuthState.authenticating() => AuthState(
        status: AuthStatus.authenticating,
        isLoading: true,
      );

  /// Estado de autenticado (usuário logado)
  factory AuthState.authenticated(UserModel user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );

  /// Estado de não autenticado (usuário não logado)
  factory AuthState.unauthenticated() => AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );

  /// Estado de erro
  factory AuthState.error(String message) => AuthState(
        status: AuthStatus.error,
        errorMessage: message,
        isLoading: false,
      );

  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// Cria uma cópia do estado com alguns campos alterados
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      user,
      errorMessage,
      isLoading,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, '
        'errorMessage: $errorMessage, isLoading: $isLoading)';
  }
}