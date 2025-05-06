import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';

class SmokingRecordRepository {
  static const String _tableName = 'smoking_records';
  
  Future<SmokingRecordModel> saveRecord(SmokingRecordModel record) async {
    final response = await SupabaseConfig.client
        .from(_tableName)
        .insert(record.toJson())
        .select()
        .single();
    
    return SmokingRecordModel.fromJson(response);
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