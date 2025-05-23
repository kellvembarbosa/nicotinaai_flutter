enum SyncStatus {
  synced,     // Item is synced with server
  pending,    // Item is waiting to be synced
  failed,     // Sync failed but will retry
  error       // Permanent error, won't retry
}

class CravingModel {
  final String? id;
  final String location;
  final String? notes;
  final String trigger;
  final String intensity;
  final bool resisted;
  final DateTime timestamp;
  final String userId;
  final SyncStatus syncStatus;

  CravingModel({
    this.id,
    required this.location,
    this.notes,
    required this.trigger,
    required this.intensity,
    required this.resisted,
    required this.timestamp,
    required this.userId,
    this.syncStatus = SyncStatus.synced,
  });

  // Add copy method for state manipulation
  CravingModel copyWith({
    String? id,
    String? location,
    String? notes,
    String? trigger,
    String? intensity,
    bool? resisted,
    DateTime? timestamp,
    String? userId,
    SyncStatus? syncStatus,
  }) {
    return CravingModel(
      id: id ?? this.id,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      trigger: trigger ?? this.trigger,
      intensity: intensity ?? this.intensity,
      resisted: resisted ?? this.resisted,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory CravingModel.fromJson(Map<String, dynamic> json) {
    // Determine resisted status from outcome enum or direct resisted field
    bool getResisted() {
      // First check if outcome field exists (database format)
      if (json.containsKey('outcome')) {
        final outcome = json['outcome'];
        if (outcome != null) {
          // RESISTED means resisted=true, any other value means resisted=false
          return outcome.toString().toUpperCase() == 'RESISTED';
        }
      }
      
      // Fallback to direct resisted field if it exists
      if (json.containsKey('resisted')) {
        return json['resisted'] == true;
      }
      
      // Default value if neither field exists
      return false;
    }
    
    // Map intensity from database enum ["LOW", "MODERATE", "HIGH", "VERY_HIGH"] to app values
    String mapIntensity(dynamic dbIntensity) {
      if (dbIntensity == null) return 'moderate';
      
      final intensity = dbIntensity.toString().toUpperCase();
      switch (intensity) {
        case 'LOW':
          return 'low';
        case 'MODERATE':
          return 'moderate';
        case 'HIGH':
          return 'high';
        case 'VERY_HIGH':
          return 'very_high';
        default:
          return 'moderate'; // fallback
      }
    }
    
    return CravingModel(
      id: json['id'],
      location: json['location'] ?? '',
      notes: json['notes'],
      trigger: json['trigger'] ?? '',
      intensity: mapIntensity(json['intensity']),
      resisted: getResisted(),
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['user_id'],
      syncStatus: SyncStatus.synced,
    );
  }

  Map<String, dynamic> toJson() {
    // We don't include syncStatus in the JSON since it's internal state
    
    // Map intensity values from our app to the database enum values
    // Database enum values: ["LOW", "MODERATE", "HIGH", "VERY_HIGH"]
    String getIntensityEnum() {
      switch (intensity.toLowerCase()) {
        case 'low':
          return 'LOW';
        case 'moderate':
          return 'MODERATE';
        case 'high': 
          return 'HIGH';
        case 'very_high':
          return 'VERY_HIGH';
        default:
          // Fallback to MODERATE if unexpected value
          return 'MODERATE';
      }
    }
    
    // Map boolean resisted field to the database enum outcome
    // Database enum values: ["RESISTED", "SMOKED", "ALTERNATIVE"]
    String getOutcomeEnum() {
      return resisted ? 'RESISTED' : 'SMOKED';
    }
    
    return {
      'id': id,
      'location': location,
      'notes': notes,
      'trigger': trigger,
      'intensity': getIntensityEnum(), // Map to valid enum values: "LOW", "MODERATE", "HIGH", "VERY_HIGH"
      'outcome': getOutcomeEnum(), // Map boolean resisted to enum outcome
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
    };
  }
}