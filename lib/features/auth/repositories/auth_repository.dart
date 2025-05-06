import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';

// Renomeando nossa exceção personalizada para evitar conflitos
import 'package:nicotinaai_flutter/core/exceptions/auth_exception.dart' as app_exceptions;

/// Repositório para operações de autenticação
class AuthRepository {
  final SupabaseClient _supabaseClient = SupabaseConfig.client;
  
  /// Obtém o usuário atualmente autenticado
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      
      if (session == null) {
        return null;
      }
      
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        return null;
      }
      
      return UserModel.fromJson(user.toJson());
    } catch (e) {
      throw app_exceptions.AuthException.fromSupabaseError(e);
    }
  }
  
  /// Realiza o login com e-mail e senha
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw app_exceptions.AuthException('Falha ao autenticar usuário');
      }
      
      // A sessão é armazenada automaticamente pelo Supabase
      
      return UserModel.fromJson(response.user!.toJson());
    } catch (e) {
      throw app_exceptions.AuthException.fromSupabaseError(e);
    }
  }
  
  /// Realiza o registro com e-mail e senha
  Future<UserModel> signUpWithEmailAndPassword(
    String email, 
    String password, 
    {String? name}
  ) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );
      
      if (response.user == null) {
        throw app_exceptions.AuthException('Falha ao registrar usuário');
      }
      
      // A sessão é armazenada automaticamente pelo Supabase
      
      return UserModel.fromJson(response.user!.toJson());
    } catch (e) {
      throw app_exceptions.AuthException.fromSupabaseError(e);
    }
  }
  
  /// Realiza o logout
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      // A sessão é limpa automaticamente pelo Supabase
    } catch (e) {
      throw app_exceptions.AuthException.fromSupabaseError(e);
    }
  }
  
  /// Envia e-mail para recuperação de senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw app_exceptions.AuthException.fromSupabaseError(e);
    }
  }
  
  /// Verifica se há uma sessão válida
  Future<bool> hasSession() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtém a sessão atual (já é gerenciada automaticamente pelo Supabase)
  Future<UserModel?> getSession() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        return null;
      }
      
      return UserModel.fromJson(user.toJson());
    } catch (e) {
      return null;
    }
  }
  
  /// Atualiza os dados do usuário
  Future<UserModel> updateUserData({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final updatedData = <String, dynamic>{};
      
      if (name != null) {
        updatedData['name'] = name;
      }
      
      if (avatarUrl != null) {
        updatedData['avatar_url'] = avatarUrl;
      }
      
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          data: updatedData,
        ),
      );
      
      final updatedUser = _supabaseClient.auth.currentUser;
      
      if (updatedUser == null) {
        throw app_exceptions.AuthException('Usuário não encontrado');
      }
      
      return UserModel.fromJson(updatedUser.toJson());
    } catch (e) {
      throw app_exceptions.AuthException.fromSupabaseError(e);
    }
  }
}