import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:nicotinaai_flutter/features/achievements/helpers/achievement_helper.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';
import 'package:nicotinaai_flutter/features/home/repositories/craving_repository.dart';
import 'package:nicotinaai_flutter/features/home/repositories/smoking_record_repository.dart';
import 'package:nicotinaai_flutter/features/tracking/models/craving.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/repositories/tracking_repository.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';
import 'package:nicotinaai_flutter/utils/improved_stats_calculator.dart';
import 'package:nicotinaai_flutter/utils/date_normalizer.dart';

import 'tracking_event.dart';
import 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  // Main repositories
  final TrackingRepository _repository;
  final CravingRepository _cravingRepository = CravingRepository();
  final SmokingRecordRepository _smokingRecordRepository = SmokingRecordRepository();
  
  // Services
  final NotificationService _notificationService = NotificationService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final _uuid = const Uuid();

  // Cache system
  DateTime? _lastStatsUpdateTime;
  DateTime? _lastLogsUpdateTime;
  DateTime? _lastCravingsUpdateTime;
  DateTime? _lastRecoveriesUpdateTime;
  DateTime? _lastUnifiedCravingsUpdateTime;
  DateTime? _lastSmokingRecordsUpdateTime;

  // Cache expiration time (5 minutes)
  static const Duration cacheExpiration = Duration(minutes: 5);

  // Loading flag to prevent multiple simultaneous initializations
  bool _isInitializing = false;

  TrackingBloc({required TrackingRepository repository}) : _repository = repository, super(const TrackingState()) {
    // Initialize notification service
    _notificationService.init();

    // Register event handlers
    on<InitializeTracking>(_onInitializeTracking);

    // User Stats events
    on<LoadUserStats>(_onLoadUserStats);
    on<RefreshUserStats>(_onRefreshUserStats);
    on<ForceUpdateStats>(_onForceUpdateStats);

    // Original Smoking Logs events
    on<LoadSmokingLogs>(_onLoadSmokingLogs);
    on<RefreshSmokingLogs>(_onRefreshSmokingLogs);
    on<AddSmokingLog>(_onAddSmokingLog);
    on<DeleteSmokingLog>(_onDeleteSmokingLog);
    on<SmokingRecordAdded>(_onSmokingRecordAdded);

    // Original Cravings events
    on<LoadCravings>(_onLoadCravings);
    on<RefreshCravings>(_onRefreshCravings);
    on<AddCraving>(_onAddCraving);
    on<UpdateCraving>(_onUpdateCraving);
    on<CravingAdded>(_onCravingAdded);

    // Health Recoveries events
    on<LoadHealthRecoveries>(_onLoadHealthRecoveries);

    // Global events
    on<RefreshAllData>(_onRefreshAllData);
    on<ClearError>(_onClearError);
    on<ResetTrackingData>(_onResetTrackingData);
    
    // ===== New unified smoking records events =====
    on<LoadSmokingRecordsForUser>(_onLoadSmokingRecordsForUser);
    on<SaveSmokingRecord>(_onSaveSmokingRecord);
    on<RemoveSmokingRecord>(_onRemoveSmokingRecord);
    on<RetrySyncSmokingRecord>(_onRetrySyncSmokingRecord);
    on<SyncPendingSmokingRecords>(_onSyncPendingSmokingRecords);
    on<GetSmokingRecordCount>(_onGetSmokingRecordCount);
    on<ClearSmokingRecordError>(_onClearSmokingRecordError);
    
    // ===== New unified cravings events =====
    on<LoadCravingsForUser>(_onLoadCravingsForUser);
    on<SaveCraving>(_onSaveCraving);
    on<RemoveCraving>(_onRemoveCraving);
    on<RetrySyncCraving>(_onRetrySyncCraving);
    on<SyncPendingCravings>(_onSyncPendingCravings);
    on<GetCravingCount>(_onGetCravingCount);
    on<ClearCravingError>(_onClearCravingError);
  }

  // Verifica se o cache expirou
  bool _isCacheExpired(DateTime? lastUpdate) {
    if (lastUpdate == null) return true;
    final now = DateTime.now();
    return now.difference(lastUpdate) > cacheExpiration;
  }

  Future<void> _onInitializeTracking(InitializeTracking event, Emitter<TrackingState> emit) async {
    if (_isInitializing) return;

    try {
      _isInitializing = true;

      emit(
        state.copyWith(status: TrackingStatus.loading, isStatsLoading: true, isLogsLoading: true, isCravingsLoading: true, isRecoveriesLoading: true),
      );

      // Primeiro carrega estatísticas do usuário e dados básicos
      await Future.wait([
        _loadUserStats(emit, forceRefresh: false),
        _loadSmokingLogs(emit, forceRefresh: false),
        _loadCravings(emit, forceRefresh: false),
      ]);

      // IMPORTANTE: Carregar unifiedCravings para garantir que os dados de cravings resistidos hoje sejam calculados corretamente
      if (state.userStats != null) {
        final userId = state.userStats!.userId;
        if (userId != null) {
          try {
            if (kDebugMode) {
              print('🔄 [TrackingBloc] Carregando unifiedCravings para o usuário: $userId');
            }
            await _onLoadCravingsForUser(LoadCravingsForUser(userId: userId), emit);
            
            if (kDebugMode) {
              print('✅ [TrackingBloc] Cravings unificados carregados: ${state.unifiedCravings.length}');
              
              // Calcular cravings resistidos hoje diretamente do estado
              int todayResisted = _calculateCravingsResistedToday();
              int minutesGainedToday = todayResisted * ImprovedStatsCalculator.MINUTES_PER_CIGARETTE;
              
              print('📊 [TrackingBloc] Cravings resistidos hoje: $todayResisted');
              print('📊 [TrackingBloc] Minutos ganhos hoje: $minutesGainedToday min');
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ [TrackingBloc] Erro ao carregar unifiedCravings: $e');
            }
          }
        }
      }

      // Try to ensure we have user stats
      if (state.userStats == null) {
        try {
          await _loadUserStats(emit, forceRefresh: true);
        } catch (statsErr) {
          print('Error loading user stats: $statsErr');
        }
      }
      
      // Verificar se temos valores nulos que precisam ser atualizados do servidor
      // Valores zero são considerados válidos e não devem forçar uma atualização
      if (state.userStats != null && 
         (state.userStats!.totalMinutesGained == null || 
          state.userStats!.moneySaved == null) &&
         state.userStats!.lastSmokeDate != null) {
        if (kDebugMode) {
          print('🔄 Stats values missing with valid last_smoke_date, forcing update from server...');
          print('📊 Current values - minutes: ${state.userStats!.totalMinutesGained}, money: ${state.userStats!.moneySaved}');
        }
        await _repository.updateUserStats();
        await _loadUserStats(emit, forceRefresh: true);
      }

      // If we have smoking logs, make sure we have a last smoke date
      if (state.userStats != null && state.userStats!.lastSmokeDate == null && state.smokingLogs.isNotEmpty) {
        // Try to update the last smoke date from the latest smoking log
        try {
          await _repository.updateUserStats();
          await _loadUserStats(emit, forceRefresh: true);
        } catch (updateErr) {
          print('Error updating user stats: $updateErr');
        }
      }

      // Log current user stats status
      if (state.userStats == null) {
        print('User stats not available after initialization');
      } else if (state.userStats!.lastSmokeDate == null) {
        print('Last smoke date not available after initialization');
      } else {
        print('User stats available: last smoke date = ${state.userStats!.lastSmokeDate}');
      }

      // First load existing health recoveries
      try {
        await _loadHealthRecoveries(emit, forceRefresh: false);
      } catch (e) {
        print('Error loading health recoveries: $e');
        // Ensure we have at least empty recoveries list
        emit(state.copyWith(healthRecoveries: [], userHealthRecoveries: [], isRecoveriesLoading: false));
      }

      // Verifica se há logs de fumo ou data do último cigarro para verificar recuperações
      if (state.smokingLogs.isNotEmpty || (state.userStats != null && state.userStats!.lastSmokeDate != null)) {
        try {
          // Se não temos data do último cigarro mas temos logs de fumo, tenta atualizar as estatísticas primeiro
          if ((state.userStats == null || state.userStats!.lastSmokeDate == null) && state.smokingLogs.isNotEmpty) {
            print('⚠️ No last smoke date available but smoking logs exist - updating stats first');
            try {
              // Atualiza as estatísticas usando os logs de fumo
              await _repository.updateUserStats();
              await _loadUserStats(emit, forceRefresh: true);
            } catch (statsErr) {
              print('⚠️ Error updating user stats: $statsErr');
            }
          }

          print('✅ Checking for new health recoveries...');
          final result = await _repository.checkHealthRecoveries(updateAchievements: false);
          print('✅ Health recovery check completed: $result');

          // Reload health recoveries after successful check
          await _loadHealthRecoveries(emit, forceRefresh: true);
        } catch (e) {
          print('⚠️ Error checking health recoveries: $e');
          // Continue even if there's an error with checking health recoveries
        }
      } else {
        print('⚠️ Skipping health recovery check: No smoking logs or last smoke date available');
      }

      emit(
        state.copyWith(
          status: TrackingStatus.loaded,
          isStatsLoading: false,
          isLogsLoading: false,
          isCravingsLoading: false,
          isRecoveriesLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TrackingStatus.error,
          errorMessage: e.toString(),
          isStatsLoading: false,
          isLogsLoading: false,
          isCravingsLoading: false,
          isRecoveriesLoading: false,
        ),
      );
    } finally {
      _isInitializing = false;
    }
  }

  // User Stats Methods
  Future<void> _onLoadUserStats(LoadUserStats event, Emitter<TrackingState> emit) async {
    await _loadUserStats(emit, forceRefresh: event.forceRefresh);
  }

  Future<void> _loadUserStats(Emitter<TrackingState> emit, {bool forceRefresh = false}) async {
    // Usa cache se disponível e não expirado
    if (!forceRefresh && !_isCacheExpired(_lastStatsUpdateTime) && state.userStats != null) {
      if (kDebugMode) {
        print('Using cached user stats from $_lastStatsUpdateTime');
      }
      emit(state.copyWith(isStatsLoading: false));
      return;
    }

    try {
      final stats = await _repository.getUserStats();
      _lastStatsUpdateTime = DateTime.now();

      // Verificar se os dados estão com valores inválidos quando deveriam ter valores
      if (stats != null) {
        // Verificar se temos campos zerados que não deveriam estar zerados
        if (kDebugMode) {
          print('📊 [TrackingBloc] Stats loaded: cravingsResisted=${stats.cravingsResisted}, ' +
                'cigarettesAvoided=${stats.cigarettesAvoided}, moneySaved=${stats.moneySaved}');
                
          // Depurar informações da data se disponível
          if (stats.lastSmokeDate != null) {
            print('📊 [TrackingBloc] Last smoke date from server: ${stats.lastSmokeDate!.toIso8601String()} (UTC: ${stats.lastSmokeDate!.isUtc})');
          }
        }
        
        // Verificamos se temos cravings zerado, mas smoking logs ou last_smoke_date presentes
        // o que indicaria um problema com os dados
        final bool hasInvalidZeros = 
          (stats.cravingsResisted == 0 && stats.lastSmokeDate != null) ||
          (stats.cigarettesAvoided == 0 && stats.lastSmokeDate != null) ||
          (stats.moneySaved == 0 && stats.lastSmokeDate != null && stats.cigarettesAvoided > 0);
          
        if (hasInvalidZeros) {
          if (kDebugMode) {
            print('⚠️ [TrackingBloc] Detected invalid zeros in stats with last_smoke_date present.');
            print('⚠️ [TrackingBloc] Forcing stats recalculation...');
          }
          
          // Forçar a atualização das estatísticas no servidor
          await _repository.updateUserStats();
          
          // Recarregar os dados atualizados
          final updatedStats = await _repository.getUserStats();
          
          if (kDebugMode) {
            if (updatedStats != null) {
              print('✅ [TrackingBloc] Stats recalculated: cravingsResisted=${updatedStats.cravingsResisted}, ' +
                    'cigarettesAvoided=${updatedStats.cigarettesAvoided}, moneySaved=${updatedStats.moneySaved}');
            } else {
              print('⚠️ [TrackingBloc] Failed to recalculate stats: updatedStats is null');
            }
          }
          
          // Usar as estatísticas atualizadas ou originais
          final statsToUse = updatedStats ?? stats;
          
          emit(state.copyWith(userStats: statsToUse, isStatsLoading: false));
        } else {
          // Usar as estatísticas diretamente
          if (kDebugMode && stats.lastSmokeDate != null) {
            print('📊 [TrackingBloc] Stat values from server:');
            print('   - Dias sem fumar: ${stats.currentStreakDays}');
            print('   - Cigarros evitados: ${stats.cigarettesAvoided}');
            print('   - Economia: ${stats.moneySaved}');
            print('   - Data do último cigarro: ${stats.lastSmokeDate!.toIso8601String()} (UTC: ${stats.lastSmokeDate!.isUtc})');
          }
          
          emit(state.copyWith(userStats: stats, isStatsLoading: false));
        }
      } else {
        // Se não há stats, simplesmente emitir o null
        emit(state.copyWith(userStats: stats, isStatsLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load user stats: ${e.toString()}', isStatsLoading: false));
    }
  }

  Future<void> _onRefreshUserStats(RefreshUserStats event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(isStatsLoading: true));

    try {
      // Update stats using the local implementation
      final updatedStats = await _repository.updateUserStats();
      
      if (updatedStats != null) {
        if (kDebugMode) {
          print('🔄 [TrackingBloc] Stats refreshed');
          if (updatedStats.lastSmokeDate != null) {
            print('📊 [TrackingBloc] Stats values:');
            print('   - Dias sem fumar: ${updatedStats.currentStreakDays}');
            print('   - Cigarros evitados: ${updatedStats.cigarettesAvoided}');
            print('   - Data do último cigarro: ${updatedStats.lastSmokeDate!.toIso8601String()} (UTC: ${updatedStats.lastSmokeDate!.isUtc})');
          }
        }
        
        // Usar as estatísticas atualizadas diretamente
        emit(state.copyWith(
          userStats: updatedStats, 
          isStatsLoading: false,
          lastUpdated: DateTime.now().millisecondsSinceEpoch
        ));
      } else {
        // Fallback to loading stats from server
        await _loadUserStats(emit, forceRefresh: true);
      }
    } finally {
      // If still loading for some reason, ensure loading flag is reset
      if (state.isStatsLoading) {
        emit(state.copyWith(isStatsLoading: false));
      }
    }
  }

  Future<void> _onForceUpdateStats(ForceUpdateStats event, Emitter<TrackingState> emit) async {
    if (kDebugMode) {
      print('🔄 [TrackingBloc] Forcing stats update...');
      if (state.userStats != null) {
        print('📊 [TrackingBloc] Current values before update:');
        print('   - Cravings Resisted: ${state.userStats!.cravingsResisted}');
        print('   - Cigarros Evitados: ${state.userStats!.cigarettesAvoided}');
        print('   - Minutos Ganhos Total: ${state.userStats!.totalMinutesGained}');
        print('   - Minutos Ganhos Hoje: ${state.userStats!.minutesGainedToday}');
        print('   - Economia: ${state.userStats!.moneySaved}');
        print('   - Dias sem fumar: ${state.userStats!.currentStreakDays}');
        
        // Depurar informações da data usando o TrackingNormalizer para diagnóstico
        if (state.userStats!.lastSmokeDate != null && kDebugMode) {
          print('🔄 [TrackingBloc] Antes da atualização, estado atual:');
          print('   - Dias sem fumar: ${state.userStats!.currentStreakDays}');
          print('   - Data do último cigarro: ${state.userStats!.lastSmokeDate!.toIso8601String()}');
        }
      }
    }

    try {
      // First emit a loading state to ensure subscribers notice the change
      emit(state.copyWith(
        isStatsLoading: true,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));

      // First load fresh cravings
      await _loadCravings(emit, forceRefresh: true);

      // Now update stats based on fresh cravings with local implementation
      final updatedStats = await _repository.updateUserStats();
      
      if (kDebugMode) {
        print('📊 [TrackingBloc] updateUserStats calculation completed');
      }

      if (updatedStats != null) {
        // Usar estatísticas diretamente (elas já serão normalizadas pelo TrackingNormalizer)
        emit(state.copyWith(
          userStats: updatedStats, 
          isStatsLoading: false,
          lastUpdated: DateTime.now().millisecondsSinceEpoch
        ));
      } else {
        // Fallback to loading stats from server
        await _loadUserStats(emit, forceRefresh: true);
      }

      // Log the changes for comparison
      if (kDebugMode && state.userStats != null) {
        print('📊 [TrackingBloc] Values after update:');
        print('   - Cravings Resisted: ${state.userStats!.cravingsResisted}');
        print('   - Cigarros Evitados: ${state.userStats!.cigarettesAvoided}');
        print('   - Minutos Ganhos Total: ${state.userStats!.totalMinutesGained}');
        print('   - Minutos Ganhos Hoje: ${state.userStats!.minutesGainedToday}');
        print('   - Economia: ${state.userStats!.moneySaved}');
        print('   - Dias sem fumar: ${state.userStats!.currentStreakDays}');
        
        // Depurar após atualização
        if (state.userStats!.lastSmokeDate != null && kDebugMode) {
          print('🔄 [TrackingBloc] Após atualização, valores atualizados:');
          print('   - Dias sem fumar: ${state.userStats!.currentStreakDays}');
          print('   - Data do último cigarro: ${state.userStats!.lastSmokeDate!.toIso8601String()}');
          print('   - É UTC: ${state.userStats!.lastSmokeDate!.isUtc}');
        }
      }

      // Ensure the state is clearly different when emitted
      emit(
        state.copyWith(
          isStatsLoading: false,
          // Force a timestamp update to make the state change detectable
          status: TrackingStatus.loaded,
          lastUpdated: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      if (kDebugMode) {
        print('✅ [TrackingBloc] Stats updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TrackingBloc] Error forcing stats update: $e');
      }
      emit(state.copyWith(
        isStatsLoading: false,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    }
  }

  // Smoking Logs Methods
  Future<void> _onLoadSmokingLogs(LoadSmokingLogs event, Emitter<TrackingState> emit) async {
    await _loadSmokingLogs(emit, forceRefresh: event.forceRefresh);
  }

  Future<void> _loadSmokingLogs(Emitter<TrackingState> emit, {bool forceRefresh = false}) async {
    // Usa cache se disponível e não expirado
    if (!forceRefresh && !_isCacheExpired(_lastLogsUpdateTime) && state.smokingLogs.isNotEmpty) {
      if (kDebugMode) {
        print('Using cached smoking logs from $_lastLogsUpdateTime');
      }
      emit(state.copyWith(isLogsLoading: false));
      return;
    }

    try {
      final logs = await _repository.getSmokingLogs();
      _lastLogsUpdateTime = DateTime.now();

      emit(state.copyWith(smokingLogs: logs, isLogsLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load smoking logs: ${e.toString()}', isLogsLoading: false));
    }
  }

  Future<void> _onRefreshSmokingLogs(RefreshSmokingLogs event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(isLogsLoading: true));
    await _loadSmokingLogs(emit, forceRefresh: true);
  }

  Future<void> _onAddSmokingLog(AddSmokingLog event, Emitter<TrackingState> emit) async {
    try {
      emit(state.copyWith(status: TrackingStatus.saving));

      final addedLog = await _repository.addSmokingLog(event.log);

      // Update the local list
      final updatedLogs = [addedLog, ...state.smokingLogs];

      emit(state.copyWith(status: TrackingStatus.loaded, smokingLogs: updatedLogs));

      // Update stats on the server
      await _repository.updateUserStats();

      // Refresh stats locally
      await _loadUserStats(emit, forceRefresh: true);

      // Reset the cache para garantir dados atualizados
      _lastLogsUpdateTime = DateTime.now();
    } catch (e) {
      emit(state.copyWith(status: TrackingStatus.error, errorMessage: 'Failed to add smoking log: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteSmokingLog(DeleteSmokingLog event, Emitter<TrackingState> emit) async {
    try {
      emit(state.copyWith(status: TrackingStatus.saving));

      await _repository.deleteSmokingLog(event.logId);

      // Update the local list
      final updatedLogs = state.smokingLogs.where((log) => log.id != event.logId).toList();

      emit(state.copyWith(status: TrackingStatus.loaded, smokingLogs: updatedLogs));

      // Update stats on the server
      await _repository.updateUserStats();

      // Refresh stats locally
      await _loadUserStats(emit, forceRefresh: true);

      // Reset the cache para garantir dados atualizados
      _lastLogsUpdateTime = DateTime.now();
    } catch (e) {
      emit(state.copyWith(status: TrackingStatus.error, errorMessage: 'Failed to delete smoking log: ${e.toString()}'));
    }
  }

  // Cravings Methods
  Future<void> _onLoadCravings(LoadCravings event, Emitter<TrackingState> emit) async {
    await _loadCravings(emit, forceRefresh: event.forceRefresh);
  }

  Future<void> _loadCravings(Emitter<TrackingState> emit, {bool forceRefresh = false}) async {
    // Usa cache se disponível e não expirado
    if (!forceRefresh && !_isCacheExpired(_lastCravingsUpdateTime) && state.cravings.isNotEmpty) {
      if (kDebugMode) {
        print('Using cached cravings from $_lastCravingsUpdateTime');
      }
      emit(state.copyWith(isCravingsLoading: false));
      return;
    }

    try {
      final cravings = await _repository.getCravings();
      _lastCravingsUpdateTime = DateTime.now();

      emit(state.copyWith(cravings: cravings, isCravingsLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load cravings: ${e.toString()}', isCravingsLoading: false));
    }
  }

  Future<void> _onRefreshCravings(RefreshCravings event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(isCravingsLoading: true));
    await _loadCravings(emit, forceRefresh: true);
  }

  Future<void> _onAddCraving(AddCraving event, Emitter<TrackingState> emit) async {
    try {
      emit(state.copyWith(status: TrackingStatus.saving));

      final addedCraving = await _repository.addCraving(event.craving);

      // Update the local list
      final updatedCravings = [addedCraving, ...state.cravings];

      emit(state.copyWith(status: TrackingStatus.loaded, cravings: updatedCravings));

      // Track craving event in analytics
      try {
        if (event.craving.outcome == CravingOutcome.resisted) {
          await _analyticsService.logCravingResisted(triggerType: event.craving.trigger ?? 'unknown');

          if (state.userStats != null) {
            // Update user properties with current stats
            await _analyticsService.setUserProperties(daysSmokeFree: state.userStats!.smokeFreeStreak);
          }
        }
      } catch (analyticsError) {
        print('⚠️ [TrackingBloc] Failed to track craving event: $analyticsError');
      }

      // Update stats on the server
      await _repository.updateUserStats();

      // Check for achievements (might have resisted a craving)
      await _repository.checkAchievements();

      // Refresh stats locally
      await _loadUserStats(emit, forceRefresh: true);

      // Reset the cache para garantir dados atualizados
      _lastCravingsUpdateTime = DateTime.now();

      // Show notification when user resisted a craving
      if (event.craving.outcome == CravingOutcome.resisted && event.context != null) {
        final l10n = AppLocalizations.of(event.context!);
        if (l10n != null) {
          await _notificationService.showCravingResistedNotification(l10n);
        }
      }
    } catch (e) {
      emit(state.copyWith(status: TrackingStatus.error, errorMessage: 'Failed to add craving: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCraving(UpdateCraving event, Emitter<TrackingState> emit) async {
    try {
      emit(state.copyWith(status: TrackingStatus.saving));

      final updatedCraving = await _repository.updateCraving(event.craving);

      // Update the local list
      final updatedCravings =
          state.cravings.map((c) {
            return c.id == event.craving.id ? updatedCraving : c;
          }).toList();

      emit(state.copyWith(status: TrackingStatus.loaded, cravings: updatedCravings));

      // Update stats on the server
      await _repository.updateUserStats();

      // Refresh stats locally
      await _loadUserStats(emit, forceRefresh: true);

      // Reset the cache para garantir dados atualizados
      _lastCravingsUpdateTime = DateTime.now();
    } catch (e) {
      emit(state.copyWith(status: TrackingStatus.error, errorMessage: 'Failed to update craving: ${e.toString()}'));
    }
  }

  /// Handler para o evento CravingAdded - atualização direta da base de dados
  Future<void> _onCravingAdded(CravingAdded event, Emitter<TrackingState> emit) async {
    if (kDebugMode) {
      print('🔄 [TrackingBloc] Processando evento CravingAdded');
      print('🔄 [TrackingBloc] Craving resistido: ${event.resisted}');
    }

    // Indicar que está carregando
    emit(state.copyWith(status: TrackingStatus.loading));

    try {
      // Atualizar os stats no servidor
      await _repository.updateUserStats();
      
      // Buscar dados atualizados
      await _loadUserStats(emit, forceRefresh: true);

      if (kDebugMode) {
        print('✅ [TrackingBloc] Atualização completa para craving adicionado');
        if (state.userStats != null) {
          print('📊 [TrackingBloc] Valores após atualização do servidor:');
          print('  - Cravings resistidos: ${state.userStats!.cravingsResisted}');
          print('  - Cigarros evitados: ${state.userStats!.cigarettesAvoided}');  
          print('  - Economia: ${state.userStats!.moneySaved} centavos');
          print('  - Minutos ganhos hoje: ${state.userStats!.minutesGainedToday}');
          print('  - Minutos ganhos total: ${state.userStats!.totalMinutesGained}');
        }
      }
      
      // Emitir estado atualizado com status de sucesso
      emit(state.copyWith(
        status: TrackingStatus.loaded,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TrackingBloc] Erro na atualização: $e');
      }
      
      // Emitir estado de erro
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: 'Erro ao atualizar estatísticas: ${e.toString()}',
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    }
  }

  /// Handler para o evento SmokingRecordAdded - atualização direta da base de dados
  Future<void> _onSmokingRecordAdded(SmokingRecordAdded event, Emitter<TrackingState> emit) async {
    if (kDebugMode) {
      print('🔄 [TrackingBloc] Processando evento SmokingRecordAdded');
      print('🔄 [TrackingBloc] Quantidade de cigarros: ${event.amount}');
    }

    // Indicar que está carregando
    emit(state.copyWith(status: TrackingStatus.loading));

    try {
      // Atualizar os stats no servidor
      await _repository.updateUserStats();
      
      // Buscar dados atualizados
      await _loadUserStats(emit, forceRefresh: true);

      if (kDebugMode) {
        print('✅ [TrackingBloc] Atualização completa para registro de fumo');
        if (state.userStats != null) {
          print('📊 [TrackingBloc] Valores após atualização do servidor:');
          print('  - Cigarros fumados: ${state.userStats!.cigarettesSmoked}');
          print('  - Registros: ${state.userStats!.smokingRecordsCount}');
          print('  - Cigarros evitados: ${state.userStats!.cigarettesAvoided}');
          print('  - Sequência atual (dias): ${state.userStats!.currentStreakDays}');
          print('  - Minutos ganhos hoje: ${state.userStats!.minutesGainedToday}');
          print('  - Minutos ganhos total: ${state.userStats!.totalMinutesGained}');
        }
      }
      
      // Emitir estado atualizado com status de sucesso
      emit(state.copyWith(
        status: TrackingStatus.loaded,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TrackingBloc] Erro na atualização: $e');
      }
      
      // Emitir estado de erro
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: 'Erro ao atualizar estatísticas: ${e.toString()}',
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    }
  }

  // Health Recoveries Methods
  Future<void> _onLoadHealthRecoveries(LoadHealthRecoveries event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(isRecoveriesLoading: true));

    try {
      // First check if we have smoking logs to possibly update the last smoke date
      if (state.smokingLogs.isNotEmpty) {
        // Try to update user stats using the latest smoking log
        try {
          await _repository.updateUserStats();
        } catch (e) {
          print('Error updating user stats: $e');
        }
      }

      // Load updated user stats
      try {
        await _loadUserStats(emit, forceRefresh: true);
      } catch (e) {
        print('Error refreshing user stats: $e');
      }

      // Now check the stats situation
      final userStats = state.userStats;

      // Informação de debug importante
      if (userStats == null) {
        print('⚠️ User stats not available in bloc');
      } else if (userStats.lastSmokeDate == null) {
        print('⚠️ Data do último cigarro não disponível no bloc');
      } else {
        print('✅ User stats available with last smoke date: ${userStats.lastSmokeDate}');
      }

      // Primeiro sempre carrega as recuperações de saúde existentes
      try {
        await _loadHealthRecoveries(emit, forceRefresh: event.forceRefresh);
        print('✅ Successfully loaded existing health recoveries');
      } catch (e) {
        print('⚠️ Error loading existing health recoveries: $e');
        // Set empty lists if we couldn't load anything
        emit(state.copyWith(healthRecoveries: [], userHealthRecoveries: [], isRecoveriesLoading: false));
      }

      // Verifica se há logs de fumo ou data do último cigarro para verificar recuperações
      if (state.smokingLogs.isNotEmpty || (userStats != null && userStats.lastSmokeDate != null)) {
        print('✅ Checking for new health recoveries...');
        try {
          // Se não temos data do último cigarro mas temos logs de fumo, tenta atualizar as estatísticas primeiro
          if ((userStats == null || userStats.lastSmokeDate == null) && state.smokingLogs.isNotEmpty) {
            print('⚠️ No last smoke date available but smoking logs exist - updating stats first');
            try {
              // Atualiza as estatísticas usando os logs de fumo
              await _repository.updateUserStats();
              await _loadUserStats(emit, forceRefresh: true);
            } catch (statsErr) {
              print('⚠️ Error updating user stats: $statsErr');
            }
          }

          // Depois verifica recuperações de saúde
          final result = await _repository.checkHealthRecoveries(updateAchievements: false);
          print('✅ Health recovery check completed: $result');

          // Reload health recoveries after successful check
          await _loadHealthRecoveries(emit, forceRefresh: true);
        } catch (e) {
          print('⚠️ Error checking for new health recoveries: $e');
          // Continue even if checkHealthRecoveries fails - não é crítico
        }
      } else {
        print('⚠️ Skipping health recovery check: No smoking logs or last smoke date available');
      }
    } catch (e) {
      print('❌ Unexpected error in loadHealthRecoveries: $e');
      emit(
        state.copyWith(
          errorMessage: 'Failed to load health recoveries: ${e.toString()}',
          isRecoveriesLoading: false,
          // Ensure we have at least empty lists even in case of error
          healthRecoveries: state.healthRecoveries.isEmpty ? [] : state.healthRecoveries,
          userHealthRecoveries: state.userHealthRecoveries.isEmpty ? [] : state.userHealthRecoveries,
        ),
      );
    } finally {
      emit(state.copyWith(isRecoveriesLoading: false));
    }
  }

  Future<void> _loadHealthRecoveries(Emitter<TrackingState> emit, {bool forceRefresh = false}) async {
    // Usa cache se disponível e não expirado
    if (!forceRefresh && !_isCacheExpired(_lastRecoveriesUpdateTime) && state.healthRecoveries.isNotEmpty && state.userHealthRecoveries.isNotEmpty) {
      if (kDebugMode) {
        print('Using cached health recoveries from $_lastRecoveriesUpdateTime');
      }
      emit(state.copyWith(isRecoveriesLoading: false));
      return;
    }

    try {
      List<HealthRecovery> recoveries = [];
      List<UserHealthRecovery> userRecoveries = [];
      List<UserHealthRecovery> previousUserRecoveries = List.from(state.userHealthRecoveries);

      try {
        recoveries = await _repository.getHealthRecoveries();
      } catch (e) {
        print('Error getting health recoveries: $e');
        // Continue with empty recoveries list
        recoveries = [];
      }

      try {
        userRecoveries = await _repository.getUserHealthRecoveries();
      } catch (e) {
        print('Error getting user health recoveries: $e');
        // Continue with empty user recoveries list
        userRecoveries = [];
      }

      _lastRecoveriesUpdateTime = DateTime.now();

      emit(state.copyWith(healthRecoveries: recoveries, userHealthRecoveries: userRecoveries, isRecoveriesLoading: false));

      // Track newly achieved health recoveries
      try {
        if (userRecoveries.isNotEmpty) {
          // Find newly achieved health recoveries since last load
          for (final userRecovery in userRecoveries) {
            // Only track achievements that are achieved
            if (userRecovery.isAchieved) {
              // Check if it's newly achieved by comparing with previous list
              final wasAlreadyAchieved = previousUserRecoveries.any((prev) => prev.id == userRecovery.id && prev.isAchieved);

              if (!wasAlreadyAchieved) {
                // Find the health recovery details
                final recoveryDetails = recoveries.firstWhere(
                  (r) => r.id == userRecovery.recoveryId,
                  orElse:
                      () => HealthRecovery(
                        id: userRecovery.recoveryId,
                        name: 'Unknown Recovery',
                        description: '',
                        daysToAchieve: userRecovery.daysToAchieve,
                      ),
                );

                // Track the health recovery achievement
                await _analyticsService.logHealthRecoveryAchieved(recoveryDetails.name);

                // If this is a major milestone (e.g., 1 day, 1 week, 1 month), track it specially
                final importantMilestones = [1, 7, 14, 30, 90, 180, 365];
                if (importantMilestones.contains(recoveryDetails.daysToAchieve)) {
                  await _analyticsService.logSmokingFreeMilestone(recoveryDetails.daysToAchieve);

                  // Update user properties with current stats
                  if (state.userStats != null) {
                    await _analyticsService.setUserProperties(daysSmokeFree: state.userStats!.smokeFreeStreak);
                  }
                }

                print('📊 [TrackingBloc] Tracked health recovery achievement: ${recoveryDetails.name}');
              }
            }
          }
        }
      } catch (analyticsError) {
        print('⚠️ [TrackingBloc] Failed to track health recovery achievements: $analyticsError');
      }
    } catch (e) {
      print('Error in _loadHealthRecoveries method: $e');
      emit(
        state.copyWith(
          errorMessage: 'Failed to load health recoveries: ${e.toString()}',
          isRecoveriesLoading: false,
          // Ensure we have at least empty lists even in case of error
          healthRecoveries: [],
          userHealthRecoveries: [],
        ),
      );
    }
  }

  // Global Methods
  Future<void> _onRefreshAllData(RefreshAllData event, Emitter<TrackingState> emit) async {
    try {
      emit(state.copyWith(isStatsLoading: true, isLogsLoading: true, isCravingsLoading: true, isRecoveriesLoading: true));

      // Update stats on the server
      await _repository.updateUserStats();

      // Limpa o cache para forçar a recarga de todos os dados
      if (event.forceRefresh) {
        _lastStatsUpdateTime = null;
        _lastLogsUpdateTime = null;
        _lastCravingsUpdateTime = null;
        _lastRecoveriesUpdateTime = null;
        _lastUnifiedCravingsUpdateTime = null;
        _lastSmokingRecordsUpdateTime = null;
      }

      // Primeiro carrega as estatísticas do usuário
      await _loadUserStats(emit, forceRefresh: event.forceRefresh);

      // IMPORTANTE: Carregar unifiedCravings para garantir que os dados de cravings resistidos hoje sejam atualizados
      if (state.userStats != null) {
        final userId = state.userStats!.userId;
        if (userId != null) {
          try {
            if (kDebugMode) {
              print('🔄 [TrackingBloc] Recarregando unifiedCravings para o usuário: $userId');
            }
            await _onLoadCravingsForUser(LoadCravingsForUser(userId: userId), emit);
            
            if (kDebugMode) {
              print('✅ [TrackingBloc] Cravings unificados recarregados: ${state.unifiedCravings.length}');
              
              // Calcular cravings resistidos hoje diretamente do estado
              int todayResisted = _calculateCravingsResistedToday();
              int minutesGainedToday = todayResisted * ImprovedStatsCalculator.MINUTES_PER_CIGARETTE;
              
              print('📊 [TrackingBloc] Cravings resistidos hoje: $todayResisted');
              print('📊 [TrackingBloc] Minutos ganhos hoje: $minutesGainedToday min');
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ [TrackingBloc] Erro ao recarregar unifiedCravings: $e');
            }
          }
        }
      }

      // Check for new achievements
      try {
        await _repository.checkAchievements();
      } catch (e) {
        print('Error checking achievements: $e');
        // Continue even if checkAchievements fails
      }

      // Verifica se temos estatísticas do usuário e data do último cigarro
      if (state.userStats != null && state.userStats!.lastSmokeDate != null) {
        // Check for health recoveries only if we have last smoke date
        try {
          await _repository.checkHealthRecoveries(updateAchievements: false);
        } catch (e) {
          print('Error checking health recoveries: $e');
          // Continue even if checkHealthRecoveries fails
        }
      } else {
        print('Skipping health recovery check: User stats or last smoke date not available');
      }

      // Reload user stats once more to get the most updated data
      try {
        await _loadUserStats(emit, forceRefresh: true);
      } catch (e) {
        print('Error refreshing user stats: $e');
      }

      // Load remaining data in parallel
      await Future.wait([
        _loadSmokingLogs(emit, forceRefresh: event.forceRefresh),
        _loadCravings(emit, forceRefresh: event.forceRefresh),
        _loadHealthRecoveries(emit, forceRefresh: event.forceRefresh),
      ]);

      emit(
        state.copyWith(
          status: TrackingStatus.loaded,
          isStatsLoading: false,
          isLogsLoading: false,
          isCravingsLoading: false,
          isRecoveriesLoading: false,
          lastUpdated: DateTime.now().millisecondsSinceEpoch
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(errorMessage: e.toString(), isStatsLoading: false, isLogsLoading: false, isCravingsLoading: false, isRecoveriesLoading: false),
      );
    }
  }

  // Error handling
  void _onClearError(ClearError event, Emitter<TrackingState> emit) {
    if (state.hasError) {
      emit(state.copyWith(status: state.isLoaded ? TrackingStatus.loaded : TrackingStatus.initial, errorMessage: null));
    }
  }

  // Reset stats for logout
  void _onResetTrackingData(ResetTrackingData event, Emitter<TrackingState> emit) {
    print('🧹 [TrackingBloc] Resetting all tracking data');
    _lastStatsUpdateTime = null;
    _lastLogsUpdateTime = null;
    _lastCravingsUpdateTime = null;
    _lastRecoveriesUpdateTime = null;
    _lastUnifiedCravingsUpdateTime = null;
    _lastSmokingRecordsUpdateTime = null;
    _isInitializing = false;
    emit(const TrackingState());
  }
  
  // =================================================
  // Unified Smoking Record handlers (migrated from SmokingRecordBloc)
  // =================================================
  
  Future<void> _onLoadSmokingRecordsForUser(LoadSmokingRecordsForUser event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(status: TrackingStatus.loading));
    
    try {
      final serverRecords = await _smokingRecordRepository.getRecordsForUser(event.userId);
      
      // Merge server data with any pending local changes
      final localPendingRecords = state.smokingRecords.where(
        (r) => r.syncStatus == SyncStatus.pending || r.syncStatus == SyncStatus.failed
      ).toList();
      
      // Use server data for everything else
      final updatedRecords = [...serverRecords, ...localPendingRecords];
      
      emit(state.copyWith(
        status: TrackingStatus.loaded,
        smokingRecords: updatedRecords,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
      
      _lastSmokingRecordsUpdateTime = DateTime.now();
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  Future<void> _onSaveSmokingRecord(SaveSmokingRecord event, Emitter<TrackingState> emit) async {
    // Generate a temporary ID for the new record
    final temporaryId = 'temp_${_uuid.v4()}';
    
    // Log for debug
    debugPrint('Creating smoking record with temporary ID: $temporaryId');
    
    // Create an optimistic version with pending status
    final optimisticRecord = event.record.copyWith(
      id: temporaryId,
      syncStatus: SyncStatus.pending
    );
    
    // Update the state immediately (optimistically)
    final updatedRecords = [optimisticRecord, ...state.smokingRecords];
    emit(state.copyWith(
      status: TrackingStatus.saving,
      smokingRecords: updatedRecords,
      lastUpdated: DateTime.now().millisecondsSinceEpoch
    ));
    
    try {
      // Perform the actual API call
      final savedRecord = await _smokingRecordRepository.saveRecord(event.record);
      
      debugPrint('Smoking record saved successfully with ID: ${savedRecord.id}');
      
      // Update the temporary item with the real one
      final finalRecords = updatedRecords.map((r) => 
        r.id == temporaryId ? savedRecord : r
      ).toList();
      
      emit(state.copyWith(
        status: TrackingStatus.loaded,
        smokingRecords: finalRecords,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
      
      // Explicitly check health recoveries to ensure they are reset due to new smoking event
      try {
        debugPrint('Checking health recoveries after new smoking record...');
        
        // This will call the edge function which has been updated to detect 
        // recent smoking events and reset health recoveries if necessary
        await _repository.checkHealthRecoveries(updateAchievements: true);
        debugPrint('Health recoveries check completed after adding smoking record');
      } catch (e) {
        // Non-critical error, just log it
        debugPrint('Error checking health recoveries after new smoking record: $e');
      }
      
      // Update tracking stats
      add(ForceUpdateStats());
      
      // Check for achievements after recording a smoking event
      if (event.record.context != null) {
        AchievementHelper.checkAfterSmokingRecord(event.record.context!);
      }
    } catch (e) {
      debugPrint('Error saving smoking record: $e');
      
      // Mark as failed but keep in the list
      final failedRecords = updatedRecords.map((r) => 
        r.id == temporaryId ? r.copyWith(syncStatus: SyncStatus.failed) : r
      ).toList();
      
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
        smokingRecords: failedRecords,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    }
  }
  
  Future<void> _onRetrySyncSmokingRecord(RetrySyncSmokingRecord event, Emitter<TrackingState> emit) async {
    final recordIndex = state.smokingRecords.indexWhere((r) => r.id == event.id);
    if (recordIndex == -1) return;
    
    // Create a new list with the updated record status
    final updatedRecords = List<SmokingRecordModel>.from(state.smokingRecords);
    updatedRecords[recordIndex] = updatedRecords[recordIndex].copyWith(
      syncStatus: SyncStatus.pending
    );
    
    emit(state.copyWith(
      status: TrackingStatus.saving,
      smokingRecords: updatedRecords,
      lastUpdated: DateTime.now().millisecondsSinceEpoch
    ));
    
    try {
      // Get a clean version without the temporary ID for API
      final recordToSync = updatedRecords[recordIndex].copyWith(
        id: event.id.startsWith('temp_') ? null : event.id
      );
      
      // Perform the actual API call
      final syncedRecord = await _smokingRecordRepository.saveRecord(recordToSync);
      
      // Replace with the synced version in our records list
      updatedRecords[recordIndex] = syncedRecord;
      
      emit(state.copyWith(
        status: TrackingStatus.loaded,
        smokingRecords: updatedRecords,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
      
      // Update the tracking stats
      add(ForceUpdateStats());
    } catch (e) {
      // Mark as failed again
      updatedRecords[recordIndex] = updatedRecords[recordIndex].copyWith(
        syncStatus: SyncStatus.failed
      );
      
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
        smokingRecords: updatedRecords,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    }
  }
  
  Future<void> _onRemoveSmokingRecord(RemoveSmokingRecord event, Emitter<TrackingState> emit) async {
    // Store the original record for potential rollback
    final originalRecord = state.smokingRecords.firstWhere((r) => r.id == event.id);
    
    // Remove immediately (optimistic update)
    final updatedRecords = state.smokingRecords.where((r) => r.id != event.id).toList();
    emit(state.copyWith(
      status: TrackingStatus.loaded,
      smokingRecords: updatedRecords,
      lastUpdated: DateTime.now().millisecondsSinceEpoch
    ));
    
    try {
      // Perform the actual deletion
      await _smokingRecordRepository.deleteRecord(event.id);
      
      // Update the tracking stats
      add(ForceUpdateStats());
    } catch (e) {
      // Put the record back on error
      final rollbackRecords = [...updatedRecords, originalRecord];
      
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
        smokingRecords: rollbackRecords,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    }
  }
  
  Future<void> _onSyncPendingSmokingRecords(SyncPendingSmokingRecords event, Emitter<TrackingState> emit) async {
    final pendingItems = [...state.pendingRecords, ...state.failedRecords];
    
    for (final record in pendingItems) {
      if (record.id != null) {
        add(RetrySyncSmokingRecord(id: record.id!));
      }
    }
  }
  
  Future<void> _onGetSmokingRecordCount(GetSmokingRecordCount event, Emitter<TrackingState> emit) async {
    try {
      final count = await _smokingRecordRepository.getRecordCountForUser(event.userId);
      emit(state.copyWith(
        recordCount: count,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  void _onClearSmokingRecordError(ClearSmokingRecordError event, Emitter<TrackingState> emit) {
    if (state.hasError) {
      emit(state.copyWith(
        errorMessage: null,
        status: state.smokingRecords.isNotEmpty
            ? TrackingStatus.loaded
            : TrackingStatus.initial,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    }
  }
  
  // =================================================
  // Unified Craving handlers (migrated from CravingBloc)
  // =================================================
  
  Future<void> _onLoadCravingsForUser(LoadCravingsForUser event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(status: TrackingStatus.loading));
    
    try {
      final serverCravings = await _cravingRepository.getCravingsForUser(event.userId);
      
      // Merge server data with any pending local changes
      final localPendingCravings = state.unifiedCravings.where(
        (c) => c.syncStatus == SyncStatus.pending || c.syncStatus == SyncStatus.failed
      ).toList();
      
      // Use server data for everything else
      final updatedCravings = [...serverCravings, ...localPendingCravings];
      
      emit(state.copyWith(
        status: TrackingStatus.loaded,
        unifiedCravings: updatedCravings,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
      
      _lastUnifiedCravingsUpdateTime = DateTime.now();
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  Future<void> _onSaveCraving(SaveCraving event, Emitter<TrackingState> emit) async {
    // Generate a temporary ID for the new craving
    final temporaryId = 'temp_${_uuid.v4()}';
    
    // Debug logs
    debugPrint('🆕 [TrackingBloc] Creating craving with ID temporário: $temporaryId');
    
    // Create an optimistic version with pending status
    final optimisticCraving = event.craving.copyWith(
      id: temporaryId,
      syncStatus: SyncStatus.pending
    );
    
    // Update the state immediately (optimistically)
    final updatedCravings = [optimisticCraving, ...state.unifiedCravings];
    emit(state.copyWith(
      status: TrackingStatus.saving,
      unifiedCravings: updatedCravings,
      lastUpdated: DateTime.now().millisecondsSinceEpoch
    ));
    
    try {
      // Perform the actual API call
      final savedCraving = await _cravingRepository.saveCraving(event.craving);
      
      debugPrint('✅ [TrackingBloc] Craving salvo com sucesso com ID: ${savedCraving.id}');
      
      // Update the temporary item with the real one
      final finalCravings = updatedCravings.map((c) => 
        c.id == temporaryId ? savedCraving : c
      ).toList();
      
      emit(state.copyWith(
        status: TrackingStatus.loaded,
        unifiedCravings: finalCravings,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
      
      // Update tracking stats
      add(CravingAdded(resisted: event.craving.resisted));
      
      // Check for health recoveries
      try {
        debugPrint('🏥 [TrackingBloc] Checking health recoveries after craving...');
        await _repository.checkHealthRecoveries(updateAchievements: true);
        debugPrint('✅ [TrackingBloc] Health recoveries check completed');
      } catch (e) {
        // Non-critical error, just log it
        debugPrint('⚠️ [TrackingBloc] Error checking health recoveries: $e');
      }
    } catch (e) {
      debugPrint('❌ [TrackingBloc] Error saving craving: $e');
      
      // Mark as failed but keep in the list
      final failedCravings = updatedCravings.map((c) => 
        c.id == temporaryId ? c.copyWith(syncStatus: SyncStatus.failed) : c
      ).toList();
      
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
        unifiedCravings: failedCravings,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    }
  }
  
  Future<void> _onRetrySyncCraving(RetrySyncCraving event, Emitter<TrackingState> emit) async {
    final cravingIndex = state.unifiedCravings.indexWhere((c) => c.id == event.id);
    if (cravingIndex == -1) return;
    
    // Create a new list with the updated craving status
    final updatedCravings = List<CravingModel>.from(state.unifiedCravings);
    updatedCravings[cravingIndex] = updatedCravings[cravingIndex].copyWith(
      syncStatus: SyncStatus.pending
    );
    
    emit(state.copyWith(
      status: TrackingStatus.saving,
      unifiedCravings: updatedCravings,
      lastUpdated: DateTime.now().millisecondsSinceEpoch
    ));
    
    try {
      // Get a clean version without the temporary ID for API
      final cravingToSync = updatedCravings[cravingIndex].copyWith(
        id: event.id.startsWith('temp_') ? null : event.id
      );
      
      // Perform the actual API call
      final syncedCraving = await _cravingRepository.saveCraving(cravingToSync);
      
      // Replace with the synced version in our cravings list
      updatedCravings[cravingIndex] = syncedCraving;
      
      emit(state.copyWith(
        status: TrackingStatus.loaded,
        unifiedCravings: updatedCravings,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
      
      // Update the tracking stats
      add(CravingAdded(resisted: syncedCraving.resisted));
    } catch (e) {
      // Mark as failed again
      updatedCravings[cravingIndex] = updatedCravings[cravingIndex].copyWith(
        syncStatus: SyncStatus.failed
      );
      
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
        unifiedCravings: updatedCravings,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    }
  }
  
  Future<void> _onRemoveCraving(RemoveCraving event, Emitter<TrackingState> emit) async {
    // Store the original craving for potential rollback
    final originalCraving = state.unifiedCravings.firstWhere((c) => c.id == event.id);
    
    // Remove immediately (optimistic update)
    final updatedCravings = state.unifiedCravings.where((c) => c.id != event.id).toList();
    emit(state.copyWith(
      status: TrackingStatus.loaded,
      unifiedCravings: updatedCravings,
      lastUpdated: DateTime.now().millisecondsSinceEpoch
    ));
    
    try {
      // Perform the actual deletion
      await _cravingRepository.deleteCraving(event.id);
      
      // Update the tracking stats
      add(ForceUpdateStats());
    } catch (e) {
      // Put the craving back on error
      final rollbackCravings = [...updatedCravings, originalCraving];
      
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
        unifiedCravings: rollbackCravings,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    }
  }
  
  Future<void> _onSyncPendingCravings(SyncPendingCravings event, Emitter<TrackingState> emit) async {
    final pendingItems = [...state.pendingCravings, ...state.failedCravings];
    
    for (final craving in pendingItems) {
      if (craving.id != null) {
        add(RetrySyncCraving(id: craving.id!));
      }
    }
  }
  
  Future<void> _onGetCravingCount(GetCravingCount event, Emitter<TrackingState> emit) async {
    try {
      final count = await _cravingRepository.getCravingCountForUser(event.userId);
      emit(state.copyWith(
        cravingCount: count,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  void _onClearCravingError(ClearCravingError event, Emitter<TrackingState> emit) {
    if (state.hasError) {
      emit(state.copyWith(
        errorMessage: null,
        status: state.unifiedCravings.isNotEmpty
            ? TrackingStatus.loaded
            : TrackingStatus.initial,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
    }
  }
  
  /// Calcula o número de cravings resistidos hoje com base na data local
  /// Este método replica a lógica da extensão TrackingNormalizer para uso interno da classe
  int _calculateCravingsResistedToday() {
    // Get current date at LOCAL midnight for comparison
    // This ensures "today" is based on the user's local date, not UTC
    final now = DateTime.now();
    final todayLocal = DateTime(now.year, now.month, now.day);
    
    // Count all resisted cravings from today (including those pending/failed)
    int todayResisted = state.unifiedCravings
        .where((c) {
          // Must be resisted
          if (!c.resisted) return false;
          
          // Convert timestamp to local time for local date comparison
          final cravingLocal = c.timestamp.toLocal();
          final cravingDateLocal = DateTime(cravingLocal.year, cravingLocal.month, cravingLocal.day);
          
          // Compare local dates (year/month/day only)
          return cravingDateLocal.isAtSameMomentAs(todayLocal);
        })
        .length;
    
    return todayResisted;
  }
}
