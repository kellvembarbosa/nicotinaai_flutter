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

  // Cache expiration times - using different durations for different data types
  static const Duration statsExpiration = Duration(minutes: 10); // Stats can be cached longer
  static const Duration logsExpiration = Duration(minutes: 5);
  static const Duration cravingsExpiration = Duration(minutes: 5);
  static const Duration recoveriesExpiration = Duration(minutes: 15); // Health recoveries change rarely
  static const Duration unifiedCravingsExpiration = Duration(minutes: 5);
  static const Duration smokingRecordsExpiration = Duration(minutes: 5);
  
  // Default cache expiration (for backward compatibility)
  static const Duration cacheExpiration = Duration(minutes: 5);
  
  // Debouncing for ForceUpdateStats
  static const Duration _debounceTime = Duration(milliseconds: 300);
  DateTime? _lastStatsUpdateRequest;
  
  // Pending ForceUpdateStats events to be processed after debounce
  bool _hasQueuedUpdate = false;

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

  // Verifica se o cache expirou com base no tipo de dados
  bool _isCacheExpired(DateTime? lastUpdate, {Duration? expiration}) {
    if (lastUpdate == null) return true;
    final now = DateTime.now();
    final expirationToUse = expiration ?? cacheExpiration;
    return now.difference(lastUpdate) > expirationToUse;
  }
  
  // Helpers específicos para cada tipo de cache
  bool _isStatsExpired() => _isCacheExpired(_lastStatsUpdateTime, expiration: statsExpiration);
  bool _isLogsExpired() => _isCacheExpired(_lastLogsUpdateTime, expiration: logsExpiration);
  bool _isCravingsExpired() => _isCacheExpired(_lastCravingsUpdateTime, expiration: cravingsExpiration);
  bool _isRecoveriesExpired() => _isCacheExpired(_lastRecoveriesUpdateTime, expiration: recoveriesExpiration);
  bool _isUnifiedCravingsExpired() => _isCacheExpired(_lastUnifiedCravingsUpdateTime, expiration: unifiedCravingsExpiration);
  bool _isSmokingRecordsExpired() => _isCacheExpired(_lastSmokingRecordsUpdateTime, expiration: smokingRecordsExpiration);
  
  // Verifica se uma atualização de estatísticas deve ser debounced
  bool _shouldDebounceStatsUpdate(DateTime now) {
    if (_lastStatsUpdateRequest == null) return false;
    return now.difference(_lastStatsUpdateRequest!) < _debounceTime;
  }

  // Sequence optimization: Initializes the tracking system with proper prioritization and caching
  Future<void> _onInitializeTracking(InitializeTracking event, Emitter<TrackingState> emit) async {
    // Prevent multiple concurrent initializations
    if (_isInitializing) {
      if (kDebugMode) {
        print('🛑 [TrackingBloc] Initialization already in progress, skipping redundant call');
      }
      return;
    }

    try {
      _isInitializing = true;
      
      if (kDebugMode) {
        print('🚀 [TrackingBloc] Starting initialization sequence');
      }

      emit(
        state.copyWith(status: TrackingStatus.loading, isStatsLoading: true, isLogsLoading: true, isCravingsLoading: true, isRecoveriesLoading: true),
      );
      
      // PHASE 1: First load critical data - prioritize user stats first as they're needed by other components
      // Use our improved cache system to avoid unnecessary network requests
      await _loadUserStats(emit, forceRefresh: _isStatsExpired());
      
      // PHASE 2: Then load other data in parallel if we have user stats
      List<Future> dataLoadTasks = [];
      
      if (state.userStats != null) {
        // We have user stats, load other data in parallel
        if (_isLogsExpired() || state.smokingLogs.isEmpty) {
          dataLoadTasks.add(_loadSmokingLogs(emit, forceRefresh: false));
        }
        
        if (_isCravingsExpired() || state.cravings.isEmpty) {
          dataLoadTasks.add(_loadCravings(emit, forceRefresh: false));
        }
        
        if (state.userStats!.userId != null) {
          // Load unified cravings if cache expired or empty
          if (_isUnifiedCravingsExpired() || state.unifiedCravings.isEmpty) {
            if (kDebugMode) {
              print('🔄 [TrackingBloc] Loading unified cravings for user: ${state.userStats!.userId}');
            }
            dataLoadTasks.add(_onLoadCravingsForUser(LoadCravingsForUser(userId: state.userStats!.userId!), emit));
          } else if (kDebugMode) {
            print('✅ [TrackingBloc] Using cached unified cravings (${state.unifiedCravings.length} items)');
          }
        }
        
        // Wait for all parallel data loading tasks to complete
        if (dataLoadTasks.isNotEmpty) {
          await Future.wait(dataLoadTasks);
          
          if (kDebugMode) {
            // Debug output after parallel loading
            print('✅ [TrackingBloc] Parallel data loading completed:');
            print('   - SmokingLogs: ${state.smokingLogs.length} items');
            print('   - Cravings: ${state.cravings.length} items');
            print('   - UnifiedCravings: ${state.unifiedCravings.length} items');
            
            // Calculate cravings resisted today for debugging
            int todayResisted = _calculateCravingsResistedToday();
            int minutesGainedToday = todayResisted * ImprovedStatsCalculator.MINUTES_PER_CIGARETTE;
            print('📊 [TrackingBloc] Cravings resisted today: $todayResisted');
            print('📊 [TrackingBloc] Minutes gained today: $minutesGainedToday min');
          }
        }
      }
      
      // PHASE 3: Fix missing or inconsistent data
      
      // 3.1: If user stats still missing, try to load them again with force refresh
      if (state.userStats == null) {
        try {
          if (kDebugMode) {
            print('⚠️ [TrackingBloc] UserStats still null, forcing refresh');
          }
          await _loadUserStats(emit, forceRefresh: true);
        } catch (statsErr) {
          print('❌ [TrackingBloc] Error loading user stats: $statsErr');
        }
      }
      
      // 3.2: Fix missing values in stats when we have a lastSmokeDate
      if (state.userStats != null && 
         (state.userStats!.totalMinutesGained == null || 
          state.userStats!.moneySaved == null || 
          state.userStats!.totalMinutesGained == 0 || 
          state.userStats!.moneySaved == 0) &&
         state.userStats!.lastSmokeDate != null) {
        
        if (kDebugMode) {
          print('🔧 [TrackingBloc] Fixing missing or zero values with valid last_smoke_date');
          print('   - Current minutes gained: ${state.userStats!.totalMinutesGained}');
          print('   - Current money saved: ${state.userStats!.moneySaved}');
        }
        
        try {
          await _repository.updateUserStats();
          await _loadUserStats(emit, forceRefresh: true);
          
          if (kDebugMode && state.userStats != null) {
            print('✅ [TrackingBloc] Values after fix:');
            print('   - Updated minutes gained: ${state.userStats!.totalMinutesGained}');
            print('   - Updated money saved: ${state.userStats!.moneySaved}');
          }
        } catch (e) {
          print('❌ [TrackingBloc] Error fixing stat values: $e');
        }
      }

      // 3.3: Fix missing lastSmokeDate when we have smoking logs
      if (state.userStats != null && state.userStats!.lastSmokeDate == null && state.smokingLogs.isNotEmpty) {
        if (kDebugMode) {
          print('🔧 [TrackingBloc] Fixing missing lastSmokeDate from smoking logs');
        }
        
        try {
          await _repository.updateUserStats();
          await _loadUserStats(emit, forceRefresh: true);
          
          if (kDebugMode && state.userStats != null) {
            print('✅ [TrackingBloc] LastSmokeDate after fix: ${state.userStats!.lastSmokeDate}');
          }
        } catch (updateErr) {
          print('❌ [TrackingBloc] Error updating lastSmokeDate: $updateErr');
        }
      }
      
      // PHASE 4: Load health recoveries
      
      // 4.1: Load existing health recoveries
      if (_isRecoveriesExpired() || state.healthRecoveries.isEmpty || state.userHealthRecoveries.isEmpty) {
        try {
          if (kDebugMode) {
            print('🔄 [TrackingBloc] Loading health recoveries');
          }
          await _loadHealthRecoveries(emit, forceRefresh: false);
        } catch (e) {
          print('❌ [TrackingBloc] Error loading health recoveries: $e');
          // Ensure we have at least empty recoveries list
          emit(state.copyWith(healthRecoveries: [], userHealthRecoveries: [], isRecoveriesLoading: false));
        }
      } else if (kDebugMode) {
        print('✅ [TrackingBloc] Using cached health recoveries (${state.healthRecoveries.length} items)');
      }
      
      // 4.2: Check for new health recoveries (only if we have lastSmokeDate)
      if ((state.smokingLogs.isNotEmpty || 
           (state.userStats != null && state.userStats!.lastSmokeDate != null)) &&
          (_isRecoveriesExpired() || state.hasError)) {
        
        try {
          if (kDebugMode) {
            print('🔍 [TrackingBloc] Checking for new health recoveries...');
          }
          
          // Only update last smoke date if we don't have it
          if ((state.userStats == null || state.userStats!.lastSmokeDate == null) && state.smokingLogs.isNotEmpty) {
            if (kDebugMode) {
              print('⚠️ [TrackingBloc] No lastSmokeDate but smoking logs exist - updating stats first');
            }
            
            try {
              await _repository.updateUserStats();
              await _loadUserStats(emit, forceRefresh: true);
            } catch (statsErr) {
              print('⚠️ [TrackingBloc] Error updating user stats: $statsErr');
            }
          }

          // Only check health recoveries if it's been a while since last check
          final result = await _repository.checkHealthRecoveries(updateAchievements: false);
          
          if (kDebugMode) {
            print('✅ [TrackingBloc] Health recovery check completed: $result');
          }

          // Reload health recoveries after successful check
          await _loadHealthRecoveries(emit, forceRefresh: true);
        } catch (e) {
          print('⚠️ [TrackingBloc] Error checking health recoveries: $e');
          // Continue even if there's an error with checking health recoveries
        }
      } else if (kDebugMode) {
        if (state.userStats == null || state.userStats!.lastSmokeDate == null) {
          print('⚠️ [TrackingBloc] Skipping health recovery check: No lastSmokeDate available');
        } else {
          print('ℹ️ [TrackingBloc] Skipping health recovery check: Cache still valid');
        }
      }
      
      // PHASE 5: Final state update
      emit(
        state.copyWith(
          status: TrackingStatus.loaded,
          isStatsLoading: false,
          isLogsLoading: false,
          isCravingsLoading: false,
          isRecoveriesLoading: false,
        ),
      );
      
      if (kDebugMode) {
        print('✅ [TrackingBloc] Initialization completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TrackingBloc] Initialization failed: $e');
      }
      
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
    // Usa cache se disponível e não expirado - usando tempo de expiração específico
    if (!forceRefresh && !_isStatsExpired() && state.userStats != null) {
      if (kDebugMode) {
        print('Using cached user stats from $_lastStatsUpdateTime (expires after ${statsExpiration.inMinutes} minutes)');
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
    // Implement debouncing to prevent excessive updates
    final now = DateTime.now();
    
    // If debouncing is enabled and an update was recently requested, queue it
    if (event.debounce && _shouldDebounceStatsUpdate(now)) {
      if (kDebugMode) {
        print('🕒 [TrackingBloc] Debouncing ForceUpdateStats event - deferring by ${_debounceTime.inMilliseconds}ms');
      }
      
      // Only queue if we don't already have one queued
      if (!_hasQueuedUpdate) {
        _hasQueuedUpdate = true;
        // Schedule a delayed update
        Future.delayed(_debounceTime, () {
          if (kDebugMode) {
            print('⏰ [TrackingBloc] Processing queued ForceUpdateStats event');
          }
          // Reset flag and add a non-debounced event
          _hasQueuedUpdate = false;
          add(ForceUpdateStats(debounce: false));
        });
      }
      
      // Don't proceed with current update
      return;
    }
    
    // Update the last update request time
    _lastStatsUpdateRequest = now;
    
    if (kDebugMode) {
      print('🔄 [TrackingBloc] Processing ForceUpdateStats event');
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
    // Usa cache se disponível e não expirado - usando tempo de expiração específico
    if (!forceRefresh && !_isLogsExpired() && state.smokingLogs.isNotEmpty) {
      if (kDebugMode) {
        print('Using cached smoking logs from $_lastLogsUpdateTime (expires after ${logsExpiration.inMinutes} minutes)');
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
    // Usa cache se disponível e não expirado - usando tempo de expiração específico
    if (!forceRefresh && !_isCravingsExpired() && state.cravings.isNotEmpty) {
      if (kDebugMode) {
        print('Using cached cravings from $_lastCravingsUpdateTime (expires after ${cravingsExpiration.inMinutes} minutes)');
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
    // Usa cache se disponível e não expirado - usando tempo de expiração específico
    // Health recoveries can be cached for longer periods since they change less frequently
    if (!forceRefresh && !_isRecoveriesExpired() && state.healthRecoveries.isNotEmpty && state.userHealthRecoveries.isNotEmpty) {
      if (kDebugMode) {
        print('Using cached health recoveries from $_lastRecoveriesUpdateTime (expires after ${recoveriesExpiration.inMinutes} minutes)');
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
  // Enhanced refresh method with improved parallel loading and better caching
  Future<void> _onRefreshAllData(RefreshAllData event, Emitter<TrackingState> emit) async {
    try {
      if (kDebugMode) {
        print('🔄 [TrackingBloc] Starting refresh all data operation (force: ${event.forceRefresh})');
      }
      
      emit(state.copyWith(isStatsLoading: true, isLogsLoading: true, isCravingsLoading: true, isRecoveriesLoading: true));

      // If forceRefresh, reset all cache timestamps
      if (event.forceRefresh) {
        if (kDebugMode) {
          print('🧹 [TrackingBloc] Clearing all cache timestamps to force refresh');
        }
        _lastStatsUpdateTime = null;
        _lastLogsUpdateTime = null;
        _lastCravingsUpdateTime = null;
        _lastRecoveriesUpdateTime = null;
        _lastUnifiedCravingsUpdateTime = null;
        _lastSmokingRecordsUpdateTime = null;
      }
      
      // PHASE 1: Update server-side stats to ensure everything is up-to-date
      if (kDebugMode) {
        print('🔄 [TrackingBloc] Updating user stats on server');
      }
      try {
        await _repository.updateUserStats(); 
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [TrackingBloc] Error updating stats on server: $e');
          print('   - Continuing with refresh operation despite error');
        }
      }

      // PHASE 2: Load data in parallel for better performance
      // Prepare parallel load operations
      final parallelLoads = <Future>[];
      
      // User stats - always refresh first as other operations depend on this
      parallelLoads.add(_loadUserStats(emit, forceRefresh: true));
      
      // Wait for user stats to complete
      await Future.wait(parallelLoads);
      parallelLoads.clear();
      
      // PHASE 3: Use user stats to load other data as needed
      if (state.userStats != null && state.userStats!.userId != null) {
        final userId = state.userStats!.userId!;
        
        // Add cravings and logs to parallel load
        parallelLoads.add(_loadSmokingLogs(emit, forceRefresh: event.forceRefresh));
        parallelLoads.add(_loadCravings(emit, forceRefresh: event.forceRefresh)); 
        
        // Conditionally add unified cravings
        if (_isUnifiedCravingsExpired() || event.forceRefresh || state.unifiedCravings.isEmpty) {
          if (kDebugMode) {
            print('🔄 [TrackingBloc] Loading unified cravings for user: $userId');
          }
          parallelLoads.add(_onLoadCravingsForUser(LoadCravingsForUser(userId: userId), emit));
        }
        
        // Check achievements in parallel
        try {
          parallelLoads.add(_repository.checkAchievements());
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ [TrackingBloc] Error checking achievements: $e');
          }
        }
        
        // Conditionally check health recoveries
        if (state.userStats!.lastSmokeDate != null) {
          // Only check health recoveries if we have last smoke date and cache is expired
          if (_isRecoveriesExpired() || event.forceRefresh) {
            if (kDebugMode) {
              print('🔄 [TrackingBloc] Checking health recoveries');
            }
            
            try {
              parallelLoads.add(_repository.checkHealthRecoveries(updateAchievements: false));
            } catch (e) {
              if (kDebugMode) {
                print('⚠️ [TrackingBloc] Error checking health recoveries: $e');
              }
            }
          }
        }
      }
      
      // Wait for all parallel operations to complete
      await Future.wait(parallelLoads);
      
      // PHASE 4: Final loads
      parallelLoads.clear();
      
      // Health recoveries might need to be loaded after the check
      if (_isRecoveriesExpired() || event.forceRefresh || state.healthRecoveries.isEmpty) {
        parallelLoads.add(_loadHealthRecoveries(emit, forceRefresh: event.forceRefresh));
      }
      
      // One final user stats refresh to get the latest data
      parallelLoads.add(_loadUserStats(emit, forceRefresh: true));
      
      // Wait for final loads
      await Future.wait(parallelLoads);
      
      // Calculate debug stats
      if (kDebugMode) {
        int todayResisted = _calculateCravingsResistedToday();
        int minutesGainedToday = todayResisted * ImprovedStatsCalculator.MINUTES_PER_CIGARETTE;
        
        print('📊 [TrackingBloc] Refresh completed with the following data:');
        print('   - SmokingLogs: ${state.smokingLogs.length} items');
        print('   - Cravings: ${state.cravings.length} items');
        print('   - UnifiedCravings: ${state.unifiedCravings.length} items');
        print('   - HealthRecoveries: ${state.healthRecoveries.length} items');
        print('   - UserHealthRecoveries: ${state.userHealthRecoveries.length} items');
        print('   - Cravings resisted today: $todayResisted');
        print('   - Minutes gained today: $minutesGainedToday min');
        
        if (state.userStats != null) {
          print('   - Last smoke date: ${state.userStats!.lastSmokeDate}');
          print('   - Cigarettes avoided: ${state.userStats!.cigarettesAvoided}');
          print('   - Money saved: ${state.userStats!.moneySaved}¢');
        }
      }
      
      // Final state update
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
      
      if (kDebugMode) {
        print('✅ [TrackingBloc] Refresh all data completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TrackingBloc] Error refreshing all data: $e');
      }
      
      emit(
        state.copyWith(
          errorMessage: e.toString(), 
          isStatsLoading: false, 
          isLogsLoading: false, 
          isCravingsLoading: false, 
          isRecoveriesLoading: false
        ),
      );
    }
  }

  // Error handling
  void _onClearError(ClearError event, Emitter<TrackingState> emit) {
    if (state.hasError) {
      emit(state.copyWith(status: state.isLoaded ? TrackingStatus.loaded : TrackingStatus.initial, errorMessage: null));
    }
  }

  // Complete reset of all tracking data and cache - used during logout
  void _onResetTrackingData(ResetTrackingData event, Emitter<TrackingState> emit) {
    if (kDebugMode) {
      print('🧹 [TrackingBloc] Resetting all tracking data and cache');
    }
    
    // Clear all cache timestamps
    _lastStatsUpdateTime = null;
    _lastLogsUpdateTime = null;
    _lastCravingsUpdateTime = null;
    _lastRecoveriesUpdateTime = null;
    _lastUnifiedCravingsUpdateTime = null;
    _lastSmokingRecordsUpdateTime = null;
    
    // Clear debounce state
    _lastStatsUpdateRequest = null;
    _hasQueuedUpdate = false;
    
    // Reset initialization flag
    _isInitializing = false;
    
    // Emit initial state
    emit(const TrackingState());
    
    if (kDebugMode) {
      print('✅ [TrackingBloc] Tracking data reset completed');
    }
  }
  
  // =================================================
  // Unified Smoking Record handlers (migrated from SmokingRecordBloc)
  // =================================================
  
  Future<void> _onLoadSmokingRecordsForUser(LoadSmokingRecordsForUser event, Emitter<TrackingState> emit) async {
    // Check if we can use the cached data
    if (!_isSmokingRecordsExpired() && state.smokingRecords.isNotEmpty) {
      if (kDebugMode) {
        print('Using cached smoking records from $_lastSmokingRecordsUpdateTime (expires after ${smokingRecordsExpiration.inMinutes} minutes)');
      }
      return;
    }
    
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
      
      if (kDebugMode) {
        print('Successfully loaded ${serverRecords.length} server smoking records and ${localPendingRecords.length} pending local records');
      }
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
    if (kDebugMode) {
      print('🆕 [TrackingBloc] Creating smoking record with temporary ID: $temporaryId');
    }
    
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
      
      if (kDebugMode) {
        print('✅ [TrackingBloc] Smoking record saved successfully with ID: ${savedRecord.id}');
      }
      
      // Update the temporary item with the real one
      final finalRecords = updatedRecords.map((r) => 
        r.id == temporaryId ? savedRecord : r
      ).toList();
      
      // Invalidate affected caches - stats will change when a smoking record is added
      _invalidateCaches();
      
      // Explicitly invalidate health recoveries cache as they're likely to be reset due to new smoking
      _lastRecoveriesUpdateTime = null;
      
      emit(state.copyWith(
        status: TrackingStatus.loaded,
        smokingRecords: finalRecords,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
      
      // Explicitly check health recoveries to ensure they are reset due to new smoking event
      try {
        if (kDebugMode) {
          print('🏥 [TrackingBloc] Checking health recoveries after new smoking record...');
        }
        
        // This will call the edge function which has been updated to detect 
        // recent smoking events and reset health recoveries if necessary
        await _repository.checkHealthRecoveries(updateAchievements: true);
        
        if (kDebugMode) {
          print('✅ [TrackingBloc] Health recoveries check completed after adding smoking record');
        }
      } catch (e) {
        // Non-critical error, just log it
        if (kDebugMode) {
          print('⚠️ [TrackingBloc] Error checking health recoveries after new smoking record: $e');
        }
      }
      
      // Update tracking stats (debounced)
      add(ForceUpdateStats());
      
      // Check for achievements after recording a smoking event
      if (event.record.context != null) {
        AchievementHelper.checkAfterSmokingRecord(event.record.context!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TrackingBloc] Error saving smoking record: $e');
      }
      
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
    // Check if we can use the cached data
    if (!_isUnifiedCravingsExpired() && state.unifiedCravings.isNotEmpty) {
      if (kDebugMode) {
        print('Using cached unified cravings from $_lastUnifiedCravingsUpdateTime (expires after ${unifiedCravingsExpiration.inMinutes} minutes)');
      }
      return;
    }
    
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
      
      if (kDebugMode) {
        print('Successfully loaded ${serverCravings.length} server cravings and ${localPendingCravings.length} pending local cravings');
      }
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  // Helper method to perform optimistic CRUD operations with cache invalidation
  void _invalidateCaches() {
    // Reset cache timestamps that depend on user stats
    _lastStatsUpdateTime = null;
    // Cravings and smoking logs directly affect stats
    _lastCravingsUpdateTime = null;
    _lastLogsUpdateTime = null;
    
    if (kDebugMode) {
      print('🧹 [TrackingBloc] Invalidated dependent caches for stats, cravings, and logs');
    }
  }

  Future<void> _onSaveCraving(SaveCraving event, Emitter<TrackingState> emit) async {
    // Generate a temporary ID for the new craving
    final temporaryId = 'temp_${_uuid.v4()}';
    
    // Debug logs
    if (kDebugMode) {
      print('🆕 [TrackingBloc] Creating craving with temporary ID: $temporaryId');
    }
    
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
      
      if (kDebugMode) {
        print('✅ [TrackingBloc] Craving saved successfully with ID: ${savedCraving.id}');
      }
      
      // Update the temporary item with the real one
      final finalCravings = updatedCravings.map((c) => 
        c.id == temporaryId ? savedCraving : c
      ).toList();
      
      // Invalidate affected caches - stats will change when a craving is added
      _invalidateCaches();
      
      emit(state.copyWith(
        status: TrackingStatus.loaded,
        unifiedCravings: finalCravings,
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      ));
      
      // Update tracking stats (debounced)
      add(CravingAdded(resisted: event.craving.resisted));
      
      // Check for health recoveries
      try {
        if (kDebugMode) {
          print('🏥 [TrackingBloc] Checking health recoveries after craving...');
        }
        await _repository.checkHealthRecoveries(updateAchievements: true);
        
        // Invalidate health recoveries cache
        _lastRecoveriesUpdateTime = null;
        
        if (kDebugMode) {
          print('✅ [TrackingBloc] Health recoveries check completed');
        }
      } catch (e) {
        // Non-critical error, just log it
        if (kDebugMode) {
          print('⚠️ [TrackingBloc] Error checking health recoveries: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TrackingBloc] Error saving craving: $e');
      }
      
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