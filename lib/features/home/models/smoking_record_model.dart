import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';

class SmokingRecordModel {
  final String? id;
  final String reason;
  final String? notes;
  final String amount;
  final String duration;
  final DateTime timestamp;
  final String userId;
  final SyncStatus syncStatus;

  SmokingRecordModel({
    this.id,
    required this.reason,
    this.notes,
    required this.amount,
    required this.duration,
    required this.timestamp,
    required this.userId,
    this.syncStatus = SyncStatus.synced,
  });

  // Add copy method for state manipulation
  SmokingRecordModel copyWith({
    String? id,
    String? reason,
    String? notes,
    String? amount,
    String? duration,
    DateTime? timestamp,
    String? userId,
    SyncStatus? syncStatus,
  }) {
    return SmokingRecordModel(
      id: id ?? this.id,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory SmokingRecordModel.fromJson(Map<String, dynamic> json) {
    return SmokingRecordModel(
      id: json['id'],
      reason: json['reason'],
      notes: json['notes'],
      amount: json['amount'],
      duration: json['duration'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['user_id'],
      syncStatus: SyncStatus.synced,
    );
  }

  Map<String, dynamic> toJson() {
    // We don't include syncStatus in the JSON since it's internal state
    return {
      'id': id,
      'reason': reason,
      'notes': notes,
      'amount': amount,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
    };
  }
}