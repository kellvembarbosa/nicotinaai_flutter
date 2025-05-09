import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:flutter/material.dart';

/// Helper functions for working with health recoveries
class HealthRecoveryUtils {
  static final _client = SupabaseConfig.client;
  
  // Cache para evitar chamadas repetidas
  static final Map<String, dynamic> _cache = {};
  static DateTime? _lastCheckTime;
  static const _cacheExpirationMs = 60000; // 1 minuto
  
  /// Verifica se uma operação foi executada recentemente
  static bool _wasRecentlyExecuted(String operation) {
    if (_lastCheckTime == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(_lastCheckTime!).inMilliseconds;
    return difference < _cacheExpirationMs;
  }

  /// Check for new health recoveries for the current user
  /// Returns the result from the checkHealthRecoveries edge function
  /// 
  /// @param updateAchievements Se true, verificará achievements. Se false, apenas verifica health recoveries.
  /// Isso ajuda a quebrar o ciclo de dependência que causa loops infinitos.
  static Future<Map<String, dynamic>> checkForNewRecoveries({bool updateAchievements = true}) async {
    try {
      // Verifica cache para evitar chamadas repetidas
      if (_wasRecentlyExecuted('checkForNewRecoveries')) {
        debugPrint('Using cached health recovery checks');
        return _cache['checkForNewRecoveries'] ?? {'message': 'Using cached data (empty)'};
      }
      
      _lastCheckTime = DateTime.now();
      
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Call the edge function to check health recoveries
      final response = await _client.functions.invoke('checkHealthRecoveries', 
        body: {
          'userId': user.id,
          'updateAchievements': updateAchievements, // Parâmetro adicional para controle
        },
      );
      
      if (response.status != 200) {
        throw Exception('Failed to check health recoveries: Status ${response.status}');
      }
      
      // Armazena em cache
      _cache['checkForNewRecoveries'] = response.data as Map<String, dynamic>;
      
      return _cache['checkForNewRecoveries']!;
    } catch (e) {
      // Log the error but don't crash the app
      debugPrint('Error checking health recoveries: $e');
      rethrow;
    }
  }
  
  /// Get the number of days required to achieve all health recoveries
  static Future<List<int>> getHealthRecoveryMilestones() async {
    try {
      // Verifica cache para evitar chamadas repetidas
      if (_wasRecentlyExecuted('getHealthRecoveryMilestones') && 
          _cache.containsKey('healthRecoveryMilestones')) {
        return _cache['healthRecoveryMilestones'] as List<int>;
      }
      
      final response = await _client
          .from('health_recoveries')
          .select('days_to_achieve')
          .order('days_to_achieve', ascending: true);
      
      final result = (response as List).map((r) => r['days_to_achieve'] as int).toList();
      
      // Armazena em cache
      _cache['healthRecoveryMilestones'] = result;
      _lastCheckTime = DateTime.now();
      
      return result;
    } catch (e) {
      // Return some sensible defaults if we can't get the milestones
      debugPrint('Error getting health recovery milestones: $e');
      return [1, 2, 3, 7, 14, 30, 90, 365];
    }
  }
  
  /// Get the next health recovery milestone for a given number of days
  static Future<int> getNextMilestone(int currentDays) async {
    debugPrint('Getting next milestone for streak: $currentDays days');
    
    try {
      // Verificar o cache para evitar chamadas repetidas
      final cacheKey = 'nextMilestone_$currentDays';
      if (_wasRecentlyExecuted(cacheKey) && _cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as int;
      }
      
      final milestones = await getHealthRecoveryMilestones();
      
      if (milestones.isEmpty) {
        debugPrint('No health recovery milestones found, using default value 365');
        return 365; // Default fallback if no milestones available
      }
      
      // Find the next milestone that's greater than the current days
      for (final days in milestones) {
        if (days > currentDays) {
          // Armazena em cache
          _cache[cacheKey] = days;
          return days;
        }
      }
      
      // If there are no more milestones, return the last one
      _cache[cacheKey] = milestones.last;
      return milestones.last;
    } catch (e) {
      debugPrint('Error getting next health recovery milestone: $e');
      // Return a sensible default if we can't get the milestones
      return currentDays < 365 ? 365 : currentDays + 30;
    }
  }
  
  /// Calculate progress towards the next milestone
  static Future<double> getProgressToNextMilestone(int currentDays) async {
    try {
      // Verificar cache para evitar chamadas repetidas
      final cacheKey = 'progressToNext_$currentDays';
      if (_wasRecentlyExecuted(cacheKey) && _cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as double;
      }
      
      final milestones = await getHealthRecoveryMilestones();
      
      // Handle no milestones case
      if (milestones.isEmpty) {
        debugPrint('No health recovery milestones found for progress calculation');
        final defaultProgress = currentDays > 0 ? 0.5 : 0.0;
        _cache[cacheKey] = defaultProgress;
        return defaultProgress;
      }
      
      // If already past all milestones
      if (currentDays >= milestones.last) {
        _cache[cacheKey] = 1.0;
        return 1.0; // 100% progress
      }
      
      // Find the previous and next milestones
      int? previousMilestone;
      int nextMilestone = milestones.first;
      
      for (final days in milestones) {
        if (days <= currentDays) {
          previousMilestone = days;
        } else {
          nextMilestone = days;
          break;
        }
      }
      
      // If no previous milestone, use 0
      previousMilestone ??= 0;
      
      // Calculate progress between previous and next milestones
      final totalDays = nextMilestone - previousMilestone;
      final progressDays = currentDays - previousMilestone;
      
      // Avoid division by zero
      final progress = totalDays > 0 ? progressDays / totalDays : 0.0;
      
      // Ensure progress is between 0 and 1
      final result = progress.clamp(0.0, 1.0);
      
      // Armazenar em cache
      _cache[cacheKey] = result;
      _lastCheckTime = DateTime.now();
      
      return result;
    } catch (e) {
      debugPrint('Error calculating progress to next milestone: $e');
      // Return a sensible default if calculation fails
      return 0.0;
    }
  }
  
  /// Get detailed information about a user's health recoveries
  /// including those achieved and those still in progress
  static Future<Map<String, dynamic>> getUserHealthRecoveryStatus() async {
    try {
      // Verifica cache para evitar chamadas repetidas
      final cacheKey = 'userHealthRecoveryStatus';
      if (_wasRecentlyExecuted(cacheKey) && _cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as Map<String, dynamic>;
      }
      
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Get all health recoveries
      final recoveries = await _client
          .from('health_recoveries')
          .select()
          .order('days_to_achieve', ascending: true);
      
      // Get user's achieved health recoveries
      final userRecoveries = await _client
          .from('user_health_recoveries')
          .select('*, recovery:recovery_id(*)')
          .eq('user_id', user.id)
          .order('achieved_at', ascending: false);
      
      // Get user's streak information
      // Usamos maybeSingle() em vez de single() para evitar exceções quando nenhuma linha é encontrada
      final userStatsResponse = await _client
          .from('user_stats')
          .select('current_streak_days, last_smoke_date')
          .eq('user_id', user.id)
          .maybeSingle();
      
      // Se não encontrou dados do usuário, retorne um objeto vazio
      if (userStatsResponse == null) {
        final emptyResult = {
          'recoveries': <Map<String, dynamic>>[],
          'achieved_recoveries': <Map<String, dynamic>>[],
          'current_streak_days': 0,
          'last_smoke_date': null,
        };
        
        // Armazena em cache para evitar chamadas repetidas
        _cache[cacheKey] = emptyResult;
        _lastCheckTime = DateTime.now();
        
        debugPrint('⚠️ Nenhum dado de usuário encontrado em user_stats');
        return emptyResult;
      }
      
      final userStats = userStatsResponse;
      
      final currentStreakDays = userStats['current_streak_days'] as int? ?? 0;
      final lastSmokeDate = userStats['last_smoke_date'] != null
          ? DateTime.parse(userStats['last_smoke_date'])
          : null;
      
      // Se não tiver data do último cigarro, retorna dados vazios para evitar cálculos desnecessários
      if (lastSmokeDate == null) {
        final emptyResult = {
          'recoveries': <Map<String, dynamic>>[],
          'achieved_recoveries': <Map<String, dynamic>>[],
          'current_streak_days': currentStreakDays,
          'last_smoke_date': null,
        };
        
        // Armazena em cache para evitar chamadas repetidas
        _cache[cacheKey] = emptyResult;
        _lastCheckTime = DateTime.now();
        
        return emptyResult;
      }
      
      // Mark each recovery as achieved or in progress
      final allRecoveries = (recoveries as List).map((dynamic r) {
        // First convert r to Map<String, dynamic> to ensure consistent typing
        final Map<String, dynamic> recoveryMap = Map<String, dynamic>.from(r as Map);
        
        final recoveryObj = HealthRecovery.fromJson(recoveryMap);
        final daysToAchieve = recoveryObj.daysToAchieve;
        final isAchieved = userRecoveries.any((ur) => ur['recovery_id'] == recoveryObj.id);
        final progress = daysToAchieve > 0 && daysToAchieve > currentStreakDays
            ? currentStreakDays / daysToAchieve
            : isAchieved ? 1.0 : 0.0;
        
        // Return a new Map<String, dynamic> with all properties
        return Map<String, dynamic>.from({
          ...recoveryMap,
          'is_achieved': isAchieved,
          'progress': progress,
          'days_remaining': isAchieved ? 0 : (daysToAchieve - currentStreakDays) > 0 ? (daysToAchieve - currentStreakDays) : 0
        });
      }).toList();
      
      // Ensure userRecoveries is properly converted to avoid type issues
      final safeUserRecoveries = (userRecoveries as List).map((dynamic item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();
      
      final result = {
        'recoveries': allRecoveries,
        'achieved_recoveries': safeUserRecoveries,
        'current_streak_days': currentStreakDays,
        'last_smoke_date': lastSmokeDate?.toIso8601String(),
      };
      
      // Armazena em cache para evitar chamadas repetidas
      _cache[cacheKey] = result;
      _lastCheckTime = DateTime.now();
      
      return result;
    } catch (e) {
      debugPrint('Error getting user health recovery status: $e');
      rethrow;
    }
  }
  
  /// Get the next health recovery milestone that is not yet achieved
  /// 
  /// Returns a map with details about the next milestone:
  /// - id: The ID of the health recovery
  /// - name: The name of the health recovery
  /// - description: The description of the health recovery
  /// - daysToAchieve: Days required to achieve this milestone
  /// - daysRemaining: Days remaining until this milestone is achieved
  /// - progress: Progress towards this milestone (0.0 to 1.0)
  /// - isNext: Whether this is the very next milestone to achieve
  /// - icon: Suggested icon for this milestone
  /// 
  /// If all milestones have been achieved, it returns null.
  static Future<Map<String, dynamic>?> getNextHealthRecoveryMilestone(int currentStreakDays) async {
    try {
      // Check cache para evitar chamadas repetidas
      final cacheKey = 'nextMilestone_$currentStreakDays';
      if (_wasRecentlyExecuted(cacheKey) && _cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as Map<String, dynamic>?;
      }
      
      // Log the current streak for debugging
      debugPrint('Getting next milestone for streak: $currentStreakDays days');
      
      try {
        // Get all health recoveries and their status
        final status = await getUserHealthRecoveryStatus();
      
        // Safe check for recoveries
        if (!status.containsKey('recoveries') || status['recoveries'] == null) {
          debugPrint('Error: No recoveries found in status');
          _cache[cacheKey] = null;
          return null;
        }
        
        final recoveries = status['recoveries'] as List;
        
        debugPrint('Found ${recoveries.length} total health recoveries');
        
        // Filter to only non-achieved recoveries and sort by days to achieve
        final nonAchievedRecoveries = recoveries
            .where((r) => r['is_achieved'] != true)
            .toList()
          ..sort((a, b) => a['days_to_achieve'].compareTo(b['days_to_achieve']));
        
        debugPrint('Found ${nonAchievedRecoveries.length} non-achieved recoveries');
        
        // If all recoveries are achieved, return null
        if (nonAchievedRecoveries.isEmpty) {
          _cache[cacheKey] = null;
          return null;
        }
      
      // Find the next recovery - the one with the lowest days_to_achieve that is higher than current streak
      Map<String, dynamic>? nextRecovery;
      
      // First try to find a recovery with days_to_achieve > currentStreakDays
      final futureRecoveries = nonAchievedRecoveries.where(
        (r) => r['days_to_achieve'] > currentStreakDays
      ).toList();
      
      dynamic rawRecovery;
      
      if (futureRecoveries.isNotEmpty) {
        // Get the closest future recovery
        rawRecovery = futureRecoveries.first;
        debugPrint('Found next recovery: ${rawRecovery['name']} at ${rawRecovery['days_to_achieve']} days');
      } else if (nonAchievedRecoveries.isNotEmpty) {
        // If no future recoveries found, use the first non-achieved one as fallback
        rawRecovery = nonAchievedRecoveries.first;
        debugPrint('Using fallback recovery: ${rawRecovery['name']} at ${rawRecovery['days_to_achieve']} days');
      } else {
        _cache[cacheKey] = null;
        return null; // No recoveries available
      }
      
      // Convert the dynamic Map to Map<String, dynamic> manually
      nextRecovery = Map<String, dynamic>.from(rawRecovery as Map);
      
      // Get icon based on name or type
      IconData icon = Icons.healing;
      final iconName = nextRecovery['icon_name'] as String?;
      if (iconName != null) {
        final iconMap = {
          'taste': Icons.restaurant,
          'smell': Icons.air,
          'blood_drop': Icons.bloodtype,
          'lungs': Icons.air_rounded,
          'heart': Icons.favorite,
          'chemical': Icons.science,
          'circulation': Icons.bike_scooter,
        };
        
        icon = iconMap[iconName] ?? Icons.healing;
      } else {
        // Try to guess icon from name
        final name = nextRecovery['name'].toString().toLowerCase();
        if (name.contains('taste')) icon = Icons.restaurant;
        else if (name.contains('smell')) icon = Icons.air;
        else if (name.contains('blood')) icon = Icons.bloodtype;
        else if (name.contains('lung') || name.contains('breath')) icon = Icons.air_rounded;
        else if (name.contains('heart')) icon = Icons.favorite;
        else if (name.contains('chemical') || name.contains('nicotin')) icon = Icons.science;
        else if (name.contains('circulation')) icon = Icons.bike_scooter;
      }
      
      // Create result
      final result = {
        'id': nextRecovery['id'],
        'name': nextRecovery['name'],
        'description': nextRecovery['description'],
        'daysToAchieve': nextRecovery['days_to_achieve'],
        'daysRemaining': nextRecovery['days_remaining'],
        'progress': nextRecovery['progress'],
        'isNext': true,
        'icon': icon,
      };
      
      // Store in cache
      _cache[cacheKey] = result;
      _lastCheckTime = DateTime.now();
      
      return result;
    } catch (e) {
      debugPrint('Error getting next health recovery milestone: $e');
      return null;
    } // Fechando o try interno
    } catch (e) {
      debugPrint('Error in getNextHealthRecoveryMilestone: $e');
      return null;
    } // Fechando o try externo
  }
}