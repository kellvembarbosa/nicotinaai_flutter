import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/tracking/models/craving.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/models/smoking_log.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception thrown when a Supabase Edge Function returns an error
class FunctionException implements Exception {
  final int status;
  final Map<String, dynamic> details;
  final String reasonPhrase;
  
  FunctionException({
    required this.status,
    required this.details,
    required this.reasonPhrase,
  });
  
  @override
  String toString() {
    return 'FunctionException(status: $status, details: $details, reasonPhrase: $reasonPhrase)';
  }
}

class TrackingRepository {
  final _client = SupabaseConfig.client;

  // Smoking Logs Methods
  Future<List<SmokingLog>> getSmokingLogs({int limit = 20, int offset = 0}) async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final response = await _client
          .from('smoking_logs')
          .select()
          .eq('user_id', user.id)
          .order('timestamp', ascending: false)
          .range(offset, offset + limit - 1);
      
      return response.map((log) => SmokingLog.fromJson(log)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<SmokingLog> addSmokingLog(SmokingLog log) async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final data = log.toJson();
      data['user_id'] = user.id;
      
      final response = await _client
          .from('smoking_logs')
          .insert(data)
          .select()
          .single();
      
      return SmokingLog.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSmokingLog(String logId) async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      await _client
          .from('smoking_logs')
          .delete()
          .eq('id', logId)
          .eq('user_id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  // Cravings Methods
  Future<List<Craving>> getCravings({int limit = 20, int offset = 0}) async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final response = await _client
          .from('cravings')
          .select()
          .eq('user_id', user.id)
          .order('timestamp', ascending: false)
          .range(offset, offset + limit - 1);
      
      return response.map((craving) => Craving.fromJson(craving)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Craving> addCraving(Craving craving) async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final data = craving.toJson();
      data['user_id'] = user.id;
      
      final response = await _client
          .from('cravings')
          .insert(data)
          .select()
          .single();
      
      return Craving.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Craving> updateCraving(Craving craving) async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      if (craving.id == null) {
        throw Exception('Craving ID is required for update');
      }
      
      final data = craving.toJson();
      data['user_id'] = user.id;
      
      final response = await _client
          .from('cravings')
          .update(data)
          .eq('id', craving.id!)
          .select()
          .single();
      
      return Craving.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // User Stats Methods
  Future<UserStats?> getUserStats() async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final response = await _client
          .from('user_stats')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return UserStats.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.message.contains('No rows found')) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> updateUserStats() async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Call the edge function to update user stats
      await _client.functions.invoke('updateUserStats', 
        body: {'userId': user.id},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkAchievements() async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Call the edge function to check achievements
      await _client.functions.invoke('checkAchievements', 
        body: {'userId': user.id},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkHealthRecoveries({bool updateAchievements = true}) async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Call the edge function to check health recoveries
      final response = await _client.functions.invoke('checkHealthRecoveries', 
        body: {
          'userId': user.id,
          'updateAchievements': updateAchievements, // Parâmetro para evitar loops infinitos
        },
      );
      
      if (response.status != 200) {
        final errorData = response.data is Map 
          ? response.data as Map<String, dynamic> 
          : {'error': 'Unknown error', 'details': response.data};
        
        // Determine appropriate reason phrase based on status code
        String reasonPhrase;
        switch (response.status) {
          case 400:
            reasonPhrase = 'Bad Request';
            break;
          case 401:
            reasonPhrase = 'Unauthorized';
            break;
          case 403:
            reasonPhrase = 'Forbidden';
            break;
          case 404:
            reasonPhrase = 'Not Found';
            break;
          case 500:
            reasonPhrase = 'Internal Server Error';
            break;
          default:
            reasonPhrase = 'Error ${response.status}';
        }
        
        throw FunctionException(
          status: response.status,
          details: errorData,
          reasonPhrase: reasonPhrase
        );
      }
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Log the error but rethrow
      print('Repository checkHealthRecoveries error: $e');
      rethrow;
    }
  }
  
  // Health Recoveries Methods
  Future<List<HealthRecovery>> getHealthRecoveries() async {
    try {
      final response = await _client
          .from('health_recoveries')
          .select()
          .order('days_to_achieve', ascending: true);
      
      return response.map((recovery) => HealthRecovery.fromJson(recovery)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserHealthRecovery>> getUserHealthRecoveries() async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final response = await _client
          .from('user_health_recoveries')
          .select()
          .eq('user_id', user.id)
          .order('achieved_at', ascending: false);
      
      return response.map((recovery) => UserHealthRecovery.fromJson(recovery)).toList();
    } catch (e) {
      rethrow;
    }
  }
}