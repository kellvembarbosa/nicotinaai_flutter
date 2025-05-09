import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'developer_mode_event.dart';
import 'developer_mode_state.dart';

/// BLoC para gerenciar o modo desenvolvedor
class DeveloperModeBloc extends Bloc<DeveloperModeEvent, DeveloperModeState> {
  /// Chave usada para armazenar o estado do modo desenvolvedor no SharedPreferences
  final String _key = 'developer_mode_enabled';

  /// Construtor
  DeveloperModeBloc() : super(DeveloperModeState.initial()) {
    on<InitializeDeveloperMode>(_onInitializeDeveloperMode);
    on<ToggleDeveloperMode>(_onToggleDeveloperMode);
  }

  /// Manipulador do evento InitializeDeveloperMode
  Future<void> _onInitializeDeveloperMode(
    InitializeDeveloperMode event,
    Emitter<DeveloperModeState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: DeveloperModeStatus.loading,
        clearError: true,
      ));

      final prefs = await SharedPreferences.getInstance();
      final isDeveloperModeEnabled = prefs.getBool(_key) ?? false;

      emit(state.copyWith(
        status: DeveloperModeStatus.loaded,
        isDeveloperModeEnabled: isDeveloperModeEnabled,
        isInitialized: true,
      ));
    } catch (e) {
      debugPrint('Erro ao carregar configuração de modo desenvolvedor: $e');
      emit(state.copyWith(
        status: DeveloperModeStatus.error,
        errorMessage: 'Erro ao carregar configuração de modo desenvolvedor: $e',
        isInitialized: true,
      ));
    }
  }

  /// Manipulador do evento ToggleDeveloperMode
  Future<void> _onToggleDeveloperMode(
    ToggleDeveloperMode event,
    Emitter<DeveloperModeState> emit,
  ) async {
    try {
      // Atualiza o estado otimisticamente
      emit(state.copyWith(
        isDeveloperModeEnabled: !state.isDeveloperModeEnabled,
        clearError: true,
      ));

      // Persiste a mudança
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, state.isDeveloperModeEnabled);

      // Confirma o estado atualizado
      emit(state.copyWith(status: DeveloperModeStatus.loaded));
    } catch (e) {
      debugPrint('Erro ao salvar configuração de modo desenvolvedor: $e');
      
      // Reverte para o estado anterior em caso de erro
      emit(state.copyWith(
        status: DeveloperModeStatus.error,
        isDeveloperModeEnabled: !state.isDeveloperModeEnabled, // Reverte a alteração
        errorMessage: 'Erro ao salvar configuração de modo desenvolvedor: $e',
      ));
    }
  }
}