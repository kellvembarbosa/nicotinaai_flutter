import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/core/exceptions/auth_exception.dart' as app_exceptions;
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';
import 'package:nicotinaai_flutter/features/settings/models/user_settings_model.dart';

/// Repositório para gerenciar configurações do usuário
class SettingsRepository {
  final SupabaseClient _supabaseClient = SupabaseConfig.client;
  
  /// Nome das tabelas no Supabase
  static const String _userStatsTable = 'user_stats';
  static const String _profilesTable = 'profiles';
  
  /// Obtém as configurações do usuário atual
  Future<UserSettingsModel> getUserSettings() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        throw app_exceptions.AuthException('Usuário não autenticado');
      }
      
      // Busca as estatísticas do usuário
      final userStatsResponse = await _supabaseClient
        .from(_userStatsTable)
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
      
      // Busca o perfil do usuário
      final profileResponse = await _supabaseClient
        .from(_profilesTable)
        .select()
        .eq('id', user.id)
        .maybeSingle();
      
      // Combina os dados das duas tabelas
      final Map<String, dynamic> settingsData = {};
      
      if (userStatsResponse != null) {
        settingsData['cigarettes_per_day'] = userStatsResponse['cigarettes_per_day'] ?? 20;
        settingsData['cigarettes_per_pack'] = userStatsResponse['cigarettes_per_pack'] ?? 20;
        settingsData['pack_price'] = userStatsResponse['pack_price'] ?? 1000; // em centavos
        settingsData['last_smoke_date'] = userStatsResponse['last_smoke_date'];
      }
      
      if (profileResponse != null) {
        settingsData['currency_code'] = profileResponse['currency_code'] ?? 'BRL';
        settingsData['currency_symbol'] = profileResponse['currency_symbol'] ?? r'R$';
      }
      
      // Se não houver dados, retorna configurações padrão
      if (settingsData.isEmpty) {
        return const UserSettingsModel();
      }
      
      return UserSettingsModel.fromJson(settingsData);
    } catch (e) {
      // Em caso de erro, retorna configurações padrão
      print('⚠️ [SettingsRepository] Erro ao obter configurações: $e');
      return const UserSettingsModel();
    }
  }
  
  /// Salva as configurações do usuário
  Future<UserSettingsModel> saveUserSettings(UserSettingsModel settings) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        throw app_exceptions.AuthException('Usuário não autenticado');
      }
      
      // Verifica se já existe um registro de estatísticas para o usuário
      final existingStats = await _supabaseClient
        .from(_userStatsTable)
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
      
      // Prepara os dados para a tabela user_stats
      final Map<String, dynamic> userStatsData = {
        'cigarettes_per_day': settings.cigarettesPerDay,
        'cigarettes_per_pack': settings.cigarettesPerPack,
        'pack_price': settings.packPriceInCents,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Adiciona a data do último cigarro, se disponível
      if (settings.quitDate != null) {
        userStatsData['last_smoke_date'] = settings.quitDate?.toIso8601String();
      }
      
      // Prepara os dados para a tabela profiles
      final Map<String, dynamic> profilesData = {
        'currency_code': settings.currencyCode,
        'currency_symbol': settings.currencySymbol,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Salva os dados na tabela user_stats
      if (existingStats == null) {
        // Se não existir, insere um novo registro
        userStatsData['user_id'] = user.id;
        userStatsData['created_at'] = DateTime.now().toIso8601String();
        
        await _supabaseClient
          .from(_userStatsTable)
          .insert(userStatsData);
      } else {
        // Se existir, atualiza o registro
        await _supabaseClient
          .from(_userStatsTable)
          .update(userStatsData)
          .eq('user_id', user.id);
      }
      
      // Atualiza a tabela profiles
      await _supabaseClient
        .from(_profilesTable)
        .update(profilesData)
        .eq('id', user.id);
      
      return settings;
    } catch (e) {
      print('⚠️ [SettingsRepository] Erro ao salvar configurações: $e');
      throw Exception('Falha ao salvar configurações: $e');
    }
  }
  
  /// Atualiza o preço do maço de cigarros
  Future<UserSettingsModel> updatePackPrice(int priceInCents) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        throw app_exceptions.AuthException('Usuário não autenticado');
      }
      
      // Atualiza diretamente na tabela user_stats
      await _supabaseClient
        .from(_userStatsTable)
        .update({
          'pack_price': priceInCents,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', user.id);
      
      // Retorna as configurações atualizadas
      return await getUserSettings();
    } catch (e) {
      print('⚠️ [SettingsRepository] Erro ao atualizar preço do maço: $e');
      throw Exception('Falha ao atualizar preço do maço: $e');
    }
  }
  
  /// Atualiza a quantidade de cigarros por dia
  Future<UserSettingsModel> updateCigarettesPerDay(int cigarettesPerDay) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        throw app_exceptions.AuthException('Usuário não autenticado');
      }
      
      // Atualiza diretamente na tabela user_stats
      await _supabaseClient
        .from(_userStatsTable)
        .update({
          'cigarettes_per_day': cigarettesPerDay,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', user.id);
      
      // Retorna as configurações atualizadas
      return await getUserSettings();
    } catch (e) {
      print('⚠️ [SettingsRepository] Erro ao atualizar cigarros por dia: $e');
      throw Exception('Falha ao atualizar cigarros por dia: $e');
    }
  }
  
  /// Atualiza a data em que o usuário parou de fumar
  Future<UserSettingsModel> updateQuitDate(DateTime? quitDate) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        throw app_exceptions.AuthException('Usuário não autenticado');
      }
      
      // Atualiza diretamente na tabela user_stats
      await _supabaseClient
        .from(_userStatsTable)
        .update({
          'last_smoke_date': quitDate?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', user.id);
      
      // Retorna as configurações atualizadas
      return await getUserSettings();
    } catch (e) {
      print('⚠️ [SettingsRepository] Erro ao atualizar data de parada: $e');
      throw Exception('Falha ao atualizar data de parada: $e');
    }
  }
  
  /// Solicita redefinição de senha
  Future<void> requestPasswordReset(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('⚠️ [SettingsRepository] Erro ao solicitar redefinição de senha: $e');
      throw Exception('Falha ao solicitar redefinição de senha: $e');
    }
  }
  
  /// Altera a senha do usuário atual
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        throw app_exceptions.AuthException('Usuário não autenticado');
      }
      
      final email = user.email;
      
      if (email == null) {
        throw app_exceptions.AuthException('Email do usuário não disponível');
      }
      
      // Verifica a senha atual tentando fazer login
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
      
      // Se chegar aqui, a senha atual está correta
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      print('⚠️ [SettingsRepository] Erro ao alterar senha: $e');
      
      if (e is AuthException) {
        throw e;
      }
      
      throw Exception('Falha ao alterar senha: $e');
    }
  }
  
  /// Exclui a conta do usuário usando a Edge Function
  Future<void> deleteAccount(String password) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        throw app_exceptions.AuthException('Usuário não autenticado');
      }
      
      final session = await _supabaseClient.auth.getSession();
      
      if (session.error != null) {
        throw app_exceptions.AuthException('Sessão inválida: ${session.error?.message}');
      }
      
      // Obtém o token de acesso da sessão atual
      final token = session.data.session?.accessToken;
      
      if (token == null) {
        throw app_exceptions.AuthException('Token de acesso não disponível');
      }
      
      try {
        // Chamada da Edge Function para excluir a conta
        final response = await _supabaseClient.functions.invoke(
          'delete-user-account',
          body: {'password': password},
          headers: {'Authorization': 'Bearer $token'}
        );
        
        // Verifica se a resposta foi bem-sucedida
        if (response.status != 200) {
          // Se a resposta contiver uma mensagem de erro, use-a
          if (response.data != null && response.data['error'] != null) {
            throw app_exceptions.AuthException(
              'Erro ao excluir conta: ${response.data['error']} - ${response.data['details'] ?? ''}'
            );
          }
          
          // Caso contrário, use o código de status
          throw app_exceptions.AuthException('Erro ao excluir conta. Código: ${response.status}');
        }
        
        // Faz logout após a exclusão bem-sucedida
        await _supabaseClient.auth.signOut();
      } catch (edgeFunctionError) {
        print('⚠️ [SettingsRepository] Erro ao chamar Edge Function: $edgeFunctionError');
        
        // Se a Edge Function falhar, use um plano B
        try {
          // Tenta apenas marcar o usuário para exclusão e excluir os dados relacionados
          await _supabaseClient.auth.updateUser(
            UserAttributes(data: {'deleted': true, 'deletion_requested': DateTime.now().toIso8601String()})
          );
          
          // Exclui os dados do usuário (de forma mais segura, através de uma função RPC)
          // Caso a função RPC não esteja disponível, usamos o método direto
          try {
            await _supabaseClient.rpc('delete_user_data', {'user_id': user.id});
          } catch (rpcError) {
            print('⚠️ [SettingsRepository] Erro ao chamar RPC, usando método direto: $rpcError');
            
            // Remove os dados do usuário das tabelas principais
            await _supabaseClient.from(_userStatsTable).delete().eq('user_id', user.id);
            await _supabaseClient.from('cravings').delete().eq('user_id', user.id);
            await _supabaseClient.from('smoking_records').delete().eq('user_id', user.id);
            await _supabaseClient.from(_profilesTable).delete().eq('id', user.id);
          }
          
          // Faz logout
          await _supabaseClient.auth.signOut();
        } catch (fallbackError) {
          throw app_exceptions.AuthException('Não foi possível excluir a conta: $fallbackError');
        }
      }
    } catch (e) {
      print('⚠️ [SettingsRepository] Erro ao excluir conta: $e');
      
      if (e is AuthException) {
        throw e;
      }
      
      throw app_exceptions.AuthException('Falha ao excluir conta: $e');
    }
  }
}