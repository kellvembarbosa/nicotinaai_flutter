import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/repositories/craving_repository.dart';

class CravingProvider extends ChangeNotifier {
  final CravingRepository _repository = CravingRepository();
  final _uuid = const Uuid();
  
  List<CravingModel> _cravings = [];
  bool _isLoading = false;
  String? _error;
  
  List<CravingModel> get cravings => _cravings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Filtered getters
  List<CravingModel> get pendingCravings => 
      _cravings.where((c) => c.syncStatus == SyncStatus.pending).toList();
  
  List<CravingModel> get failedCravings => 
      _cravings.where((c) => c.syncStatus == SyncStatus.failed).toList();
  
  Future<void> loadCravingsForUser(String userId) async {
    _setLoading(true);
    try {
      final serverCravings = await _repository.getCravingsForUser(userId);
      
      // Merge server data with any pending local changes
      final localPendingCravings = _cravings.where(
        (c) => c.syncStatus == SyncStatus.pending || c.syncStatus == SyncStatus.failed
      ).toList();
      
      // Use server data for everything else
      _cravings = [...serverCravings, ...localPendingCravings];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  // Removido método logDebugInfo que causava solicitações desnecessárias
  
  // Optimistic update implementation
  Future<void> saveCraving(CravingModel craving) async {
    // Generate a temporary ID for the new craving
    final temporaryId = 'temp_${_uuid.v4()}';
    
    // Log para debug
    debugPrint('Creating craving with temporary ID: $temporaryId');
    debugPrint('Craving details:');
    debugPrint('- Location: ${craving.location}');
    debugPrint('- Trigger: ${craving.trigger}');
    debugPrint('- Intensity: ${craving.intensity}');
    debugPrint('- Resisted: ${craving.resisted}');
    debugPrint('- Notes: ${craving.notes}');
    debugPrint('- User ID: ${craving.userId}');
    
    // Debug: Print the exact JSON that will be sent to the server
    final jsonData = craving.toJson();
    debugPrint('JSON to be sent to server:');
    jsonData.forEach((key, value) => debugPrint('  $key: $value'));
    
    // Create an optimistic version with pending status
    final optimisticCraving = craving.copyWith(
      id: temporaryId,
      syncStatus: SyncStatus.pending
    );
    
    // Update the UI immediately (optimistically)
    _cravings = [optimisticCraving, ..._cravings];
    notifyListeners();
    
    try {
      // Perform the actual API call
      final savedCraving = await _repository.saveCraving(craving);
      
      debugPrint('Craving saved successfully with ID: ${savedCraving.id}');
      
      // Update the temporary item with the real one
      _cravings = _cravings.map((c) => 
        c.id == temporaryId ? savedCraving : c
      ).toList();
      
      _error = null;
      notifyListeners();
      
      // Force reload tracking stats to update the UI
      // This ensures the cravings count gets updated
      try {
        debugPrint('Refreshing tracking stats after saving craving...');
        
        // Método direto para forçar atualização de estatísticas
        final trackingProvider = await _getTrackingProvider();
        if (trackingProvider != null) {
          debugPrint('🔥 Forcing immediate stats update with forceUpdateStats()');
          await trackingProvider.forceUpdateStats();
          debugPrint('✅ Stats updated successfully with forceUpdateStats()');
        } else {
          debugPrint('⚠️ TrackingProvider not available, stats refresh may be delayed');
          // Trigger a notification to ensure UI updates
          Future.microtask(() => notifyListeners());
        }
      } catch (statsError) {
        debugPrint('Error refreshing stats: $statsError');
        // Fallback to ensure refresh
        Future.microtask(() => notifyListeners());
      }
    } catch (e) {
      debugPrint('Error saving craving: $e');
      
      // Mark as failed but keep in the list
      _cravings = _cravings.map((c) => 
        c.id == temporaryId ? c.copyWith(syncStatus: SyncStatus.failed) : c
      ).toList();
      
      _error = e.toString();
      notifyListeners();
      
      // Rethrow para permitir que o chamador trate o erro também
      rethrow;
    }
  }
  
  // Helper to get tracking provider from the nearest context
  // This must be used carefully since we're not in a build context
  Future<dynamic> _getTrackingProvider() async {
    try {
      // Infelizmente, não temos um buildContext aqui para acessar o Provider
      // Idealmente, este código deveria ser reescrito para receber o TrackingProvider via construtor
      
      debugPrint('TrackingProvider must be explicitly passed. Updating stats will happen on next UI refresh.');
      
      // Enviar notificação global para que outros componentes atualizem seus estados
      // Este é um hack temporário até que possamos refatorar o código para usar injeção de dependência
      Future.delayed(const Duration(seconds: 1)).then((_) {
        debugPrint('Firing delayed notification to refresh UI');
        notifyListeners();
      });
      
      return null;
    } catch (e) {
      debugPrint('Error getting tracking provider: $e');
      return null;
    }
  }
  
  // Retry failed cravings
  Future<void> retrySyncCraving(String id) async {
    final cravingIndex = _cravings.indexWhere((c) => c.id == id);
    if (cravingIndex == -1) return;
    
    // Mark as pending
    _cravings[cravingIndex] = _cravings[cravingIndex].copyWith(
      syncStatus: SyncStatus.pending
    );
    notifyListeners();
    
    try {
      // Get a clean version without the temporary ID
      final cravingToSync = _cravings[cravingIndex].copyWith(
        id: id.startsWith('temp_') ? null : id
      );
      
      // Perform the actual API call
      final syncedCraving = await _repository.saveCraving(cravingToSync);
      
      // Replace with the synced version
      _cravings[cravingIndex] = syncedCraving;
      _error = null;
      notifyListeners();
    } catch (e) {
      // Mark as failed again
      _cravings[cravingIndex] = _cravings[cravingIndex].copyWith(
        syncStatus: SyncStatus.failed
      );
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Remove a craving (optimistically)
  Future<void> removeCraving(String id) async {
    // Store the original item for potential rollback
    final originalCraving = _cravings.firstWhere((c) => c.id == id);
    
    // Remove immediately (optimistic update)
    _cravings = _cravings.where((c) => c.id != id).toList();
    notifyListeners();
    
    try {
      // Perform the actual deletion
      await _repository.deleteCraving(id);
      _error = null;
    } catch (e) {
      // Put the item back on error
      _cravings = [..._cravings, originalCraving];
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Background sync of all pending/failed items
  Future<void> syncPendingCravings() async {
    final pendingItems = [...pendingCravings, ...failedCravings];
    
    for (final craving in pendingItems) {
      if (craving.id != null) {
        await retrySyncCraving(craving.id!);
      }
    }
  }
  
  Future<int> getCravingCount(String userId) async {
    try {
      return await _repository.getCravingCountForUser(userId);
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
}