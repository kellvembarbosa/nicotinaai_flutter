import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';
import 'package:nicotinaai_flutter/features/tracking/models/craving.dart';
import 'package:nicotinaai_flutter/features/tracking/models/smoking_log.dart';

abstract class TrackingEvent {}

// Initialize events
class InitializeTracking extends TrackingEvent {}

// User Stats events
class LoadUserStats extends TrackingEvent {
  final bool forceRefresh;

  LoadUserStats({this.forceRefresh = false});
}

class RefreshUserStats extends TrackingEvent {
  final bool forceRefresh;

  RefreshUserStats({this.forceRefresh = false});
}

class ForceUpdateStats extends TrackingEvent {}

// ===============================================
// Unified Smoking Records events (replaces both SmokingRecordBloc and old events)
// ===============================================

// Load records events
class LoadSmokingLogs extends TrackingEvent {
  final bool forceRefresh;

  LoadSmokingLogs({this.forceRefresh = false});
}

class RefreshSmokingLogs extends TrackingEvent {}

class LoadSmokingRecordsForUser extends TrackingEvent {
  final String userId;
  
  LoadSmokingRecordsForUser({required this.userId});
}

// Add smoking record events
class AddSmokingLog extends TrackingEvent {
  final SmokingLog log;

  AddSmokingLog({required this.log});
}

class SaveSmokingRecord extends TrackingEvent {
  final SmokingRecordModel record;

  SaveSmokingRecord({required this.record});
}

// Delete smoking record events
class DeleteSmokingLog extends TrackingEvent {
  final String logId;

  DeleteSmokingLog({required this.logId});
}

class RemoveSmokingRecord extends TrackingEvent {
  final String id;

  RemoveSmokingRecord({required this.id});
}

// Sync smoking record events
class RetrySyncSmokingRecord extends TrackingEvent {
  final String id;

  RetrySyncSmokingRecord({required this.id});
}

class SyncPendingSmokingRecords extends TrackingEvent {}

class GetSmokingRecordCount extends TrackingEvent {
  final String userId;

  GetSmokingRecordCount({required this.userId});
}

// ===============================================
// Unified Cravings events (replaces both CravingBloc and old events)
// ===============================================

// Load cravings events
class LoadCravings extends TrackingEvent {
  final bool forceRefresh;

  LoadCravings({this.forceRefresh = false});
}

class RefreshCravings extends TrackingEvent {}

class LoadCravingsForUser extends TrackingEvent {
  final String userId;
  
  LoadCravingsForUser({required this.userId});
}

// Add craving events
class AddCraving extends TrackingEvent {
  final Craving craving;
  final BuildContext? context;

  AddCraving({required this.craving, this.context});
}

class SaveCraving extends TrackingEvent {
  final CravingModel craving;

  SaveCraving({required this.craving});
}

// Update craving events
class UpdateCraving extends TrackingEvent {
  final Craving craving;

  UpdateCraving({required this.craving});
}

// Delete craving events
class RemoveCraving extends TrackingEvent {
  final String id;

  RemoveCraving({required this.id});
}

// Sync craving events
class RetrySyncCraving extends TrackingEvent {
  final String id;

  RetrySyncCraving({required this.id});
}

class SyncPendingCravings extends TrackingEvent {}

class GetCravingCount extends TrackingEvent {
  final String userId;

  GetCravingCount({required this.userId});
}

// Notification events
class CravingAdded extends TrackingEvent {
  // Include the resisted flag to correctly update statistics
  final bool resisted;
  
  CravingAdded({this.resisted = true});
}

class SmokingRecordAdded extends TrackingEvent {
  final int amount;
  
  SmokingRecordAdded({required this.amount});
}

// Health Recoveries events
class LoadHealthRecoveries extends TrackingEvent {
  final bool forceRefresh;

  LoadHealthRecoveries({this.forceRefresh = false});
}

// Global events
class RefreshAllData extends TrackingEvent {
  final bool forceRefresh;

  RefreshAllData({this.forceRefresh = false});
}

// Error handling events
class ClearError extends TrackingEvent {}
class ClearCravingError extends TrackingEvent {}
class ClearSmokingRecordError extends TrackingEvent {}

// Logout/reset events
class ResetTrackingData extends TrackingEvent {}