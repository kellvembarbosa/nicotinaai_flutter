import 'package:flutter/material.dart';
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

// Smoking Logs events
class LoadSmokingLogs extends TrackingEvent {
  final bool forceRefresh;

  LoadSmokingLogs({this.forceRefresh = false});
}

class RefreshSmokingLogs extends TrackingEvent {}

class AddSmokingLog extends TrackingEvent {
  final SmokingLog log;

  AddSmokingLog({required this.log});
}

class DeleteSmokingLog extends TrackingEvent {
  final String logId;

  DeleteSmokingLog({required this.logId});
}

// Cravings events
class LoadCravings extends TrackingEvent {
  final bool forceRefresh;

  LoadCravings({this.forceRefresh = false});
}

class RefreshCravings extends TrackingEvent {}

class AddCraving extends TrackingEvent {
  final Craving craving;
  final BuildContext? context;

  AddCraving({required this.craving, this.context});
}

class UpdateCraving extends TrackingEvent {
  final Craving craving;

  UpdateCraving({required this.craving});
}

// Health Recoveries events
class LoadHealthRecoveries extends TrackingEvent {
  final bool forceRefresh;

  LoadHealthRecoveries({this.forceRefresh = false});
}

class RefreshAllData extends TrackingEvent {
  final bool forceRefresh;

  RefreshAllData({this.forceRefresh = false});
}

// Error handling events
class ClearError extends TrackingEvent {}

// Logout/reset events
class ResetTrackingData extends TrackingEvent {}