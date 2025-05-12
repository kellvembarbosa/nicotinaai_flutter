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
  
  /// Exclui a conta do usuário usando hard delete via Edge Function
  /// Usa a SERVICE_ROLE key no servidor para excluir completamente o usuário
  /// 
  /// Esta implementação usa somente a função Edge Function que:
  /// 1. Limpa todos os dados do usuário via função SQL cascade_delete_user
  /// 2. Tenta fazer hard delete do usuário
  /// 3. Se falhar, tenta soft delete
  /// 4. Se ambos falharem, marca o usuário como excluído nos metadados
  /// 
  /// Retorna true se a exclusão foi bem-sucedida para que o chamador possa
  /// despachar o evento AccountDeletedLogout no AuthBloc
  Future<bool> deleteAccount() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        throw app_exceptions.AuthException('Usuário não autenticado');
      }
      
      print('🗑️ [SettingsRepository] Iniciando exclusão de conta via Edge Function...');
      print('🔍 [SettingsRepository] User ID: ${user.id}');
      
      try {
        // Log para depuração
        print('📝 [SettingsRepository] Verificando dados da sessão atual...');
        
        // Obter token de autenticação para a solicitação
        final token = _supabaseClient.auth.currentSession?.accessToken;
        final refreshToken = _supabaseClient.auth.currentSession?.refreshToken;
        
        if (token == null) {
          print('❌ [SettingsRepository] Token de acesso não encontrado na sessão atual');
          throw app_exceptions.AuthException('Sessão de usuário inválida, faça login novamente');
        }
        
        print('✅ [SettingsRepository] Token de acesso obtido (${token.substring(0, 15)}...)');
        print('📝 [SettingsRepository] Refresh token disponível: ${refreshToken != null}');
        
        // Chamar a Edge Function diretamente com o ID do usuário
        print('📡 [SettingsRepository] Enviando requisição para delete-user-account Edge Function...');
        print('📝 [SettingsRepository] Body: { "user_id": "${user.id}" }');
        
        final stopwatch = Stopwatch()..start();
        
        final response = await _supabaseClient.functions.invoke(
          'delete-user-account',
          body: { 'user_id': user.id },
          headers: { 'Authorization': 'Bearer $token' }
        );
        
        stopwatch.stop();
        print('⏱️ [SettingsRepository] Edge Function executada em ${stopwatch.elapsedMilliseconds}ms');
        print('📊 [SettingsRepository] Status da resposta: ${response.status}');
        
        // Verificar se a função Edge Function foi bem-sucedida
        if (response.status != 200) {
          if (response.data != null && response.data['error'] != null) {
            final errorMessage = response.data['error'].toString().toLowerCase();
            print('⚠️ [SettingsRepository] Erro da Edge Function: ${response.data['error']}');
            
            // Verificar se o erro é relacionado a usuário não encontrado
            if (errorMessage.contains('user_not_found') || 
                errorMessage.contains('user not found')) {
              print('ℹ️ [SettingsRepository] Usuário não encontrado na função Edge, provavelmente já foi excluído');
              return true;
            }
            
            throw app_exceptions.AuthException(
              'Erro ao excluir conta: ${response.data['error']} - ${response.data['details'] ?? ''}'
            );
          }
          throw app_exceptions.AuthException('Erro ao excluir conta. Código: ${response.status}');
        }
        
        print('✅ [SettingsRepository] Usuário excluído com sucesso!');
        
        // Imprimir detalhes da resposta para depuração
        bool responseHasSuccess = false;
        
        if (response.data != null) {
          print('📝 [SettingsRepository] Resposta da Edge Function:');
          
          if (response.data['message'] != null) {
            print('📄 [SettingsRepository] Mensagem: ${response.data['message']}');
          }
          
          if (response.data['notes'] != null) {
            print('📋 [SettingsRepository] Detalhes: ${response.data['notes']}');
          }
          
          if (response.data['method'] != null) {
            print('🔧 [SettingsRepository] Método de exclusão: ${response.data['method']}');
          }
          
          // Verificar se a resposta indica sucesso explicitamente
          if (response.data['success'] == true) {
            responseHasSuccess = true;
            print('🔑 [SettingsRepository] Resposta contém flag de sucesso = true');
          }
          
          // Imprimir outros dados disponíveis na resposta
          final otherKeys = response.data.keys.where((key) => 
            key != 'message' && key != 'notes' && key != 'method' && key != 'error' && key != 'details');
          
          for (final key in otherKeys) {
            print('🔹 [SettingsRepository] $key: ${response.data[key]}');
          }
        } else {
          print('⚠️ [SettingsRepository] Resposta vazia da Edge Function');
        }
        
        // Delay para garantir que a resposta tenha tempo de ser processada
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Não fazemos logout via Supabase, pois o token já não é mais válido
        // Em vez disso, retornamos true para indicar sucesso, e o chamador
        // deve despachar o evento AccountDeletedLogout no AuthBloc
        return true;
        
      } catch (edgeFunctionError) {
        print('⚠️ [SettingsRepository] Erro na Edge Function: $edgeFunctionError');
        print('📝 [SettingsRepository] Tipo de erro: ${edgeFunctionError.runtimeType}');
        
        // Detalhes adicionais para depuração
        if (edgeFunctionError is Exception) {
          print('🔍 [SettingsRepository] Detalhes da exceção: ${edgeFunctionError.toString()}');
        }
        
        throw app_exceptions.AuthException('Falha ao excluir conta via Edge Function: $edgeFunctionError');
      }
    } catch (e) {
      print('⚠️ [SettingsRepository] Erro ao excluir conta: $e');
      print('📝 [SettingsRepository] Tipo de erro: ${e.runtimeType}');
      
      // Verifica se o erro é "user_not_found", o que significa que o usuário já foi excluído
      // Neste caso, consideramos como sucesso e retornamos true
      if (e is AuthException && e.message.toLowerCase().contains('user_not_found')) {
        print('ℹ️ [SettingsRepository] Usuário não encontrado, provavelmente já foi excluído');
        return true;
      }
      
      // Verifica outros erros relacionados ao usuário não encontrado
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('user_not_found') || 
          errorString.contains('user not found') ||
          errorString.contains('not found') && errorString.contains('user')) {
        print('ℹ️ [SettingsRepository] Usuário não encontrado, provavelmente já foi excluído');
        return true;
      }
      
      // Verificar outros erros comuns
      if (errorString.contains('timeout') || errorString.contains('timed out')) {
        print('⏱️ [SettingsRepository] Timeout na operação, mas a conta pode ter sido excluída');
        // Ainda retornamos true para evitar que o usuário fique preso
        return true;
      }
      
      if (e is AuthException) {
        throw e;
      }
      
      throw app_exceptions.AuthException('Falha ao excluir conta: $e');
    }
  }

}