import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/utils/achievement_localizer.dart';
import 'package:nicotinaai_flutter/utils/currency_utils.dart';

/// A model class representing an achievement
class Achievement {
  final String id;
  final String name; // Fallback name if localization fails
  final String description; // Fallback description if localization fails
  final String iconName;
  final int xpReward;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.xpReward,
    this.isUnlocked = false,
  });
}

/// A card widget that displays an achievement with proper localization
class LocalizedAchievementCard extends StatelessWidget {
  final Achievement achievement;
  
  const LocalizedAchievementCard({
    Key? key,
    required this.achievement,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get the currency symbol for financial achievements
    final currencySymbol = CurrencyUtils.getCurrencySymbol(context);
    
    // Get localized name and description
    final name = AchievementLocalizer.getLocalizedName(context, achievement.id);
    
    // For financial achievements, format the currency in the description
    final description = achievement.id.contains('money_saved')
      ? AchievementLocalizer.formatFinancialDescription(
          context, 
          achievement.id, 
          currencySymbol
        )
      : AchievementLocalizer.getLocalizedDescription(context, achievement.id);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Achievement icon
                Icon(
                  _getIconData(achievement.iconName),
                  color: achievement.isUnlocked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                  size: 32,
                ),
                const SizedBox(width: 16),
                
                // Achievement name and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: achievement.isUnlocked
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                      Text(
                        achievement.isUnlocked ? 'Unlocked' : 'Locked',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: achievement.isUnlocked
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // XP reward
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '+${achievement.xpReward} XP',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Achievement description
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to convert icon name to IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'first_step':
        return Icons.start;
      case 'streak':
        return Icons.local_fire_department;
      case 'money':
        return Icons.attach_money;
      case 'willpower':
        return Icons.fitness_center;
      default:
        return Icons.emoji_events;
    }
  }
}

// Example usage
class AchievementsExampleScreen extends StatelessWidget {
  const AchievementsExampleScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Example achievement data
    final achievements = [
      const Achievement(
        id: '4bb169cc-8cc6-4440-ae1a-aa25a2105715',
        name: 'First Step',
        description: 'Complete the onboarding process',
        iconName: 'first_step',
        xpReward: 50,
        isUnlocked: true,
      ),
      const Achievement(
        id: 'b807746a-3988-44cf-88d4-fd99d92bc6aa',
        name: 'One Day Wonder',
        description: 'Stay smoke-free for 1 day',
        iconName: 'streak',
        xpReward: 100,
        isUnlocked: true,
      ),
      const Achievement(
        id: '26deeffb-d7cf-4e69-8973-cdc07f1c2698',
        name: 'Week Warrior',
        description: 'Stay smoke-free for 7 days',
        iconName: 'streak',
        xpReward: 200,
        isUnlocked: false,
      ),
      const Achievement(
        id: 'fe471ea4-0d4d-43ab-bb7e-46eb979ce400',
        name: 'Money Mindful',
        description: 'Save $50 by not smoking',
        iconName: 'money',
        xpReward: 100,
        isUnlocked: false,
      ),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView.builder(
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          return LocalizedAchievementCard(achievement: achievements[index]);
        },
      ),
    );
  }
}