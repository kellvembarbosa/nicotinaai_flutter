import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';
import 'package:nicotinaai_flutter/utils/improved_stats_calculator.dart';

/// Serviço para calcular estatísticas do usuário localmente
/// 
/// Esta classe substitui a edge function updateUserStats, permitindo
/// que o cálculo de estatísticas seja feito localmente no dispositivo
/// em vez de no servidor Supabase.
class LocalStatsService {
  // Usa Singleton para garantir uma única instância do serviço
  static final LocalStatsService _instance = LocalStatsService._internal();
  
  factory LocalStatsService() {
    return _instance;
  }
  
  LocalStatsService._internal();
  
  /// Calcula e atualiza estatísticas do usuário localmente
  /// 
  /// Este método busca todos os registros de cigarros e cravings do usuário,
  /// calcula as estatísticas e atualiza a tabela user_stats no Supabase.
  /// 
  /// Retorna as estatísticas atualizadas ou null em caso de erro.
  Future<UserStats?> updateUserStats({String? userId}) async {
    try {
      // 1. Obter o ID do usuário atual
      final currentUser = SupabaseConfig.auth.currentUser;
      final userIdToUse = userId ?? currentUser?.id;
      
      if (userIdToUse == null) {
        if (kDebugMode) {
          print('❌ [LocalStatsService] Usuário não autenticado');
        }
        return null;
      }
      
      if (kDebugMode) {
        print('🔄 [LocalStatsService] Atualizando estatísticas para o usuário: $userIdToUse');
      }
      
      // 2. Buscar estatísticas atuais
      final userStatsResponse = await SupabaseConfig.client
          .from('user_stats')
          .select('*')
          .eq('user_id', userIdToUse)
          .maybeSingle();
          
      // 3. Buscar todos os registros de fumo
      final smokingLogsResponse = await SupabaseConfig.client
          .from('smoking_logs')
          .select('*')
          .eq('user_id', userIdToUse)
          .order('timestamp', ascending: false);
          
      final smokingLogs = (smokingLogsResponse as List)
          .map((log) => SmokingRecordModel.fromJson(log))
          .toList();
          
      // 4. Buscar todas as cravings
      final cravingsResponse = await SupabaseConfig.client
          .from('cravings')
          .select('*')
          .eq('user_id', userIdToUse);
          
      final cravings = (cravingsResponse as List)
          .map((craving) => CravingModel.fromJson(craving))
          .toList();
          
      // 5. Calcular estatísticas
      
      // Data do último cigarro (registro mais recente)
      DateTime? lastSmokeDate;
      if (smokingLogs.isNotEmpty) {
        lastSmokeDate = smokingLogs.first.timestamp;
      }
      
      // Contadores
      int cravingsResisted = 0;
      int cigarettesSmoked = 0;
      int smokingRecordsCount = smokingLogs.length;
      
      // Contar cravings resistidas
      for (final craving in cravings) {
        if (craving.resisted) {
          cravingsResisted++;
        }
      }
      
      // Contar cigarros fumados
      for (final log in smokingLogs) {
        // Converter o amount string para quantidade estimada
        int quantity = 1; // valor padrão
        switch (log.amount) {
          case 'one_or_less':
            quantity = 1;
            break;
          case 'two_to_five':
            quantity = 3; // Média de 2-5
            break;
          case 'more_than_five':
            quantity = 6;
            break;
        }
        cigarettesSmoked += quantity;
      }
      
      // Calcular dias sem fumar
      int currentStreakDays = 0;
      if (lastSmokeDate != null) {
        currentStreakDays = ImprovedStatsCalculator.calculateDaysWithoutSmoking(lastSmokeDate);
      }
      
      // Pegar preferências do usuário (ou valores padrão)
      int cigarettesPerDay = userStatsResponse != null ? 
          (userStatsResponse['cigarettes_per_day'] ?? ImprovedStatsCalculator.DEFAULT_CIGARETTES_PER_DAY) :
          ImprovedStatsCalculator.DEFAULT_CIGARETTES_PER_DAY;
          
      int cigarettesPerPack = userStatsResponse != null ? 
          (userStatsResponse['cigarettes_per_pack'] ?? ImprovedStatsCalculator.DEFAULT_CIGARETTES_PER_PACK) :
          ImprovedStatsCalculator.DEFAULT_CIGARETTES_PER_PACK;
          
      int packPrice = userStatsResponse != null ? 
          (userStatsResponse['pack_price'] ?? ImprovedStatsCalculator.DEFAULT_PACK_PRICE_CENTS) :
          ImprovedStatsCalculator.DEFAULT_PACK_PRICE_CENTS;
          
      // Calcular cigarros evitados e economia
      int cigarettesAvoided = 0;
      if (lastSmokeDate != null) {
        cigarettesAvoided = ImprovedStatsCalculator.calculateCigarettesAvoided(
          lastSmokeDate, 
          cigarettesPerDay
        );
      }
      
      // Usando o método com parâmetros nomeados
      int moneySaved = ImprovedStatsCalculator.calculateMoneySaved(
        daysWithoutSmoking: currentStreakDays,
        cigarettesPerDay: cigarettesPerDay,
        packPrice: packPrice,
        cigarettesPerPack: cigarettesPerPack
      );
      
      // Calcular minutos ganhos
      int totalMinutesGained = ImprovedStatsCalculator.calculateMinutesGained(cigarettesAvoided);
      
      // Calcular minutos ganhos hoje
      int minutesGainedToday = cigarettesPerDay * ImprovedStatsCalculator.MINUTES_PER_CIGARETTE ~/ 24;
      
      // 6. Atualizar a maior sequência (se a atual for maior)
      int longestStreakDays = userStatsResponse != null ? 
          (userStatsResponse['longest_streak_days'] ?? 0) : 0;
          
      if (currentStreakDays > longestStreakDays) {
        longestStreakDays = currentStreakDays;
      }
      
      // 7. Preparar dados para atualização
      final updateData = {
        'user_id': userIdToUse,
        'cigarettes_avoided': cigarettesAvoided,
        'money_saved': moneySaved,
        'cravings_resisted': cravingsResisted,
        'current_streak_days': currentStreakDays,
        'longest_streak_days': longestStreakDays,
        'last_smoke_date': lastSmokeDate?.toIso8601String(),
        'cigarettes_smoked': cigarettesSmoked,
        'smoking_records_count': smokingRecordsCount,
        'minutes_gained_today': minutesGainedToday,
        'total_minutes_gained': totalMinutesGained,
        'updated_at': DateTime.now().toIso8601String()
      };
      
      if (kDebugMode) {
        print('📊 [LocalStatsService] Dados calculados:');
        print('- Cravings resistidas: $cravingsResisted');
        print('- Cigarros evitados: $cigarettesAvoided');
        print('- Economia: $moneySaved centavos');
        print('- Dias sem fumar: $currentStreakDays');
        print('- Minutos ganhos total: $totalMinutesGained');
      }
      
      // 8. Salvar no Supabase via upsert
      await SupabaseConfig.client
          .from('user_stats')
          .upsert(updateData)
          .select();
      
      // 9. Obter estatísticas atualizadas
      final updatedStatsResponse = await SupabaseConfig.client
          .from('user_stats')
          .select('*')
          .eq('user_id', userIdToUse)
          .single();
          
      return UserStats.fromJson(updatedStatsResponse);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [LocalStatsService] Erro ao atualizar estatísticas: $e');
      }
      return null;
    }
  }
}