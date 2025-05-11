import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/repositories/craving_repository.dart';
import 'package:nicotinaai_flutter/features/tracking/repositories/tracking_repository.dart';
import 'package:nicotinaai_flutter/utils/stats_calculator.dart';

import 'craving_event.dart';
import 'craving_state.dart';

class CravingBloc extends Bloc<CravingEvent, CravingState> {
  final CravingRepository _repository;
  final TrackingBloc? _trackingBloc;
  final _uuid = const Uuid();
  
  CravingBloc({
    required CravingRepository repository,
    TrackingBloc? trackingBloc,
  }) : _repository = repository,
       _trackingBloc = trackingBloc,
       super(CravingState.initial()) {
    on<LoadCravingsRequested>(_onLoadCravingsRequested);
    on<SaveCravingRequested>(_onSaveCravingRequested);
    on<RetrySyncCravingRequested>(_onRetrySyncCravingRequested);
    on<RemoveCravingRequested>(_onRemoveCravingRequested);
    on<SyncPendingCravingsRequested>(_onSyncPendingCravingsRequested);
    on<GetCravingCountRequested>(_onGetCravingCountRequested);
    on<ClearCravingsRequested>(_onClearCravingsRequested);
    on<ClearCravingErrorRequested>(_onClearCravingErrorRequested);
  }
  
  Future<void> _onLoadCravingsRequested(
    LoadCravingsRequested event,
    Emitter<CravingState> emit,
  ) async {
    emit(CravingState.loading());
    
    try {
      final serverCravings = await _repository.getCravingsForUser(event.userId);
      
      // Merge server data with any pending local changes
      final localPendingCravings = state.cravings.where(
        (c) => c.syncStatus == SyncStatus.pending || c.syncStatus == SyncStatus.failed
      ).toList();
      
      // Use server data for everything else
      final updatedCravings = [...serverCravings, ...localPendingCravings];
      
      emit(CravingState.loaded(updatedCravings));
    } catch (e) {
      emit(CravingState.error(
        e.toString(),
        cravings: state.cravings,
      ));
    }
  }
  
  Future<void> _onSaveCravingRequested(
    SaveCravingRequested event,
    Emitter<CravingState> emit,
  ) async {
    // Generate a temporary ID for the new craving
    final temporaryId = 'temp_${_uuid.v4()}';
    
    // Debug logs
    debugPrint('Creating craving with temporary ID: $temporaryId');
    debugPrint('Craving details:');
    debugPrint('- Location: ${event.craving.location}');
    debugPrint('- Trigger: ${event.craving.trigger}');
    debugPrint('- Intensity: ${event.craving.intensity}');
    debugPrint('- Resisted: ${event.craving.resisted ? 'Yes' : 'No'}');
    debugPrint('- Notes: ${event.craving.notes}');
    debugPrint('- User ID: ${event.craving.userId}');
    
    // Create an optimistic version with pending status
    final optimisticCraving = event.craving.copyWith(
      id: temporaryId,
      syncStatus: SyncStatus.pending
    );
    
    // Update the state immediately (optimistically)
    final updatedCravings = [optimisticCraving, ...state.cravings];
    emit(CravingState.saving(updatedCravings));
    
    try {
      // Perform the actual API call
      final savedCraving = await _repository.saveCraving(event.craving);
      
      debugPrint('Craving saved successfully with ID: ${savedCraving.id}');
      
      // Update the temporary item with the real one
      final finalCravings = updatedCravings.map((c) => 
        c.id == temporaryId ? savedCraving : c
      ).toList();
      
      emit(CravingState.loaded(finalCravings));
      
      // Check if this is a new user (no smoking_logs or user_stats)
      // and explicitly initialize user_stats if needed
      try {
        debugPrint('Checking and initializing health recoveries after craving...');
        final trackingRepository = TrackingRepository();
        final userStats = await trackingRepository.getUserStats();

        if (userStats == null) {
          // No user stats yet, explicitly initiate health recovery check
          // to trigger initialization
          debugPrint('No user_stats found, initializing health recoveries...');
          await trackingRepository.checkHealthRecoveries(updateAchievements: true);
          debugPrint('Health recoveries initialized successfully');
        } else {
          debugPrint('user_stats already exist, no need to initialize');
        }
      } catch (e) {
        // Non-critical error, just log it
        debugPrint('Error initializing health recoveries after craving: $e');
      }
      
      // Update tracking stats
      _updateTrackingStats();
      
      // Check for achievements
      try {
        debugPrint('Checking for achievements after craving recorded');
        // Try to get AchievementProvider if needed (this would require BuildContext)
        // For now, we skip the achievement check in the BLoC implementation
        // as it requires access to Provider which is not available in BLoC
        // This can be handled at the UI level instead
      } catch (e) {
        debugPrint('Error checking achievements: $e');
        // Non-critical error, don't rethrow
      }
    } catch (e) {
      debugPrint('Error saving craving: $e');
      
      // Mark as failed but keep in the list
      final failedCravings = updatedCravings.map((c) => 
        c.id == temporaryId ? c.copyWith(syncStatus: SyncStatus.failed) : c
      ).toList();
      
      emit(CravingState.error(
        e.toString(),
        cravings: failedCravings,
      ));
      
      // Re-throw to allow caller to handle the error
      rethrow;
    }
  }
  
  Future<void> _onRetrySyncCravingRequested(
    RetrySyncCravingRequested event,
    Emitter<CravingState> emit,
  ) async {
    final cravingIndex = state.cravings.indexWhere((c) => c.id == event.id);
    if (cravingIndex == -1) return;
    
    // Create a new list with the updated craving status
    final updatedCravings = List<CravingModel>.from(state.cravings);
    updatedCravings[cravingIndex] = updatedCravings[cravingIndex].copyWith(
      syncStatus: SyncStatus.pending
    );
    
    emit(CravingState.saving(updatedCravings));
    
    try {
      // Get a clean version without the temporary ID for API
      final cravingToSync = updatedCravings[cravingIndex].copyWith(
        id: event.id.startsWith('temp_') ? null : event.id
      );
      
      // Perform the actual API call
      final syncedCraving = await _repository.saveCraving(cravingToSync);
      
      // Replace with the synced version in our cravings list
      updatedCravings[cravingIndex] = syncedCraving;
      
      emit(CravingState.loaded(updatedCravings));
      
      // Update the tracking stats
      _updateTrackingStats();
    } catch (e) {
      // Mark as failed again
      updatedCravings[cravingIndex] = updatedCravings[cravingIndex].copyWith(
        syncStatus: SyncStatus.failed
      );
      
      emit(CravingState.error(
        e.toString(),
        cravings: updatedCravings,
      ));
    }
  }
  
  Future<void> _onRemoveCravingRequested(
    RemoveCravingRequested event,
    Emitter<CravingState> emit,
  ) async {
    // Store the original craving for potential rollback
    final originalCraving = state.cravings.firstWhere((c) => c.id == event.id);
    
    // Remove immediately (optimistic update)
    final updatedCravings = state.cravings.where((c) => c.id != event.id).toList();
    emit(CravingState.loaded(updatedCravings));
    
    try {
      // Perform the actual deletion
      await _repository.deleteCraving(event.id);
      
      // Update the tracking stats
      _updateTrackingStats();
    } catch (e) {
      // Put the craving back on error
      final rollbackCravings = [...updatedCravings, originalCraving];
      
      emit(CravingState.error(
        e.toString(),
        cravings: rollbackCravings,
      ));
    }
  }
  
  Future<void> _onSyncPendingCravingsRequested(
    SyncPendingCravingsRequested event,
    Emitter<CravingState> emit,
  ) async {
    final pendingItems = [...state.pendingCravings, ...state.failedCravings];
    
    for (final craving in pendingItems) {
      if (craving.id != null) {
        add(RetrySyncCravingRequested(id: craving.id!));
      }
    }
  }
  
  Future<void> _onGetCravingCountRequested(
    GetCravingCountRequested event,
    Emitter<CravingState> emit,
  ) async {
    try {
      final count = await _repository.getCravingCountForUser(event.userId);
      emit(state.copyWith(cravingCount: count));
    } catch (e) {
      emit(CravingState.error(
        e.toString(),
        cravings: state.cravings,
      ));
    }
  }
  
  void _onClearCravingsRequested(
    ClearCravingsRequested event,
    Emitter<CravingState> emit,
  ) {
    emit(CravingState.initial());
    debugPrint('🧹 [CravingBloc] Todos os cravings foram limpos');
  }
  
  void _onClearCravingErrorRequested(
    ClearCravingErrorRequested event,
    Emitter<CravingState> emit,
  ) {
    if (state.hasError) {
      emit(state.copyWith(
        errorMessage: null,
        status: state.cravings.isNotEmpty
            ? CravingStatus.loaded
            : CravingStatus.initial,
      ));
    }
  }
  
  // Update tracking stats after changes to cravings
  void _updateTrackingStats() {
    if (_trackingBloc != null) {
      // Primeiro dispara o evento otimista de craving adicionado
      _trackingBloc.add(CravingAdded());
      
      // Em seguida, programa atualização completa com leve atraso para garantir persistência
      Future.delayed(const Duration(milliseconds: 300), () {
        _trackingBloc.add(ForceUpdateStats());
      });
      
      debugPrint('✅ [CravingBloc] Updated tracking stats with optimistic update');
    } else {
      debugPrint('⚠️ [CravingBloc] TrackingBloc not available to update stats');
    }
  }
}