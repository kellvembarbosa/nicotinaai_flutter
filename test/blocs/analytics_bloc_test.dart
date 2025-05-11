import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_bloc.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_event.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_state.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';

// Gere os mocks com:
// flutter pub run build_runner build
@GenerateMocks([AnalyticsService])
import 'analytics_bloc_test.mocks.dart';

void main() {
  group('AnalyticsBloc', () {
    late MockAnalyticsService analyticsService;
    late AnalyticsBloc analyticsBloc;

    setUp(() {
      analyticsService = MockAnalyticsService();
      analyticsBloc = AnalyticsBloc(analyticsService: analyticsService);
    });

    tearDown(() {
      analyticsBloc.close();
    });

    test('initial state should be empty', () {
      expect(analyticsBloc.state, const AnalyticsState());
    });

    blocTest<AnalyticsBloc, AnalyticsState>(
      'emits [initialized] when InitializeAnalyticsEvent is added',
      build: () {
        when(analyticsService.initialize()).thenAnswer((_) async {});
        when(analyticsService.activeAdapters).thenReturn(['Facebook']);
        return analyticsBloc;
      },
      act: (bloc) => bloc.add(const InitializeAnalyticsEvent()),
      expect: () => [
        const AnalyticsState(
          isInitialized: true,
          activeProviders: ['Facebook'],
        ),
      ],
      verify: (_) {
        verify(analyticsService.initialize()).called(1);
        verify(analyticsService.activeAdapters).called(1);
      },
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'emits [error] when InitializeAnalyticsEvent fails',
      build: () {
        when(analyticsService.initialize())
            .thenThrow(Exception('Initialization error'));
        return analyticsBloc;
      },
      act: (bloc) => bloc.add(const InitializeAnalyticsEvent()),
      expect: () => [
        isA<AnalyticsState>().having(
          (state) => state.error,
          'error',
          contains('Initialization error'),
        ),
      ],
      verify: (_) {
        verify(analyticsService.initialize()).called(1);
      },
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'calls trackEvent when TrackCustomEvent is added',
      build: () {
        when(analyticsService.trackEvent(any, parameters: anyNamed('parameters')))
            .thenAnswer((_) async {});
        return analyticsBloc;
      },
      act: (bloc) => bloc.add(
        const TrackCustomEvent('test_event', parameters: {'value': 'test'}),
      ),
      expect: () => [isA<AnalyticsState>()],
      verify: (_) {
        verify(analyticsService.trackEvent('test_event', parameters: {'value': 'test'}))
            .called(1);
      },
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'calls logLogin when LogLoginEvent is added',
      build: () {
        when(analyticsService.logLogin(method: anyNamed('method')))
            .thenAnswer((_) async {});
        return analyticsBloc;
      },
      act: (bloc) => bloc.add(const LogLoginEvent(method: 'email')),
      expect: () => [isA<AnalyticsState>()],
      verify: (_) {
        verify(analyticsService.logLogin(method: 'email')).called(1);
      },
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'calls setUserProperties when SetUserPropertiesEvent is added',
      build: () {
        when(analyticsService.setUserProperties(
          userId: anyNamed('userId'),
          email: anyNamed('email'),
          daysSmokeFree: anyNamed('daysSmokeFree'),
          cigarettesPerDay: anyNamed('cigarettesPerDay'),
          pricePerPack: anyNamed('pricePerPack'),
          currency: anyNamed('currency'),
          additionalProperties: anyNamed('additionalProperties'),
        )).thenAnswer((_) async {});
        return analyticsBloc;
      },
      act: (bloc) => bloc.add(
        const SetUserPropertiesEvent(
          userId: 'user123',
          email: 'test@example.com',
          daysSmokeFree: 10,
        ),
      ),
      expect: () => [isA<AnalyticsState>()],
      verify: (_) {
        verify(analyticsService.setUserProperties(
          userId: 'user123',
          email: 'test@example.com',
          daysSmokeFree: 10,
          cigarettesPerDay: null,
          pricePerPack: null,
          currency: null,
          additionalProperties: null,
        )).called(1);
      },
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'calls addAdapter when AddAnalyticsProviderEvent is added',
      build: () {
        when(analyticsService.addAdapter(any, config: anyNamed('config')))
            .thenAnswer((_) async => true);
        when(analyticsService.activeAdapters).thenReturn(['Facebook', 'PostHog']);
        return analyticsBloc;
      },
      act: (bloc) => bloc.add(
        AddAnalyticsProviderEvent(
          'PostHog',
          providerConfig: {'apiKey': 'test_key'},
        ),
      ),
      expect: () => [
        const AnalyticsState(
          activeProviders: ['Facebook', 'PostHog'],
        ),
      ],
      verify: (_) {
        verify(analyticsService.addAdapter(
          'PostHog',
          config: {'apiKey': 'test_key'},
        )).called(1);
        verify(analyticsService.activeAdapters).called(1);
      },
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'calls removeAdapter when RemoveAnalyticsProviderEvent is added',
      build: () {
        when(analyticsService.removeAdapter(any)).thenReturn(true);
        when(analyticsService.activeAdapters).thenReturn(['PostHog']);
        return analyticsBloc;
      },
      act: (bloc) => bloc.add(const RemoveAnalyticsProviderEvent('Facebook')),
      expect: () => [
        const AnalyticsState(
          activeProviders: ['PostHog'],
        ),
      ],
      verify: (_) {
        verify(analyticsService.removeAdapter('Facebook')).called(1);
        verify(analyticsService.activeAdapters).called(1);
      },
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'calls clearUserData when ClearUserDataEvent is added',
      build: () {
        when(analyticsService.clearUserData()).thenAnswer((_) async {});
        return analyticsBloc;
      },
      act: (bloc) => bloc.add(const ClearUserDataEvent()),
      expect: () => [isA<AnalyticsState>()],
      verify: (_) {
        verify(analyticsService.clearUserData()).called(1);
      },
    );
  });
}