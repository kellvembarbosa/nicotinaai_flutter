import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:nicotinaai_flutter/services/analytics_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Create mock annotations
@GenerateMocks([])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock method channel for Facebook App Events
  const MethodChannel channel = MethodChannel('flutter.io/facebook_app_events');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
    log.clear();
  });

  group('AnalyticsService', () {
    test('should initialize without throwing', () async {
      // This is a basic test to ensure the service can be instantiated
      final service = AnalyticsService();
      expect(service, isNotNull);
    });

    test('should log app open event', () async {
      try {
        // Since we can't fully test the actual Facebook SDK in a test environment,
        // we're just checking that the method doesn't throw an exception
        final service = AnalyticsService();
        await service.logAppOpen();
        expect(true, isTrue); // If we get here, the test passes
      } catch (e) {
        fail('Should not throw an exception: $e');
      }
    });

    test('should log login event', () async {
      try {
        final service = AnalyticsService();
        await service.logLogin(method: 'email');
        expect(true, isTrue);
      } catch (e) {
        fail('Should not throw an exception: $e');
      }
    });

    test('should log craving resisted event', () async {
      try {
        final service = AnalyticsService();
        await service.logCravingResisted(triggerType: 'stress');
        expect(true, isTrue);
      } catch (e) {
        fail('Should not throw an exception: $e');
      }
    });

    test('should set user properties', () async {
      try {
        final service = AnalyticsService();
        await service.setUserProperties(
          userId: 'test-user-id',
          email: 'test@example.com',
          daysSmokeFree: 7,
          cigarettesPerDay: 10,
          pricePerPack: 10.0,
          currency: 'USD',
        );
        expect(true, isTrue);
      } catch (e) {
        fail('Should not throw an exception: $e');
      }
    });

    test('should clear user data', () async {
      try {
        final service = AnalyticsService();
        await service.clearUserData();
        expect(true, isTrue);
      } catch (e) {
        fail('Should not throw an exception: $e');
      }
    });
  });
}