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
  /// Agora utiliza cálculo baseado em tempo real sem fumar para economia
  static UserStats calculateAddCraving(UserStats currentStats) {
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
    final int cigarettesPerDay = currentStats.cigarettesPerDay ?? DEFAULT_CIGARETTES_PER_DAY;
    final double pricePerCigarette = packPrice / cigarettesPerPack;
    
    // Incrementar cravings resistidos
    final int newCravingsResisted = (currentStats.cravingsResisted ?? 0) + 1;
    
    // Calcular cigarros evitados com base em dias sem fumar para valores mais precisos
    int calculatedCigarettesAvoided = 0;
    
    // Se temos data do último cigarro, calcular com base nisso
    if (currentStats.lastSmokeDate != null) {
      final DateTime now = DateTime.now();
      final int daysSinceLastSmoke = now.difference(currentStats.lastSmokeDate!).inDays;
      
      // Cigarros evitados = dias sem fumar * cigarros por dia
      calculatedCigarettesAvoided = daysSinceLastSmoke * cigarettesPerDay;
      
      debugPrint('📊 [StatsCalculator] Calculando cigarros evitados por dias sem fumar:');
      debugPrint('   - Dias sem fumar: $daysSinceLastSmoke');
      debugPrint('   - Cigarros por dia: $cigarettesPerDay');
      debugPrint('   - Cigarros evitados calculados: $calculatedCigarettesAvoided');
    } else {
      // Sem data do último cigarro, incrementar cigarros evitados com base em cravings
      // Máximo de 5 para não inflar artificialmente sem data de referência
      if (currentStats.cigarettesAvoided >= 5) {
        calculatedCigarettesAvoided = 5;
        debugPrint('⚠️ [StatsCalculator] Sem data de último cigarro. Limite de 5 cigarros evitados atingido.');
      } else {
        calculatedCigarettesAvoided = currentStats.cigarettesAvoided + 1;
        debugPrint('⚠️ [StatsCalculator] Sem data de último cigarro. Incrementando cigarros evitados para: $calculatedCigarettesAvoided');
      }
    }
    
    // Calcular economia com base nos cigarros evitados calculados
    final int newMoneySaved = (calculatedCigarettesAvoided * pricePerCigarette).round();
    
    // Calcular minutos ganhos com base nos cigarros evitados
    int minutesGained = StatsCalculator.calculateMinutesGained(calculatedCigarettesAvoided);
    
    debugPrint('💰 [StatsCalculator] Craving adicionado:');
    debugPrint('   - Pack price: ${packPrice}¢');
    debugPrint('   - Cigarros por maço: $cigarettesPerPack');
    debugPrint('   - Cigarros por dia: $cigarettesPerDay');
    debugPrint('   - Preço por cigarro: ${pricePerCigarette.round()}¢');
    debugPrint('   - Cravings resistidos: $newCravingsResisted');
    debugPrint('   - Cigarros evitados calculados: $calculatedCigarettesAvoided');
    debugPrint('   - Economia total: ${newMoneySaved}¢');
    debugPrint('   - Minutos ganhos: $minutesGained');
    
    // Inclui a timestamp atual para garantir que a mudança de estado seja detectada
    return currentStats.copyWith(
      cravingsResisted: newCravingsResisted,
      cigarettesAvoided: calculatedCigarettesAvoided,
      moneySaved: newMoneySaved,
      minutesGainedToday: minutesGained,
      lastUpdated: DateTime.now().millisecondsSinceEpoch
    );
  }

  /// Calcula as estatísticas atualizadas após adicionar um registro de fumo
  /// Atualiza lastSmokeDate para garantir consistência nos cálculos
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
    
    // Atualizar data do último cigarro para agora (crucial para cálculos futuros)
    final DateTime newLastSmokeDate = DateTime.now();
    
    // Calcular economia com base no novo lastSmokeDate (será zero inicialmente)
    // Economia é redefinida já que estamos começando uma nova contagem a partir de hoje
    final int newMoneySaved = 0;
    
    debugPrint('🚬 [StatsCalculator] Registro de fumo adicionado:');
    debugPrint('   - Pack price: ${packPrice}¢');
    debugPrint('   - Cigarros por maço: $cigarettesPerPack');
    debugPrint('   - Preço por cigarro: ${pricePerCigarette.round()}¢');
    debugPrint('   - Total de cigarros fumados: $cigarettesSmoked');
    debugPrint('   - Total de registros: $smokingRecordsCount');
    debugPrint('   - Nova data do último cigarro: ${newLastSmokeDate.toIso8601String()}');
    debugPrint('   - Nova economia calculada: $newMoneySaved (reiniciada)');
    
    return currentStats.copyWith(
      smokingRecordsCount: smokingRecordsCount,
      cigarettesSmoked: cigarettesSmoked,
      cigarettesAvoided: newCigarettesAvoided,
      currentStreakDays: currentStreakDays,
      moneySaved: newMoneySaved,
      lastSmokeDate: newLastSmokeDate,
      lastUpdated: DateTime.now().millisecondsSinceEpoch
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
  
  /// Calcula a economia monetária baseada em dias sem fumar
  /// Método unificado para garantir consistência em todos os lugares
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
}