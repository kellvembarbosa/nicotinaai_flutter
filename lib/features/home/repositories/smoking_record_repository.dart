import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';

class SmokingRecordRepository {
  static const String _tableName = 'smoking_records';
  
  Future<SmokingRecordModel> saveRecord(SmokingRecordModel record) async {
    // If we have an ID, we're updating an existing record
    if (record.id != null && !record.id!.startsWith('temp_')) {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(record.toJson())
          .eq('id', record.id!)
          .select()
          .single();
      
      return SmokingRecordModel.fromJson(response);
    } 
    // Otherwise, we're creating a new record
    else {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert(record.toJson())
          .select()
          .single();
      
      return SmokingRecordModel.fromJson(response);
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