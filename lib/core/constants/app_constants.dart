/// Constantes utilizadas em toda a aplicação
class AppConstants {
  /// Chave para armazenamento seguro do token de autenticação
  static const String authTokenKey = 'auth_token';
  
  /// Chave para armazenamento seguro dos dados do usuário
  static const String userDataKey = 'user_data';
  
  /// Duração do timeout para operações de rede (em segundos)
  static const int networkTimeout = 30;
  
  /// Duração da sessão (em dias)
  static const int sessionDuration = 30;
  
  /// Tamanho mínimo da senha
  static const int minPasswordLength = 8;
}