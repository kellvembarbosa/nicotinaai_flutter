/// Exceção personalizada para erros de autenticação
class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AuthException(
    this.message, {
    this.code,
    this.originalError,
  });

  /// Cria uma exceção a partir do erro do Supabase
  factory AuthException.fromSupabaseError(dynamic error) {
    // Mensagens e códigos de erro comuns do Supabase
    if (error is Map<String, dynamic>) {
      final String? message = error['message'] as String?;
      final String? code = error['code'] as String?;
      
      if (message != null) {
        return AuthException(message, code: code, originalError: error);
      }
    }

    String errorMessage = error.toString();
    String? errorCode;

    // Tratamento de mensagens de erro específicas
    if (errorMessage.contains('email address is not confirmed')) {
      return AuthException(
        'E-mail não confirmado. Verifique sua caixa de entrada.',
        code: 'email-not-confirmed',
        originalError: error,
      );
    } else if (errorMessage.contains('Invalid login credentials')) {
      return AuthException(
        'Credenciais inválidas. Verifique seu e-mail e senha.',
        code: 'invalid-credentials',
        originalError: error,
      );
    } else if (errorMessage.contains('User already registered')) {
      return AuthException(
        'E-mail já cadastrado. Tente fazer login ou recuperar a senha.',
        code: 'email-already-in-use',
        originalError: error,
      );
    } else if (errorMessage.contains('network')) {
      return AuthException(
        'Erro de conexão. Verifique sua internet e tente novamente.',
        code: 'network-error',
        originalError: error,
      );
    }

    // Erro genérico
    return AuthException(
      'Ocorreu um erro na autenticação. Tente novamente mais tarde.',
      code: errorCode,
      originalError: error,
    );
  }

  @override
  String toString() => 'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}