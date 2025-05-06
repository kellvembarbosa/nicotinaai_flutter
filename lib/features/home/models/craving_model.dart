class CravingModel {
  final String? id;
  final String location;
  final String? notes;
  final String trigger;
  final String intensity;
  final bool resisted;
  final DateTime timestamp;
  final String userId;

  CravingModel({
    this.id,
    required this.location,
    this.notes,
    required this.trigger,
    required this.intensity,
    required this.resisted,
    required this.timestamp,
    required this.userId,
  });

  factory CravingModel.fromJson(Map<String, dynamic> json) {
    return CravingModel(
      id: json['id'],
      location: json['location'],
      notes: json['notes'],
      trigger: json['trigger'],
      intensity: json['intensity'],
      resisted: json['resisted'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'notes': notes,
      'trigger': trigger,
      'intensity': intensity,
      'resisted': resisted,
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
    };
  }
}