class HealthRecovery {
  final String id;
  final String name;
  final String description;
  final int daysToAchieve;
  final String? iconName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HealthRecovery({
    required this.id,
    required this.name,
    required this.description,
    required this.daysToAchieve,
    this.iconName,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthRecovery.fromJson(Map<String, dynamic> json) {
    return HealthRecovery(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      daysToAchieve: json['days_to_achieve'],
      iconName: json['icon_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'days_to_achieve': daysToAchieve,
      if (iconName != null) 'icon_name': iconName,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

class UserHealthRecovery {
  final String id;
  final String userId;
  final String recoveryId;
  final DateTime achievedAt;
  final bool isViewed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? _daysToAchieve; // Internal storage for daysToAchieve

  const UserHealthRecovery({
    required this.id,
    required this.userId,
    required this.recoveryId,
    required this.achievedAt,
    required this.isViewed,
    this.createdAt,
    this.updatedAt,
    int? daysToAchieve,
  }) : _daysToAchieve = daysToAchieve;
  
  // A health recovery is considered achieved since it has an achievedAt date
  bool get isAchieved => true;
  
  // No longer needed since we updated tracking_provider.dart to use recoveryId directly
  
  // Getter for daysToAchieve, defaulting to 0 if not provided
  int get daysToAchieve => _daysToAchieve ?? 0;

  factory UserHealthRecovery.fromJson(Map<String, dynamic> json) {
    return UserHealthRecovery(
      id: json['id'],
      userId: json['user_id'],
      recoveryId: json['recovery_id'],
      achievedAt: DateTime.parse(json['achieved_at']),
      isViewed: json['is_viewed'],
      daysToAchieve: json['days_to_achieve'] != null 
          ? int.tryParse(json['days_to_achieve'].toString()) 
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recovery_id': recoveryId,
      'achieved_at': achievedAt.toIso8601String(),
      'is_viewed': isViewed,
      if (_daysToAchieve != null) 'days_to_achieve': _daysToAchieve,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}