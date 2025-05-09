import 'achievement_definition.dart';

/// Represents a user's progress or completion status for an achievement
class UserAchievement {
  /// Same as achievement definition id
  final String id;
  
  /// Reference to the achievement definition
  final AchievementDefinition definition;
  
  /// DateTime when the achievement was unlocked (or future date if not unlocked)
  final DateTime unlockedAt;
  
  /// Whether the user has viewed this achievement after unlocking
  final bool isViewed;
  
  /// Progress toward completion (0.0 to 1.0)
  final double progress;

  /// Whether this achievement is unlocked (convenience getter)
  bool get isUnlocked => progress >= 1.0;

  const UserAchievement({
    required this.id,
    required this.definition,
    required this.unlockedAt,
    required this.isViewed,
    required this.progress,
  });
  
  /// Creates a copy of this UserAchievement with updated properties
  UserAchievement copyWith({
    String? id,
    AchievementDefinition? definition,
    DateTime? unlockedAt,
    bool? isViewed,
    double? progress,
  }) {
    return UserAchievement(
      id: id ?? this.id,
      definition: definition ?? this.definition,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isViewed: isViewed ?? this.isViewed,
      progress: progress ?? this.progress,
    );
  }
}