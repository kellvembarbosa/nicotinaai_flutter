import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';
import 'package:nicotinaai_flutter/features/achievements/helpers/achievement_helper.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart'; // Import for SyncStatus enum
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';
import 'package:nicotinaai_flutter/features/home/repositories/smoking_record_repository.dart';

import 'smoking_record_event.dart';
import 'smoking_record_state.dart';

class SmokingRecordBloc extends Bloc<SmokingRecordEvent, SmokingRecordState> {
  final SmokingRecordRepository _repository;
  final TrackingBloc? _trackingBloc;
  final _uuid = const Uuid();
  
  SmokingRecordBloc({
    required SmokingRecordRepository repository,
    TrackingBloc? trackingBloc,
  }) : _repository = repository,
       _trackingBloc = trackingBloc,
       super(SmokingRecordState.initial()) {
    on<LoadSmokingRecordsRequested>(_onLoadSmokingRecordsRequested);
    on<SaveSmokingRecordRequested>(_onSaveSmokingRecordRequested);
    on<RetrySyncRecordRequested>(_onRetrySyncRecordRequested);
    on<RemoveSmokingRecordRequested>(_onRemoveSmokingRecordRequested);
    on<SyncPendingRecordsRequested>(_onSyncPendingRecordsRequested);
    on<GetRecordCountRequested>(_onGetRecordCountRequested);
    on<ClearSmokingRecordsRequested>(_onClearSmokingRecordsRequested);
    on<ClearSmokingRecordErrorRequested>(_onClearSmokingRecordErrorRequested);
  }
  
  Future<void> _onLoadSmokingRecordsRequested(
    LoadSmokingRecordsRequested event,
    Emitter<SmokingRecordState> emit,
  ) async {
    emit(SmokingRecordState.loading());
    
    try {
      final serverRecords = await _repository.getRecordsForUser(event.userId);
      
      // Merge server data with any pending local changes
      final localPendingRecords = state.records.where(
        (r) => r.syncStatus == SyncStatus.pending || r.syncStatus == SyncStatus.failed
      ).toList();
      
      // Use server data for everything else
      final updatedRecords = [...serverRecords, ...localPendingRecords];
      
      emit(SmokingRecordState.loaded(updatedRecords));
    } catch (e) {
      emit(SmokingRecordState.error(
        e.toString(),
        records: state.records,
      ));
    }
  }
  
  Future<void> _onSaveSmokingRecordRequested(
    SaveSmokingRecordRequested event,
    Emitter<SmokingRecordState> emit,
  ) async {
    // Generate a temporary ID for the new record
    final temporaryId = 'temp_${_uuid.v4()}';
    
    // Log para debug
    debugPrint('Creating smoking record with temporary ID: $temporaryId');
    
    // Create an optimistic version with pending status
    final optimisticRecord = event.record.copyWith(
      id: temporaryId,
      syncStatus: SyncStatus.pending
    );
    
    // Update the state immediately (optimistically)
    final updatedRecords = [optimisticRecord, ...state.records];
    emit(SmokingRecordState.saving(updatedRecords));
    
    try {
      // Perform the actual API call
      final savedRecord = await _repository.saveRecord(event.record);
      
      debugPrint('Smoking record saved successfully with ID: ${savedRecord.id}');
      
      // Update the temporary item with the real one
      final finalRecords = updatedRecords.map((r) => 
        r.id == temporaryId ? savedRecord : r
      ).toList();
      
      emit(SmokingRecordState.loaded(finalRecords));
      
      // Update tracking stats
      _updateTrackingStats();
      
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
      
      emit(SmokingRecordState.error(
        e.toString(),
        records: failedRecords,
      ));
      
      // Re-throw to allow caller to handle the error
      rethrow;
    }
  }
  
  Future<void> _onRetrySyncRecordRequested(
    RetrySyncRecordRequested event,
    Emitter<SmokingRecordState> emit,
  ) async {
    final recordIndex = state.records.indexWhere((r) => r.id == event.id);
    if (recordIndex == -1) return;
    
    // Create a new list with the updated record status
    final updatedRecords = List<SmokingRecordModel>.from(state.records);
    updatedRecords[recordIndex] = updatedRecords[recordIndex].copyWith(
      syncStatus: SyncStatus.pending
    );
    
    emit(SmokingRecordState.saving(updatedRecords));
    
    try {
      // Get a clean version without the temporary ID for API
      final recordToSync = updatedRecords[recordIndex].copyWith(
        id: event.id.startsWith('temp_') ? null : event.id
      );
      
      // Perform the actual API call
      final syncedRecord = await _repository.saveRecord(recordToSync);
      
      // Replace with the synced version in our records list
      updatedRecords[recordIndex] = syncedRecord;
      
      emit(SmokingRecordState.loaded(updatedRecords));
      
      // Update the tracking stats
      _updateTrackingStats();
    } catch (e) {
      // Mark as failed again
      updatedRecords[recordIndex] = updatedRecords[recordIndex].copyWith(
        syncStatus: SyncStatus.failed
      );
      
      emit(SmokingRecordState.error(
        e.toString(),
        records: updatedRecords,
      ));
    }
  }
  
  Future<void> _onRemoveSmokingRecordRequested(
    RemoveSmokingRecordRequested event,
    Emitter<SmokingRecordState> emit,
  ) async {
    // Store the original record for potential rollback
    final originalRecord = state.records.firstWhere((r) => r.id == event.id);
    
    // Remove immediately (optimistic update)
    final updatedRecords = state.records.where((r) => r.id != event.id).toList();
    emit(SmokingRecordState.loaded(updatedRecords));
    
    try {
      // Perform the actual deletion
      await _repository.deleteRecord(event.id);
      
      // Update the tracking stats
      _updateTrackingStats();
    } catch (e) {
      // Put the record back on error
      final rollbackRecords = [...updatedRecords, originalRecord];
      
      emit(SmokingRecordState.error(
        e.toString(),
        records: rollbackRecords,
      ));
    }
  }
  
  Future<void> _onSyncPendingRecordsRequested(
    SyncPendingRecordsRequested event,
    Emitter<SmokingRecordState> emit,
  ) async {
    final pendingItems = [...state.pendingRecords, ...state.failedRecords];
    
    for (final record in pendingItems) {
      if (record.id != null) {
        add(RetrySyncRecordRequested(id: record.id!));
      }
    }
  }
  
  Future<void> _onGetRecordCountRequested(
    GetRecordCountRequested event,
    Emitter<SmokingRecordState> emit,
  ) async {
    try {
      final count = await _repository.getRecordCountForUser(event.userId);
      emit(state.copyWith(recordCount: count));
    } catch (e) {
      emit(SmokingRecordState.error(
        e.toString(),
        records: state.records,
      ));
    }
  }
  
  void _onClearSmokingRecordsRequested(
    ClearSmokingRecordsRequested event,
    Emitter<SmokingRecordState> emit,
  ) {
    emit(SmokingRecordState.initial());
    debugPrint('🧹 [SmokingRecordBloc] Todos os registros de fumo foram limpos');
  }
  
  void _onClearSmokingRecordErrorRequested(
    ClearSmokingRecordErrorRequested event,
    Emitter<SmokingRecordState> emit,
  ) {
    if (state.hasError) {
      emit(state.copyWith(
        errorMessage: null,
        status: state.records.isNotEmpty
            ? SmokingRecordStatus.loaded
            : SmokingRecordStatus.initial,
      ));
    }
  }
  
  // Update tracking stats after changes to smoking records
  void _updateTrackingStats() {
    if (_trackingBloc != null) {
      _trackingBloc.add(ForceUpdateStats());
      debugPrint('✅ [SmokingRecordBloc] Updated tracking stats');
    } else {
      debugPrint('⚠️ [SmokingRecordBloc] TrackingBloc not available to update stats');
    }
  }
}