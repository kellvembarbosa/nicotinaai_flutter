import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';

class SmokingRecordRepository {
  // Usando a tabela smoking_logs existente em vez de smoking_records
  static const String _tableName = 'smoking_logs';
  
  /// Salva um registro de fumo (adaptado com base no CravingRepository)
  Future<SmokingRecordModel> saveRecord(SmokingRecordModel record) async {
    try {
      // Log para debug
      debugPrint('Repository: Saving smoking record');
      
      // Preparar dados para envio, removendo campos temporários
      final jsonData = record.toJson();
      
      // Log dos dados que estamos enviando (apenas em modo de depuração)
      if (kDebugMode) {
        debugPrint('Dados a serem salvos:');
        jsonData.forEach((key, value) => debugPrint('- $key: $value'));
      }
      
      // Remover ID se for temporário ou nulo
      if (record.id == null || record.id!.startsWith('temp_')) {
        jsonData.remove('id');
      }
      
      // Se estamos atualizando um registro existente (ID não temporário)
      if (record.id != null && !record.id!.startsWith('temp_')) {
        debugPrint('Repository: Updating existing smoking record with ID ${record.id}');
        
        final response = await SupabaseConfig.client
            .from(_tableName)
            .update(jsonData)
            .eq('id', record.id!)
            .select()
            .single();
        
        return SmokingRecordModel.fromJson(response);
      } 
      // Caso contrário, estamos criando um novo registro
      else {
        debugPrint('Repository: Creating new smoking record');
        
        final response = await SupabaseConfig.client
            .from(_tableName)
            .insert(jsonData)
            .select()
            .single();
        
        return SmokingRecordModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Repository error saving smoking record: $e');
      
      // Fornecer informações úteis de depuração
      if (e.toString().contains('404')) {
        debugPrint('⚠️ Tabela $_tableName não encontrada. Verifique se as migrações foram aplicadas corretamente.');
      }
      
      if (e.toString().contains('reason')) {
        debugPrint('⚠️ Erro com o campo "reason". Verifique se o modelo está configurado corretamente.');
      }
      
      rethrow; // Propagar erro para o provider
    }
  }
  
  Future<void> deleteRecord(String id) async {
    // Don't try to delete temporary IDs from the server
    if (id.startsWith('temp_')) return;
    
    await SupabaseConfig.client
        .from(_tableName)
        .delete()
        .eq('id', id);
  }
  
  Future<List<SmokingRecordModel>> getRecordsForUser(String userId) async {
    final data = await SupabaseConfig.client
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false);
    
    return (data as List<dynamic>).map((item) => SmokingRecordModel.fromJson(item)).toList();
  }
  
  Future<int> getRecordCountForUser(String userId) async {
    final data = await SupabaseConfig.client
        .from(_tableName)
        .select('id')
        .eq('user_id', userId);
    
    return (data as List<dynamic>).length;
  }
}