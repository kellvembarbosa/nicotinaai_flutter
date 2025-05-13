import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/utils/date_normalizer.dart';

/// Classe utilitária melhorada para cálculos de estatísticas de saúde e economia
/// Implementa a lógica de normalização de valores para garantir consistência em todo o app
class ImprovedStatsCalculator {
  // Valores padrão centralizados como fallback, mas com preferência para valores do usuário
  static const int DEFAULT_PACK_PRICE_CENTS = 1200;
  static const int DEFAULT_CIGARETTES_PER_PACK = 20;
  static const int DEFAULT_CIGARETTES_PER_DAY = 20;
  static const int MINUTES_PER_CIGARETTE = 6;
  
  /// Normaliza as estatísticas do usuário para garantir valores consistentes
  /// Deve ser usado sempre antes de exibir estatísticas para o usuário
  static UserStats getNormalizedStats(UserStats stats) {
    // Se não temos data do último cigarro, retornar as estatísticas como estão
    if (stats.lastSmokeDate == null) {
      return stats;
    }
    
    // Garantir que a data do último cigarro esteja em UTC
    final lastSmokeDateUtc = DateNormalizer.toUtc(stats.lastSmokeDate!);
    
    // Se as datas são diferentes (uma era UTC e outra local)
    if (lastSmokeDateUtc.millisecondsSinceEpoch != stats.lastSmokeDate!.millisecondsSinceEpoch) {
      if (kDebugMode) {
        print('🔍 [ImprovedStatsCalculator] Normalizing lastSmokeDate:');
        print('   - Original: ${stats.lastSmokeDate!.toIso8601String()} (UTC: ${stats.lastSmokeDate!.isUtc})');
        print('   - Normalized UTC: ${lastSmokeDateUtc.toIso8601String()} (UTC: ${lastSmokeDateUtc.isUtc})');
      }
    }
    
    // Calcular dias sem fumar baseado na data UTC normalizada
    final now = DateTime.now().toUtc();
    final daysWithoutSmoking = DateNormalizer.daysBetween(lastSmokeDateUtc, now);
    
    // Calcular cigarros evitados com base nos dias sem fumar
    final cigarettesPerDay = stats.cigarettesPerDay ?? DEFAULT_CIGARETTES_PER_DAY;
    final calculatedCigarettesAvoided = daysWithoutSmoking * cigarettesPerDay;
    
    // Calcular economia com base nos cigarros evitados
    final packPrice = stats.packPrice ?? DEFAULT_PACK_PRICE_CENTS;
    final cigarettesPerPack = stats.cigarettesPerPack ?? DEFAULT_CIGARETTES_PER_PACK;
    final pricePerCigarette = packPrice / cigarettesPerPack;
    final calculatedMoneySaved = (calculatedCigarettesAvoided * pricePerCigarette).round();
    
    // Calcular total de minutos de vida ganhos
    final calculatedTotalMinutesGained = calculateMinutesGained(calculatedCigarettesAvoided);
    
    if (kDebugMode) {
      print('📊 [ImprovedStatsCalculator] Normalized stats calculation:');
      print('   - Dias sem fumar: $daysWithoutSmoking');
      print('   - Cigarros por dia: $cigarettesPerDay');
      print('   - Preço por maço: ${packPrice}¢');
      print('   - Cigarros por maço: $cigarettesPerPack');
      print('   - Cigarros evitados calculados: $calculatedCigarettesAvoided');
      print('   - Economia calculada: ${calculatedMoneySaved}¢');
      print('   - Minutos ganhos calculados: $calculatedTotalMinutesGained');
    }
    
    // Se as estatísticas têm valores zerados ou nulos que deveriam ter valores positivos
    // vamos substituir com os valores calculados
    final int normalizedCigarettesAvoided;
    final int normalizedMoneySaved;
    final int normalizedTotalMinutesGained;
    final int normalizedCurrentStreakDays;
    
    // Comparar valores e usar os calculados se os originais parecem incorretos
    if (stats.cigarettesAvoided == 0 && calculatedCigarettesAvoided > 0) {
      normalizedCigarettesAvoided = calculatedCigarettesAvoided;
    } else {
      normalizedCigarettesAvoided = stats.cigarettesAvoided;
    }
    
    // Comparar economia e usar valor calculado se o original parece incorreto
    if (stats.moneySaved == 0 && calculatedMoneySaved > 0) {
      normalizedMoneySaved = calculatedMoneySaved;
    } else {
      normalizedMoneySaved = stats.moneySaved;
    }
    
    // Verificar minutos ganhos
    if (stats.totalMinutesGained == 0 && calculatedTotalMinutesGained > 0) {
      normalizedTotalMinutesGained = calculatedTotalMinutesGained;
    } else {
      normalizedTotalMinutesGained = stats.totalMinutesGained ?? calculatedTotalMinutesGained;
    }
    
    // Verificar dias de sequência
    if (stats.currentStreakDays == 0 && daysWithoutSmoking > 0) {
      normalizedCurrentStreakDays = daysWithoutSmoking;
    } else {
      normalizedCurrentStreakDays = stats.currentStreakDays;
    }
    
    // Retornar estatísticas normalizadas
    return stats.copyWith(
      cigarettesAvoided: normalizedCigarettesAvoided,
      moneySaved: normalizedMoneySaved,
      totalMinutesGained: normalizedTotalMinutesGained,
      currentStreakDays: normalizedCurrentStreakDays,
      lastSmokeDate: lastSmokeDateUtc,
    );
  }
  
  /// Calcula minutos de vida ganhos com base nos cigarros evitados
  static int calculateMinutesGained(int cigarettesAvoided) {
    return cigarettesAvoided * MINUTES_PER_CIGARETTE;
  }
  
  /// Calcula o percentual de capacidade pulmonar recuperada
  /// baseado em dias sem fumar
  static int calculateBreathCapacityPercent(int daysWithoutSmoking) {
    // Modelo simplificado de recuperação pulmonar:
    // - Começa em 70% ao parar de fumar
    // - Recupera linearmente até 100% em 270 dias (9 meses)
    
    // Percentual base ao parar de fumar
    const int basePercent = 70;
    
    // Dias para recuperação total
    const int daysToFullRecovery = 270;
    
    // Cada dia representa quanto percentual de recuperação?
    const double percentPerDay = (100 - basePercent) / daysToFullRecovery;
    
    // Calcular percentual atual
    int currentPercent = basePercent + (daysWithoutSmoking * percentPerDay).round();
    
    // Limitar a 100%
    return currentPercent > 100 ? 100 : currentPercent;
  }
  
  /// Calcula a economia monetária baseada em dias sem fumar
  static int calculateMoneySaved({
    required int daysWithoutSmoking,
    required int cigarettesPerDay,
    required int packPrice,
    required int cigarettesPerPack,
  }) {
    // Calcular cigarros evitados
    final int cigarettesAvoided = daysWithoutSmoking * cigarettesPerDay;
    
    // Calcular preço por cigarro
    final double pricePerCigarette = packPrice / cigarettesPerPack;
    
    // Calcular economia total
    final int moneySaved = (cigarettesAvoided * pricePerCigarette).round();
    
    return moneySaved;
  }
  
  /// Converte minutos em uma representação de dias/horas/minutos
  static String formatTimeGained(int minutes) {
    final int days = minutes ~/ 1440; // 24 * 60
    final int remainingMinutes = minutes % 1440;
    final int hours = remainingMinutes ~/ 60;
    final int mins = remainingMinutes % 60;
    
    if (days > 0) {
      return '$days dias, $hours horas e $mins minutos';
    } else if (hours > 0) {
      return '$hours horas e $mins minutos';
    } else {
      return '$mins minutos';
    }
  }
}