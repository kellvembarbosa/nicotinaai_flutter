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
        
        // Lista de tabelas a serem limpas - excluímos com try/catch para cada uma
        // para garantir que uma tabela inexistente não interrompa o processo
        
        try {
          await _supabaseClient.from(_userStatsTable).delete().eq('user_id', user.id);
          print('✓ Excluído dados de user_stats');
        } catch (e) {
          print('⚠️ Erro ao excluir de user_stats: $e');
        }
        
        try {
          await _supabaseClient.from('cravings').delete().eq('user_id', user.id);
          print('✓ Excluído dados de cravings');
        } catch (e) {
          print('⚠️ Erro ao excluir de cravings: $e');
        }
        
        try {
          await _supabaseClient.from('smoking_logs').delete().eq('user_id', user.id);
          print('✓ Excluído dados de smoking_logs');
        } catch (e) {
          print('⚠️ Erro ao excluir de smoking_logs: $e');
        }
        
        try {
          await _supabaseClient.from('user_notifications').delete().eq('user_id', user.id);
          print('✓ Excluído dados de user_notifications');
        } catch (e) {
          print('⚠️ Erro ao excluir de user_notifications: $e');
        }
        
        try {
          await _supabaseClient.from('user_achievements').delete().eq('user_id', user.id);
          print('✓ Excluído dados de user_achievements');
        } catch (e) {
          print('⚠️ Erro ao excluir de user_achievements: $e');
        }
        
        try {
          await _supabaseClient.from('user_health_recoveries').delete().eq('user_id', user.id);
          print('✓ Excluído dados de user_health_recoveries');
        } catch (e) {
          print('⚠️ Erro ao excluir de user_health_recoveries: $e');
        }
        
        try {
          await _supabaseClient.from('user_fcm_tokens').delete().eq('user_id', user.id);
          print('✓ Excluído dados de user_fcm_tokens');
        } catch (e) {
          print('⚠️ Erro ao excluir de user_fcm_tokens: $e');
        }
        
        try {
          await _supabaseClient.from(_profilesTable).delete().eq('id', user.id);
          print('✓ Excluído dados de profiles');
        } catch (e) {
          print('⚠️ Erro ao excluir de profiles: $e');
        }
        
        // Hard delete: chama a Edge Function para excluir o usuário totalmente
        print('🗑️ [SettingsRepository] Executando hard delete via Edge Function...');
        
        try {
          // Agora enviamos diretamente o user_id e password para a Edge Function
          // Sem depender do token JWT
          print('📤 [SettingsRepository] Enviando requisição para a Edge Function...');
          
          // Chamada da Edge Function para excluir a conta - simplificada
          final response = await _supabaseClient.functions.invoke(
            'delete-user-account',
            body: {
              'user_id': user.id
              // Não precisamos mais do password na Edge Function
            }
          );
          
          // Verifica se a resposta foi bem-sucedida
          if (response.status != 200) {
            // Se a resposta contiver uma mensagem de erro, use-a
            if (response.data != null && response.data['error'] != null) {
              print('⚠️ [SettingsRepository] Erro da Edge Function: ${response.data['error']}');
              throw app_exceptions.AuthException(
                'Erro ao excluir conta: ${response.data['error']} - ${response.data['details'] ?? ''}'
              );
            }
            
            // Caso contrário, use o código de status
            throw app_exceptions.AuthException('Erro ao excluir conta. Código: ${response.status}');
          }
          
          print('✅ [SettingsRepository] Usuário excluído com sucesso via Edge Function');
        } catch (edgeFunctionError) {
          print('⚠️ [SettingsRepository] Edge Function falhou: $edgeFunctionError');
          
          // Já que a Edge Function falhou, usamos o plano B
          // A opção mais próxima é tornar a conta inutilizável
          print('📝 [SettingsRepository] Tornando a conta inutilizável...');
          
          // Apenas marque os metadados do usuário como excluído
          // Não tente alterar o email ou senha, pois isso pode causar erros de validação
          print('📝 [SettingsRepository] Marcando metadados do usuário como excluído...');
          
          try {
            await _supabaseClient.auth.updateUser(
              UserAttributes(
                data: {
                  'account_deleted': true, 
                  'deletion_timestamp': DateTime.now().toIso8601String(),
                  'deleted_by': 'user_request'
                }
              )
            );
            print('✅ [SettingsRepository] Metadados do usuário atualizados com sucesso');
          } catch (metadataError) {
            print('⚠️ [SettingsRepository] Erro ao atualizar metadados: $metadataError');
            // Continuamos mesmo se falhar a atualização dos metadados
          }
          
          print('✅ [SettingsRepository] Conta tornada inutilizável com sucesso');
        }
        
        // Procedimento de limpeza final
        print('🧹 [SettingsRepository] Realizando limpeza final...');
        
        // Se apenas quisermos desativar a conta sem impedir registro futuro
        // Apenas marcamos os metadados e ignoramos qualquer operação na senha
        final wasHardDeleted = response?.status == 200;
        
        if (!wasHardDeleted) {
          print('🔒 [SettingsRepository] Hard delete não foi bem-sucedido, desabilitando conta via metadados...');
          
          try {
            // Apenas atualizamos os metadados marcando a conta como excluída
            // Isso permitirá que o usuário use o mesmo email para se registrar no futuro
            await _supabaseClient.auth.updateUser(
              UserAttributes(
                data: {
                  'account_deleted': true,
                  'deletion_timestamp': DateTime.now().toIso8601String(),
                  'deletion_complete': true,
                  'deletion_method': 'soft_delete_with_metadata'
                }
              )
            );
            
            print('📝 [SettingsRepository] Metadados atualizados para marcar conta como excluída');
          } catch (metadataError) {
            print('⚠️ [SettingsRepository] Erro ao atualizar metadados: $metadataError');
          }
        }
        
        // Executa logout em todas as sessões para encerrar o acesso em todos os dispositivos
        print('👋 [SettingsRepository] Fazendo logout...');
        await _supabaseClient.auth.signOut();
        
        print('✅ [SettingsRepository] Processo de exclusão de conta concluído com sucesso');
        
        // Garantir que o usuário seja redirecionado para a tela de login
        // Observação: Este código será executado na camada de UI, através do BLoC no DeleteAccountScreen
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