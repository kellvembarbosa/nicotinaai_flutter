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
  /// Executa a exclusão da conta e armazena o resultado no estado
  /// para que a UI possa decidir quando disparar o evento AccountDeletedLogout
  Future<void> _onDeleteAccount(DeleteAccount event, Emitter<SettingsState> emit) async {
    print('⏱️ [SettingsBloc] Iniciando processo de exclusão de conta');
    print('🔍 [SettingsBloc] Estado anterior: status=${state.status}, isDeleteAccountLoading=${state.isDeleteAccountLoading}');
    
    emit(state.copyWith(
      isDeleteAccountLoading: true,
      status: SettingsStatus.loading,
      clearError: true,
      clearSuccess: true,
    ));
    
    print('🔄 [SettingsBloc] Estado atualizado para loading: status=${state.status}, isDeleteAccountLoading=${state.isDeleteAccountLoading}');
    
    try {
      // Executa a exclusão da conta com feedback detalhado
      // O método agora retorna um booleano indicando sucesso
      final accountDeleted = await _settingsRepository.deleteAccount();
      print('🔍 [SettingsBloc] Resultado da exclusão: $accountDeleted');
      
      if (accountDeleted) {
        // Emite um estado de sucesso para indicar que a exclusão foi bem-sucedida
        // É importante usar SettingsStatus.success para que a UI saiba redirecionar
        print('✅ [SettingsBloc] Conta excluída com sucesso, emitindo estado de sucesso');
        
        final newState = state.copyWith(
          isDeleteAccountLoading: false,
          status: SettingsStatus.success,
          successMessage: 'Sua conta foi excluída com sucesso.',
        );
        
        print('📝 [SettingsBloc] Detalhes do novo estado: status=${newState.status}, isDeleteAccountLoading=${newState.isDeleteAccountLoading}, hasError=${newState.hasError}');
        
        emit(newState);
        
        print('✅ [SettingsBloc] Estado de sucesso emitido!');
      } else {
        // Se a exclusão não foi bem-sucedida (improvável neste ponto)
        print('⚠️ [SettingsBloc] Exclusão retornou false, emitindo estado de falha');
        emit(state.copyWith(
          isDeleteAccountLoading: false,
          status: SettingsStatus.failure,
          errorMessage: 'Falha na exclusão da conta. Por favor, tente novamente.',
        ));
      }
    } catch (e) {
      // Em caso de erro, emite um estado de falha detalhado
      print('❌ [SettingsBloc] Erro ao excluir conta: $e');
      emit(state.copyWith(
        isDeleteAccountLoading: false,
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}