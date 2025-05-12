import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/utils/improved_stats_calculator.dart';

/// Serviço para verificar recuperações de saúde localmente
/// 
/// Esta classe substitui a edge function checkHealthRecoveries, permitindo
/// que a verificação de marcos de recuperação de saúde seja feita localmente
/// no dispositivo em vez de no servidor Supabase.
class LocalHealthRecoveryService {
  // Usa Singleton para garantir uma única instância do serviço
  static final LocalHealthRecoveryService _instance = LocalHealthRecoveryService._internal();
  
  factory LocalHealthRecoveryService() {
    return _instance;
  }
  
  LocalHealthRecoveryService._internal();
  
  /// Verifica recuperações de saúde localmente com base nos dias sem fumar
  /// 
  /// Este método busca todas as definições de recuperação de saúde disponíveis,
  /// as recuperações já alcançadas pelo usuário, e identifica novas conquistas
  /// com base nos dias sem fumar.
  /// 
  /// Parâmetros:
  /// - userId: ID do usuário (opcional, usa usuário atual se não fornecido)
  /// - updateAchievements: se true, cria notificações e concede XP (padrão: true)
  /// 
  /// Retorna um mapa com informações sobre as recuperações alcançadas.
  Future<Map<String, dynamic>> checkHealthRecoveries({
    String? userId,
    bool updateAchievements = true,
  }) async {
    try {
      // 1. Obter o ID do usuário atual
      final currentUser = SupabaseConfig.auth.currentUser;
      final userIdToUse = userId ?? currentUser?.id;
      
      if (userIdToUse == null) {
        if (kDebugMode) {
          print('❌ [LocalHealthRecoveryService] Usuário não autenticado');
        }
        throw Exception('User not authenticated');
      }
      
      if (kDebugMode) {
        print('🔄 [LocalHealthRecoveryService] Verificando recuperações de saúde para usuário: $userIdToUse');
      }
      
      // 2. Buscar estatísticas do usuário para obter a data do último cigarro
      final userStatsResponse = await SupabaseConfig.client
          .from('user_stats')
          .select('last_smoke_date')
          .eq('user_id', userIdToUse)
          .maybeSingle();
      
      // Verificar se temos dados de estatísticas e data do último cigarro
      dynamic processedUserStatsResponse = userStatsResponse;
      if (userStatsResponse == null || userStatsResponse['last_smoke_date'] == null) {
        if (kDebugMode) {
          print('⚠️ [LocalHealthRecoveryService] Sem data do último cigarro, verificando cravings...');
        }
        
        // Verificar se há registros de craving para inicializar as estatísticas
        final cravingsResponse = await SupabaseConfig.client
            .from('cravings')
            .select('*')
            .eq('user_id', userIdToUse)
            .limit(1);
        
        if (cravingsResponse == null || (cravingsResponse as List).isEmpty) {
          if (kDebugMode) {
            print('❌ [LocalHealthRecoveryService] Sem histórico de fumo ou cravings');
          }
          return {
            'success': false,
            'error': 'User has no smoking history or cravings to establish a baseline'
          };
        }
        
        // Temos cravings, podemos inicializar user_stats com a data atual
        final now = DateTime.now();
        
        // Criar registro em user_stats com a data atual como last_smoke_date
        try {
          await SupabaseConfig.client
              .from('user_stats')
              .upsert({
                'user_id': userIdToUse,
                'last_smoke_date': now.toIso8601String(),
                'current_streak_days': 0,
                'money_saved': 0,
                'cigarettes_avoided': 0,
                'cravings_resisted': 0
              });
          
          if (kDebugMode) {
            print('✅ [LocalHealthRecoveryService] Inicializado user_stats com data atual');
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ [LocalHealthRecoveryService] Erro ao inicializar user_stats: $e');
          }
          return {
            'success': false,
            'error': 'Failed to initialize user stats',
            'details': e.toString()
          };
        }
        
        // Usar a data atual como data do último cigarro para usuário novo
        processedUserStatsResponse = {
          'last_smoke_date': now.toIso8601String()
        };
      }
      
      // 3. Calcular dias sem fumar
      final lastSmokeDate = DateTime.parse(processedUserStatsResponse['last_smoke_date']);
      final daysWithoutSmoking = ImprovedStatsCalculator.calculateDaysWithoutSmoking(lastSmokeDate);
      
      if (kDebugMode) {
        print('📊 [LocalHealthRecoveryService] Dias sem fumar: $daysWithoutSmoking');
      }
      
      // 4. Verificar se há um evento recente de fumo (na última hora)
      final now = DateTime.now();
      final smokeEventTimeDiff = now.difference(lastSmokeDate).inHours;
      final isRecentSmokeEvent = smokeEventTimeDiff < 1 && daysWithoutSmoking == 0;
      
      // 5. Se um novo cigarro foi registrado recentemente, resetar recuperações de saúde
      if (isRecentSmokeEvent) {
        if (kDebugMode) {
          print('⚠️ [LocalHealthRecoveryService] Evento recente de fumo detectado, resetando recuperações...');
        }
        
        // Buscar recuperações de saúde existentes do usuário
        final existingRecoveriesResponse = await SupabaseConfig.client
            .from('user_health_recoveries')
            .select('id, recovery_id')
            .eq('user_id', userIdToUse);
        
        if (existingRecoveriesResponse != null && (existingRecoveriesResponse as List).isNotEmpty) {
          // Deletar todas as recuperações de saúde deste usuário
          try {
            await SupabaseConfig.client
                .from('user_health_recoveries')
                .delete()
                .eq('user_id', userIdToUse);
            
            if (kDebugMode) {
              print('✅ [LocalHealthRecoveryService] Resetadas ${existingRecoveriesResponse.length} recuperações');
            }
            
            // Criar notificação sobre o reset se updateAchievements é true
            if (updateAchievements) {
              try {
                await SupabaseConfig.client
                    .from('notifications')
                    .insert({
                      'user_id': userIdToUse,
                      'title': 'Health Recovery Reset',
                      'message': 'Your health recovery progress has been reset due to a new smoking event.',
                      'type': 'HEALTH_RECOVERY_RESET',
                      'reference_id': null,
                      'is_read': false
                    });
                
                if (kDebugMode) {
                  print('✅ [LocalHealthRecoveryService] Criada notificação de reset');
                }
              } catch (e) {
                if (kDebugMode) {
                  print('⚠️ [LocalHealthRecoveryService] Erro ao criar notificação: $e');
                }
                // Continuar mesmo com erro na notificação
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ [LocalHealthRecoveryService] Erro ao resetar recuperações: $e');
            }
            // Continuar mesmo com erro no reset
          }
        } else {
          if (kDebugMode) {
            print('ℹ️ [LocalHealthRecoveryService] Sem recuperações para resetar');
          }
        }
      }
      
      // 6. Buscar todas as definições de recuperação de saúde
      final healthRecoveriesResponse = await SupabaseConfig.client
          .from('health_recoveries')
          .select('*')
          .order('days_to_achieve', ascending: true);
      
      if (healthRecoveriesResponse == null) {
        return {
          'success': false,
          'error': 'Unable to fetch health recoveries'
        };
      }
      
      final healthRecoveries = (healthRecoveriesResponse as List)
          .map((recovery) => HealthRecovery.fromJson(recovery))
          .toList();
      
      // 7. Buscar recuperações de saúde já alcançadas pelo usuário
      final userRecoveriesResponse = await SupabaseConfig.client
          .from('user_health_recoveries')
          .select('recovery_id')
          .eq('user_id', userIdToUse);
      
      final achievedRecoveryIds = userRecoveriesResponse != null ?
          Set<String>.from((userRecoveriesResponse as List).map((r) => r['recovery_id'])) :
          <String>{};
      
      // 8. Verificar novas conquistas
      final newAchievements = <Map<String, dynamic>>[];
      
      for (final recovery in healthRecoveries) {
        // Verificar se já foi alcançada a recuperação de saúde
        if (daysWithoutSmoking >= recovery.daysToAchieve && !achievedRecoveryIds.contains(recovery.id)) {
          if (kDebugMode) {
            print('🏆 [LocalHealthRecoveryService] Nova recuperação alcançada: ${recovery.name}');
          }
          
          // Adicionar a recuperação de saúde do usuário
          final newRecoveryResponse = await SupabaseConfig.client
              .from('user_health_recoveries')
              .insert({
                'user_id': userIdToUse,
                'recovery_id': recovery.id,
                'achieved_at': DateTime.now().toIso8601String(),
                'is_viewed': false
              })
              .select()
              .single();
          
          // Salvar no array de novas conquistas
          if (newRecoveryResponse != null) {
            newAchievements.add({
              'id': newRecoveryResponse['id'],
              'recovery_id': recovery.id,
              'name': recovery.name,
              'description': recovery.description,
              'xp_reward': recovery.xpReward,
              'days_to_achieve': recovery.daysToAchieve
            });
            
            // Conceder XP ao usuário se updateAchievements é true
            if (updateAchievements) {
              try {
                await SupabaseConfig.client.rpc('add_user_xp', {
                  'p_user_id': userIdToUse,
                  'p_amount': recovery.xpReward,
                  'p_source': 'HEALTH_RECOVERY',
                  'p_reference_id': recovery.id
                });
                
                if (kDebugMode) {
                  print('💰 [LocalHealthRecoveryService] Concedidos ${recovery.xpReward} XP para recuperação ${recovery.name}');
                }
              } catch (e) {
                if (kDebugMode) {
                  print('⚠️ [LocalHealthRecoveryService] Erro ao conceder XP: $e');
                }
                // Continuar mesmo com erro ao conceder XP
              }
            } else {
              if (kDebugMode) {
                print('ℹ️ [LocalHealthRecoveryService] XP não concedido (updateAchievements=false)');
              }
            }
            
            // Criar notificação se updateAchievements é true
            if (updateAchievements) {
              try {
                await SupabaseConfig.client
                    .from('notifications')
                    .insert({
                      'user_id': userIdToUse,
                      'title': `Health Recovery: ${recovery.name}`,
                      'message': `Your ${recovery.name.toLowerCase()} has improved after ${recovery.daysToAchieve} days without smoking.`,
                      'type': 'HEALTH_RECOVERY',
                      'reference_id': newRecoveryResponse['id'],
                      'is_read': false
                    });
                
                if (kDebugMode) {
                  print('✅ [LocalHealthRecoveryService] Criada notificação para recuperação ${recovery.name}');
                }
              } catch (e) {
                if (kDebugMode) {
                  print('⚠️ [LocalHealthRecoveryService] Erro ao criar notificação: $e');
                }
                // Continuar mesmo com erro na notificação
              }
            } else {
              if (kDebugMode) {
                print('ℹ️ [LocalHealthRecoveryService] Notificação não criada (updateAchievements=false)');
              }
            }
          }
        }
      }
      
      // 9. Retornar resultado
      return {
        'success': true,
        'days_smoke_free': daysWithoutSmoking,
        'new_achievements': newAchievements,
        'total_achievements': achievedRecoveryIds.length + newAchievements.length
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ [LocalHealthRecoveryService] Erro: $e');
      }
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
}