import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nicotinaai_flutter/blocs/craving/craving_bloc.dart';
import 'package:nicotinaai_flutter/blocs/craving/craving_event.dart';
import 'package:nicotinaai_flutter/blocs/craving/craving_state.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/repositories/craving_repository.dart';

// Criar mocks
class MockCravingRepository extends Mock implements CravingRepository {}
class MockTrackingBloc extends Mock implements TrackingBloc {}

void main() {
  late CravingRepository cravingRepository;
  late TrackingBloc trackingBloc;
  late CravingBloc cravingBloc;
  
  setUp(() {
    cravingRepository = MockCravingRepository();
    trackingBloc = MockTrackingBloc();
    cravingBloc = CravingBloc(
      repository: cravingRepository,
      trackingBloc: trackingBloc,
    );
  });
  
  tearDown(() {
    cravingBloc.close();
  });
  
  // Definindo dados de teste
  final testUserId = 'test-user-id';
  
  final testCraving = CravingModel(
    id: 'test-craving-id',
    userId: testUserId,
    timestamp: DateTime.now(),
    location: 'At home',
    trigger: 'Stress',
    intensity: 'high',
    resisted: true,
    notes: 'Test notes',
  );
  
  final testCravings = [
    testCraving,
    testCraving.copyWith(
      id: 'test-craving-id-2',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      resisted: false,
    ),
  ];
  
  group('CravingBloc', () {
    test('Estado inicial deve ser inicial', () {
      expect(cravingBloc.state, CravingState.initial());
    });
    
    blocTest<CravingBloc, CravingState>(
      'emite [loading, loaded] quando carrega cravings com sucesso',
      build: () {
        when(() => cravingRepository.getCravingsForUser(testUserId))
            .thenAnswer((_) async => testCravings);
        return cravingBloc;
      },
      act: (bloc) => bloc.add(LoadCravingsRequested(userId: testUserId)),
      expect: () => [
        CravingState.loading(),
        CravingState.loaded(testCravings),
      ],
    );
    
    blocTest<CravingBloc, CravingState>(
      'emite [loading, error] quando falha ao carregar cravings',
      build: () {
        when(() => cravingRepository.getCravingsForUser(testUserId))
            .thenThrow(Exception('Failed to load cravings'));
        return cravingBloc;
      },
      act: (bloc) => bloc.add(LoadCravingsRequested(userId: testUserId)),
      expect: () => [
        CravingState.loading(),
        CravingState.error('Exception: Failed to load cravings'),
      ],
    );
    
    blocTest<CravingBloc, CravingState>(
      'emite [saving, loaded] quando salva craving com sucesso',
      build: () {
        when(() => cravingRepository.saveCraving(any()))
            .thenAnswer((_) async => testCraving);
        return cravingBloc;
      },
      act: (bloc) => bloc.add(SaveCravingRequested(craving: testCraving)),
      expect: () => [
        isA<CravingState>().having(
          (state) => state.status, 
          'status', 
          CravingStatus.saving
        ),
        isA<CravingState>().having(
          (state) => state.status, 
          'status', 
          CravingStatus.loaded
        ),
      ],
    );
    
    blocTest<CravingBloc, CravingState>(
      'emite [saving, error] quando falha ao salvar craving',
      build: () {
        when(() => cravingRepository.saveCraving(any()))
            .thenThrow(Exception('Failed to save craving'));
        return cravingBloc;
      },
      act: (bloc) => bloc.add(SaveCravingRequested(craving: testCraving)),
      errors: () => [isA<Exception>()],
      expect: () => [
        isA<CravingState>().having(
          (state) => state.status, 
          'status', 
          CravingStatus.saving
        ),
        isA<CravingState>().having(
          (state) => state.status, 
          'status', 
          CravingStatus.error
        ),
      ],
    );
    
    blocTest<CravingBloc, CravingState>(
      'emite [loaded] quando remove craving com sucesso',
      build: () {
        when(() => cravingRepository.deleteCraving(any()))
            .thenAnswer((_) async {});
        return cravingBloc;
      },
      seed: () => CravingState.loaded(testCravings),
      act: (bloc) => bloc.add(RemoveCravingRequested(id: testCraving.id!)),
      expect: () => [
        isA<CravingState>()
            .having((state) => state.status, 'status', CravingStatus.loaded)
            .having((state) => state.cravings.length, 'cravings.length', 1),
      ],
    );
    
    blocTest<CravingBloc, CravingState>(
      'emite [] quando limpa erros e não há erros',
      build: () => cravingBloc,
      act: (bloc) => bloc.add(ClearCravingErrorRequested()),
      expect: () => [],
    );
    
    blocTest<CravingBloc, CravingState>(
      'emite estado sem erro quando ClearCravingErrorRequested é chamado com erro',
      build: () => cravingBloc,
      seed: () => CravingState.error('Some error'),
      act: (bloc) => bloc.add(ClearCravingErrorRequested()),
      expect: () => [
        isA<CravingState>()
            .having((state) => state.errorMessage, 'errorMessage', null)
            .having((state) => state.status, 'status', CravingStatus.initial),
      ],
    );
    
    blocTest<CravingBloc, CravingState>(
      'emite estado inicial quando ClearCravingsRequested é chamado',
      build: () => cravingBloc,
      seed: () => CravingState.loaded(testCravings),
      act: (bloc) => bloc.add(ClearCravingsRequested()),
      expect: () => [CravingState.initial()],
    );
  });
}