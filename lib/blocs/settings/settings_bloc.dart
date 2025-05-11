import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_event.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_state.dart';
import 'package:nicotinaai_flutter/features/settings/repositories/settings_repository.dart';

/// BLoC para gerenciamento de configurações do usuário
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;
  
  SettingsBloc({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(SettingsState.initial()) {
    // Registra os handlers para cada evento
    on<LoadSettings>(_onLoadSettings);
    on<UpdatePackPrice>(_onUpdatePackPrice);
    on<UpdateCigarettesPerDay>(_onUpdateCigarettesPerDay);
    on<UpdateQuitDate>(_onUpdateQuitDate);
    on<RequestPasswordReset>(_onRequestPasswordReset);
    on<ChangePassword>(_onChangePassword);
    on<DeleteAccount>(_onDeleteAccount);
  }
  
  /// Handler para o evento LoadSettings
  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(
      status: SettingsStatus.loading,
      clearError: true,
    ));
    
    try {
      final settings = await _settingsRepository.getUserSettings();
      
      emit(state.copyWith(
        status: SettingsStatus.success,
        settings: settings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
  
  /// Handler para o evento UpdatePackPrice
  Future<void> _onUpdatePackPrice(UpdatePackPrice event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(
      status: SettingsStatus.loading,
      clearError: true,
      clearSuccess: true,
    ));
    
    try {
      final updatedSettings = await _settingsRepository.updatePackPrice(event.priceInCents);
      
      emit(state.copyWith(
        status: SettingsStatus.success,
        settings: updatedSettings,
        successMessage: 'Preço atualizado com sucesso!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
  
  /// Handler para o evento UpdateCigarettesPerDay
  Future<void> _onUpdateCigarettesPerDay(UpdateCigarettesPerDay event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(
      status: SettingsStatus.loading,
      clearError: true,
      clearSuccess: true,
    ));
    
    try {
      final updatedSettings = await _settingsRepository.updateCigarettesPerDay(event.cigarettesPerDay);
      
      emit(state.copyWith(
        status: SettingsStatus.success,
        settings: updatedSettings,
        successMessage: 'Quantidade de cigarros atualizada com sucesso!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
  
  /// Handler para o evento UpdateQuitDate
  Future<void> _onUpdateQuitDate(UpdateQuitDate event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(
      status: SettingsStatus.loading,
      clearError: true,
      clearSuccess: true,
    ));
    
    try {
      final updatedSettings = await _settingsRepository.updateQuitDate(event.quitDate);
      
      emit(state.copyWith(
        status: SettingsStatus.success,
        settings: updatedSettings,
        successMessage: 'Data atualizada com sucesso!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
  
  /// Handler para o evento RequestPasswordReset
  Future<void> _onRequestPasswordReset(RequestPasswordReset event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(
      isResetPasswordLoading: true,
      isResetPasswordSuccess: false,
      clearError: true,
    ));
    
    try {
      await _settingsRepository.requestPasswordReset(event.email);
      
      emit(state.copyWith(
        isResetPasswordLoading: false,
        isResetPasswordSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isResetPasswordLoading: false,
        isResetPasswordSuccess: false,
        errorMessage: e.toString(),
      ));
    }
  }
  
  /// Handler para o evento ChangePassword
  Future<void> _onChangePassword(ChangePassword event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(
      isChangePasswordLoading: true,
      isChangePasswordSuccess: false,
      clearError: true,
    ));
    
    try {
      await _settingsRepository.changePassword(
        event.currentPassword,
        event.newPassword,
      );
      
      emit(state.copyWith(
        isChangePasswordLoading: false,
        isChangePasswordSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isChangePasswordLoading: false,
        isChangePasswordSuccess: false,
        errorMessage: e.toString(),
      ));
    }
  }
  
  /// Handler para o evento DeleteAccount
  Future<void> _onDeleteAccount(DeleteAccount event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(
      isDeleteAccountLoading: true,
      clearError: true,
    ));
    
    try {
      await _settingsRepository.deleteAccount(event.password);
      
      emit(state.copyWith(
        isDeleteAccountLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDeleteAccountLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }
}