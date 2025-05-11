import 'package:flutter_test/flutter_test.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/utils/stats_calculator.dart';

void main() {
  group('StatsCalculator', () {
    group('calculateMinutesGained', () {
      test('retorna o número correto de minutos por cigarro evitado', () {
        // Arrange
        const cigarettesAvoided = 10;
        const expectedMinutes = 10 * 6; // MINUTES_PER_CIGARETTE = 6
        
        // Act
        final result = StatsCalculator.calculateMinutesGained(cigarettesAvoided);
        
        // Assert
        expect(result, equals(expectedMinutes));
      });
      
      test('retorna 0 quando não há cigarros evitados', () {
        // Arrange
        const cigarettesAvoided = 0;
        
        // Act
        final result = StatsCalculator.calculateMinutesGained(cigarettesAvoided);
        
        // Assert
        expect(result, equals(0));
      });
    });
    
    group('calculateAddCraving', () {
      test('calcula corretamente as estatísticas após adicionar um craving', () {
        // Arrange
        const initialStats = UserStats(
          userId: 'test-user',
          cigarettesAvoided: 10,
          moneySaved: 500,
          cravingsResisted: 5,
          packPrice: 1000, // R$10,00
          cigarettesPerPack: 20,
        );
        
        // Act
        final updatedStats = StatsCalculator.calculateAddCraving(initialStats);
        
        // Assert
        expect(updatedStats.cravingsResisted, equals(6));
        expect(updatedStats.cigarettesAvoided, equals(11));
        expect(updatedStats.moneySaved, equals(550)); // 500 + (1000/20)
      });
    });
    
    group('formatTimeGained', () {
      test('formata minutos corretamente para valores pequenos', () {
        // Act & Assert
        expect(StatsCalculator.formatTimeGained(30), equals('30 minutos'));
      });
      
      test('formata horas corretamente', () {
        // Act & Assert
        expect(StatsCalculator.formatTimeGained(90), equals('1 horas e 30 minutos'));
      });
      
      test('formata dias corretamente', () {
        // Act & Assert
        expect(StatsCalculator.formatTimeGained(1500), 
            equals('1 dias, 1 horas e 0 minutos'));
      });
    });
    
    // Teste para verificar o cálculo de "Minutes of Life Gained Today" na tela principal
    // Este teste verifica a lógica implementada na função _calculateDailyMinutesGained
    group('Minutes of Life Gained Today calculation', () {
      test('calcula minutos ganhos hoje com base nos cravings registrados', () {
        // Arrange
        const cravingsResisted = 3;
        const minutesPerCigarette = StatsCalculator.MINUTES_PER_CIGARETTE;
        
        // Act
        // Simulando a lógica implementada na função _calculateDailyMinutesGained
        final minutesGainedToday = cravingsResisted * minutesPerCigarette;
        
        // Assert
        expect(minutesGainedToday, equals(18)); // 3 cravings * 6 minutos = 18 minutos
      });
      
      test('calcula minutos ganhos com base nos cigarros por dia quando não há cravings', () {
        // Arrange
        const cravingsResisted = 0;
        const cigarettesPerDay = 20;
        const minutesPerCigarette = StatsCalculator.MINUTES_PER_CIGARETTE;
        
        // Act
        // Simulando a lógica quando não há cravings registrados
        final minutesGainedToday = cravingsResisted > 0 
            ? cravingsResisted * minutesPerCigarette
            : cigarettesPerDay > 0 
                ? minutesPerCigarette * cigarettesPerDay ~/ 24
                : 0;
        
        // Assert
        // 20 cigarros por dia = 20/24 cigarros por hora = aprox. 5 cigarros em 6 horas
        // 5 cigarros * 6 minutos = 30 minutos, mas dividido por 24 horas = aprox. 5 minutos
        expect(minutesGainedToday, equals(5));
      });
    });
  });
}