import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/providers/craving_provider.dart';
import 'package:nicotinaai_flutter/features/home/providers/smoking_record_provider.dart';

class SyncService {
  final CravingProvider _cravingProvider;
  final SmokingRecordProvider _recordProvider;
  
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Timer? _periodicSyncTimer;
  bool _isSyncing = false;
  
  SyncService({
    required CravingProvider cravingProvider,
    required SmokingRecordProvider recordProvider,
  }) : _cravingProvider = cravingProvider,
       _recordProvider = recordProvider {
    _initConnectivityListener();
    _startPeriodicSync();
  }
  
  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      // When at least one connection is available, attempt to sync
      if (results.isNotEmpty && !results.every((result) => result == ConnectivityResult.none)) {
        syncAllPending();
      }
    });
  }
  
  void _startPeriodicSync() {
    // Attempt to sync every 15 minutes
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => syncAllPending(),
    );
  }
  
  Future<void> syncAllPending() async {
    // Prevent multiple syncs from running simultaneously
    if (_isSyncing) return;
    
    _isSyncing = true;
    
    try {
      // Sync cravings first - manual implementation since method isn't available
      final pendingCravings = [..._cravingProvider.pendingCravings, ..._cravingProvider.failedCravings];
      for (final craving in pendingCravings) {
        if (craving.id != null) {
          await _cravingProvider.saveCraving(craving.copyWith(
            id: craving.id!.startsWith('temp_') ? null : craving.id,
            syncStatus: SyncStatus.pending
          ));
        }
      }
      
      // Then sync records
      await _recordProvider.syncPendingRecords();
    } finally {
      _isSyncing = false;
    }
  }
  
  void dispose() {
    _connectivitySubscription.cancel();
    _periodicSyncTimer?.cancel();
  }
}