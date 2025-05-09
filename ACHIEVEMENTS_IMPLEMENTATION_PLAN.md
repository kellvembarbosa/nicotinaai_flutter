# Achievements Implementation Plan

## Overview

This document outlines the implementation plan for the Achievements feature in the NicotinaAI Flutter app. The feature will track, display, and reward users for reaching various milestones in their journey to quit smoking. This plan ensures alignment with the recent Health Recovery system implementation.

## Achievement Categories

Based on the existing UI in `achievements_screen.dart` and the health recovery system, we'll implement the following achievement categories:

1. **Health** - Achievements related to health improvements
2. **Time** - Achievements for duration without smoking
3. **Savings** - Achievements for money saved
4. **Habits** - Achievements for developing new positive habits

## Database Design

We'll need to create two tables:

1. `achievements` - Master list of all possible achievements
2. `user_achievements` - Tracks which achievements a user has earned

### SQL Migration

```sql
-- Create achievements table
CREATE TABLE IF NOT EXISTS public.achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  requirement_value INTEGER NOT NULL,
  requirement_type TEXT NOT NULL,
  icon_name TEXT,
  badge_text TEXT,
  order_index INTEGER NOT NULL,
  xp_reward INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_achievements table
CREATE TABLE IF NOT EXISTS public.user_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES public.achievements(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_viewed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes
CREATE INDEX idx_user_achievements_user_id ON public.user_achievements(user_id);
CREATE INDEX idx_user_achievements_achievement_id ON public.user_achievements(achievement_id);
CREATE INDEX idx_achievements_category ON public.achievements(category);
CREATE INDEX idx_achievements_requirement_type ON public.achievements(requirement_type);

-- Setup RLS
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- RLS policies for achievements
CREATE POLICY "Anyone can view achievements" 
  ON public.achievements
  FOR SELECT
  USING (true);

-- RLS policies for user_achievements
CREATE POLICY "Users can view their own achievements" 
  ON public.user_achievements
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own achievements" 
  ON public.user_achievements
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own achievements" 
  ON public.user_achievements
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Trigger for updated_at
CREATE TRIGGER update_achievements_modtime
BEFORE UPDATE ON public.achievements
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_user_achievements_modtime
BEFORE UPDATE ON public.user_achievements
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Insert initial achievement data
INSERT INTO public.achievements (name, description, category, requirement_type, requirement_value, badge_text, icon_name, order_index, xp_reward)
VALUES
  -- Time achievements
  ('First Day', 'Complete 24 hours without smoking', 'TIME', 'DAYS_SMOKE_FREE', 1, '24h', 'calendar_today', 1, 10),
  ('One Week', 'One week without smoking!', 'TIME', 'DAYS_SMOKE_FREE', 7, '7 days', 'celebration', 2, 25),
  ('Two Weeks', 'Two complete weeks without smoking!', 'TIME', 'DAYS_SMOKE_FREE', 14, '14 days', 'calendar_month', 3, 50),
  ('One Month', 'A whole month without smoking!', 'TIME', 'DAYS_SMOKE_FREE', 30, '30 days', 'emoji_events', 4, 100),
  ('Three Months', 'Three months smoke-free!', 'TIME', 'DAYS_SMOKE_FREE', 90, '90 days', 'military_tech', 5, 250),
  ('Six Months', 'Half a year without smoking!', 'TIME', 'DAYS_SMOKE_FREE', 180, '180 days', 'workspace_premium', 6, 500),
  ('One Year', 'One year smoke-free anniversary!', 'TIME', 'DAYS_SMOKE_FREE', 365, '1 year', 'verified', 7, 1000),
  
  -- Health achievements (aligned with Health Recovery system)
  ('Improved Taste', 'Taste buds have recovered', 'HEALTH', 'HEALTH_RECOVERY', 1, 'Taste', 'restaurant', 1, 20),
  ('Improved Smell', 'Sense of smell has improved', 'HEALTH', 'HEALTH_RECOVERY', 2, 'Smell', 'air', 2, 20),
  ('Improved Circulation', 'Oxygen levels normalized', 'HEALTH', 'HEALTH_RECOVERY', 3, 'Circulation', 'favorite', 3, 50),
  ('Clean Breathing', 'Lung capacity increased by 30%', 'HEALTH', 'HEALTH_RECOVERY', 4, 'Lungs', 'air_sharp', 4, 100),
  ('Heart Health', 'Heart attack risk reduced by 50%', 'HEALTH', 'HEALTH_RECOVERY', 5, 'Heart', 'favorite_border', 5, 300),
  
  -- Savings achievements
  ('Initial Savings', 'Save the equivalent of 1 pack of cigarettes', 'SAVINGS', 'MONEY_SAVED', 1, 'First Pack', 'savings', 1, 15),
  ('Smart Saver', 'Save the equivalent of 5 packs', 'SAVINGS', 'MONEY_SAVED', 5, '5 Packs', 'attach_money', 2, 30),
  ('Substantial Savings', 'Save the equivalent of 10 packs', 'SAVINGS', 'MONEY_SAVED', 10, '10 Packs', 'monetization_on', 3, 60),
  ('Money Milestone', 'Save the equivalent of 25 packs', 'SAVINGS', 'MONEY_SAVED', 25, '25 Packs', 'savings_outlined', 4, 125),
  ('Financial Freedom', 'Save the equivalent of 100 packs', 'SAVINGS', 'MONEY_SAVED', 100, '100 Packs', 'account_balance', 5, 500),
  
  -- Habits achievements
  ('Streak Starter', 'Record activity for 3 consecutive days', 'HABITS', 'LOGIN_STREAK', 3, 'Streak', 'trending_up', 1, 10),
  ('Consistency Champion', 'Record activity for 7 consecutive days', 'HABITS', 'LOGIN_STREAK', 7, 'Consistent', 'auto_graph', 2, 25),
  ('Habit Formed', 'Record activity for 21 consecutive days', 'HABITS', 'LOGIN_STREAK', 21, 'Habit', 'published_with_changes', 3, 75),
  ('Resisted Cravings', 'Successfully resist 10 cravings', 'HABITS', 'CRAVINGS_RESISTED', 10, 'Willpower', 'fitness_center', 4, 50),
  ('Craving Crusher', 'Successfully resist 50 cravings', 'HABITS', 'CRAVINGS_RESISTED', 50, 'Crusher', 'psychology', 5, 200),
  ('New Habit: Exercise', 'Record 5 days of exercise', 'HABITS', 'EXERCISE_LOGGED', 5, 'Active', 'directions_run', 6, 35);
```

## Data Models

### Achievement Model

```dart
class Achievement {
  final String id;
  final String name;
  final String description;
  final String category;
  final String requirementType;
  final int requirementValue;
  final String? iconName;
  final String? badgeText;
  final int orderIndex;
  final int xpReward;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Achievement({
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
    this.createdAt,
    this.updatedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      requirementType: json['requirement_type'],
      requirementValue: json['requirement_value'],
      orderIndex: json['order_index'],
      xpReward: json['xp_reward'] ?? 0,
      iconName: json['icon_name'],
      badgeText: json['badge_text'],
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
      'category': category,
      'requirement_type': requirementType,
      'requirement_value': requirementValue,
      'order_index': orderIndex,
      'xp_reward': xpReward,
      if (iconName != null) 'icon_name': iconName,
      if (badgeText != null) 'badge_text': badgeText,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
```

### UserAchievement Model

```dart
class UserAchievement {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;
  final bool isViewed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Achievement? achievement; // Optional nested achievement data

  const UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    required this.isViewed,
    this.createdAt,
    this.updatedAt,
    this.achievement,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'],
      userId: json['user_id'],
      achievementId: json['achievement_id'],
      unlockedAt: DateTime.parse(json['unlocked_at']),
      isViewed: json['is_viewed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      achievement: json['achievement'] != null
          ? Achievement.fromJson(json['achievement'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'achievement_id': achievementId,
      'unlocked_at': unlockedAt.toIso8601String(),
      'is_viewed': isViewed,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (achievement != null) 'achievement': achievement!.toJson(),
    };
  }
}
```

## Achievement Repository Implementation

```dart
class AchievementRepository {
  final SupabaseClient _supabase;

  AchievementRepository(this._supabase);

  // Get all achievements
  Future<List<Achievement>> getAllAchievements() async {
    final response = await _supabase.from('achievements').select().order('order_index');
    return response.map<Achievement>((json) => Achievement.fromJson(json)).toList();
  }

  // Get achievements by category
  Future<List<Achievement>> getAchievementsByCategory(String category) async {
    final response = await _supabase
        .from('achievements')
        .select()
        .eq('category', category)
        .order('order_index');
    return response.map<Achievement>((json) => Achievement.fromJson(json)).toList();
  }

  // Get user's unlocked achievements
  Future<List<UserAchievement>> getUserAchievements() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('user_achievements')
        .select('*, achievement:achievement_id(*)')
        .eq('user_id', userId)
        .order('unlocked_at', ascending: false);
    
    return response.map<UserAchievement>((json) => UserAchievement.fromJson(json)).toList();
  }

  // Check if user has unlocked specific achievement
  Future<bool> hasUnlockedAchievement(String achievementId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return false;
    }

    final response = await _supabase
        .from('user_achievements')
        .select('id')
        .eq('user_id', userId)
        .eq('achievement_id', achievementId)
        .limit(1);
    
    return response.isNotEmpty;
  }

  // Mark achievement as viewed
  Future<void> markAchievementAsViewed(String userAchievementId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _supabase
        .from('user_achievements')
        .update({'is_viewed': true})
        .eq('id', userAchievementId)
        .eq('user_id', userId);
  }

  // Get achievement progress for a specific requirement type
  Future<Map<String, dynamic>> getAchievementProgress(String requirementType) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    switch (requirementType) {
      case 'DAYS_SMOKE_FREE':
        final response = await _supabase
            .from('user_stats')
            .select('last_smoke_date')
            .eq('user_id', userId)
            .single();
        
        if (response != null && response['last_smoke_date'] != null) {
          final lastSmokeDate = DateTime.parse(response['last_smoke_date']);
          final now = DateTime.now();
          final daysSinceLast = now.difference(lastSmokeDate).inDays;
          return {
            'current_value': daysSinceLast,
            'metric': 'days'
          };
        }
        return {'current_value': 0, 'metric': 'days'};

      case 'MONEY_SAVED':
        // TODO: Implement logic to calculate money saved (in packs)
        return {'current_value': 0, 'metric': 'packs'};
        
      case 'LOGIN_STREAK':
        // TODO: Implement logic to get login streak
        return {'current_value': 0, 'metric': 'days'};
        
      case 'CRAVINGS_RESISTED':
        final response = await _supabase
            .from('cravings')
            .select('count')
            .eq('user_id', userId)
            .eq('was_resisted', true);
        
        return {
          'current_value': response.length,
          'metric': 'cravings'
        };
        
      case 'HEALTH_RECOVERY':
        final response = await _supabase
            .from('user_health_recoveries')
            .select('count')
            .eq('user_id', userId);
        
        return {
          'current_value': response.length,
          'metric': 'recoveries'
        };
        
      default:
        return {'current_value': 0, 'metric': 'unknown'};
    }
  }
}
```

## Achievement Provider Implementation

```dart
enum AchievementStatus {
  initial,
  loading,
  loaded,
  error
}

class AchievementState {
  final AchievementStatus status;
  final List<Achievement> allAchievements;
  final List<UserAchievement> userAchievements;
  final String? errorMessage;
  
  const AchievementState({
    this.status = AchievementStatus.initial,
    this.allAchievements = const [],
    this.userAchievements = const [],
    this.errorMessage,
  });
  
  AchievementState copyWith({
    AchievementStatus? status,
    List<Achievement>? allAchievements,
    List<UserAchievement>? userAchievements,
    String? errorMessage,
  }) {
    return AchievementState(
      status: status ?? this.status,
      allAchievements: allAchievements ?? this.allAchievements,
      userAchievements: userAchievements ?? this.userAchievements,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  // Helper methods for the UI
  List<Achievement> getAchievementsByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      return allAchievements;
    }
    return allAchievements.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();
  }
  
  bool isAchievementUnlocked(String achievementId) {
    return userAchievements.any((ua) => ua.achievementId == achievementId);
  }
  
  double getAchievementProgress(Achievement achievement) {
    // TODO: Implement logic to calculate progress
    return 0.0;
  }
  
  int getUnlockedAchievementsCount() {
    return userAchievements.length;
  }
  
  int getInProgressAchievementsCount() {
    // Count achievements with progress > 0 but not unlocked
    // TODO: Implement this properly with progress tracking
    return 8; // Placeholder
  }
  
  String getCompletionPercentage() {
    if (allAchievements.isEmpty) return "0%";
    return "${((userAchievements.length / allAchievements.length) * 100).round()}%";
  }
}

class AchievementProvider extends ChangeNotifier {
  final AchievementRepository _repository;
  AchievementState _state = AchievementState();
  
  AchievementProvider(this._repository);
  
  AchievementState get state => _state;
  
  Future<void> loadAchievements() async {
    try {
      _state = _state.copyWith(status: AchievementStatus.loading);
      notifyListeners();
      
      final allAchievements = await _repository.getAllAchievements();
      final userAchievements = await _repository.getUserAchievements();
      
      _state = _state.copyWith(
        status: AchievementStatus.loaded,
        allAchievements: allAchievements,
        userAchievements: userAchievements,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        status: AchievementStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }
  
  Future<void> markAchievementAsViewed(String userAchievementId) async {
    try {
      await _repository.markAchievementAsViewed(userAchievementId);
      
      // Update local state
      final updatedUserAchievements = _state.userAchievements.map((ua) {
        if (ua.id == userAchievementId) {
          return UserAchievement(
            id: ua.id,
            userId: ua.userId,
            achievementId: ua.achievementId,
            unlockedAt: ua.unlockedAt,
            isViewed: true,
            createdAt: ua.createdAt,
            updatedAt: ua.updatedAt,
            achievement: ua.achievement,
          );
        }
        return ua;
      }).toList();
      
      _state = _state.copyWith(userAchievements: updatedUserAchievements);
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error marking achievement as viewed: $e');
    }
  }
  
  Future<void> checkForNewAchievements() async {
    // TODO: Implement logic to check for new achievements based on user progress
    // This would typically be called after significant events like:
    // - Days without smoking increment
    // - Money saved milestone reached
    // - Login streak updated
    // - Craving resisted
    // - Health recovery achieved
  }
}
```

## UI Implementation

### Update AchievementsScreen

The existing `achievements_screen.dart` already has most of the UI components needed:

1. Summary section with counts for:
   - Unlocked achievements
   - In-progress achievements
   - Completion percentage

2. Category tabs for filtering achievements:
   - All
   - Health
   - Time
   - Savings
   - Habits

3. Progress tracker section showing:
   - Days without smoking
   - Current level
   - Progress to next level
   - Health benefits achieved

4. Achievement list showing:
   - Achievement icon and name
   - Description
   - Badge/category
   - Progress indicator for in-progress achievements
   - Checkmark for completed achievements

The main updates needed are:
- Connect the UI to the AchievementProvider
- Implement real data instead of the placeholder values
- Handle loading, error, and empty states
- Add proper filtering based on categories
- Implement progress calculation for in-progress achievements

### Achievement Detail Screen

Create a new screen to display detailed information about an achievement:

```dart
class AchievementDetailScreen extends StatelessWidget {
  final String achievementId;
  
  const AchievementDetailScreen({required this.achievementId, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final achievementProvider = Provider.of<AchievementProvider>(context);
    final state = achievementProvider.state;
    
    // Find the achievement in the provider
    final achievement = state.allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found'),
    );
    
    final isUnlocked = state.isAchievementUnlocked(achievementId);
    final progress = state.getAchievementProgress(achievement);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(achievement.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Achievement header with icon and status
            _buildAchievementHeader(context, achievement, isUnlocked),
            
            // Description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                achievement.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            
            // Progress section (if not unlocked)
            if (!isUnlocked) _buildProgressSection(context, achievement, progress),
            
            // Requirements
            _buildRequirementSection(context, achievement),
            
            // Reward
            if (achievement.xpReward > 0) _buildRewardSection(context, achievement),
            
            // Tips for achieving (if not unlocked)
            if (!isUnlocked) _buildTipsSection(context, achievement),
          ],
        ),
      ),
    );
  }
  
  // Implementation of the various build methods...
}
```

## Achievements Checking Logic

Create an edge function to periodically check for achievements:

```typescript
// checkAchievements.ts
import { serve } from 'https://deno.land/std@0.131.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.2.0';

serve(async (req) => {
  try {
    const { userId } = await req.json();
    
    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);
    
    // Get user's stats
    const { data: userStats } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', userId)
      .single();
      
    if (!userStats) {
      return new Response(
        JSON.stringify({ error: 'User stats not found' }),
        { headers: { 'Content-Type': 'application/json' }, status: 404 }
      );
    }
    
    // Get all achievements
    const { data: achievements } = await supabase
      .from('achievements')
      .select('*');
      
    // Get user's existing achievements
    const { data: userAchievements } = await supabase
      .from('user_achievements')
      .select('achievement_id')
      .eq('user_id', userId);
      
    const unlockedAchievementIds = new Set(userAchievements?.map(ua => ua.achievement_id) || []);
    const newAchievements = [];
    
    // Process achievements by type
    for (const achievement of achievements || []) {
      if (unlockedAchievementIds.has(achievement.id)) {
        continue; // Skip already unlocked achievements
      }
      
      let isUnlocked = false;
      let currentValue = 0;
      
      switch (achievement.requirement_type) {
        case 'DAYS_SMOKE_FREE':
          if (userStats.last_smoke_date) {
            const lastSmokeDate = new Date(userStats.last_smoke_date);
            const now = new Date();
            const daysSinceLast = Math.floor((now - lastSmokeDate) / (1000 * 60 * 60 * 24));
            currentValue = daysSinceLast;
            isUnlocked = daysSinceLast >= achievement.requirement_value;
          }
          break;
          
        case 'MONEY_SAVED':
          // Calculate packs saved
          if (userStats.cigarettes_per_day && userStats.cigarettes_per_pack && 
              userStats.pack_price && userStats.last_smoke_date) {
            const lastSmokeDate = new Date(userStats.last_smoke_date);
            const now = new Date();
            const daysSinceLast = Math.floor((now - lastSmokeDate) / (1000 * 60 * 60 * 24));
            const cigarettesSaved = daysSinceLast * userStats.cigarettes_per_day;
            const packsSaved = cigarettesSaved / userStats.cigarettes_per_pack;
            currentValue = Math.floor(packsSaved);
            isUnlocked = packsSaved >= achievement.requirement_value;
          }
          break;
          
        case 'LOGIN_STREAK':
          // TODO: Implement login streak check
          break;
          
        case 'CRAVINGS_RESISTED':
          // Count resisted cravings
          const { count: resistedCount } = await supabase
            .from('cravings')
            .select('id', { count: 'exact' })
            .eq('user_id', userId)
            .eq('was_resisted', true);
            
          currentValue = resistedCount || 0;
          isUnlocked = (resistedCount || 0) >= achievement.requirement_value;
          break;
          
        case 'HEALTH_RECOVERY':
          // Count health recoveries
          const { count: recoveriesCount } = await supabase
            .from('user_health_recoveries')
            .select('id', { count: 'exact' })
            .eq('user_id', userId);
            
          currentValue = recoveriesCount || 0;
          isUnlocked = (recoveriesCount || 0) >= achievement.requirement_value;
          break;
          
        default:
          break;
      }
      
      // If achievement is unlocked, add it
      if (isUnlocked) {
        const { data: newAchievement, error } = await supabase
          .from('user_achievements')
          .insert({
            user_id: userId,
            achievement_id: achievement.id,
            unlocked_at: new Date().toISOString(),
            is_viewed: false
          })
          .select()
          .single();
          
        if (!error && newAchievement) {
          newAchievements.push({
            id: newAchievement.id,
            name: achievement.name,
            description: achievement.description,
            badge_text: achievement.badge_text,
            xp_reward: achievement.xp_reward
          });
          
          // Award XP
          try {
            await supabase.rpc('add_user_xp', {
              p_user_id: userId,
              p_amount: achievement.xp_reward,
              p_source: 'ACHIEVEMENT',
              p_reference_id: achievement.id
            });
          } catch (e) {
            console.error('Error awarding XP:', e);
          }
          
          // Create notification
          try {
            await supabase.from('notifications').insert({
              user_id: userId,
              title: 'Achievement Unlocked!',
              message: `You've earned the "${achievement.name}" achievement!`,
              type: 'ACHIEVEMENT',
              reference_id: newAchievement.id,
              is_read: false
            });
          } catch (e) {
            console.error('Error creating notification:', e);
          }
        }
      }
    }
    
    return new Response(
      JSON.stringify({
        success: true,
        new_achievements: newAchievements,
        total_achievements: (userAchievements?.length || 0) + newAchievements.length
      }),
      { headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
```

## Integration with Health Recovery System

The achievement system will integrate directly with the health recovery system:

1. Health category achievements will unlock based on the user's health recoveries
2. The achievement UI will use similar styles to the health recovery UI for consistency
3. Both systems will award XP and generate notifications
4. The achievement categories will align with the health recovery categories

## Milestones and XP Rewards

The achievements will be designed to provide regular reinforcement:

1. Early achievements are easier to unlock for quick reinforcement
2. Later achievements require more effort but offer larger XP rewards
3. Achievement badges display on the user's profile
4. XP system will tie into a leveling system (future implementation)

## Implementation Phases

### Phase 1: Database and Models
- Create SQL migration for achievement tables
- Implement data models for Achievement and UserAchievement
- Test database with basic queries and relationships

### Phase 2: Repository and Provider
- Implement AchievementRepository with all required methods
- Create AchievementProvider for state management
- Add methods for tracking progress and achievement status

### Phase 3: UI Updates
- Connect existing AchievementsScreen to the provider
- Replace placeholder data with real achievement information
- Implement filters and progress tracking
- Create AchievementDetailScreen

### Phase 4: Achievement Checking and Edge Function
- Create edge function for checking achievements
- Implement periodic checks for new achievements
- Add notification creation for newly unlocked achievements
- Connect XP system to achievements

## Future Enhancements

- Achievement sharing functionality
- Achievement progress notifications ("You're 80% of the way to...")
- Social achievements (compare with friends)
- Custom achievement badges/icons
- Limited-time achievements for special events

## Conclusion

The achievement system will provide users with clear goals and recognition for their progress in quitting smoking. By aligning with the health recovery system and providing tangible rewards through XP, we create a comprehensive gamification framework that keeps users engaged and motivated throughout their journey.