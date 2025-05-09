/// Defines an achievement that users can unlock in the app
class AchievementDefinition {
  /// Unique identifier for the achievement
  final String id;
  
  /// Display name of the achievement
  final String name;
  
  /// Detailed description of the achievement
  final String description;
  
  /// Category of the achievement (TIME, HEALTH, SAVINGS, HABITS)
  final String category;
  
  /// Type of requirement for unlocking (DAYS_SMOKE_FREE, HEALTH_RECOVERY, etc.)
  final String requirementType;
  
  /// Value required to unlock (can be int or String depending on type)
  final dynamic requirementValue;
  
  /// Optional name of the icon to display
  final String? iconName;
  
  /// Optional text to display on the achievement badge
  final String? badgeText;
  
  /// Order index for sorting within category
  final int orderIndex;
  
  /// XP reward when achievement is unlocked
  final int xpReward;

  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.requirementType,
    required this.requirementValue,
    required this.orderIndex,
    required this.xpReward,
    this.iconName,
    this.badgeText,
  });
}