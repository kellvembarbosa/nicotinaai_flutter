import 'package:flutter_test/flutter_test.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/utils/improved_stats_calculator.dart';

void main() {
  group('ImprovedStatsCalculator', () {
    test('calculateMinutesGained should return correct value', () {
      const int cigarettesAvoided = 10;
      const int expectedMinutes = 10 * ImprovedStatsCalculator.MINUTES_PER_CIGARETTE;
      
      final int result = ImprovedStatsCalculator.calculateMinutesGained(cigarettesAvoided);
      
      expect(result, equals(expectedMinutes));
    });
    
    test('calculateBreathCapacityPercent should return correct value', () {
      // Test start (0 days)
      expect(ImprovedStatsCalculator.calculateBreathCapacityPercent(0), equals(70));
      
      // Test midpoint (135 days)
      final int midpointPercent = ImprovedStatsCalculator.calculateBreathCapacityPercent(135);
      expect(midpointPercent, greaterThan(70));
      expect(midpointPercent, lessThan(100));
      
      // Test full recovery (270+ days)
      expect(ImprovedStatsCalculator.calculateBreathCapacityPercent(270), equals(100));
      expect(ImprovedStatsCalculator.calculateBreathCapacityPercent(300), equals(100));
    });
    
    test('getNormalizedStats should handle null lastSmokeDate', () {
      final UserStats stats = UserStats(
        id: '1',
        userId: 'user1',
        // No lastSmokeDate provided
      );
      
      final UserStats normalizedStats = ImprovedStatsCalculator.getNormalizedStats(stats);
      
      // Should return the same stats since there's no lastSmokeDate
      expect(normalizedStats, equals(stats));
    });
    
    test('getNormalizedStats should normalize lastSmokeDate to UTC', () {
      final DateTime localDate = DateTime.now().toLocal();
      
      final UserStats stats = UserStats(
        id: '1',
        userId: 'user1',
        lastSmokeDate: localDate, // Local date
      );
      
      final UserStats normalizedStats = ImprovedStatsCalculator.getNormalizedStats(stats);
      
      // The normalized stats should have a UTC date
      expect(normalizedStats.lastSmokeDate!.isUtc, isTrue);
    });
    
    test('calculateMoneySaved should return correct value', () {
      const int daysWithoutSmoking = 10;
      const int cigarettesPerDay = 20;
      const int packPrice = 1000; // 10 dollars in cents
      const int cigarettesPerPack = 20;
      
      final int result = ImprovedStatsCalculator.calculateMoneySaved(
        daysWithoutSmoking: daysWithoutSmoking,
        cigarettesPerDay: cigarettesPerDay,
        packPrice: packPrice,
        cigarettesPerPack: cigarettesPerPack,
      );
      
      // Expected calculation: 
      // 10 days * 20 cigarettes = 200 cigarettes avoided
      // Price per cigarette = 1000 / 20 = 50 cents
      // Money saved = 200 * 50 = 10000 cents = $100
      expect(result, equals(10000));
    });
  });
}