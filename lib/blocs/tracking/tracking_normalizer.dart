import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart'; // Contains SyncStatus enum
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/utils/date_normalizer.dart';
import 'package:nicotinaai_flutter/utils/improved_stats_calculator.dart';

/// Classe de extensão para TrackingBloc que fornece acesso normalizado aos dados estatísticos
/// 
/// Esta classe garante que todas as telas usem os mesmos valores calculados
/// da mesma maneira, evitando inconsistências entre diferentes telas.
extension TrackingNormalizer on TrackingBloc {
  /// Obtém as estatísticas de usuário normalizadas e consistentes
  /// 
  /// Este é o método principal que todas as telas devem usar para acessar estatísticas
  /// em vez de acessar diretamente o estado do BLoC
  UserStats? getNormalizedStats() {
    final currentStats = state.userStats;
    
    // Se não há estatísticas, retornar null
    if (currentStats == null) {
      return null;
    }
    
    // Verificar se temos data do último cigarro
    if (currentStats.lastSmokeDate != null) {
      // Converter a data para UTC se necessário
      final lastSmokeDateUtc = DateNormalizer.toUtc(currentStats.lastSmokeDate!);
      
      // Depurar informações sobre a data em modo de desenvolvimento
      if (kDebugMode) {
        print('🔄 [TrackingNormalizer] Normalizando estatísticas:');
        print('   - Data original do último cigarro: ${currentStats.lastSmokeDate!.toIso8601String()}');
        print('   - Data UTC do último cigarro: ${lastSmokeDateUtc.toIso8601String()}');
        print('   - É UTC: ${lastSmokeDateUtc.isUtc}');
      }
    }
    
    // Usar o ImprovedStatsCalculator para normalizar os valores
    return ImprovedStatsCalculator.getNormalizedStats(currentStats);
  }
  
  /// Obtém os dias sem fumar de forma consistente
  int getDaysWithoutSmoking() {
    final stats = getNormalizedStats();
    if (stats == null || stats.lastSmokeDate == null) {
      return 0;
    }
    
    // Usar o valor normalizado do stats (já processado por DateNormalizer em getNormalizedStats)
    return stats.currentStreakDays;
  }
  
  /// Obtém a data do último cigarro em UTC
  /// Útil para cálculos consistentes de tempo em diferentes componentes
  DateTime? getLastSmokeDateUtc() {
    final stats = getNormalizedStats();
    if (stats == null || stats.lastSmokeDate == null) {
      return null;
    }
    
    // Garantir que estamos retornando uma data UTC
    return DateNormalizer.toUtc(stats.lastSmokeDate!);
  }
  
  /// Obtém os minutos de vida ganhos de forma consistente
  int getMinutesLifeGained() {
    final stats = getNormalizedStats();
    if (stats == null) {
      return 0;
    }
    
    // Usar o valor normalizado
    return stats.totalMinutesGained ?? 0;
  }
  
  /// Obtém o percentual de capacidade pulmonar de forma consistente
  int getBreathCapacityPercent() {
    final daysWithoutSmoking = getDaysWithoutSmoking();
    return ImprovedStatsCalculator.calculateBreathCapacityPercent(daysWithoutSmoking);
  }
  
  /// Obtém os cravings resistidos de forma consistente (total acumulado)
  int getCravingsResisted() {
    final stats = getNormalizedStats();
    if (stats == null) {
      return 0;
    }
    
    // Include both data sources:
    // 1. The database value (stats.cravingsResisted)
    // 2. The count of unified cravings marked as resisted that might not be in the DB yet
    int databaseValue = stats.cravingsResisted;
    
    // Count pending or failed unified cravings that are marked as resisted
    // These might not be reflected in the stats.cravingsResisted value yet
    int pendingResisted = state.unifiedCravings
        .where((c) => c.resisted && 
                     (c.syncStatus == SyncStatus.pending || 
                      c.syncStatus == SyncStatus.failed))
        .length;
    
    if (kDebugMode) {
      print('📊 [TrackingNormalizer] Calculating cravings resisted:');
      print('   - From database: $databaseValue');
      print('   - Pending/failed resisted cravings: $pendingResisted');
      print('   - Total: ${databaseValue + pendingResisted}');
    }
    
    return databaseValue + pendingResisted;
  }
  
  /// Obtém os cravings resistidos apenas no dia atual
  /// 
  /// Usa a data local do dispositivo para determinar o que é "hoje"
  /// para que o contador não resete à meia-noite UTC, o que pode ser
  /// no meio do dia local em alguns fusos horários.
  /// 
  /// Este método SEMPRE calcula os cravings do dia atual, independente 
  /// do que está armazenado no banco de dados, garantindo valores corretos.
  int getCravingsResistedToday() {
    // Get current date at LOCAL midnight for comparison
    // This ensures "today" is based on the user's local date, not UTC
    final now = DateTime.now();
    final todayLocal = DateTime(now.year, now.month, now.day);
    
    // Count all resisted cravings from today (including those pending/failed)
    int todayResisted = state.unifiedCravings
        .where((c) {
          // Must be resisted
          if (!c.resisted) return false;
          
          // Convert timestamp to local time for local date comparison
          final cravingLocal = c.timestamp.toLocal();
          final cravingDateLocal = DateTime(cravingLocal.year, cravingLocal.month, cravingLocal.day);
          
          // Compare local dates (year/month/day only)
          return cravingDateLocal.isAtSameMomentAs(todayLocal);
        })
        .length;
    
    if (kDebugMode) {
      print('📊 [TrackingNormalizer] Calculating cravings resisted TODAY:');
      print('   - Today\'s date (local midnight): ${todayLocal.toIso8601String()}');
      print('   - Current local time: ${now.toIso8601String()}');
      print('   - Resisted cravings today: $todayResisted');
      
      // Print all cravings for debugging
      if (state.unifiedCravings.isNotEmpty) {
        print('   - All resisted cravings:');
        for (final c in state.unifiedCravings.where((c) => c.resisted)) {
          final cravingLocal = c.timestamp.toLocal();
          final cravingDateLocal = DateTime(cravingLocal.year, cravingLocal.month, cravingLocal.day);
          print('     - ${c.id}: ${c.timestamp.toIso8601String()} (local: ${cravingLocal.toIso8601String()})');
          print('       - Same day as today: ${cravingDateLocal.isAtSameMomentAs(todayLocal)}');
        }
      }
    }
    
    return todayResisted;
  }
  
  /// Obtém o dinheiro economizado de forma consistente
  int getMoneySavedInCents() {
    final stats = getNormalizedStats();
    if (stats == null) {
      return 0;
    }
    
    return stats.moneySaved;
  }
  
  /// Obtém os minutos ganhos hoje de forma consistente - com base em cravings resistidos
  /// Cada craving resistido representa 6 minutos de vida ganhos
  String getMinutesGainedTodayFormatted() {
    // Count cravings resisted today
    final cravingsResistedToday = getCravingsResistedToday();
    
    // Calculate minutes gained (6 minutes per craving resisted)
    final minutesGainedToday = cravingsResistedToday * ImprovedStatsCalculator.MINUTES_PER_CIGARETTE;
    
    if (kDebugMode) {
      print('📊 [TrackingNormalizer] Minutes gained today calculation:');
      print('   - Cravings resisted today: $cravingsResistedToday');
      print('   - Minutes gained per craving: ${ImprovedStatsCalculator.MINUTES_PER_CIGARETTE}');
      print('   - Total minutes gained today: $minutesGainedToday');
    }
    
    return "$minutesGainedToday min";
  }
  
  /// Obtém os minutos ganhos hoje como um valor inteiro - com base em cravings resistidos
  /// Cada craving resistido representa 6 minutos de vida ganhos
  int getMinutesGainedToday() {
    // Count cravings resisted today
    final cravingsResistedToday = getCravingsResistedToday();
    
    // Calculate minutes gained (6 minutes per craving resisted)
    return cravingsResistedToday * ImprovedStatsCalculator.MINUTES_PER_CIGARETTE;
  }
  
  /// Calcula a diferença em dias entre duas datas, normalizando para UTC
  /// Método utilitário para uso em widgets que precisam calcular diferenças de tempo
  int calculateDaysBetween(DateTime? start, DateTime? end) {
    if (start == null) {
      return 0;
    }
    
    return DateNormalizer.daysBetween(start, end);
  }
  
  /// Imprime no console os valores normalizados para depuração
  void debugPrintNormalizedStats() {
    if (!kDebugMode) return;
    
    final stats = getNormalizedStats();
    if (stats == null) {
      print('⚠️ [TrackingNormalizer] Estatísticas não disponíveis');
      return;
    }
    
    print('📊 [TrackingNormalizer] Estatísticas Normalizadas:');
    print('   - Dias sem fumar: ${stats.currentStreakDays}');
    print('   - Cravings resistidos: ${stats.cravingsResisted}');
    print('   - Cigarros evitados: ${stats.cigarettesAvoided}');
    print('   - Economia (centavos): ${stats.moneySaved}');
    print('   - Minutos de vida ganhos: ${stats.totalMinutesGained}');
    
    if (stats.lastSmokeDate != null) {
      final lastSmokeUtc = DateNormalizer.toUtc(stats.lastSmokeDate!);
      final lastSmokeMidnightUtc = DateNormalizer.normalizeToMidnightUtc(stats.lastSmokeDate!);
      final now = DateTime.now();
      final nowUtc = DateNormalizer.toUtc(now);
      final nowMidnightUtc = DateNormalizer.normalizeToMidnightUtc(now);
      
      print('   - Data do último cigarro: ${stats.lastSmokeDate!.toIso8601String()} (UTC: ${stats.lastSmokeDate!.isUtc})');
      print('   - Data do último cigarro (UTC): ${lastSmokeUtc.toIso8601String()} (UTC: ${lastSmokeUtc.isUtc})');
      print('   - Data do último cigarro (Meia-noite UTC): ${lastSmokeMidnightUtc.toIso8601String()}');
      print('   - Data atual: ${now.toIso8601String()} (UTC: ${now.isUtc})');
      print('   - Data atual (UTC): ${nowUtc.toIso8601String()} (UTC: ${nowUtc.isUtc})');
      print('   - Data atual (Meia-noite UTC): ${nowMidnightUtc.toIso8601String()}');
      
      // Calcular dias entre usando diferentes métodos para diagnóstico
      final rawDiffDays = nowUtc.difference(lastSmokeUtc).inDays;
      final normalizedDiffDays = DateNormalizer.daysBetween(lastSmokeUtc, nowUtc);
      
      print('   - Diferença em dias (bruta): $rawDiffDays');
      print('   - Diferença em dias (normalizada): $normalizedDiffDays');
    } else {
      print('   - Não há data do último cigarro');
    }
    
    if (state.lastUpdated != null) {
      print('   - Timestamp de atualização: ${DateTime.fromMillisecondsSinceEpoch(state.lastUpdated!).toIso8601String()}');
    } else {
      print('   - Timestamp de atualização: Não disponível');
    }
  }
}