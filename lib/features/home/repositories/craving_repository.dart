import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';

class CravingRepository {
  static const String _tableName = 'cravings';
  
  // Removido método logTableInfo que causava mensagens de log em loop

  Future<CravingModel> saveCraving(CravingModel craving) async {
    try {
      // Log para debug
      debugPrint('Repository: Saving craving');
      
      // Preparar dados para envio, removendo campos temporários
      final jsonData = craving.toJson();
      
      // Log dos dados que estamos enviando (apenas em desenvolvimento)
      if (kDebugMode) {
        debugPrint('Dados a serem salvos:');
        jsonData.forEach((key, value) => debugPrint('- $key: $value'));
        
        // Verificação específica para o campo intensity
        final intensity = jsonData['intensity'];
        debugPrint('Verificando campo intensity: $intensity');
        if (intensity != 'LOW' && intensity != 'MODERATE' && intensity != 'HIGH' && intensity != 'VERY_HIGH') {
          debugPrint('⚠️ AVISO: O valor do intensity não corresponde aos valores esperados do enum no banco de dados!');
          debugPrint('Valores esperados: ["LOW", "MODERATE", "HIGH", "VERY_HIGH"]');
        }
        
        // Verificação específica para o campo outcome
        final outcome = jsonData['outcome'];
        debugPrint('Verificando campo outcome: $outcome');
        if (outcome != 'RESISTED' && outcome != 'SMOKED' && outcome != 'ALTERNATIVE') {
          debugPrint('⚠️ AVISO: O valor do outcome não corresponde aos valores esperados do enum no banco de dados!');
          debugPrint('Valores esperados: ["RESISTED", "SMOKED", "ALTERNATIVE"]');
        }
      }
      
      // Remover ID se for temporário ou nulo
      if (craving.id == null || craving.id!.startsWith('temp_')) {
        jsonData.remove('id');
      }
      
      // Se estamos atualizando um registro existente (ID não temporário)
      if (craving.id != null && !craving.id!.startsWith('temp_')) {
        debugPrint('Repository: Updating existing craving with ID ${craving.id}');
        final response = await SupabaseConfig.client
            .from(_tableName)
            .update(jsonData)
            .eq('id', craving.id!)
            .select()
            .single();
        
        return CravingModel.fromJson(response);
      } 
      // Caso contrário, estamos criando um novo registro
      else {
        debugPrint('Repository: Creating new craving');
        final response = await SupabaseConfig.client
            .from(_tableName)
            .insert(jsonData)
            .select()
            .single();
        
        return CravingModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Repository error saving craving: $e');
      
      // Fornecer informações úteis de depuração 
      if (e.toString().contains('outcome')) {
        debugPrint('⚠️ Erro com o campo "outcome". Verifique se o modelo está configurado corretamente.');
        debugPrint('  O modelo "CravingModel.resisted" deve ser mapeado para "outcome" no banco de dados.');
      }
      
      rethrow; // Propagar erro para o provider
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