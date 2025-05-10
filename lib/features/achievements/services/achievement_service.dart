import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/achievement_definition.dart';
import '../models/achievement_definitions.dart';
import '../models/user_achievement.dart';
import '../../tracking/repositories/tracking_repository.dart';
import '../../tracking/models/health_recovery.dart';

/// Service responsible for calculating user achievement progress and status
class AchievementService {
  final SupabaseClient _supabase;
  final TrackingRepository _trackingRepo;
  
  // Cache viewed achievements
  Set<String> _viewedAchievementIds = {};
  bool _hasLoadedViewedState = false;

  // Cache para os achievements já notificados nesta sessão do app
  // Isso evita que o mesmo achievement seja notificado múltiplas vezes
  final Set<String> _notifiedAchievementsThisSession = {};

  AchievementService(this._supabase, this._trackingRepo);

  /// Load which achievements have been viewed
  /// with better error handling for when the table doesn't exist yet
  Future<void> loadViewedAchievements() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      try {
        final response = await _supabase
            .from('viewed_achievements')
            .select('achievement_id')
            .eq('user_id', userId);
        
        _viewedAchievementIds = Set.from((response as List).map((item) => item['achievement_id']));
      } catch (e) {
        // Verifica se o erro é porque a tabela não existe
        if (e.toString().contains('relation "public.viewed_achievements" does not exist') ||
            e.toString().contains('42P01')) {
          // Tabela não existe ainda, então usamos um conjunto vazio
          _viewedAchievementIds = {};
          
          // Agendar a criação da tabela para mais tarde
          _scheduleTableCreation();
        } else {
          // Outro tipo de erro
          debugPrint('Error querying viewed achievements: $e');
        }
      }
      
      _hasLoadedViewedState = true;
    } catch (e) {
      debugPrint('Error loading viewed achievements: $e');
      // Define um estado vazio para evitar erros futuros
      _viewedAchievementIds = {};
      _hasLoadedViewedState = true;
    }
  }
  
  /// Log issues with viewed_achievements table
  void _scheduleTableCreation() {
    Future.delayed(const Duration(seconds: 2), () async {
      debugPrint('SECURITY WARNING: Cannot create viewed_achievements table from client-side.');
      debugPrint('The viewed_achievements table should be created through proper Supabase migrations.');
      
      // We'll use an empty local cache as a temporary fallback
      _viewedAchievementIds = {}; 
      _hasLoadedViewedState = true;
      
      // Log info about what needs to be done server-side
      debugPrint('ACTION REQUIRED: Add a migration script to create the viewed_achievements table.');
      debugPrint('Please add the migration using the Supabase dashboard or CLI.');
    });
  }

  /// Mark an achievement as viewed with improved error handling
  Future<void> markAchievementAsViewed(String achievementId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Update local cache immediately
      _viewedAchievementIds.add(achievementId);
      
      try {
        // Update database
        await _supabase.from('viewed_achievements').upsert({
          'user_id': userId,
          'achievement_id': achievementId,
          'viewed_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Verifica se o erro é porque a tabela não existe
        if (e.toString().contains('relation "public.viewed_achievements" does not exist') ||
            e.toString().contains('42P01')) {
          // Tabela não existe ainda, tenta criar
          await _createViewedAchievementsTable();
          
          // Tenta novamente após criar a tabela
          try {
            await _supabase.from('viewed_achievements').upsert({
              'user_id': userId,
              'achievement_id': achievementId,
              'viewed_at': DateTime.now().toIso8601String(),
            });
          } catch (retryError) {
            debugPrint('Error on retry marking achievement as viewed: $retryError');
          }
        } else {
          // Outro tipo de erro
          debugPrint('Error marking achievement as viewed: $e');
        }
      }
    } catch (e) {
      debugPrint('General error marking achievement as viewed: $e');
    }
  }
  
  /// Create the viewed_achievements table using proper channels
  Future<void> _createViewedAchievementsTable() async {
    debugPrint('SECURITY WARNING: Unable to create viewed_achievements table. This operation should not be done on the client side.');
    debugPrint('Please create the table using Supabase migrations or MCP functions instead.');
    
    // Rather than executing SQL from the client, we'll use a simple workaround for now
    // by creating a local cache of viewed achievements. This is a temporary solution until
    // the proper table is created server-side.
    
    // Log detailed instructions for what should be done
    debugPrint('ACTION REQUIRED: Create the viewed_achievements table using Supabase migrations.');
    debugPrint('Table definition should include:');
    debugPrint('1. id UUID PRIMARY KEY');
    debugPrint('2. user_id UUID NOT NULL with foreign key to auth.users');
    debugPrint('3. achievement_id TEXT NOT NULL');
    debugPrint('4. viewed_at TIMESTAMPTZ NOT NULL DEFAULT now()');
    debugPrint('5. UNIQUE constraint on (user_id, achievement_id)');
    debugPrint('6. Appropriate RLS policies for user access control');
    
    // Use local storage as a temporary solution
    _viewedAchievementIds = {}; // Empty set as fallback
  }

  /// Check if an achievement has been viewed
  bool isAchievementViewed(String achievementId) {
    return _viewedAchievementIds.contains(achievementId);
  }

  /// Get all achievement definitions
  List<AchievementDefinition> getAllAchievementDefinitions() {
    return achievementDefinitions;
  }

  /// Get achievement definitions by category
  List<AchievementDefinition> getAchievementDefinitionsByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      return achievementDefinitions;
    }
    return achievementDefinitions
        .where((def) => def.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Calculate user's progress for all achievements
  Future<List<UserAchievement>> calculateUserAchievements() async {
    // Ensure viewed state is loaded
    if (!_hasLoadedViewedState) {
      await loadViewedAchievements();
    }
    
    try {
      // Load user stats
      final stats = await _trackingRepo.getUserStats();
      
      // Handle null stats
      if (stats == null) {
        // Return empty list if stats are unavailable
        debugPrint('⚠️ User stats not available, cannot calculate achievements');
        return [];
      }
      
      // Calculate days smoke-free
      final daysSmokeFreee = stats.lastSmokeDate != null
          ? DateTime.now().difference(stats.lastSmokeDate!).inDays
          : 0;
      
      // For money saved calculation, use hardcoded values since they're not in UserStats
      // TODO: These should be fetched from user preferences or onboarding data
      final cigarettesPerPack = 20; // Default value
      
      // Use cigarettes avoided from stats and directly calculate packs saved
      final cigarettesSaved = stats.cigarettesAvoided;
      final packsSaved = cigarettesPerPack > 0 ? cigarettesSaved / cigarettesPerPack : 0;
      
      // Get health recoveries
      final healthRecoveries = await _getUserHealthRecoveries();
      
      // Get cravings data
      final cravingsResisted = await _getCravingsResisted();
      
      // Calculate each achievement's status
      final userAchievements = <UserAchievement>[];
      
      // Also try to fetch persisted achievements from the database
      final persistedAchievements = await _getPersistedAchievements();
      debugPrint('📊 Found ${persistedAchievements.length} persisted achievements in database');
      
      for (final definition in achievementDefinitions) {
        bool isUnlocked = false;
        double progress = 0.0;
        
        // Check if this achievement is already persisted in the database
        final isPersisted = persistedAchievements.any((a) => a['achievement_id'] == definition.id);
        
        // If already unlocked in database, consider it unlocked
        if (isPersisted) {
          isUnlocked = true;
          progress = 1.0;
          debugPrint('🏆 Achievement ${definition.id} found in database: ${definition.name}');
        } else {
          // Otherwise calculate if it should be unlocked based on current stats
          switch (definition.requirementType) {
            case 'DAYS_SMOKE_FREE':
              final requiredDays = definition.requirementValue as int;
              progress = requiredDays > 0 ? (daysSmokeFreee / requiredDays).clamp(0.0, 1.0) : 0.0;
              isUnlocked = daysSmokeFreee >= requiredDays;
              break;
              
            case 'MONEY_SAVED':
              final requiredPacks = definition.requirementValue as int;
              progress = requiredPacks > 0 ? (packsSaved / requiredPacks).clamp(0.0, 1.0) : 0.0;
              isUnlocked = packsSaved >= requiredPacks;
              break;
              
            case 'CRAVINGS_RESISTED':
              final requiredCravings = definition.requirementValue as int;
              progress = requiredCravings > 0 ? 
                  (cravingsResisted / requiredCravings).clamp(0.0, 1.0) : 0.0;
              isUnlocked = cravingsResisted >= requiredCravings;
              break;
              
            case 'HEALTH_RECOVERY':
              // Check if the specific recovery is achieved
              final recoveryId = definition.requirementValue.toString();
              isUnlocked = healthRecoveries.any((hr) => 
                  hr.recoveryId.toLowerCase() == recoveryId.toLowerCase());
              progress = isUnlocked ? 1.0 : 0.0;
              break;
              
            case 'LOGIN_STREAK':
              // TODO: Implement login streak calculation
              final requiredDays = definition.requirementValue as int;
              final streak = await _getLoginStreak();
              progress = requiredDays > 0 ? (streak / requiredDays).clamp(0.0, 1.0) : 0.0;
              isUnlocked = streak >= requiredDays;
              break;
              
            case 'onboarding_complete':
              // Special case for onboarding achievement
              isUnlocked = true; // If the user is signed in, onboarding is complete
              progress = 1.0;
              break;
              
            case 'EXERCISE_LOGGED':
              // Not implemented yet, show as in progress
              progress = 0.1;  // Show some progress to indicate it's available
              isUnlocked = false;
              break;
              
            default:
              // Unknown requirement type - don't log warning for every calculation
              progress = 0.0;
              isUnlocked = false;
          }
        }
        
        // Create user achievement object
        userAchievements.add(UserAchievement(
          id: definition.id,
          definition: definition,
          unlockedAt: isUnlocked ? DateTime.now() : DateTime(9999), // Future date if not unlocked
          isViewed: isAchievementViewed(definition.id),
          progress: progress,
        ));
      }
      
      // Sort: unlocked first (by unlock date), then by progress
      userAchievements.sort((a, b) {
        if (a.isUnlocked && b.isUnlocked) {
          return a.unlockedAt.compareTo(b.unlockedAt); // Both unlocked, sort by unlock date
        } else if (a.isUnlocked) {
          return -1; // a is unlocked, comes first
        } else if (b.isUnlocked) {
          return 1; // b is unlocked, comes first
        } else {
          return b.progress.compareTo(a.progress); // Neither unlocked, sort by progress
        }
      });
      
      return userAchievements;
    } catch (e) {
      debugPrint('❌ Error calculating user achievements: $e');
      return [];
    }
  }
  
  /// Get achievements that are already persisted in the database
  Future<List<Map<String, dynamic>>> _getPersistedAchievements() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];
      
      final response = await _supabase
          .from('user_achievements')
          .select('achievement_id, unlocked_at, is_viewed')
          .eq('user_id', userId);
      
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('❌ Error fetching persisted achievements: $e');
      return [];
    }
  }
  
  /// Helper method to try to get a UUID from a string ID
  Future<String?> _tryGetAchievementUuid(String achievementId) async {
    try {
      // Try to find the achievement in the database
      final response = await _supabase
          .from('achievements')
          .select('id')
          .eq('id', achievementId)
          .limit(1);
      
      if (response is List && response.isNotEmpty) {
        return response[0]['id'] as String;
      }
      
      // If not found, try to convert directly to UUID
      try {
        // This is just validation - if it parses as UUID, return the original
        return achievementId;
      } catch (_) {
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error finding achievement UUID: $e');
      return null;
    }
  }
  
  /// Force persist any unlocked achievements that aren't already in the database
  /// This helps ensure that achievements are properly stored even if RLS or other issues prevented it
  Future<void> forcePersistUnlockedAchievements() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ Cannot persist achievements: user not logged in');
        return;
      }
      
      // Get current achievements
      final achievements = await calculateUserAchievements();
      final unlockedAchievements = achievements.where((a) => a.isUnlocked).toList();
      
      // Get already persisted achievements to avoid duplicates
      final persistedAchievements = await _getPersistedAchievements();
      final persistedIds = persistedAchievements.map((a) => a['achievement_id'] as String).toSet();
      
      // Find achievements that need to be persisted
      final achievementsToPersist = unlockedAchievements
          .where((a) => !persistedIds.contains(a.id))
          .toList();
      
      if (achievementsToPersist.isEmpty) {
        debugPrint('✅ All unlocked achievements are already persisted (${persistedIds.length})');
        return;
      }
      
      debugPrint('🔄 Persisting ${achievementsToPersist.length} unlocked achievements');
      
      // Persist each achievement using the unlock_achievement function
      for (final achievement in achievementsToPersist) {
        try {
          final params = {
            'p_user_id': userId,
            'p_achievement_id': achievement.id.toString()  // Ensure we send as String
          };
          
          try {
            await _supabase.rpc('unlock_achievement_text', params: params);
          } catch (e) {
            // Fallback to the original function in case of error
            try {
              final uuid = await _tryGetAchievementUuid(achievement.id);
              if (uuid != null) {
                await _supabase.rpc('unlock_achievement', params: {
                  'p_user_id': userId,
                  'p_achievement_id': uuid
                });
              }
            } catch (fallbackError) {
              // Just log the error and continue
              debugPrint('❌ Fallback persistence also failed: $fallbackError');
              throw fallbackError; // Rethrow to trigger outer catch block
            }
          }
          debugPrint('✅ Persisted achievement: ${achievement.definition.name}');
        } catch (e) {
          debugPrint('❌ Error persisting achievement ${achievement.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error in forcePersistUnlockedAchievements: $e');
    }
  }

  // Dados em cache para health recoveries
  List<UserHealthRecovery>? _healthRecoveryCache;
  DateTime? _healthRecoveryCacheTime;
  static const _healthRecoveryCacheExpirationMs = 300000; // 5 minutos
  
  /// Verifica se o cache de health recoveries está válido
  bool get _isHealthRecoveryCacheValid {
    if (_healthRecoveryCache == null || _healthRecoveryCacheTime == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(_healthRecoveryCacheTime!).inMilliseconds;
    return difference < _healthRecoveryCacheExpirationMs;
  }
  
  /// Get user's health recoveries with caching
  Future<List<UserHealthRecovery>> _getUserHealthRecoveries() async {
    // Verifica se o cache é válido
    if (_isHealthRecoveryCacheValid) {
      debugPrint('Using cached health recoveries in AchievementService');
      return _healthRecoveryCache!;
    }
    
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('user_health_recoveries')
          .select('*')
          .eq('user_id', userId);
      
      // Processa os dados
      final result = (response as List)
          .map((data) => UserHealthRecovery.fromJson(data))
          .toList();
      
      // Armazena no cache
      _healthRecoveryCache = result;
      _healthRecoveryCacheTime = DateTime.now();
      
      return result;
    } catch (e) {
      print('Error getting health recoveries: $e');
      // Usa o cache mesmo se for mais antigo, em caso de erro
      return _healthRecoveryCache ?? [];
    }
  }

  /// Get count of resisted cravings
  Future<int> _getCravingsResisted() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      // Get the cravings and count them
      final countResponse = await _supabase
          .from('cravings')
          .select('id') // Just select the ID for better performance
          .eq('user_id', userId)
          .eq('outcome', 'RESISTED');
      
      // Return the count from the response length
      return countResponse.length;
    } catch (e) {
      print('Error getting resisted cravings: $e');
      return 0;
    }
  }

  /// Get user's login streak
  Future<int> _getLoginStreak() async {
    // TODO: Implement proper login streak calculation
    // This would need to check user login history
    // For now, return a placeholder value
    return 0;
  }

  /// Check for newly unlocked achievements and handle notifications/XP
  Future<List<UserAchievement>> checkForNewAchievements() async {
    // Ensure viewed state is loaded
    if (!_hasLoadedViewedState) {
      await loadViewedAchievements();
    }
    
    final currentAchievements = await calculateUserAchievements();
    final newlyUnlocked = <UserAchievement>[];
    
    for (final achievement in currentAchievements) {
      // If unlocked but not viewed, it might be new
      if (achievement.isUnlocked && !achievement.isViewed) {
        // Verifica se já notificamos sobre este achievement nesta sessão
        if (_notifiedAchievementsThisSession.contains(achievement.id)) {
          debugPrint('🔕 Achievement ${achievement.id} already notified this session, skipping notification');
          continue;
        }

        // Adiciona à lista de achievements recém-desbloqueados
        newlyUnlocked.add(achievement);
        
        // Marca como notificado nesta sessão
        _notifiedAchievementsThisSession.add(achievement.id);
        
        // Persist achievement to database using new function
        try {
          final userId = _supabase.auth.currentUser?.id;
          if (userId != null) {
            // Call RPC function to record the achievement using the text variant
            final unlockParams = {
              'p_user_id': userId,
              'p_achievement_id': achievement.id.toString()  // Ensure we send as String
            };
            
            try {
              await _supabase.rpc('unlock_achievement_text', params: unlockParams);
            } catch (e) {
              // Fallback to the original function in case of error
              try {
                final uuid = await _tryGetAchievementUuid(achievement.id);
                if (uuid != null) {
                  await _supabase.rpc('unlock_achievement', params: {
                    'p_user_id': userId,
                    'p_achievement_id': uuid
                  });
                }
              } catch (fallbackError) {
                // Just log the error and continue
                debugPrint('❌ Fallback persistence also failed: $fallbackError');
              }
            }
            debugPrint('✅ Achievement ${achievement.id} persisted to database');
          }
        } catch (e) {
          debugPrint('❌ Error persisting achievement: $e');
          // Continue even if persisting fails - UI will still show achievement
        }
        
        // Award XP if supported
        try {
          final userId = _supabase.auth.currentUser?.id;
          if (userId != null) {
            // Call RPC function to add XP
            final params = {
              'p_user_id': userId,
              'p_amount': achievement.definition.xpReward,
              'p_source': 'ACHIEVEMENT',
              'p_reference_id': achievement.id
            };
            
            await _supabase.rpc('add_user_xp', params: params);
            debugPrint('✅ XP awarded for achievement ${achievement.id}');
          }
        } catch (e) {
          // Ignore if XP function doesn't exist
          debugPrint('⚠️ XP award failed: $e');
        }
        
        // Temporarily disable notifications to reduce errors
        /* 
        // Create notification if supported
        try {
          final userId = _supabase.auth.currentUser?.id;
          if (userId != null) {
            // Create notification using Supabase upsert
            final notification = {
              'user_id': userId,
              'title': 'Achievement Unlocked!',
              'message': 'You\'ve earned the "${achievement.definition.name}" achievement!',
              'notification_type': 'ACHIEVEMENT', // Updated field name to match schema
              'data': {
                'achievement_id': achievement.id,
                'achievement_name': achievement.definition.name
              },
              'status': 'PENDING'
            };
            
            await _supabase.from('user_notifications').upsert(notification);
            debugPrint('✅ Notification created for achievement ${achievement.id}');
          }
        } catch (e) {
          // Ignore if notifications table doesn't exist
          debugPrint('⚠️ Notification creation failed: $e');
        }
        */
        
        // Just log achievement unlock
        debugPrint('🏆 Achievement unlocked: ${achievement.definition.name}');
      }
    }
    
    return newlyUnlocked;
  }
}