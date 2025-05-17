import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/core/routes/app_router.dart';
import 'package:nicotinaai_flutter/features/auth/screens/splash_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/first_launch_language_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Create mock classes for the blocs
class MockAuthBloc extends Mock implements AuthBloc {
  @override
  AuthState get state => AuthState.unauthenticated();
}

class MockOnboardingBloc extends Mock implements OnboardingBloc {}

@GenerateMocks([SharedPreferences])
void main() {
  group('App Navigation Flow Tests', () {
    late MockAuthBloc authBloc;
    late MockOnboardingBloc onboardingBloc;
    late LocaleBloc localeBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      onboardingBloc = MockOnboardingBloc();
      localeBloc = LocaleBloc();

      // Set up shared preferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      localeBloc.close();
    });

    testWidgets('First launch should show language selection screen', (WidgetTester tester) async {
      // Create app router with mocked blocs
      final appRouter = AppRouter(
        authBloc: authBloc,
        onboardingBloc: onboardingBloc,
      );

      // Build the app with the router and providers
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<OnboardingBloc>.value(value: onboardingBloc),
            BlocProvider<LocaleBloc>.value(value: localeBloc),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter.router,
          ),
        ),
      );

      // Initial screen should be the splash screen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Wait for the splash screen delay
      await tester.pump(const Duration(milliseconds: 1600));

      // Wait for animations and redirects to complete
      await tester.pumpAndSettle();

      // Since language selection is not complete, we should be redirected to the language selection screen
      expect(find.byType(FirstLaunchLanguageScreen), findsOneWidget);
      expect(find.text('Welcome to NicotinaAI'), findsOneWidget);
      expect(find.text('Select your preferred language'), findsOneWidget);

      // Select a language
      await tester.tap(find.text('Português (Brasil)'));
      await tester.pumpAndSettle();

      // Tap continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify language selection was marked as complete
      final isComplete = await localeBloc.isLanguageSelectionComplete();
      expect(isComplete, isTrue);
    });
  });
}