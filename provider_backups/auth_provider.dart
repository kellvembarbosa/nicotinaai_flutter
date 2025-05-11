import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/core/exceptions/auth_exception.dart' as app_exceptions;
import 'package:nicotinaai_flutter/features/auth/models/auth_state.dart';
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';
import 'package:nicotinaai_flutter/features/home/providers/craving_provider.dart';
import 'package:nicotinaai_flutter/features/home/providers/smoking_record_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:nicotinaai_flutter/services/analytics_service.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';
import 'package:nicotinaai_flutter/services/storage_service.dart';

/// Provider para gerenciamento do estado de autenticação
/// Implementa ChangeNotifier para ser usado como refreshListenable no GoRouter
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  /// Estado atual da autenticação
  AuthState _state = AuthState.initial();
  
  /// Construtor que recebe o repositório de autenticação
  AuthProvider({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository {
    _checkCurrentAuthState();
  }
  
  /// Getter para o estado atual
  AuthState get state => _state;
  
  /// Getter para o usuário atual
  UserModel? get currentUser => _state.user;
  
  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => _state.isAuthenticated;
  
  /// Verifica o estado atual de autenticação
  Future<void> _checkCurrentAuthState() async {
    try {
      // Define o estado como carregando
      _state = AuthState.initial();
      notifyListeners();
      
      print('🔍 [AuthProvider] Verificando estado de autenticação');
      
      // Verifica se há uma sessão válida
      final hasSession = await _authRepository.hasSession();
      
      if (!hasSession) {
        print('🔒 [AuthProvider] Nenhuma sessão encontrada');
        _state = AuthState.unauthenticated();
        notifyListeners();
        return;
      }
      
      print('🔓 [AuthProvider] Sessão encontrada');
      
      // Obtém o usuário da sessão atual (Supabase já restaura automaticamente)
      final user = await _authRepository.getSession();
      
      if (user != null) {
        print('👤 [AuthProvider] Usuário autenticado: ${user.email}');
        _state = AuthState.authenticated(user);
      } else {
        print('⚠️ [AuthProvider] Sessão encontrada, mas sem usuário válido');
        _state = AuthState.unauthenticated();
      }
    } catch (e) {
      print('❌ [AuthProvider] Erro ao verificar autenticação: $e');
      _state = AuthState.unauthenticated();
    } finally {
      notifyListeners();
    }
  }
  
  /// Realiza o login com e-mail e senha
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('🔄 [AuthProvider] Início do login: ${DateTime.now()}');
      _state = AuthState.authenticating();
      notifyListeners();
      
      final user = await _authRepository.signInWithEmailAndPassword(
        email,
        password,
      );
      
      print('✅ [AuthProvider] Usuário autenticado: ${user.email}');
      _state = AuthState.authenticated(user);
      print('📊 [AuthProvider] Estado atualizado para autenticado: ${DateTime.now()}');
      
      // Salvar o token FCM para o usuário que acabou de logar
      await NotificationService().saveFcmTokenAfterLogin();
      print('🔔 [AuthProvider] Token FCM salvo após login');
      
      // Track login event in analytics
      try {
        await AnalyticsService().logLogin(method: 'email');
        await AnalyticsService().setUserProperties(
          userId: user.id,
          email: user.email,
        );
        print('📊 [AuthProvider] Login event tracked in analytics');
      } catch (analyticsError) {
        print('⚠️ [AuthProvider] Failed to track login event: $analyticsError');
      }
      
      // Forçar redirecionamento imediato para garantir navegação adequada
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Esta chamada é vazia, mas força um rebuild que ativa o sistema de rotas
        notifyListeners();
      });
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthProvider] Erro na autenticação: ${error.message}');
      _state = AuthState.error(error.message);
    } finally {
      notifyListeners();
      print('🔔 [AuthProvider] Notificação enviada após login: ${DateTime.now()}');
    }
  }
  
  /// Realiza o registro com e-mail e senha
  Future<void> signUpWithEmailAndPassword(
    String email, 
    String password, 
    {String? name}
  ) async {
    try {
      print('🔄 [AuthProvider] Iniciando registro');
      _state = AuthState.authenticating();
      notifyListeners();
      
      final user = await _authRepository.signUpWithEmailAndPassword(
        email,
        password,
        name: name,
      );
      
      print('✅ [AuthProvider] Usuário registrado com sucesso: ${user.email}');
      _state = AuthState.authenticated(user);
      
      // Salvar o token FCM para o usuário recém-registrado
      await NotificationService().saveFcmTokenAfterLogin();
      print('🔔 [AuthProvider] Token FCM salvo após registro');
      
      // Track signup event in analytics
      try {
        await AnalyticsService().logSignUp(method: 'email');
        await AnalyticsService().setUserProperties(
          userId: user.id,
          email: user.email,
        );
        print('📊 [AuthProvider] Signup event tracked in analytics');
      } catch (analyticsError) {
        print('⚠️ [AuthProvider] Failed to track signup event: $analyticsError');
      }
      
      // Forçar redirecionamento imediato para garantir navegação adequada
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Esta chamada é vazia, mas força um rebuild que ativa o sistema de rotas
        notifyListeners();
      });
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthProvider] Erro no registro: ${error.message}');
      _state = AuthState.error(error.message);
    } finally {
      notifyListeners();
    }
  }
  
  /// Realiza o logout
  Future<void> signOut() async {
    try {
      print('🔄 [AuthProvider] Iniciando logout');
      
      // Clear analytics data before signing out
      try {
        await AnalyticsService().clearUserData();
        print('🧹 [AuthProvider] Analytics data cleared');
      } catch (analyticsError) {
        print('⚠️ [AuthProvider] Failed to clear analytics data: $analyticsError');
      }
      
      // Limpar dados locais dos providers
      try {
        // Importar os providers necessários
        final cravingProvider = _getCravingProvider();
        final smokingRecordProvider = _getSmokingRecordProvider();
        final trackingProvider = _getTrackingProvider();
        
        // Agora com os métodos implementados, podemos limpar os dados
        if (cravingProvider != null) {
          cravingProvider.clearCravings();
          print('🧹 [AuthProvider] Cravings data cleared');
        }
        
        if (smokingRecordProvider != null) {
          smokingRecordProvider.clearRecords();
          print('🧹 [AuthProvider] Smoking records data cleared');
        }
        
        if (trackingProvider != null) {
          trackingProvider.resetStats();
          print('🧹 [AuthProvider] Tracking stats reset');
        }
      } catch (providersError) {
        print('⚠️ [AuthProvider] Failed to clear providers data: $providersError');
      }
      
      // Limpar dados do storage seguro
      try {
        final storageService = StorageService();
        await storageService.clearAll();
        print('🧹 [AuthProvider] Secure storage cleared');
      } catch (storageError) {
        print('⚠️ [AuthProvider] Failed to clear secure storage: $storageError');
      }
      
      await _authRepository.signOut();
      print('✅ [AuthProvider] Logout realizado com sucesso');
      _state = AuthState.unauthenticated();
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthProvider] Erro no logout: ${error.message}');
      _state = AuthState.error(error.message);
    } finally {
      notifyListeners();
    }
  }
  
  // Métodos auxiliares para obter instâncias dos providers
  // Nota: Estes métodos são simplificados e devem ser adaptados para uma
  // solução de injeção de dependência adequada no futuro
  CravingProvider? _getCravingProvider() {
    try {
      return null; // Deve ser implementado com uma solução real de DI
    } catch (e) {
      print('⚠️ [AuthProvider] Erro ao obter CravingProvider: $e');
      return null;
    }
  }
  
  SmokingRecordProvider? _getSmokingRecordProvider() {
    try {
      return null; // Deve ser implementado com uma solução real de DI
    } catch (e) {
      print('⚠️ [AuthProvider] Erro ao obter SmokingRecordProvider: $e');
      return null;
    }
  }
  
  TrackingProvider? _getTrackingProvider() {
    try {
      return null; // Deve ser implementado com uma solução real de DI
    } catch (e) {
      print('⚠️ [AuthProvider] Erro ao obter TrackingProvider: $e');
      return null;
    }
  }
  
  /// Força a verificação do estado atual de autenticação
  Future<void> refreshAuthState() async {
    print('🔄 [AuthProvider] Atualizando estado de autenticação');
    await _checkCurrentAuthState();
  }
  
  /// Envia e-mail para recuperação de senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      print('🔄 [AuthProvider] Enviando e-mail de recuperação de senha');
      _state = _state.copyWith(isLoading: true);
      notifyListeners();
      
      await _authRepository.sendPasswordResetEmail(email);
      
      print('✉️ [AuthProvider] E-mail de recuperação enviado');
      _state = _state.copyWith(isLoading: false);
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthProvider] Erro ao enviar e-mail: ${error.message}');
      _state = AuthState.error(error.message);
    } finally {
      notifyListeners();
    }
  }
  
  /// Atualiza os dados do usuário
  Future<void> updateUserData({
    String? name,
    String? avatarUrl,
    String? currencyCode,
    String? currencySymbol,
    String? currencyLocale,
  }) async {
    try {
      print('🔄 [AuthProvider] Atualizando dados do usuário');
      _state = _state.copyWith(isLoading: true);
      notifyListeners();
      
      final updatedUser = await _authRepository.updateUserData(
        name: name,
        avatarUrl: avatarUrl,
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
        currencyLocale: currencyLocale,
      );
      
      print('✅ [AuthProvider] Dados atualizados com sucesso');
      _state = AuthState.authenticated(updatedUser);
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthProvider] Erro ao atualizar dados: ${error.message}');
      _state = AuthState.error(error.message);
    } finally {
      notifyListeners();
    }
  }
  
  /// Atualiza o perfil completo do usuário
  Future<void> updateUserProfile(UserModel user) async {
    try {
      print('🔄 [AuthProvider] Atualizando perfil do usuário');
      _state = _state.copyWith(isLoading: true);
      notifyListeners();
      
      final updatedUser = await _authRepository.updateUserProfile(user);
      
      print('✅ [AuthProvider] Perfil atualizado com sucesso');
      _state = AuthState.authenticated(updatedUser);
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthProvider] Erro ao atualizar perfil: ${error.message}');
      _state = AuthState.error(error.message);
    } finally {
      notifyListeners();
    }
  }
  
  /// Limpa uma mensagem de erro
  void clearError() {
    if (_state.errorMessage != null) {
      _state = _state.copyWith(
        errorMessage: null,
        status: _state.user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      );
      notifyListeners();
    }
  }
}