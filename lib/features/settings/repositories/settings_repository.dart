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
  
  /// Exclui a conta do usuário diretamente no app
  Future<void> deleteAccount(String password) async {
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
      try {
        await _supabaseClient.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } catch (signInError) {
        throw app_exceptions.AuthException('Senha incorreta. Verifique sua senha e tente novamente.');
      }
      
      print('✅ [SettingsRepository] Senha verificada, prosseguindo com exclusão de conta');
      
      // Realizar a exclusão de dados
      try {
        // Exclui os dados do usuário das tabelas principais
        print('🗑️ [SettingsRepository] Excluindo dados do usuário das tabelas...');
        await _supabaseClient.from(_userStatsTable).delete().eq('user_id', user.id);
        await _supabaseClient.from('cravings').delete().eq('user_id', user.id);
        await _supabaseClient.from('smoking_logs').delete().eq('user_id', user.id);
        await _supabaseClient.from('user_notifications').delete().eq('user_id', user.id);
        await _supabaseClient.from('user_achievements').delete().eq('user_id', user.id);
        await _supabaseClient.from('user_health_recoveries').delete().eq('user_id', user.id);
        await _supabaseClient.from('user_fcm_tokens').delete().eq('user_id', user.id);
        await _supabaseClient.from('daily_motivation_logs').delete().eq('user_id', user.id);
        await _supabaseClient.from(_profilesTable).delete().eq('id', user.id);
        
        // Hard delete: tenta excluir o usuário totalmente
        print('🗑️ [SettingsRepository] Executando hard delete do usuário...');
        
        try {
          // Tenta remover a conta do usuário completamente
          // Como este método requer permissões administrativas, pode falhar
          // Mas tentamos mesmo assim caso as permissões permitam
          await _supabaseClient.auth.admin.deleteUser(user.id);
          print('✅ [SettingsRepository] Usuário excluído com sucesso via admin.deleteUser');
        } catch (adminError) {
          print('⚠️ [SettingsRepository] Não foi possível excluir o usuário via admin.deleteUser: $adminError');
          
          // Já que não podemos excluir o usuário com permissões de admin, 
          // a opção mais próxima é tornar a conta inutilizável
          print('📝 [SettingsRepository] Tornando a conta inutilizável...');
          
          // Gera uma senha aleatória para impedir logins futuros
          final randomPassword = DateTime.now().millisecondsSinceEpoch.toString();
          
          // Altera o email para um valor que torna a conta inacessível
          final anonymizedEmail = 'deleted_${DateTime.now().millisecondsSinceEpoch}@deleted.account';
          
          // Atualiza o usuário para tornar a conta inutilizável
          await _supabaseClient.auth.updateUser(
            UserAttributes(
              email: anonymizedEmail,
              password: randomPassword,
              data: {
                'hard_deleted': true, 
                'deletion_timestamp': DateTime.now().toIso8601String()
              }
            )
          );
          
          print('✅ [SettingsRepository] Conta tornada inutilizável com sucesso');
        }
        
        // Procedimento de limpeza final
        print('🧹 [SettingsRepository] Realizando limpeza final...');
        
        // Executa logout para encerrar a sessão atual
        print('👋 [SettingsRepository] Fazendo logout...');
        await _supabaseClient.auth.signOut();
        
        print('✅ [SettingsRepository] Processo de exclusão de conta concluído com sucesso');
      } catch (error) {
        print('⚠️ [SettingsRepository] Erro ao excluir dados: $error');
        throw app_exceptions.AuthException('Falha ao excluir dados da conta: $error');
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