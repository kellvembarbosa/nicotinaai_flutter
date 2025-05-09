# Achievements Implementation Plan (Revised)

## Overview

This document outlines the revised implementation plan for the Achievements feature in the NicotinaAI Flutter app. Instead of creating new database tables, we'll leverage existing data structures and implement a virtual achievement system that dynamically calculates achievements based on existing user data.

## Achievement Categories

Based on the existing UI in `achievements_screen.dart` and the health recovery system, we'll implement the following achievement categories:

1. **Health** - Achievements related to health improvements
2. **Time** - Achievements for duration without smoking
3. **Savings** - Achievements for money saved
4. **Habits** - Achievements for developing new positive habits

## Achievement Data Structure

Instead of creating database tables, we'll define achievements in code:

```dart
// In lib/features/achievements/models/achievement_definitions.dart
final List<AchievementDefinition> achievementDefinitions = [
  // Time achievements
  AchievementDefinition(
    id: 'time_first_day',
    name: 'First Day',
    description: 'Complete 24 hours without smoking',
    category: 'TIME',
    requirementType: 'DAYS_SMOKE_FREE',
    requirementValue: 1,
    badgeText: '24h',
    iconName: 'calendar_today',
    orderIndex: 1,
    xpReward: 10,
  ),
  AchievementDefinition(
    id: 'time_one_week',
    name: 'One Week',
    description: 'One week without smoking!',
    category: 'TIME',
    requirementType: 'DAYS_SMOKE_FREE',
    requirementValue: 7,
    badgeText: '7 days',
    iconName: 'celebration',
    orderIndex: 2,
    xpReward: 25,
  ),
  // Add more time achievements...
  
  // Health achievements (aligned with Health Recovery system)
  AchievementDefinition(
    id: 'health_taste',
    name: 'Improved Taste',
    description: 'Taste buds have recovered',
    category: 'HEALTH',
    requirementType: 'HEALTH_RECOVERY',
    requirementValue: 'taste', // Reference to recovery_id
    badgeText: 'Taste',
    iconName: 'restaurant',
    orderIndex: 1,
    xpReward: 20,
  ),
  // Add more health achievements...
  
  // Savings achievements
  AchievementDefinition(
    id: 'savings_first_pack',
    name: 'Initial Savings',
    description: 'Save the equivalent of 1 pack of cigarettes',
    category: 'SAVINGS',
    requirementType: 'MONEY_SAVED',
    requirementValue: 1,
    badgeText: 'First Pack',
    iconName: 'savings',
    orderIndex: 1,
    xpReward: 15,
  ),
  // Add more savings achievements...
  
  // Habits achievements
  AchievementDefinition(
    id: 'habits_streak_starter',
    name: 'Streak Starter',
    description: 'Record activity for 3 consecutive days',
    category: 'HABITS',
    requirementType: 'LOGIN_STREAK',
    requirementValue: 3,
    badgeText: 'Streak',
    iconName: 'trending_up',
    orderIndex: 1,
    xpReward: 10,
  ),
  // Add more habits achievements...
];
```

## Data Models

### Achievement Models

```dart
// lib/features/achievements/models/achievement_definition.dart
class AchievementDefinition {
  final String id;
  final String name;
  final String description;
  final String category;
  final String requirementType;
  final dynamic requirementValue; // Can be int or String depending on type
  final String? iconName;
  final String? badgeText;
  final int orderIndex;
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

// lib/features/achievements/models/user_achievement.dart
class UserAchievement {
  final String id; // Same as achievement definition id
  final AchievementDefinition definition;
  final DateTime unlockedAt;
  final bool isViewed;
  final double progress; // Progress from 0.0 to 1.0

  const UserAchievement({
    required this.id,
    required this.definition,
    required this.unlockedAt,
    required this.isViewed,
    required this.progress,
  });
}
```

### Simple Storage for Viewed State

We'll need a minimal table just to track which achievements have been viewed:

```sql
-- Only for tracking viewed state to avoid re-showing notifications
CREATE TABLE IF NOT EXISTS public.viewed_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_id TEXT NOT NULL, -- References the string ID in code
  viewed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

-- Setup RLS
ALTER TABLE public.viewed_achievements ENABLE ROW LEVEL SECURITY;

-- RLS policies
CREATE POLICY "Users can manage their viewed achievements" 
  ON public.viewed_achievements
  USING (auth.uid() = user_id);
```

## Achievement Service Implementation

```dart
// lib/features/achievements/services/achievement_service.dart
class AchievementService {
  final SupabaseClient _supabase;
  final TrackingRepository _trackingRepo;
  final HealthRecoveryRepository _healthRepo;
  
  // Cache viewed achievements
  Set<String> _viewedAchievementIds = {};
  bool _hasLoadedViewedState = false;

  AchievementService(this._supabase, this._trackingRepo, this._healthRepo);

  // Load which achievements have been viewed
  Future<void> loadViewedAchievements() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('viewed_achievements')
          .select('achievement_id')
          .eq('user_id', userId);
      
      _viewedAchievementIds = Set.from((response as List).map((item) => item['achievement_id']));
      _hasLoadedViewedState = true;
    } catch (e) {
      print('Error loading viewed achievements: $e');
    }
  }

  // Mark an achievement as viewed
  Future<void> markAchievementAsViewed(String achievementId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Update local cache
      _viewedAchievementIds.add(achievementId);
      
      // Update database
      await _supabase.from('viewed_achievements').upsert({
        'user_id': userId,
        'achievement_id': achievementId,
        'viewed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error marking achievement as viewed: $e');
    }
  }

  // Check if an achievement has been viewed
  bool isAchievementViewed(String achievementId) {
    return _viewedAchievementIds.contains(achievementId);
  }

  // Get all achievement definitions
  List<AchievementDefinition> getAllAchievementDefinitions() {
    return achievementDefinitions;
  }

  // Get achievement definitions by category
  List<AchievementDefinition> getAchievementDefinitionsByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      return achievementDefinitions;
    }
    return achievementDefinitions
        .where((def) => def.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // Calculate user's progress for all achievements
  Future<List<UserAchievement>> calculateUserAchievements() async {
    // Ensure viewed state is loaded
    if (!_hasLoadedViewedState) {
      await loadViewedAchievements();
    }
    
    // Load user stats and data needed for calculations
    final stats = await _trackingRepo.getUserStats();
    final healthRecoveries = await _healthRepo.getUserHealthRecoveries();
    final cravings = await _trackingRepo.getCravings();
    
    // Calculate days smoke free
    final daysSmokeFreee = stats.lastSmokeDate != null
        ? DateTime.now().difference(stats.lastSmokeDate!).inDays
        : 0;
    
    // Calculate money saved
    final cigarettesPerDay = stats.cigarettesPerDay ?? 0;
    final cigarettesPerPack = stats.cigarettesPerPack ?? 20;
    final packPrice = stats.packPrice ?? 0;
    final cigarettesSaved = daysSmokeFreee * cigarettesPerDay;
    final packsSaved = cigarettesPerPack > 0 ? cigarettesSaved / cigarettesPerPack : 0;
    final moneySaved = packsSaved * packPrice;
    
    // Calculate cravings resisted
    final cravingsResisted = cravings.where((c) => c.wasResisted).length;
    
    // Set of health recovery IDs the user has achieved
    final recoveryIds = healthRecoveries.map((hr) => hr.recoveryId).toSet();
    
    // Calculate each achievement's status
    final userAchievements = <UserAchievement>[];
    
    for (final definition in achievementDefinitions) {
      bool isUnlocked = false;
      double progress = 0.0;
      
      switch (definition.requirementType) {
        case 'DAYS_SMOKE_FREE':
          final requiredDays = definition.requirementValue as int;
          progress = daysSmokeFreee / requiredDays;
          isUnlocked = daysSmokeFreee >= requiredDays;
          break;
          
        case 'MONEY_SAVED':
          final requiredPacks = definition.requirementValue as int;
          progress = packsSaved / requiredPacks;
          isUnlocked = packsSaved >= requiredPacks;
          break;
          
        case 'CRAVINGS_RESISTED':
          final requiredCravings = definition.requirementValue as int;
          progress = cravingsResisted / requiredCravings;
          isUnlocked = cravingsResisted >= requiredCravings;
          break;
          
        case 'HEALTH_RECOVERY':
          // For health recovery, we check if the specific recovery is achieved
          final recoveryId = definition.requirementValue as String;
          isUnlocked = recoveryIds.contains(recoveryId);
          progress = isUnlocked ? 1.0 : 0.0;
          break;
          
        case 'LOGIN_STREAK':
          // TODO: Implement login streak calculation
          final requiredDays = definition.requirementValue as int;
          final streak = 0; // Placeholder, actual implementation needed
          progress = streak / requiredDays;
          isUnlocked = streak >= requiredDays;
          break;
      }
      
      // Clamp progress between 0 and 1
      progress = progress.clamp(0.0, 1.0);
      
      if (isUnlocked || progress > 0) {
        userAchievements.add(UserAchievement(
          id: definition.id,
          definition: definition,
          unlockedAt: isUnlocked ? DateTime.now() : DateTime(9999), // Future date for unlocked = false
          isViewed: isAchievementViewed(definition.id),
          progress: progress,
        ));
      }
    }
    
    // Sort: unlocked first (by unlock date), then by progress
    userAchievements.sort((a, b) {
      if (a.progress == 1.0 && b.progress == 1.0) {
        return a.unlockedAt.compareTo(b.unlockedAt); // Both unlocked, sort by unlock date
      } else if (a.progress == 1.0) {
        return -1; // a is unlocked, comes first
      } else if (b.progress == 1.0) {
        return 1; // b is unlocked, comes first
      } else {
        return b.progress.compareTo(a.progress); // Neither unlocked, sort by progress
      }
    });
    
    return userAchievements;
  }

  // Check for newly unlocked achievements and handle notifications/XP
  Future<List<UserAchievement>> checkForNewAchievements() async {
    final currentAchievements = await calculateUserAchievements();
    final newlyUnlocked = <UserAchievement>[];
    
    for (final achievement in currentAchievements) {
      // If unlocked but not viewed, it might be new
      if (achievement.progress >= 1.0 && !achievement.isViewed) {
        newlyUnlocked.add(achievement);
        
        // Award XP if supported
        try {
          await _supabase.rpc('add_user_xp', {
            'p_user_id': _supabase.auth.currentUser!.id,
            'p_amount': achievement.definition.xpReward,
            'p_source': 'ACHIEVEMENT',
            'p_reference_id': achievement.id
          });
        } catch (e) {
          // Ignore if XP function doesn't exist
          print('Note: XP award failed: $e');
        }
        
        // Create notification if supported
        try {
          await _supabase.from('notifications').insert({
            'user_id': _supabase.auth.currentUser!.id,
            'title': 'Achievement Unlocked!',
            'message': 'You\'ve earned the "${achievement.definition.name}" achievement!',
            'type': 'ACHIEVEMENT',
            'reference_id': achievement.id,
            'is_read': false
          });
        } catch (e) {
          // Ignore if notifications table doesn't exist
          print('Note: Notification creation failed: $e');
        }
      }
    }
    
    return newlyUnlocked;
  }
}
```

## Achievement Provider Implementation

```dart
// lib/features/achievements/providers/achievement_provider.dart
enum AchievementStatus {
  initial,
  loading,
  loaded,
  error
}

class AchievementState {
  final AchievementStatus status;
  final List<AchievementDefinition> allDefinitions;
  final List<UserAchievement> userAchievements;
  final String? errorMessage;
  
  const AchievementState({
    this.status = AchievementStatus.initial,
    this.allDefinitions = const [],
    this.userAchievements = const [],
    this.errorMessage,
  });
  
  AchievementState copyWith({
    AchievementStatus? status,
    List<AchievementDefinition>? allDefinitions,
    List<UserAchievement>? userAchievements,
    String? errorMessage,
  }) {
    return AchievementState(
      status: status ?? this.status,
      allDefinitions: allDefinitions ?? this.allDefinitions,
      userAchievements: userAchievements ?? this.userAchievements,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  // Helper methods for the UI
  List<UserAchievement> getAchievementsByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      return userAchievements;
    }
    return userAchievements.where(
      (a) => a.definition.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }
  
  // Get the number of unlocked achievements
  int get unlockedCount => userAchievements.where((a) => a.progress >= 1.0).length;
  
  // Get the number of in-progress achievements
  int get inProgressCount => userAchievements.where((a) => a.progress > 0 && a.progress < 1.0).length;
  
  // Get the completion percentage
  String get completionPercentage {
    if (allDefinitions.isEmpty) return "0%";
    return "${((unlockedCount / allDefinitions.length) * 100).round()}%";
  }
}

class AchievementProvider extends ChangeNotifier {
  final AchievementService _service;
  AchievementState _state = AchievementState();
  
  AchievementProvider(this._service);
  
  AchievementState get state => _state;
  
  Future<void> loadAchievements() async {
    try {
      _state = _state.copyWith(status: AchievementStatus.loading);
      notifyListeners();
      
      final allDefinitions = _service.getAllAchievementDefinitions();
      final userAchievements = await _service.calculateUserAchievements();
      
      _state = _state.copyWith(
        status: AchievementStatus.loaded,
        allDefinitions: allDefinitions,
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
  
  Future<void> markAchievementAsViewed(String achievementId) async {
    await _service.markAchievementAsViewed(achievementId);
    
    // Update local state
    final updatedAchievements = _state.userAchievements.map((ua) {
      if (ua.id == achievementId) {
        return UserAchievement(
          id: ua.id,
          definition: ua.definition,
          unlockedAt: ua.unlockedAt,
          isViewed: true,
          progress: ua.progress,
        );
      }
      return ua;
    }).toList();
    
    _state = _state.copyWith(userAchievements: updatedAchievements);
    notifyListeners();
  }
  
  Future<void> checkForNewAchievements() async {
    try {
      final newlyUnlocked = await _service.checkForNewAchievements();
      
      if (newlyUnlocked.isNotEmpty) {
        // Refresh achievements list
        await loadAchievements();
      }
    } catch (e) {
      print('Error checking for new achievements: $e');
    }
  }
}
```

## UI Implementation

### Update AchievementsScreen

The existing `achievements_screen.dart` already has most of the UI components needed. We'll update it to connect with our provider:

```dart
class AchievementsScreen extends StatefulWidget {
  static const String routeName = '/achievements';
  
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _categories;
  String _currentCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Load achievements when screen initializes
    Future.microtask(() {
      context.read<AchievementProvider>().loadAchievements();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentCategory = _categories[_tabController.index].toLowerCase();
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final achievementProvider = Provider.of<AchievementProvider>(context);
    final state = achievementProvider.state;
    
    _categories = [
      l10n.achievementCategoryAll,
      l10n.achievementCategoryHealth,
      l10n.achievementCategoryTime,
      l10n.achievementCategorySavings,
      l10n.achievementCategoryHabits
    ];
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: state.status == AchievementStatus.loading 
          ? _buildLoadingIndicator()
          : state.status == AchievementStatus.error
              ? _buildErrorView(state.errorMessage)
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildSliverAppBar(l10n),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildSummarySection(l10n, state),
                          const SizedBox(height: 24),
                          _buildTabBar(),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildProgressTracker(l10n, state),
                          const SizedBox(height: 24),
                          ..._buildAchievementsList(l10n, state),
                        ]),
                      ),
                    ),
                  ],
                ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget _buildErrorView(String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error loading achievements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (errorMessage != null) Text(
            errorMessage,
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<AchievementProvider>().loadAchievements();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Update other build methods to use real data from state...
  // For example, update _buildSummaryContent:
  
  Widget _buildSummaryContent(AppLocalizations l10n, AchievementState state, {Color? textColor}) {
    final textStyle = textColor ?? context.contentColor;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAchievementCountItem('${state.unlockedCount}', l10n.achievementUnlocked, textStyle),
        _buildDivider(context),
        _buildAchievementCountItem('${state.inProgressCount}', l10n.achievementInProgress, textStyle),
        _buildDivider(context),
        _buildAchievementCountItem('${state.completionPercentage}', l10n.achievementCompleted, textStyle),
      ],
    );
  }
  
  // And update _buildAchievementsList:
  
  List<Widget> _buildAchievementsList(AppLocalizations l10n, AchievementState state) {
    final achievements = state.getAchievementsByCategory(_currentCategory);
    
    if (achievements.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'No achievements in this category yet',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ];
    }
    
    return achievements.map((achievement) => 
      _buildEnhancedAchievementItem(
        context,
        achievement.definition.name,
        achievement.definition.description,
        IconData(int.parse('0xe${achievement.definition.iconName}', radix: 16), 
                  fontFamily: 'MaterialIcons'),
        achievement.progress >= 1.0,
        badge: achievement.definition.badgeText,
        progress: achievement.progress < 1.0 ? achievement.progress : 0.0,
        l10n: l10n,
      ),
    ).toList();
  }
  
  // Update other build methods similarly...
}
```

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
    
    // Find the achievement
    final achievement = state.userAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found'),
    );
    
    final isUnlocked = achievement.progress >= 1.0;
    
    // Mark as viewed if unlocked
    if (isUnlocked && !achievement.isViewed) {
      // Use Future.microtask to avoid build-time side effects
      Future.microtask(() {
        achievementProvider.markAchievementAsViewed(achievementId);
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(achievement.definition.name),
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
                achievement.definition.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            
            // Progress section (if not unlocked)
            if (!isUnlocked) _buildProgressSection(context, achievement),
            
            // Requirements
            _buildRequirementSection(context, achievement),
            
            // Reward
            if (achievement.definition.xpReward > 0) 
              _buildRewardSection(context, achievement),
            
            // Tips for achieving (if not unlocked)
            if (!isUnlocked) _buildTipsSection(context, achievement),
          ],
        ),
      ),
    );
  }
  
  // Implementation of the various build methods...
  Widget _buildAchievementHeader(BuildContext context, UserAchievement achievement, bool isUnlocked) {
    // Implementation details...
    return Container(); // Placeholder
  }
  
  Widget _buildProgressSection(BuildContext context, UserAchievement achievement) {
    // Implementation details...
    return Container(); // Placeholder
  }
  
  Widget _buildRequirementSection(BuildContext context, UserAchievement achievement) {
    // Implementation details...
    return Container(); // Placeholder
  }
  
  Widget _buildRewardSection(BuildContext context, UserAchievement achievement) {
    // Implementation details...
    return Container(); // Placeholder
  }
  
  Widget _buildTipsSection(BuildContext context, UserAchievement achievement) {
    // Implementation details...
    return Container(); // Placeholder
  }
}
```

## Integration with Health Recovery System

The achievement system will be directly integrated with the health recovery system:

1. Health achievements will be calculated based on user health recoveries
2. Both systems will use the same progress tracking mechanisms
3. Visual styles will be consistent between both features

Instead of a dedicated edge function, we'll check for achievements:
1. When the app starts
2. After a smoking record is added/updated
3. After a craving is recorded
4. After a health recovery is achieved
5. Periodically (e.g., daily) to detect time-based achievements

## Implementation Phases

### Phase 1: Models and In-Memory Data Structure
- Create achievement models and definitions
- Design a minimal viewed_achievements table

### Phase 2: Service and Provider
- Implement AchievementService for calculations
- Create AchievementProvider for state management
- Add methods for tracking progress and achievement status

### Phase 3: UI Updates
- Connect existing AchievementsScreen to the provider
- Replace placeholder data with real achievement information
- Create AchievementDetailScreen

### Phase 4: Integration Points
- Add achievement checks to key app events
- Connect with notification system
- Link to XP system (if available)

## Benefits of This Approach

1. **Simplicity** - No need for complex database schema or migrations
2. **Low Storage Overhead** - Only storing viewed state, not duplicating data
3. **Real-time Accuracy** - Achievements always calculated from latest data
4. **Flexibility** - Easy to add, modify, or remove achievements
5. **Performance** - Calculations happen client-side, reducing server load

## Future Enhancements

- Cache calculated achievement states for better performance
- Add offline support for achievement tracking
- Add social sharing for unlocked achievements
- Implement comparative achievements (e.g., "Top 10% of users")

## Conclusion

This revised approach leverages existing data structures to create a dynamic achievement system without the overhead of additional database tables. By calculating achievements in real-time based on user data, we ensure accuracy while maintaining simplicity and flexibility.