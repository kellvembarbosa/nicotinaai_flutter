import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';

class StatsCalculator {
  // Valores padrão centralizados
  static const int DEFAULT_PACK_PRICE_CENTS = 1200;
  static const int DEFAULT_CIGARETTES_PER_PACK = 20;
  static const int DEFAULT_CIGARETTES_PER_DAY = 20;
  static const int MINUTES_PER_CIGARETTE = 6;

  /// Calcula as estatísticas atualizadas após adicionar um craving
  static UserStats calculateAddCraving(UserStats currentStats) {
    // Calcular o preço por cigarro
    final double pricePerCigarette = 
      (currentStats.packPrice ?? DEFAULT_PACK_PRICE_CENTS) / 
      (currentStats.cigarettesPerPack ?? DEFAULT_CIGARETTES_PER_PACK);
    
    // Incrementar valores relevantes
    final int newCravingsResisted = (currentStats.cravingsResisted ?? 0) + 1;
    final int newCigarettesAvoided = (currentStats.cigarettesAvoided) + 1;
    final int newMoneySaved = currentStats.moneySaved + pricePerCigarette.round();
    
    debugPrint('💰 [StatsCalculator] Craving adicionado: cravings=$newCravingsResisted, cigarros evitados=$newCigarettesAvoided, economia=${newMoneySaved}¢');
    
    return currentStats.copyWith(
      cravingsResisted: newCravingsResisted,
      cigarettesAvoided: newCigarettesAvoided,
      moneySaved: newMoneySaved
    );
  }

  /// Calcula as estatísticas atualizadas após adicionar um registro de fumo
  static UserStats calculateAddSmoking(UserStats currentStats, int amount) {
    // Calcular o preço do cigarro fumado
    final double pricePerCigarette = 
      (currentStats.packPrice ?? DEFAULT_PACK_PRICE_CENTS) / 
      (currentStats.cigarettesPerPack ?? DEFAULT_CIGARETTES_PER_PACK);
    
    // Calcular novos valores
    final int smokingRecordsCount = (currentStats.smokingRecordsCount ?? 0) + 1;
    final int cigarettesSmoked = (currentStats.cigarettesSmoked ?? 0) + amount;
    
    // Reinicia cigarros evitados e atualiza a sequência atual
    final int newCigarettesAvoided = 0;
    final int currentStreakDays = 0; // Reinicia a sequência quando fuma
    
    // Manter o dinheiro economizado (não reiniciar)
    final int moneySaved = currentStats.moneySaved;
    
    debugPrint('🚬 [StatsCalculator] Registro de fumo adicionado: total=${cigarettesSmoked}, registros=${smokingRecordsCount}');
    
    return currentStats.copyWith(
      smokingRecordsCount: smokingRecordsCount,
      cigarettesSmoked: cigarettesSmoked,
      cigarettesAvoided: newCigarettesAvoided,
      currentStreakDays: currentStreakDays,
      moneySaved: moneySaved
    );
  }

  /// Calcula minutos de vida ganhos com base nos cigarros evitados
  static int calculateMinutesGained(int cigarettesAvoided) {
    return cigarettesAvoided * MINUTES_PER_CIGARETTE;
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