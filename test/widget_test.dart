// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:nicotinaai_flutter/features/tracking/repositories/tracking_repository.dart';
import 'package:nicotinaai_flutter/features/achievements/services/achievement_notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:nicotinaai_flutter/main.dart';

// Mock das classes necessárias
class MockAuthRepository extends Mock implements AuthRepository {}
class MockOnboardingRepository extends Mock implements OnboardingRepository {}
class MockTrackingRepository extends Mock implements TrackingRepository {}
class MockAchievementNotificationService extends Mock implements AchievementNotificationService {}

void main() {
  testWidgets('Teste de integração básico', (WidgetTester tester) async {
    // Cria os mocks necessários
    final authRepository = MockAuthRepository();
    final onboardingRepository = MockOnboardingRepository();
    final trackingRepository = MockTrackingRepository();
    final achievementNotifications = MockAchievementNotificationService();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      authRepository: authRepository,
      onboardingRepository: onboardingRepository,
      trackingRepository: trackingRepository,
      achievementNotifications: achievementNotifications,
    ));

    // Verifica se a tela de login é exibida inicialmente
    expect(find.text('Bem-vindo de volta'), findsOneWidget);
  });
}
