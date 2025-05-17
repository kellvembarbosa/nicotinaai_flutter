import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_bloc.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_event.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_state.dart';
import 'package:nicotinaai_flutter/features/auth/screens/first_launch_language_screen.dart';

@GenerateMocks([SharedPreferences])
void main() {
  group('FirstLaunchLanguageScreen Tests', () {
    late LocaleBloc localeBloc;

    setUp(() {
      localeBloc = LocaleBloc();
      
      // Initialize shared preferences with an empty map
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      localeBloc.close();
    });

    testWidgets('Displays language options and allows selection', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LocaleBloc>.value(
            value: localeBloc,
            child: const FirstLaunchLanguageScreen(),
          ),
        ),
      );

      // Wait for animations
      await tester.pumpAndSettle();

      // Verify that the language options are displayed
      expect(find.text('Welcome to NicotinaAI'), findsOneWidget);
      expect(find.text('Select your preferred language'), findsOneWidget);
      
      // Check if options are displayed
      expect(find.text('English (US)'), findsOneWidget);
      expect(find.text('Português (Brasil)'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(find.text('Italiano'), findsOneWidget);
      expect(find.text('Deutsch'), findsOneWidget);
      expect(find.text('Nederlands'), findsOneWidget);
      expect(find.text('Polski'), findsOneWidget);
      
      // Continue button should be present
      expect(find.text('Continue'), findsOneWidget);
      
      // Initially English should be selected
      final localeState = localeBloc.state;
      expect(localeState.locale.languageCode, equals('en'));
      expect(localeState.locale.countryCode, equals('US'));
      
      // Tap on Portuguese option
      await tester.tap(find.text('Português (Brasil)'));
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Directly change locale for testing
      localeBloc.add(const ChangeLocale(Locale('pt', 'BR')));
      await tester.pumpAndSettle();
      
      // Verify Portuguese is selected
      final updatedState = localeBloc.state;
      expect(updatedState.locale.languageCode, equals('pt'));
      expect(updatedState.locale.countryCode, equals('BR'));
      
      // Tap Continue button
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      
      // Verify that language selection was marked as completed
      final isComplete = await localeBloc.isLanguageSelectionComplete();
      expect(isComplete, isTrue);
    });
    
    testWidgets('Saves language preference to SharedPreferences', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LocaleBloc>.value(
            value: localeBloc,
            child: const FirstLaunchLanguageScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Directly change locale for testing
      localeBloc.add(const ChangeLocale(Locale('es', 'ES')));
      await tester.pumpAndSettle();
      
      // Verify Spanish is selected in the bloc state
      expect(localeBloc.state.locale.languageCode, equals('es'));
      expect(localeBloc.state.locale.countryCode, equals('ES'));
      
      // Tap continue button
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      
      // Get shared preferences and verify language is saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), equals('es_ES'));
      expect(prefs.getBool('language_selection_complete'), isTrue);
    });
  });
}