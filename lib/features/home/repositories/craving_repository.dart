import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';

class CravingRepository {
  static const String _tableName = 'cravings';
  
  Future<CravingModel> saveCraving(CravingModel craving) async {
    final response = await SupabaseConfig.client
        .from(_tableName)
        .insert(craving.toJson())
        .select()
        .single();
    
    return CravingModel.fromJson(response);
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