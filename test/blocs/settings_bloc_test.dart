import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_event.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_state.dart';
import 'package:nicotinaai_flutter/features/settings/models/user_settings_model.dart';
import 'package:nicotinaai_flutter/features/settings/repositories/settings_repository.dart';
import 'settings_bloc_test.mocks.dart';

@GenerateMocks([SettingsRepository])
void main() {
  late SettingsBloc settingsBloc;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    settingsBloc = SettingsBloc(settingsRepository: mockRepository);
  });

  tearDown(() {
    settingsBloc.close();
  });

  group('SettingsBloc', () {
    final testSettings = UserSettingsModel(
      packPriceInCents: 1000,
      cigarettesPerDay: 10,
      quitDate: DateTime(2023, 1, 1),
      cigarettesPerPack: 20,
    );

    test('initial state is correct', () {
      expect(settingsBloc.state, equals(SettingsState.initial()));
    });

    group('LoadSettings', () {
      test('emits [loading, success] when settings are loaded successfully', () async {
        // Arrange
        when(mockRepository.getUserSettings())
            .thenAnswer((_) async => testSettings);

        // Act
        settingsBloc.add(const LoadSettings());

        // Assert
        await expectLater(
          settingsBloc.stream,
          emitsInOrder([
            predicate<SettingsState>((state) => 
              state.status == SettingsStatus.loading && state.errorMessage == null),
            predicate<SettingsState>((state) => 
              state.status == SettingsStatus.success && state.settings == testSettings),
          ]),
        );
      });

      test('emits [loading, failure] when loading settings fails', () async {
        // Arrange
        when(mockRepository.getUserSettings())
            .thenThrow(Exception('Failed to load settings'));

        // Act
        settingsBloc.add(const LoadSettings());

        // Assert
        await expectLater(
          settingsBloc.stream,
          emitsInOrder([
            predicate<SettingsState>((state) => 
              state.status == SettingsStatus.loading && state.errorMessage == null),
            predicate<SettingsState>((state) => 
              state.status == SettingsStatus.failure && state.errorMessage != null),
          ]),
        );
      });
    });

    group('UpdatePackPrice', () {
      test('emits [loading, success] when pack price is updated successfully', () async {
        // Arrange
        final updatedSettings = testSettings.copyWith(packPriceInCents: 1500);
        when(mockRepository.updatePackPrice(1500))
            .thenAnswer((_) async => updatedSettings);

        // Act
        settingsBloc.add(const UpdatePackPrice(priceInCents: 1500));

        // Assert
        await expectLater(
          settingsBloc.stream,
          emitsInOrder([
            predicate<SettingsState>((state) => 
              state.status == SettingsStatus.loading && state.errorMessage == null),
            predicate<SettingsState>((state) => 
              state.status == SettingsStatus.success && 
              state.settings.packPriceInCents == 1500),
          ]),
        );
      });
    });

    group('UpdateCigarettesPerDay', () {
      test('emits [loading, success] when cigarettes per day is updated successfully', () async {
        // Arrange
        final updatedSettings = testSettings.copyWith(cigarettesPerDay: 15);
        when(mockRepository.updateCigarettesPerDay(15))
            .thenAnswer((_) async => updatedSettings);

        // Act
        settingsBloc.add(const UpdateCigarettesPerDay(cigarettesPerDay: 15));

        // Assert
        await expectLater(
          settingsBloc.stream,
          emitsInOrder([
            predicate<SettingsState>((state) => 
              state.status == SettingsStatus.loading && state.errorMessage == null),
            predicate<SettingsState>((state) => 
              state.status == SettingsStatus.success && 
              state.settings.cigarettesPerDay == 15),
          ]),
        );
      });
    });

    group('UpdateQuitDate', () {
      test('emits [loading, success] when quit date is updated successfully', () async {
        // Arrange
        final newDate = DateTime(2023, 6, 1);
        final updatedSettings = testSettings.copyWith(quitDate: newDate);
        when(mockRepository.updateQuitDate(newDate))
            .thenAnswer((_) async => updatedSettings);

        // Act
        settingsBloc.add(UpdateQuitDate(quitDate: newDate));

        // Assert
        await expectLater(
          settingsBloc.stream,
          emitsInOrder([
            predicate<SettingsState>((state) => 
              state.status == SettingsStatus.loading && state.errorMessage == null),
            predicate<SettingsState>((state) => 
              state.status == SettingsStatus.success && 
              state.settings.quitDate == newDate),
          ]),
        );
      });
    });

    group('RequestPasswordReset', () {
      test('emits correct states when password reset request is successful', () async {
        // Arrange
        when(mockRepository.requestPasswordReset('test@example.com'))
            .thenAnswer((_) async => {});

        // Act
        settingsBloc.add(const RequestPasswordReset(email: 'test@example.com'));

        // Assert
        await expectLater(
          settingsBloc.stream,
          emitsInOrder([
            predicate<SettingsState>((state) => 
              state.isResetPasswordLoading && !state.isResetPasswordSuccess),
            predicate<SettingsState>((state) => 
              !state.isResetPasswordLoading && state.isResetPasswordSuccess),
          ]),
        );
      });
    });

    group('ChangePassword', () {
      test('emits correct states when changing password is successful', () async {
        // Arrange
        when(mockRepository.changePassword('oldPass', 'newPass'))
            .thenAnswer((_) async => {});

        // Act
        settingsBloc.add(const ChangePassword(
          currentPassword: 'oldPass',
          newPassword: 'newPass',
        ));

        // Assert
        await expectLater(
          settingsBloc.stream,
          emitsInOrder([
            predicate<SettingsState>((state) => 
              state.isChangePasswordLoading && !state.isChangePasswordSuccess),
            predicate<SettingsState>((state) => 
              !state.isChangePasswordLoading && state.isChangePasswordSuccess),
          ]),
        );
      });
    });

    group('DeleteAccount', () {
      test('emits correct states when account deletion is successful', () async {
        // Arrange
        when(mockRepository.deleteAccount('password'))
            .thenAnswer((_) async => {});

        // Act
        settingsBloc.add(const DeleteAccount(password: 'password'));

        // Assert
        await expectLater(
          settingsBloc.stream,
          emitsInOrder([
            predicate<SettingsState>((state) => state.isDeleteAccountLoading),
            predicate<SettingsState>((state) => !state.isDeleteAccountLoading),
          ]),
        );
      });
    });
  });
}