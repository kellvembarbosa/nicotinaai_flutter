import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/features/achievements/models/user_achievement.dart';
import 'package:nicotinaai_flutter/features/achievements/services/achievement_service.dart';
import 'package:nicotinaai_flutter/features/achievements/services/achievement_notification_service.dart';
import 'package:nicotinaai_flutter/features/achievements/models/time_period.dart';

import 'achievement_event.dart';
import 'achievement_state.dart';

/// BLoC para gerenciar achievements
class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final AchievementService _service;
  final AchievementNotificationService? _notificationService;
  
  // Flags para controle de loops infinitos
  bool _isLoadingAchievements = false;
  DateTime? _lastLoadTime;
  static const _minLoadIntervalMs = 1000; // 1 segundo entre carregamentos
  
  // Flag para prevent concurrent achievement checks
  bool _isCheckingAchievements = false;
  DateTime? _lastCheckTime;
  static const _minCheckIntervalMs = 2000; // 2 segundos entre verificações
  
  // Counter for consecutive check failures
  int _consecutiveCheckFailures = 0;
  static const _maxConsecutiveFailures = 3;
  
  /// Construtor
  AchievementBloc({
    required AchievementService service,
    AchievementNotificationService? notificationService,
  }) : _service = service,
       _notificationService = notificationService,
       super(AchievementState.initial()) {
    on<InitializeAchievements>(_onInitializeAchievements);
    on<LoadAchievements>(_onLoadAchievements);
    on<MarkAchievementAsViewed>(_onMarkAchievementAsViewed);
    on<CheckForNewAchievements>(_onCheckForNewAchievements);
    on<ChangeTimePeriod>(_onChangeTimePeriod);
    on<ClearAchievementError>(_onClearAchievementError);
  }
  
  /// Verifica se podemos recarregar achievements baseado no tempo decorrido
  bool get _canReloadAchievements {
    if (_lastLoadTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(_lastLoadTime!).inMilliseconds;
    return difference > _minLoadIntervalMs;
  }
  
  /// Verifica se podemos verificar achievements baseado no tempo decorrido
  bool get _canCheckAchievements {
    if (_lastCheckTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(_lastCheckTime!).inMilliseconds;
    return difference > _minCheckIntervalMs;
  }

  /// Manipulador do evento InitializeAchievements
  Future<void> _onInitializeAchievements(
    InitializeAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    // Em vez de apenas logar, carregamos os achievements imediatamente
    debugPrint('🏁 [AchievementBloc] Inicializado e carregando achievements');
    
    // Disparar o evento para carregar dados
    add(LoadAchievements());
  }

  /// Manipulador do evento LoadAchievements
  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    // Impede carregamentos múltiplos ou muito frequentes
    if (_isLoadingAchievements || !_canReloadAchievements) {
      debugPrint('⏳ [AchievementBloc] Ignorando carregamento duplicado');
      return;
    }
    
    _isLoadingAchievements = true;
    _lastLoadTime = DateTime.now();
    
    try {
      emit(AchievementState.loading());
      
      final allDefinitions = _service.getAllAchievementDefinitions();
      
      // First, force persist any unlocked achievements to ensure database consistency
      await _service.forcePersistUnlockedAchievements();
      
      // Then load all achievements including those from the database
      final userAchievements = await _service.calculateUserAchievements();
      
      debugPrint('📊 [AchievementBloc] Carregados ${userAchievements.length} achievements, ${userAchievements.where((a) => a.isUnlocked).length} desbloqueados');
      
      emit(AchievementState.loaded(
        allDefinitions: allDefinitions,
        userAchievements: userAchievements,
        selectedTimePeriod: state.selectedTimePeriod,
      ));
      
      // Check for new achievements after loading
      if (userAchievements.isNotEmpty && state.status == AchievementStatus.initial) {
        debugPrint('🔍 [AchievementBloc] Verificando novos achievements após primeiro carregamento');
        // Use a small delay to avoid UI jank
        Future.delayed(const Duration(milliseconds: 500), () {
          add(CheckForNewAchievements());
        });
      }
    } catch (e) {
      debugPrint('❌ [AchievementBloc] Erro ao carregar achievements: $e');
      emit(AchievementState.error(e.toString()));
    } finally {
      _isLoadingAchievements = false;
    }
  }

  /// Manipulador do evento MarkAchievementAsViewed
  Future<void> _onMarkAchievementAsViewed(
    MarkAchievementAsViewed event,
    Emitter<AchievementState> emit,
  ) async {
    await _service.markAchievementAsViewed(event.achievementId);
    
    // Update local state
    final updatedAchievements = state.userAchievements.map((ua) {
      if (ua.id == event.achievementId) {
        return UserAchievement(
          id: ua.id,
          definition: ua.definition,
          unlockedAt: ua.unlockedAt,
          isViewed: true,
          progress: ua.progress,
        );
      }
      return ua;
    }).toList();
    
    emit(state.copyWith(userAchievements: updatedAchievements));
  }

  /// Manipulador do evento CheckForNewAchievements
  Future<void> _onCheckForNewAchievements(
    CheckForNewAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    // Prevent concurrent checks and limit check frequency unless forced
    if (!event.forceDailyCheck && (_isCheckingAchievements || !_canCheckAchievements)) {
      debugPrint('⏳ [AchievementBloc] Ignorando verificação duplicada');
      return;
    }
    
    // If we've had too many consecutive failures, stop checking temporarily
    // Unless this is a forced daily check
    if (!event.forceDailyCheck && _consecutiveCheckFailures >= _maxConsecutiveFailures) {
      debugPrint('⚠️ [AchievementBloc] Muitas falhas consecutivas, ignorando verificação temporariamente');
      return;
    }
    
    _isCheckingAchievements = true;
    _lastCheckTime = DateTime.now();
    
    if (event.forceDailyCheck) {
      debugPrint('🔍 [AchievementBloc] Verificando achievements diários (forçado)');
    }
    
    try {
      final newlyUnlocked = await _service.checkForNewAchievements();
      
      // Reset failure counter on success
      _consecutiveCheckFailures = 0;
      
      if (newlyUnlocked.isNotEmpty) {
        debugPrint('✅ [AchievementBloc] ${newlyUnlocked.length} novos achievements desbloqueados');
        
        // Mostrar notificações para novos achievements
        if (_notificationService != null) {
          for (final achievement in newlyUnlocked) {
            await _notificationService!.showAchievementUnlockedNotification(achievement);
          }
        }
        
        // Only refresh if we're not already loading and enough time has passed
        if (state.status != AchievementStatus.loading && _canReloadAchievements) {
          // No need for full reload, just update the viewed status
          
          // Update the user achievements in state to mark these as viewed
          final updatedAchievements = state.userAchievements.map((ua) {
            // If this achievement is in the newly unlocked list, mark it as viewed
            if (newlyUnlocked.any((nu) => nu.id == ua.id)) {
              return UserAchievement(
                id: ua.id,
                definition: ua.definition,
                unlockedAt: ua.unlockedAt,
                isViewed: true,
                progress: 1.0,
              );
            }
            return ua;
          }).toList();
          
          emit(state.copyWith(
            userAchievements: updatedAchievements,
            newlyUnlockedAchievements: newlyUnlocked,
          ));
        } else {
          // Se não pudermos atualizar completamente, ao menos atualizamos a lista de novos
          emit(state.copyWith(
            newlyUnlockedAchievements: newlyUnlocked,
          ));
        }
      } else {
        // Se não houver novos achievements, limpar a lista de recém-desbloqueados
        if (state.newlyUnlockedAchievements != null) {
          emit(state.copyWith(clearNewlyUnlocked: true));
        }
      }
    } catch (e) {
      debugPrint('❌ [AchievementBloc] Erro ao verificar novos achievements: $e');
      // Increment failure counter
      _consecutiveCheckFailures++;
    } finally {
      _isCheckingAchievements = false;
    }
  }

  /// Manipulador do evento ChangeTimePeriod
  void _onChangeTimePeriod(
    ChangeTimePeriod event,
    Emitter<AchievementState> emit,
  ) {
    if (event.period != state.selectedTimePeriod) {
      emit(state.copyWith(selectedTimePeriod: event.period));
    }
  }

  /// Manipulador do evento ClearAchievementError
  void _onClearAchievementError(
    ClearAchievementError event,
    Emitter<AchievementState> emit,
  ) {
    if (state.status == AchievementStatus.error) {
      emit(state.copyWith(
        status: state.userAchievements.isNotEmpty 
            ? AchievementStatus.loaded 
            : AchievementStatus.initial,
        clearError: true,
      ));
    }
  }
}