import 'package:flutter_test/flutter_test.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';

void main() {
  group('UserStats Model Tests', () {
    test('UserStats should include cravings_count field', () {
      // Create a UserStats object with cravings_count
      final userStats = UserStats(
        userId: 'test-user-id',
        cravingsCount: 10,
      );
      
      // Test that the field is correctly set
      expect(userStats.cravingsCount, 10);
      
      // Test JSON serialization and deserialization
      final json = userStats.toJson();
      expect(json['cravings_count'], 10);
      
      final parsedStats = UserStats.fromJson(json);
      expect(parsedStats.cravingsCount, 10);
    });
    
    test('UserStats copyWith should work with cravings_count', () {
      final userStats = UserStats(
        userId: 'test-user-id',
        cravingsCount: 10,
      );
      
      // Test that copyWith correctly copies the value
      final updatedStats = userStats.copyWith();
      expect(updatedStats.cravingsCount, 10);
      
      // Test that copyWith correctly updates the value
      final modifiedStats = userStats.copyWith(cravingsCount: 20);
      expect(modifiedStats.cravingsCount, 20);
    });
  });
  
  group('CravingModel Tests', () {
    test('CravingModel should correctly handle outcome enum values', () {
      // Create a CravingModel with outcome
      final craving = CravingModel(
        userId: 'test-user-id',
        location: 'Home',
        trigger: 'Stress',
        intensity: 'moderate',
        resisted: true,
        timestamp: DateTime.now(),
      );
      
      // Test that the outcome is correctly generated in JSON
      final json = craving.toJson();
      expect(json['outcome'], 'RESISTED');
      
      // Test with resisted = false
      final cravingnot = CravingModel(
        userId: 'test-user-id',
        location: 'Home',
        trigger: 'Stress',
        intensity: 'moderate',
        resisted: false,
        timestamp: DateTime.now(),
      );
      
      final jsonnot = cravingnot.toJson();
      expect(jsonnot['outcome'], 'SMOKED');
    });
    
    test('CravingModel should correctly parse from server JSON', () {
      // Simulate server JSON with outcome enum value
      final serverJson = {
        'id': 'test-id',
        'user_id': 'test-user-id',
        'location': 'Home',
        'trigger': 'Stress',
        'intensity': 'MODERATE',
        'outcome': 'RESISTED',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Parse the model from the JSON
      final craving = CravingModel.fromJson(serverJson);
      
      // Test that the boolean field is correctly set
      expect(craving.resisted, true);
      
      // Test with SMOKED outcome
      final serverJsonSmoked = {
        'id': 'test-id',
        'user_id': 'test-user-id',
        'location': 'Home',
        'trigger': 'Stress',
        'intensity': 'MODERATE',
        'outcome': 'SMOKED',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final cravingSmoked = CravingModel.fromJson(serverJsonSmoked);
      expect(cravingSmoked.resisted, false);
    });
  });
}