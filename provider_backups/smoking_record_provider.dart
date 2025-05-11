import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';
import 'package:nicotinaai_flutter/features/home/repositories/smoking_record_repository.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart'; // Importação explícita
import 'package:nicotinaai_flutter/features/achievements/helpers/achievement_helper.dart';

class SmokingRecordProvider extends ChangeNotifier {
  final SmokingRecordRepository _repository = SmokingRecordRepository();
  final _uuid = const Uuid();
  
  List<SmokingRecordModel> _records = [];
  bool _isLoading = false;
  String? _error;
  
  // Referência ao TrackingProvider (será injetada externamente)
  TrackingProvider? _trackingProvider;
  
  // Setter para permitir a injeção do TrackingProvider
  set trackingProvider(TrackingProvider provider) {
    _trackingProvider = provider;
  }
  
  List<SmokingRecordModel> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Filtered getters
  List<SmokingRecordModel> get pendingRecords => 
      _records.where((r) => r.syncStatus == SyncStatus.pending).toList();
  
  List<SmokingRecordModel> get failedRecords => 
      _records.where((r) => r.syncStatus == SyncStatus.failed).toList();
  
  Future<void> loadRecordsForUser(String userId) async {
    _setLoading(true);
    try {
      final serverRecords = await _repository.getRecordsForUser(userId);
      
      // Merge server data with any pending local changes
      final localPendingRecords = _records.where(
        (r) => r.syncStatus == SyncStatus.pending || r.syncStatus == SyncStatus.failed
      ).toList();
      
      // Use server data for everything else
      _records = [...serverRecords, ...localPendingRecords];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  // Optimistic update implementation
  Future<void> saveRecord(SmokingRecordModel record) async {
    // Generate a temporary ID for the new record
    final temporaryId = 'temp_${_uuid.v4()}';
    
    // Log para debug
    debugPrint('Creating smoking record with temporary ID: $temporaryId');
    
    // Create an optimistic version with pending status
    final optimisticRecord = record.copyWith(
      id: temporaryId,
      syncStatus: SyncStatus.pending
    );
    
    // Update the UI immediately (optimistically)
    _records = [optimisticRecord, ..._records];
    notifyListeners();
    
    try {
      // Perform the actual API call
      final savedRecord = await _repository.saveRecord(record);
      
      debugPrint('Smoking record saved successfully with ID: ${savedRecord.id}');
      
      // Update the temporary item with the real one
      _records = _records.map((r) => 
        r.id == temporaryId ? savedRecord : r
      ).toList();
      
      _error = null;
      
      // Update last smoke date in TrackingProvider
      await _updateLastSmokeDate();
      
      // Check for achievements after recording a smoking event
      if (record.context != null) {
        AchievementHelper.checkAfterSmokingRecord(record.context!);
      }
      
      // Only emit one notification - multiple notifications will be triggered by the TrackingProvider
      // from the method that calls this one
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving smoking record: $e');
      
      // Mark as failed but keep in the list
      _records = _records.map((r) => 
        r.id == temporaryId ? r.copyWith(syncStatus: SyncStatus.failed) : r
      ).toList();
      
      _error = e.toString();
      notifyListeners();
      
      // Re-throw to allow caller to handle the error
      rethrow;
    }
  }
  
  // Método para atualizar a última data de fumo no TrackingProvider
  Future<void> _updateLastSmokeDate() async {
    // Verificar se o TrackingProvider está disponível
    if (_trackingProvider == null) {
      debugPrint('⚠️ TrackingProvider não está disponível para atualizar última data de fumo');
      return;
    }
    
    try {
      // Força a atualização das estatísticas no TrackingProvider
      // Isso atualizará a lastSmokeDate e outros dados relevantes
      await _trackingProvider!.forceUpdateStats();
      debugPrint('✅ Última data de fumo atualizada com sucesso no TrackingProvider');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar última data de fumo: $e');
    }
  }
  
  // Retry failed records
  Future<void> retrySyncRecord(String id) async {
    final recordIndex = _records.indexWhere((r) => r.id == id);
    if (recordIndex == -1) return;
    
    // Mark as pending
    _records[recordIndex] = _records[recordIndex].copyWith(
      syncStatus: SyncStatus.pending
    );
    notifyListeners();
    
    try {
      // Get a clean version without the temporary ID
      final recordToSync = _records[recordIndex].copyWith(
        id: id.startsWith('temp_') ? null : id
      );
      
      // Perform the actual API call
      final syncedRecord = await _repository.saveRecord(recordToSync);
      
      // Replace with the synced version
      _records[recordIndex] = syncedRecord;
      _error = null;
      
      // Update the last smoke date since a new record was successfully saved
      await _updateLastSmokeDate();
      
      notifyListeners();
    } catch (e) {
      // Mark as failed again
      _records[recordIndex] = _records[recordIndex].copyWith(
        syncStatus: SyncStatus.failed
      );
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Remove a record (optimistically)
  Future<void> removeRecord(String id) async {
    // Store the original item for potential rollback
    final originalRecord = _records.firstWhere((r) => r.id == id);
    
    // Remove immediately (optimistic update)
    _records = _records.where((r) => r.id != id).toList();
    notifyListeners();
    
    try {
      // Perform the actual deletion
      await _repository.deleteRecord(id);
      _error = null;
    } catch (e) {
      // Put the item back on error
      _records = [..._records, originalRecord];
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Background sync of all pending/failed items
  Future<void> syncPendingRecords() async {
    final pendingItems = [...pendingRecords, ...failedRecords];
    
    for (final record in pendingItems) {
      if (record.id != null) {
        await retrySyncRecord(record.id!);
      }
    }
  }
  
  Future<int> getRecordCount(String userId) async {
    try {
      return await _repository.getRecordCountForUser(userId);
    } catch (e) {
      _error = e.toString();
      return 0;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Limpa todos os registros de fumo em memória (usado no logout)
  void clearRecords() {
    _records = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
    print('🧹 [SmokingRecordProvider] Todos os registros de fumo foram limpos');
  }
}