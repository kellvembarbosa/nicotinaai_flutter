import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';
import 'package:nicotinaai_flutter/utils/supported_currencies.dart';

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
      
      final userData = UserModel.fromJson(user.toJson());
      
      // Tenta obter informações adicionais do perfil
      try {
        final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
          
        if (response != null) {
          // Mescla dados do perfil com dados do usuário
          return userData.copyWith(
            name: response['full_name'] ?? userData.name,
            avatarUrl: response['avatar_url'] ?? userData.avatarUrl,
            currencyCode: response['currency_code'] ?? userData.currencyCode ?? SupportedCurrencies.defaultCurrency.code,
            currencySymbol: response['currency_symbol'] ?? userData.currencySymbol ?? SupportedCurrencies.defaultCurrency.symbol,
            currencyLocale: response['currency_locale'] ?? userData.currencyLocale ?? SupportedCurrencies.defaultCurrency.locale,
          );
        }
      } catch (e) {
        // Se houver erro ao obter o perfil, retorna apenas os dados de autenticação
        print('⚠️ [AuthRepository] Erro ao obter perfil: $e');
      }
      
      return userData;
    } catch (e) {
      return null;
    }
  }
  
  /// Atualiza os dados do usuário
  Future<UserModel> updateUserData({
    String? name,
    String? avatarUrl,
    String? currencyCode,
    String? currencySymbol,
    String? currencyLocale,
  }) async {
    try {
      final updatedData = <String, dynamic>{};
      
      if (name != null) {
        updatedData['name'] = name;
      }
      
      if (avatarUrl != null) {
        updatedData['avatar_url'] = avatarUrl;
      }
      
      // Se há informações de moeda, adiciona aos metadados
      if (currencyCode != null) {
        updatedData['currency_code'] = currencyCode;
      }
      
      if (currencySymbol != null) {
        updatedData['currency_symbol'] = currencySymbol;
      }
      
      if (currencyLocale != null) {
        updatedData['currency_locale'] = currencyLocale;
      }
      
      // Atualiza metadados na autenticação
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          data: updatedData,
        ),
      );
      
      // Atualiza também o perfil na tabela profiles
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        final profileData = <String, dynamic>{};
        
        if (name != null) {
          profileData['full_name'] = name;
        }
        
        if (avatarUrl != null) {
          profileData['avatar_url'] = avatarUrl;
        }
        
        if (currencyCode != null) {
          profileData['currency_code'] = currencyCode;
        }
        
        if (currencySymbol != null) {
          profileData['currency_symbol'] = currencySymbol;
        }
        
        if (currencyLocale != null) {
          profileData['currency_locale'] = currencyLocale;
        }
        
        if (profileData.isNotEmpty) {
          await _supabaseClient
            .from('profiles')
            .update(profileData)
            .eq('id', userId);
        }
      }
      
      // Retorna o usuário atualizado, incluindo dados do perfil
      final session = await getSession();
      if (session == null) {
        throw app_exceptions.AuthException('Usuário não encontrado');
      }
      return session;
    } catch (e) {
      throw app_exceptions.AuthException.fromSupabaseError(e);
    }
  }
  
  /// Atualiza o perfil completo do usuário
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      return await updateUserData(
        name: user.name,
        avatarUrl: user.avatarUrl,
        currencyCode: user.currencyCode,
        currencySymbol: user.currencySymbol,
        currencyLocale: user.currencyLocale,
      );
    } catch (e) {
      throw app_exceptions.AuthException.fromSupabaseError(e);
    }
  }
}