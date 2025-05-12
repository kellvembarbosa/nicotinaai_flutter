import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';

class CravingRepository {
  static const String _tableName = 'cravings';
  
  // Removido método logTableInfo que causava mensagens de log em loop

  Future<CravingModel> saveCraving(CravingModel craving) async {
    try {
      // Log para debug
      debugPrint('🔄 Repository: Iniciando salvamento de craving');
      
      // Verificar se o usuário está autenticado
      final currentUser = SupabaseConfig.auth.currentUser;
      debugPrint('👤 Auth Check: User ID atual: ${currentUser?.id}');
      debugPrint('👤 Auth Check: User ID do objeto craving: ${craving.userId}');
      
      if (currentUser == null) {
        throw Exception('Usuário não autenticado. Impossível salvar o craving.');
      }
      
      // Verificar se o token de autenticação é válido
      final session = SupabaseConfig.auth.currentSession;
      if (session == null) {
        throw Exception('Sessão não encontrada. Token de autenticação inválido.');
      }
      
      debugPrint('🔐 Token de acesso válido: ${session.accessToken.substring(0, 10)}...');
      
      // Preparar dados para envio, removendo campos temporários
      final jsonData = craving.toJson();
      
      // Log detalhado dos dados que estamos enviando (apenas em desenvolvimento)
      if (kDebugMode) {
        debugPrint('📋 DADOS ORIGINAIS DO CRAVING:');
        debugPrint('- ID: ${craving.id ?? "null (novo registro)"}');
        debugPrint('- Location: ${craving.location}');
        debugPrint('- Trigger: ${craving.trigger}');
        debugPrint('- Intensity: ${craving.intensity}');
        debugPrint('- Resisted: ${craving.resisted}');
        debugPrint('- Notes: ${craving.notes}');
        debugPrint('- UserID: ${craving.userId}');
        debugPrint('- Timestamp: ${craving.timestamp}');
        
        debugPrint('📦 DADOS JSON A SEREM ENVIADOS:');
        jsonData.forEach((key, value) => debugPrint('- $key: $value'));
        
        // Verificar todos os campos obrigatórios da tabela
        final requiredFields = ['location', 'trigger', 'intensity', 'outcome', 'user_id', 'timestamp'];
        final missingFields = requiredFields.where((field) => !jsonData.containsKey(field) || jsonData[field] == null).toList();
        
        if (missingFields.isNotEmpty) {
          debugPrint('❌ ERRO: Campos obrigatórios faltando: ${missingFields.join(', ')}');
        }
        
        // Verificação específica para o campo intensity
        final intensity = jsonData['intensity'];
        debugPrint('🔍 Verificando campo intensity: $intensity');
        if (intensity != 'LOW' && intensity != 'MODERATE' && intensity != 'HIGH' && intensity != 'VERY_HIGH') {
          debugPrint('⚠️ AVISO: O valor do intensity não corresponde aos valores esperados do enum no banco de dados!');
          debugPrint('Valores esperados: ["LOW", "MODERATE", "HIGH", "VERY_HIGH"]');
        }
        
        // Verificação específica para o campo outcome
        final outcome = jsonData['outcome'];
        debugPrint('🔍 Verificando campo outcome: $outcome');
        if (outcome != 'RESISTED' && outcome != 'SMOKED' && outcome != 'ALTERNATIVE') {
          debugPrint('⚠️ AVISO: O valor do outcome não corresponde aos valores esperados do enum no banco de dados!');
          debugPrint('Valores esperados: ["RESISTED", "SMOKED", "ALTERNATIVE"]');
        }
        
        // Verificação de permissões RLS
        debugPrint('🔒 Verificando RLS: user_id no request (${jsonData['user_id']}) deve corresponder ao auth.uid() (${currentUser.id})');
        if (jsonData['user_id'] != currentUser.id) {
          debugPrint('⚠️ AVISO DE RLS: user_id no request não corresponde ao auth.uid(), o que violará as políticas RLS!');
          debugPrint('🔧 Correção: Ajustando user_id para corresponder ao usuário autenticado');
          jsonData['user_id'] = currentUser.id;
        }
      }
      
      // Force user_id to match the current user to avoid RLS issues
      jsonData['user_id'] = currentUser.id;
      
      // Remover ID se for temporário ou nulo
      if (craving.id == null || craving.id!.startsWith('temp_')) {
        jsonData.remove('id');
      }
      
      // Mostrar comando SQL equivalente para debug
      debugPrint('🔍 SIMULAÇÃO SQL:');
      if (craving.id != null && !craving.id!.startsWith('temp_')) {
        debugPrint("UPDATE public.cravings SET ");
        jsonData.forEach((key, value) {
          if (key != 'id') {
            debugPrint('  $key = ${value is String ? "'$value'" : value},');
          }
        });
        debugPrint("WHERE id = '${craving.id}' AND auth.uid() = '${currentUser.id}';");
      } else {
        debugPrint("INSERT INTO public.cravings (${jsonData.keys.join(', ')})");
        debugPrint("VALUES (${jsonData.values.map((v) => v is String ? "'$v'" : v).join(', ')});");
      }
      
      // Se estamos atualizando um registro existente (ID não temporário)
      if (craving.id != null && !craving.id!.startsWith('temp_')) {
        debugPrint('Repository: Updating existing craving with ID ${craving.id}');
        try {
          final response = await SupabaseConfig.client
              .from(_tableName)
              .update(jsonData)
              .eq('id', craving.id!)
              .select()
              .single();
          
          debugPrint('✅ SUCESSO no update! Resposta recebida: ${response.toString().substring(0, 100)}...');
          return CravingModel.fromJson(response);
        } catch (updateError) {
          debugPrint('❌ ERRO NO UPDATE: $updateError');
          throw updateError;
        }
      } 
      // Caso contrário, estamos criando um novo registro
      else {
        debugPrint('Repository: Creating new craving');
        try {
          final response = await SupabaseConfig.client
              .from(_tableName)
              .insert(jsonData)
              .select()
              .single();
          
          debugPrint('✅ SUCESSO no insert! Resposta recebida: ${response.toString().substring(0, 100)}...');
          return CravingModel.fromJson(response);
        } catch (insertError) {
          debugPrint('❌ ERRO NO INSERT: $insertError');
          throw insertError;
        }
      }
    } catch (e) {
      debugPrint('❌ ERRO AO SALVAR CRAVING: $e');
      debugPrint('------------------------------------');
      debugPrint('DETALHES DO ERRO:');
      
      final errorMsg = e.toString();
      debugPrint(errorMsg);
      
      // Debug avançado da sessão do usuário
      try {
        final currentUser = SupabaseConfig.auth.currentUser;
        final session = SupabaseConfig.auth.currentSession;
        
        debugPrint('=== DADOS DE AUTENTICAÇÃO ===');
        debugPrint('User autenticado: ${currentUser != null ? "SIM" : "NÃO"}');
        if (currentUser != null) {
          debugPrint('- User ID: ${currentUser.id}');
          debugPrint('- User Email: ${currentUser.email}');
          debugPrint('- Created At: ${currentUser.createdAt}');
          debugPrint('- Last Sign In: ${currentUser.lastSignInAt}');
        }
        
        debugPrint('Sessão válida: ${session != null ? "SIM" : "NÃO"}');
        if (session != null) {
          debugPrint('- Token expira em: ${session.expiresAt != null ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000) : "N/A"}');
          debugPrint('- Token expirado: ${session.isExpired ? "SIM" : "NÃO"}');
        }
        debugPrint('=============================');
      } catch (authDebugError) {
        debugPrint('⚠️ Erro ao obter dados de autenticação para debug: $authDebugError');
      }
      
      // Tentar executar uma query simples para testar a conexão e autenticação
      try {
        debugPrint('🔍 TESTE DE CONEXÃO: Executando query simples para verificar autenticação...');
        
        // Disparar query assíncrona para debug - apenas para registro nos logs
        SupabaseConfig.client
            .from('profiles')
            .select('id')
            .limit(1)
            .then((result) {
              debugPrint('✅ Query de teste bem-sucedida: $result');
            })
            .catchError((testError) {
              debugPrint('❌ Query de teste falhou: $testError');
              debugPrint('🔑 Provável problema de autenticação ou conexão com o Supabase');
            });
      } catch (testError) {
        debugPrint('❌ Erro ao executar query de teste: $testError');
      }
      
      // Analisar erros comuns
      if (errorMsg.contains('outcome')) {
        debugPrint('⚠️ PROBLEMA IDENTIFICADO: Erro com o campo "outcome"');
        debugPrint('- O campo "outcome" deve ser um dos valores: "RESISTED", "SMOKED", "ALTERNATIVE"');
        debugPrint('- Verificar o método toJson() no CravingModel');
      } 
      else if (errorMsg.contains('column')) {
        // Pode ser problema de colunas faltando ou incompatíveis
        debugPrint('⚠️ PROBLEMA IDENTIFICADO: Erro de coluna no banco de dados');
        debugPrint('- Verifique se todas as colunas obrigatórias estão presentes no JSON');
        debugPrint('- Verifique se os nomes das colunas estão corretos (ex: user_id vs userId)');
        debugPrint('- A coluna "outcome" (não "resisted") é usada no banco de dados');
      }
      else if (errorMsg.contains('not null')) {
        debugPrint('⚠️ PROBLEMA IDENTIFICADO: Violação de restrição NOT NULL');
        debugPrint('- Campo obrigatório está faltando ou é nulo');
        debugPrint('- Verifique todos os campos marcados como NOT NULL na migração do banco');
        debugPrint('- Campos obrigatórios: location, trigger, intensity, outcome, user_id, timestamp');
      }
      else if (errorMsg.contains('violates foreign key')) {
        debugPrint('⚠️ PROBLEMA IDENTIFICADO: Violação de chave estrangeira');
        debugPrint('- Verifique se o user_id é válido e existe na tabela auth.users');
      }
      else if (errorMsg.contains('policy')) {
        debugPrint('⚠️ PROBLEMA IDENTIFICADO: Violação de política RLS');
        debugPrint('- Verifique se o usuário está autenticado');
        debugPrint('- Verifique se o user_id no craving corresponde ao auth.uid()');
      }
      else if (errorMsg.contains('invalid input value for enum')) {
        debugPrint('⚠️ PROBLEMA IDENTIFICADO: Valor inválido para um campo enum');
        debugPrint('- intensity deve ser: "LOW", "MODERATE", "HIGH", "VERY_HIGH"');
        debugPrint('- outcome deve ser: "RESISTED", "SMOKED", "ALTERNATIVE"');
      }
      else if (errorMsg.contains('JWT')) {
        debugPrint('⚠️ PROBLEMA IDENTIFICADO: Erro de autenticação JWT');
        debugPrint('- O token de autenticação pode estar expirado ou ser inválido');
        debugPrint('- Tente fazer logout e login novamente');
      }
      else if (errorMsg.contains('timeout') || errorMsg.contains('network')) {
        debugPrint('⚠️ PROBLEMA IDENTIFICADO: Erro de rede ou timeout');
        debugPrint('- Verifique a conexão de internet do dispositivo');
        debugPrint('- A API do Supabase pode estar temporariamente indisponível');
      }
      else if (errorMsg.contains('rate limit')) {
        debugPrint('⚠️ PROBLEMA IDENTIFICADO: Rate limit excedido');
        debugPrint('- Muitas requisições em um curto período de tempo');
        debugPrint('- Tente novamente em alguns segundos');
      }
      
      debugPrint('------------------------------------');
      
      // Propagar erro para o provider
      rethrow;
    }
  }
  
  Future<void> deleteCraving(String id) async {
    // Don't try to delete temporary IDs from the server
    if (id.startsWith('temp_')) return;
    
    await SupabaseConfig.client
        .from(_tableName)
        .delete()
        .eq('id', id);
  }
  
  Future<List<CravingModel>> getCravingsForUser(String userId) async {
    final data = await SupabaseConfig.client
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false);
    
    return (data as List<dynamic>).map((item) => CravingModel.fromJson(item)).toList();
  }
  
  Future<int> getCravingCountForUser(String userId) async {
    final data = await SupabaseConfig.client
        .from(_tableName)
        .select('id')
        .eq('user_id', userId);
    
    return (data as List<dynamic>).length;
  }
}