import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';

class StatsCalculator {
  // Valores padrão centralizados como fallback, mas com preferência para valores do usuário
  // Estes só devem ser usados quando não houver dados do usuário, e
  // devem ser substituídos assim que os dados de onboarding estiverem disponíveis
  static const int DEFAULT_PACK_PRICE_CENTS = 1200;
  static const int DEFAULT_CIGARETTES_PER_PACK = 20;
  static const int DEFAULT_CIGARETTES_PER_DAY = 20;
  static const int MINUTES_PER_CIGARETTE = 6;

  /// Calcula as estatísticas atualizadas após adicionar um craving
  /// Tem preferência pelos valores do usuário, mas usa fallbacks quando necessário
  static UserStats calculateAddCraving(UserStats currentStats) {
    // Verificar se temos valores válidos do usuário, com logs detalhados para debug
    if (currentStats.packPrice == null) {
      debugPrint('⚠️ [StatsCalculator] AVISO: Usando preço padrão (${DEFAULT_PACK_PRICE_CENTS}¢) porque currentStats.packPrice é nulo');
    }
    if (currentStats.cigarettesPerPack == null) {
      debugPrint('⚠️ [StatsCalculator] AVISO: Usando cigarros por maço padrão (${DEFAULT_CIGARETTES_PER_PACK}) porque currentStats.cigarettesPerPack é nulo');
    }
    
    // Calcular o preço por cigarro - preferencialmente com dados do usuário
    final int packPrice = currentStats.packPrice ?? DEFAULT_PACK_PRICE_CENTS;
    final int cigarettesPerPack = currentStats.cigarettesPerPack ?? DEFAULT_CIGARETTES_PER_PACK;
    final double pricePerCigarette = packPrice / cigarettesPerPack;
    
    // Incrementar valores relevantes
    final int newCravingsResisted = (currentStats.cravingsResisted ?? 0) + 1;
    final int newCigarettesAvoided = (currentStats.cigarettesAvoided) + 1;
    final int newMoneySaved = currentStats.moneySaved + pricePerCigarette.round();
    
    debugPrint('💰 [StatsCalculator] Craving adicionado:');
    debugPrint('   - Pack price: ${packPrice}¢');
    debugPrint('   - Cigarros por maço: $cigarettesPerPack');
    debugPrint('   - Preço por cigarro: ${pricePerCigarette.round()}¢');
    debugPrint('   - Cravings resistidos: $newCravingsResisted');
    debugPrint('   - Cigarros evitados: $newCigarettesAvoided');
    debugPrint('   - Economia total: ${newMoneySaved}¢');
    
    return currentStats.copyWith(
      cravingsResisted: newCravingsResisted,
      cigarettesAvoided: newCigarettesAvoided,
      moneySaved: newMoneySaved
    );
  }

  /// Calcula as estatísticas atualizadas após adicionar um registro de fumo
  static UserStats calculateAddSmoking(UserStats currentStats, int amount) {
    // Verificar se temos valores válidos do usuário, com logs detalhados para debug
    if (currentStats.packPrice == null) {
      debugPrint('⚠️ [StatsCalculator] AVISO: Usando preço padrão (${DEFAULT_PACK_PRICE_CENTS}¢) porque currentStats.packPrice é nulo');
    }
    if (currentStats.cigarettesPerPack == null) {
      debugPrint('⚠️ [StatsCalculator] AVISO: Usando cigarros por maço padrão (${DEFAULT_CIGARETTES_PER_PACK}) porque currentStats.cigarettesPerPack é nulo');
    }
    
    // Usar valores do usuário quando disponíveis
    final int packPrice = currentStats.packPrice ?? DEFAULT_PACK_PRICE_CENTS;
    final int cigarettesPerPack = currentStats.cigarettesPerPack ?? DEFAULT_CIGARETTES_PER_PACK;
    final double pricePerCigarette = packPrice / cigarettesPerPack;
    
    // Calcular novos valores
    final int smokingRecordsCount = (currentStats.smokingRecordsCount ?? 0) + 1;
    final int cigarettesSmoked = (currentStats.cigarettesSmoked ?? 0) + amount;
    
    // Reinicia cigarros evitados e atualiza a sequência atual
    final int newCigarettesAvoided = 0;
    final int currentStreakDays = 0; // Reinicia a sequência quando fuma
    
    // Manter o dinheiro economizado (não reiniciar)
    final int moneySaved = currentStats.moneySaved;
    
    debugPrint('🚬 [StatsCalculator] Registro de fumo adicionado:');
    debugPrint('   - Pack price: ${packPrice}¢');
    debugPrint('   - Cigarros por maço: $cigarettesPerPack');
    debugPrint('   - Preço por cigarro: ${pricePerCigarette.round()}¢');
    debugPrint('   - Total de cigarros fumados: $cigarettesSmoked');
    debugPrint('   - Total de registros: $smokingRecordsCount');
    
    return currentStats.copyWith(
      smokingRecordsCount: smokingRecordsCount,
      cigarettesSmoked: cigarettesSmoked,
      cigarettesAvoided: newCigarettesAvoided,
      currentStreakDays: currentStreakDays,
      moneySaved: moneySaved
    );
  }

  /// Calcula minutos de vida ganhos com base nos cigarros evitados
  /// Nota: este é um cálculo estimado e aproximado
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