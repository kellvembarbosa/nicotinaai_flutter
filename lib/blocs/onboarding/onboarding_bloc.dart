import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:nicotinaai_flutter/services/analytics_service.dart';
import 'package:nicotinaai_flutter/services/onboarding_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_event.dart';
import 'onboarding_state.dart';

/// BLoC para gerenciar o onboarding
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository _repository;
  
  // Flag para controlar inicialização em andamento
  bool _isInitializing = false;
  
  /// Construtor
  OnboardingBloc({
    required OnboardingRepository repository,
  }) : _repository = repository,
      super(OnboardingState.initial()) {
    on<InitializeOnboarding>(_onInitializeOnboarding);
    on<UpdateOnboarding>(_onUpdateOnboarding);
    on<NextOnboardingStep>(_onNextOnboardingStep);
    on<PreviousOnboardingStep>(_onPreviousOnboardingStep);
    on<GoToOnboardingStep>(_onGoToOnboardingStep);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<ClearOnboardingError>(_onClearOnboardingError);
  }

  /// Manipulador do evento InitializeOnboarding
  Future<void> _onInitializeOnboarding(
    InitializeOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    // Prevenção contra chamadas concorrentes
    if (_isInitializing) {
      debugPrint('⏳ [OnboardingBloc] Inicialização já em andamento, ignorando chamada');
      return;
    }
    
    try {
      _isInitializing = true;
      debugPrint('🔍 [OnboardingBloc] Inicializando onboarding');
      
      emit(OnboardingState.loading());
      
      // Primeira verificação: ver diretamente se o onboarding está completo no Supabase
      debugPrint('🔍 [OnboardingBloc] Verificando status de conclusão no Supabase');
      final isCompleteInSupabase = await _repository.hasCompletedOnboarding();
      
      if (isCompleteInSupabase) {
        // Se já está completo no Supabase, marcar como completo imediatamente
        debugPrint('✅ [OnboardingBloc] Onboarding COMPLETO no Supabase');
        
        // Buscar dados do onboarding do servidor
        final onboarding = await _repository.getOnboarding();
        
        if (onboarding != null) {
          emit(OnboardingState.completed(onboarding));
        } else {
          // Se não conseguiu buscar, criar um modelo simples completo
          final userId = _getCurrentUserId() ?? '';
          emit(OnboardingState.completed(
            OnboardingModel(userId: userId, completed: true)
          ));
        }
        
        _isInitializing = false;
        return;
      }
      
      // Verificação secundária: ler do Supabase
      final onboarding = await _repository.getOnboarding();
      
      if (onboarding != null) {
        debugPrint('📝 [OnboardingBloc] Onboarding encontrado no Supabase: ${onboarding.id}');
        
        if (onboarding.completed) {
          emit(OnboardingState.completed(onboarding));
        } else {
          emit(OnboardingState.loaded(onboarding, isNew: false));
        }
        
        _isInitializing = false;
        return;
      }
      
      // Verificação terciária: ler da cache local
      final localOnboarding = await _getLocalOnboarding();
      
      if (localOnboarding != null) {
        debugPrint('💾 [OnboardingBloc] Onboarding encontrado na cache local');
        
        if (localOnboarding.completed) {
          emit(OnboardingState.completed(localOnboarding));
          // Tentar sincronizar sem bloquear
          _repository.saveOnboarding(localOnboarding).catchError((e) {
            debugPrint('⚠️ [OnboardingBloc] Erro ao sincronizar: $e');
          });
        } else {
          emit(OnboardingState.loaded(localOnboarding, isNew: false));
        }
        
        _isInitializing = false;
        return;
      }
      
      // Caso final: criar novo
      debugPrint('🆕 [OnboardingBloc] Criando novo onboarding');
      final userId = _getCurrentUserId();
      
      if (userId == null) {
        debugPrint('❌ [OnboardingBloc] Usuário não autenticado');
        emit(OnboardingState.error('Usuário não autenticado'));
        _isInitializing = false;
        return;
      }
      
      final newOnboarding = OnboardingModel(userId: userId, completed: false);
      emit(OnboardingState.loaded(newOnboarding, isNew: true));
      
      // Salvar localmente e tentar salvar no servidor
      await _saveLocalOnboarding(newOnboarding);
      _repository.saveOnboarding(newOnboarding).catchError((e) {
        debugPrint('⚠️ [OnboardingBloc] Erro ao salvar: $e');
      });
      
    } catch (e) {
      debugPrint('❌ [OnboardingBloc] Erro ao inicializar: $e');
      emit(OnboardingState.error(e.toString()));
    } finally {
      _isInitializing = false;
    }
  }

  /// Manipulador do evento UpdateOnboarding
  Future<void> _onUpdateOnboarding(
    UpdateOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: OnboardingStatus.saving,
        onboarding: event.onboarding,
      ));
      
      debugPrint('🔄 [OnboardingBloc] Atualizando onboarding');
      
      // Salvar localmente primeiro
      await _saveLocalOnboarding(event.onboarding);
      
      // Depois tentar salvar no Supabase se houver conexão
      try {
        debugPrint('🔄 [OnboardingBloc] Salvando no Supabase');
        final savedOnboarding = await _repository.saveOnboarding(event.onboarding);
        debugPrint('✅ [OnboardingBloc] Onboarding atualizado com sucesso no Supabase');
        emit(state.copyWith(
          status: OnboardingStatus.loaded,
          onboarding: savedOnboarding,
        ));
      } catch (e) {
        debugPrint('⚠️ [OnboardingBloc] Erro ao salvar no Supabase: $e');
        // Se falhar o salvamento no Supabase, manter o estado como loaded
        // mas com os dados do armazenamento local
        emit(state.copyWith(
          status: OnboardingStatus.loaded,
          onboarding: event.onboarding,
        ));
      }
    } catch (e) {
      debugPrint('❌ [OnboardingBloc] Erro ao atualizar: $e');
      emit(state.copyWith(
        status: OnboardingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Manipulador do evento NextOnboardingStep
  void _onNextOnboardingStep(
    NextOnboardingStep event,
    Emitter<OnboardingState> emit,
  ) {
    if (!state.canAdvance) return;
    
    emit(state.copyWith(
      currentStep: state.currentStep + 1,
    ));
  }

  /// Manipulador do evento PreviousOnboardingStep
  void _onPreviousOnboardingStep(
    PreviousOnboardingStep event,
    Emitter<OnboardingState> emit,
  ) {
    if (!state.canGoBack) return;
    
    emit(state.copyWith(
      currentStep: state.currentStep - 1,
    ));
  }

  /// Manipulador do evento GoToOnboardingStep
  void _onGoToOnboardingStep(
    GoToOnboardingStep event,
    Emitter<OnboardingState> emit,
  ) {
    if (event.step < 1 || event.step > state.totalSteps) return;
    
    emit(state.copyWith(
      currentStep: event.step,
    ));
  }

  /// Manipulador do evento CompleteOnboarding
  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      debugPrint('🔄 [OnboardingBloc] Completando onboarding');
      
      if (state.onboarding == null) {
        debugPrint('❌ [OnboardingBloc] Não há onboarding para completar');
        return;
      }
      
      // Sempre usar o onboarding atual, apenas atualizando o status para completo
      final updated = state.onboarding!.copyWith(completed: true);
      
      // Atualizar o estado local PRIMEIRO - isso é o mais importante
      debugPrint('✅ [OnboardingBloc] Definindo estado como COMPLETO');
      emit(OnboardingState.completed(updated));
      
      // Salvar localmente
      debugPrint('💾 [OnboardingBloc] Salvando status completo localmente');
      await _saveLocalOnboarding(updated);
      
      // Registrar evento de analytics
      AnalyticsService().logCompletedOnboarding().catchError((e) {
        debugPrint('⚠️ [OnboardingBloc] Analytics error: $e');
      });
      
      // Salvar no Supabase - não aguardar retorno para não bloquear UI
      debugPrint('☁️ [OnboardingBloc] Enviando status completo para Supabase');
      
      // Usamos Future.sync para não bloquear, mas ainda manter o controle de erros
      Future.sync(() async {
        try {
          // Salvar onboarding atualizado
          final savedOnboarding = await _repository.saveOnboarding(updated);
          
          // Marcar como completo explicitamente no servidor
          if (savedOnboarding.id != null) {
            await _repository.completeOnboarding(savedOnboarding.id!);
            debugPrint('✅ [OnboardingBloc] Status salvo no Supabase com sucesso');
            
            // IMPORTANTE: Sincronizar dados do onboarding para UserStats
            debugPrint('🔄 [OnboardingBloc] Sincronizando dados do onboarding para UserStats');
            final syncService = OnboardingSyncService();
            final syncSuccess = await syncService.syncOnboardingDataToUserStats();
            if (syncSuccess) {
              debugPrint('✅ [OnboardingBloc] Dados do onboarding sincronizados com UserStats');
            } else {
              debugPrint('⚠️ [OnboardingBloc] Falha ao sincronizar dados com UserStats');
            }
          }
        } catch (e) {
          debugPrint('⚠️ [OnboardingBloc] Erro ao salvar no Supabase: $e');
          // Erro no servidor não afeta a experiência do usuário
          // O estado local já está atualizado para completo
        }
      });
      
    } catch (e) {
      debugPrint('❌ [OnboardingBloc] Erro ao completar onboarding: $e');
      // Mesmo em caso de erro, garantir que o estado esteja como completo
      if (state.onboarding != null) {
        emit(OnboardingState.completed(state.onboarding!));
      }
    }
  }

  /// Manipulador do evento CheckOnboardingStatus
  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      // IMPORTANTE: Verificar diretamente no Supabase sem usar cache
      debugPrint('🔍 [OnboardingBloc] Verificando status de conclusão NO SUPABASE');
      final isCompletedInSupabase = await _repository.hasCompletedOnboarding();
      debugPrint('📊 [OnboardingBloc] Status do onboarding no Supabase: ${isCompletedInSupabase ? "COMPLETO" : "INCOMPLETO"}');
      
      // Se estiver completo no servidor, atualizar estado local
      if (isCompletedInSupabase) {
        // SEMPRE sincronizar o estado local com o Supabase
        if (!state.isCompleted) {
          debugPrint('🔄 [OnboardingBloc] Atualizando estado local para COMPLETO para corresponder ao Supabase');
          
          // Buscar os dados completos do onboarding
          final onboarding = await _repository.getOnboarding();
          
          if (onboarding != null) {
            // Usar os dados completos do onboarding do servidor
            final updatedOnboarding = onboarding.copyWith(completed: true);
            emit(OnboardingState.completed(updatedOnboarding));
          } else {
            // Fallback: criar um modelo simples marcado como completo
            final userId = _getCurrentUserId() ?? '';
            emit(OnboardingState.completed(
              OnboardingModel(userId: userId, completed: true)
            ));
          }
          
          // Salvar em cache local para acesso offline
          if (state.onboarding != null) {
            await _saveLocalOnboarding(state.onboarding!);
          }
        }
      } else {
        // Se NÃO está completo no Supabase, mas está marcado como completo localmente
        if (state.isCompleted) {
          // Tentar sincronizar o estado local para o Supabase
          debugPrint('⚠️ [OnboardingBloc] Estado INCONSISTENTE: completo localmente, mas incompleto no Supabase');
          
          // Verificar se temos o ID para fazer o update
          final onboarding = state.onboarding;
          if (onboarding != null && onboarding.id != null) {
            try {
              debugPrint('🔄 [OnboardingBloc] Tentando sincronizar estado completo para o Supabase');
              await _repository.completeOnboarding(onboarding.id!);
              // Acabamos de marcar como completo no Supabase
            } catch (e) {
              debugPrint('❌ [OnboardingBloc] Falha ao sincronizar para Supabase: $e');
              // O Supabase é a fonte primária da verdade
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [OnboardingBloc] Erro ao verificar status: $e');
      
      // Em caso de erro de comunicação, usar o estado local como fallback
      // mas avisar claramente no log que estamos usando fallback
      debugPrint('⚠️ [OnboardingBloc] FALLBACK: usando estado local: ${state.isCompleted ? "COMPLETO" : "INCOMPLETO"}');
    }
  }

  /// Manipulador do evento ClearOnboardingError
  void _onClearOnboardingError(
    ClearOnboardingError event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.hasError) {
      emit(state.copyWith(
        status: state.onboarding != null 
            ? OnboardingStatus.loaded 
            : OnboardingStatus.initial,
        clearError: true,
      ));
    }
  }

  // Métodos auxiliares
  
  /// Obtém o ID do usuário atual
  String? _getCurrentUserId() {
    final user = SupabaseConfig.client.auth.currentUser;
    return user?.id;
  }
  
  /// Obtém o onboarding salvo localmente
  Future<OnboardingModel?> _getLocalOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('onboarding_data');
      
      if (json == null) return null;
      
      final data = jsonDecode(json);
      return OnboardingModel.fromJson(data);
    } catch (e) {
      debugPrint('⚠️ [OnboardingBloc] Erro ao ler dados locais: $e');
      return null;
    }
  }
  
  /// Salva o onboarding localmente
  Future<void> _saveLocalOnboarding(OnboardingModel onboarding) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(onboarding.toJson());
      await prefs.setString('onboarding_data', json);
      debugPrint('✅ [OnboardingBloc] Dados salvos localmente');
    } catch (e) {
      debugPrint('⚠️ [OnboardingBloc] Erro ao salvar dados locais: $e');
    }
  }
  
  /// Remove o onboarding salvo localmente
  Future<void> _removeLocalOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_data');
      debugPrint('✅ [OnboardingBloc] Dados locais removidos');
    } catch (e) {
      debugPrint('⚠️ [OnboardingBloc] Erro ao remover dados locais: $e');
    }
  }
}