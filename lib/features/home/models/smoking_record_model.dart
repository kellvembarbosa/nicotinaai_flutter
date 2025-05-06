class SmokingRecordModel {
  final String? id;
  final String reason;
  final String? notes;
  final String amount;
  final String duration;
  final DateTime timestamp;
  final String userId;

  SmokingRecordModel({
    this.id,
    required this.reason,
    this.notes,
    required this.amount,
    required this.duration,
    required this.timestamp,
    required this.userId,
  });

  factory SmokingRecordModel.fromJson(Map<String, dynamic> json) {
    return SmokingRecordModel(
      id: json['id'],
      reason: json['reason'],
      notes: json['notes'],
      amount: json['amount'],
      duration: json['duration'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
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