import 'package:flutter/foundation.dart';

enum CravingIntensity { low, moderate, high, veryHigh }
enum CravingOutcome { resisted, smoked, alternative }

class Craving {
  final String? id;
  final String userId;
  final DateTime timestamp;
  final CravingIntensity intensity;
  final String? trigger;
  final String? location;
  final int? durationMinutes;
  final CravingOutcome outcome;
  final String? copingStrategy;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Craving({
    this.id,
    required this.userId,
    required this.timestamp,
    required this.intensity,
    this.trigger,
    this.location,
    this.durationMinutes,
    this.outcome = CravingOutcome.resisted,
    this.copingStrategy,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Copy constructor
  Craving copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    CravingIntensity? intensity,
    String? trigger,
    String? location,
    int? durationMinutes,
    CravingOutcome? outcome,
    String? copingStrategy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Craving(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      intensity: intensity ?? this.intensity,
      trigger: trigger ?? this.trigger,
      location: location ?? this.location,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      outcome: outcome ?? this.outcome,
      copingStrategy: copingStrategy ?? this.copingStrategy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // From JSON to Model
  factory Craving.fromJson(Map<String, dynamic> json) {
    return Craving(
      id: json['id'],
      userId: json['user_id'],
      timestamp: DateTime.parse(json['timestamp']),
      intensity: _stringToIntensity(json['intensity']),
      trigger: json['trigger'],
      location: json['location'],
      durationMinutes: json['duration_minutes'],
      outcome: _stringToOutcome(json['outcome']),
      copingStrategy: json['coping_strategy'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // From Model to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'intensity': _intensityToString(intensity),
      if (trigger != null) 'trigger': trigger,
      if (location != null) 'location': location,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      'outcome': _outcomeToString(outcome),
      if (copingStrategy != null) 'coping_strategy': copingStrategy,
      if (notes != null) 'notes': notes,
    };
  }

  // Helper methods for conversion
  static CravingIntensity _stringToIntensity(String value) {
    switch (value) {
      case 'LOW':
        return CravingIntensity.low;
      case 'MODERATE':
        return CravingIntensity.moderate;
      case 'HIGH':
        return CravingIntensity.high;
      case 'VERY_HIGH':
        return CravingIntensity.veryHigh;
      default:
        return CravingIntensity.moderate;
    }
  }

  static String _intensityToString(CravingIntensity intensity) {
    switch (intensity) {
      case CravingIntensity.low:
        return 'LOW';
      case CravingIntensity.moderate:
        return 'MODERATE';
      case CravingIntensity.high:
        return 'HIGH';
      case CravingIntensity.veryHigh:
        return 'VERY_HIGH';
    }
  }

  static CravingOutcome _stringToOutcome(String value) {
    switch (value) {
      case 'RESISTED':
        return CravingOutcome.resisted;
      case 'SMOKED':
        return CravingOutcome.smoked;
      case 'ALTERNATIVE':
        return CravingOutcome.alternative;
      default:
        return CravingOutcome.resisted;
    }
  }

  static String _outcomeToString(CravingOutcome outcome) {
    switch (outcome) {
      case CravingOutcome.resisted:
        return 'RESISTED';
      case CravingOutcome.smoked:
        return 'SMOKED';
      case CravingOutcome.alternative:
        return 'ALTERNATIVE';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Craving &&
      other.id == id &&
      other.userId == userId &&
      other.timestamp == timestamp &&
      other.intensity == intensity &&
      other.trigger == trigger &&
      other.location == location &&
      other.durationMinutes == durationMinutes &&
      other.outcome == outcome &&
      other.copingStrategy == copingStrategy &&
      other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      timestamp.hashCode ^
      intensity.hashCode ^
      trigger.hashCode ^
      location.hashCode ^
      durationMinutes.hashCode ^
      outcome.hashCode ^
      copingStrategy.hashCode ^
      notes.hashCode;
  }
}