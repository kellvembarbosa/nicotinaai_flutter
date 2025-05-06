import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/core/exceptions/auth_exception.dart' as app_exceptions;
import 'package:nicotinaai_flutter/features/auth/models/auth_state.dart';
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';

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
      
      // Verifica se há uma sessão válida
      final hasSession = await _authRepository.hasSession();
      
      if (!hasSession) {
        _state = AuthState.unauthenticated();
        notifyListeners();
        return;
      }
      
      // Obtém o usuário da sessão atual (Supabase já restaura automaticamente)
      final user = await _authRepository.getSession();
      
      if (user != null) {
        _state = AuthState.authenticated(user);
      } else {
        _state = AuthState.unauthenticated();
      }
    } catch (e) {
      _state = AuthState.unauthenticated();
    } finally {
      notifyListeners();
    }
  }
  
  /// Realiza o login com e-mail e senha
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Início do login: ${DateTime.now()}');
      _state = AuthState.authenticating();
      notifyListeners();
      
      final user = await _authRepository.signInWithEmailAndPassword(
        email,
        password,
      );
      
      print('Usuário autenticado: ${user.email}');
      _state = AuthState.authenticated(user);
      print('Estado atualizado para autenticado: ${DateTime.now()}');
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('Erro na autenticação: ${error.message}');
      _state = AuthState.error(error.message);
    } finally {
      notifyListeners();
      print('Notificação enviada após login: ${DateTime.now()}');
    }
  }
  
  /// Realiza o registro com e-mail e senha
  Future<void> signUpWithEmailAndPassword(
    String email, 
    String password, 
    {String? name}
  ) async {
    try {
      _state = AuthState.authenticating();
      notifyListeners();
      
      final user = await _authRepository.signUpWithEmailAndPassword(
        email,
        password,
        name: name,
      );
      
      _state = AuthState.authenticated(user);
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      _state = AuthState.error(error.message);
    } finally {
      notifyListeners();
    }
  }
  
  /// Realiza o logout
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      _state = AuthState.unauthenticated();
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      _state = AuthState.error(error.message);
    } finally {
      notifyListeners();
    }
  }
  
  /// Envia e-mail para recuperação de senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _state = _state.copyWith(isLoading: true);
      notifyListeners();
      
      await _authRepository.sendPasswordResetEmail(email);
      
      _state = _state.copyWith(isLoading: false);
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      _state = AuthState.error(error.message);
    } finally {
      notifyListeners();
    }
  }
  
  /// Atualiza os dados do usuário
  Future<void> updateUserData({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      _state = _state.copyWith(isLoading: true);
      notifyListeners();
      
      final updatedUser = await _authRepository.updateUserData(
        name: name,
        avatarUrl: avatarUrl,
      );
      
      _state = AuthState.authenticated(updatedUser);
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
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