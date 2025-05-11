import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/features/tracking/models/craving.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/features/tracking/repositories/tracking_repository.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';
import 'package:nicotinaai_flutter/utils/stats_calculator.dart';

import 'tracking_event.dart';
import 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final TrackingRepository _repository;
  final NotificationService _notificationService = NotificationService();
  final AnalyticsService _analyticsService = AnalyticsService();

  // Cache system
  DateTime? _lastStatsUpdateTime;
  DateTime? _lastLogsUpdateTime;
  DateTime? _lastCravingsUpdateTime;
  DateTime? _lastRecoveriesUpdateTime;

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

    // Smoking Logs events
    on<LoadSmokingLogs>(_onLoadSmokingLogs);
    on<RefreshSmokingLogs>(_onRefreshSmokingLogs);
    on<AddSmokingLog>(_onAddSmokingLog);
    on<DeleteSmokingLog>(_onDeleteSmokingLog);
    on<SmokingRecordAdded>(_onSmokingRecordAdded);

    // Cravings events
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

      // Try to ensure we have user stats
      if (state.userStats == null) {
        try {
          await _loadUserStats(emit, forceRefresh: true);
        } catch (statsErr) {
          print('Error loading user stats: $statsErr');
        }
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

      emit(state.copyWith(userStats: stats, isStatsLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load user stats: ${e.toString()}', isStatsLoading: false));
    }
  }

  Future<void> _onRefreshUserStats(RefreshUserStats event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(isStatsLoading: true));

    try {
      // Update stats on the server
      await _repository.updateUserStats();

      // Load updated stats
      await _loadUserStats(emit, forceRefresh: true);
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
    }

    try {
      // First emit a loading state to ensure subscribers notice the change
      emit(state.copyWith(isStatsLoading: true));

      // First load fresh cravings
      await _loadCravings(emit, forceRefresh: true);

      // Now update stats based on fresh cravings
      await _repository.updateUserStats();

      // Finally load the updated stats
      await _loadUserStats(emit, forceRefresh: true);

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
      emit(state.copyWith(isStatsLoading: false));
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

  /// Handler para o evento CravingAdded - atualização otimista imediata usando o StatsCalculator
  Future<void> _onCravingAdded(CravingAdded event, Emitter<TrackingState> emit) async {
    if (kDebugMode) {
      print('🔄 [TrackingBloc] Atualização otimista para craving adicionado');
    }

    // Atualização otimista usando o calculator centralizado
    final currentStats = state.userStats;
    if (currentStats != null) {
      // Usar o serviço centralizado para calcular os novos valores
      final updatedStats = StatsCalculator.calculateAddCraving(currentStats);

      if (kDebugMode) {
        print('✅ [TrackingBloc] Atualizando otimisticamente:');
        print('  - Cravings resistidos: ${currentStats.cravingsResisted} -> ${updatedStats.cravingsResisted}');
        print('  - Cigarros evitados: ${currentStats.cigarettesAvoided} -> ${updatedStats.cigarettesAvoided}');
        print('  - Economia: ${currentStats.moneySaved} -> ${updatedStats.moneySaved} centavos');
        print(
          '  - Minutos de vida ganhos: ${StatsCalculator.calculateMinutesGained(currentStats.cigarettesAvoided)} -> ${StatsCalculator.calculateMinutesGained(updatedStats.cigarettesAvoided)}',
        );
      }

      // Emitir um novo estado com todos os valores atualizados
      emit(state.copyWith(userStats: updatedStats, lastUpdated: DateTime.now().millisecondsSinceEpoch));
    } else if (kDebugMode) {
      print('⚠️ [TrackingBloc] Não foi possível fazer atualização otimista - userStats é null');
    }

    // Em segundo plano, busca os dados atualizados
    try {
      await _repository.updateUserStats();
      await _loadUserStats(emit, forceRefresh: true);

      if (kDebugMode) {
        print('✅ [TrackingBloc] Atualização de fundo completa para craving adicionado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TrackingBloc] Erro na atualização de fundo: $e');
      }
      // Não expomos o erro para o usuário já que a atualização otimista foi feita
    }
  }

  /// Handler para o evento SmokingRecordAdded - atualização otimista imediata usando o StatsCalculator
  Future<void> _onSmokingRecordAdded(SmokingRecordAdded event, Emitter<TrackingState> emit) async {
    if (kDebugMode) {
      print('🔄 [TrackingBloc] Atualização otimista para registro de fumo adicionado');
    }

    // Atualização otimista usando o calculator centralizado
    final currentStats = state.userStats;
    if (currentStats != null) {
      // Usar o serviço centralizado para calcular os novos valores
      final updatedStats = StatsCalculator.calculateAddSmoking(currentStats, event.amount);

      if (kDebugMode) {
        print('✅ [TrackingBloc] Atualizando otimisticamente para fumo:');
        print('  - Cigarros fumados: ${currentStats.cigarettesSmoked} -> ${updatedStats.cigarettesSmoked}');
        print('  - Registros: ${currentStats.smokingRecordsCount} -> ${updatedStats.smokingRecordsCount}');
        print('  - Cigarros evitados: ${currentStats.cigarettesAvoided} -> ${updatedStats.cigarettesAvoided} (reset)');
        print('  - Sequência atual (dias): ${currentStats.currentStreakDays} -> ${updatedStats.currentStreakDays} (reset)');
      }

      // Emitir um novo estado com todos os valores atualizados
      emit(state.copyWith(userStats: updatedStats, lastUpdated: DateTime.now().millisecondsSinceEpoch));
    } else if (kDebugMode) {
      print('⚠️ [TrackingBloc] Não foi possível fazer atualização otimista - userStats é null');
    }

    // Em segundo plano, busca os dados atualizados
    try {
      await _repository.updateUserStats();
      await _loadUserStats(emit, forceRefresh: true);

      if (kDebugMode) {
        print('✅ [TrackingBloc] Atualização de fundo completa para registro de fumo');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TrackingBloc] Erro na atualização de fundo: $e');
      }
      // Não expomos o erro para o usuário já que a atualização otimista foi feita
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
      }

      // Primeiro carrega as estatísticas do usuário
      await _loadUserStats(emit, forceRefresh: event.forceRefresh);

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
    _isInitializing = false;
    emit(const TrackingState());
  }
}
