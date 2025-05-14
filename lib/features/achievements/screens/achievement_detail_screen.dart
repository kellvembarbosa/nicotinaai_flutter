import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_bloc.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_event.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_state.dart';
import 'package:nicotinaai_flutter/services/feedback_trigger_service.dart';

import '../models/user_achievement.dart';
import '../models/achievement_definition.dart';

class AchievementDetailScreen extends StatefulWidget {
  static const String routeName = '/achievement-detail';
  final String achievementId;
  
  const AchievementDetailScreen({required this.achievementId, super.key});
  
  @override
  State<AchievementDetailScreen> createState() => _AchievementDetailScreenState();
}

class _AchievementDetailScreenState extends State<AchievementDetailScreen> {
  // Feedback trigger service instance
  final FeedbackTriggerService _feedbackService = FeedbackTriggerService();
  
  @override
  void initState() {
    super.initState();
    
    // Track screen visit for feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _feedbackService.trackScreenVisit();
    });
  }
  
  // Check if feedback should be shown
  Future<void> _checkForFeedback() async {
    if (mounted) {
      await _feedbackService.checkAndTriggerFeedback(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        // Find the achievement
        final achievement = state.getAchievementById(widget.achievementId);
        
        if (achievement == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.achievements),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Text('Achievement not found'),
            ),
          );
        }
        
        final isUnlocked = achievement.isUnlocked;
        
        // Mark as viewed if unlocked
        if (isUnlocked && !achievement.isViewed) {
          // Use addPostFrameCallback to avoid build-time side effects
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<AchievementBloc>().add(MarkAchievementAsViewed(widget.achievementId));
              
              // Check for feedback after achievement is viewed
              _checkForFeedback();
            }
          });
        }
        
        return Scaffold(
          backgroundColor: context.backgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, achievement, l10n),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAchievementCard(context, achievement, l10n),
                    _buildProgressSection(context, achievement, l10n),
                    _buildRequirementSection(context, achievement, l10n),
                    if (achievement.definition.xpReward > 0) 
                      _buildRewardSection(context, achievement, l10n),
                    if (!isUnlocked) 
                      _buildTipsSection(context, achievement, l10n),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSliverAppBar(BuildContext context, UserAchievement achievement, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: context.isDarkMode 
          ? Colors.black.withOpacity(0.8) 
          : context.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(), // Use context.pop for GoRouter
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          achievement.definition.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: achievement.isUnlocked 
                  ? [
                      context.primaryColor.withOpacity(0.8),
                      context.primaryColor,
                    ]
                  : [
                      Colors.grey.withOpacity(0.7),
                      Colors.grey,
                    ],
            ),
          ),
          child: Center(
            child: _buildHeroIcon(context, achievement),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeroIcon(BuildContext context, UserAchievement achievement) {
    // Convert string icon name to IconData
    IconData getIconData(String? iconName) {
      if (iconName == null) return Icons.emoji_events;
      
      // Map icon names to Flutter's Icons class constants
      switch (iconName) {
        case 'calendar_today': return Icons.calendar_today;
        case 'celebration': return Icons.celebration;
        case 'calendar_month': return Icons.calendar_month;
        case 'emoji_events': return Icons.emoji_events;
        case 'military_tech': return Icons.military_tech;
        case 'workspace_premium': return Icons.workspace_premium;
        case 'verified': return Icons.verified;
        case 'bloodtype': return Icons.bloodtype;
        case 'air_purifier_gen': return Icons.air; // Using Icons.air as fallback
        case 'restaurant': return Icons.restaurant;
        case 'air': return Icons.air;
        case 'science': return Icons.science;
        case 'air_sharp': return Icons.air_sharp;
        case 'favorite': return Icons.favorite;
        case 'healing': return Icons.healing;
        case 'air_rounded': return Icons.air_rounded;
        case 'favorite_border': return Icons.favorite_border;
        case 'savings': return Icons.savings;
        case 'attach_money': return Icons.attach_money;
        case 'monetization_on': return Icons.monetization_on;
        case 'savings_outlined': return Icons.savings_outlined;
        case 'account_balance': return Icons.account_balance;
        case 'trending_up': return Icons.trending_up;
        case 'auto_graph': return Icons.auto_graph;
        case 'published_with_changes': return Icons.published_with_changes;
        case 'fitness_center': return Icons.fitness_center;
        case 'psychology': return Icons.psychology;
        case 'directions_run': return Icons.directions_run;
        default: return Icons.emoji_events; // Fallback icon
      }
    }
    
    final iconData = getIconData(achievement.definition.iconName);
    final isUnlocked = achievement.isUnlocked;
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUnlocked
            ? LinearGradient(
                colors: [
                  Colors.amber.shade300,
                  Colors.amber.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isUnlocked ? null : Colors.grey.shade400,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        iconData,
        size: 60,
        color: Colors.white,
      ),
    );
  }
  
  Widget _buildAchievementCard(BuildContext context, UserAchievement achievement, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.isDarkMode
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(achievement.definition.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getCategoryColor(achievement.definition.category).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getCategoryName(achievement.definition.category, l10n),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(achievement.definition.category),
                    ),
                  ),
                ),
                if (achievement.isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      l10n.achieved,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              achievement.definition.description,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: context.contentColor,
              ),
            ),
            if (achievement.isUnlocked) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event_available, 
                      size: 16, 
                      color: context.subtitleColor),
                  const SizedBox(width: 8),
                  Text(
                    l10n.achievedOn(achievement.unlockedAt),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: context.subtitleColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressSection(BuildContext context, UserAchievement achievement, AppLocalizations l10n) {
    if (achievement.isUnlocked) {
      return const SizedBox.shrink(); // Don't show progress for unlocked achievements
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.progress,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.contentColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressBar(context, achievement.progress),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.percentCompleted((achievement.progress * 100).toInt()),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.subtitleColor,
                  ),
                ),
                _buildRequirementText(context, achievement, l10n),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressBar(BuildContext context, double value) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.primaryColor.withOpacity(0.8),
                    context.primaryColor,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: context.primaryColor.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRequirementText(BuildContext context, UserAchievement achievement, AppLocalizations l10n) {
    final requirementType = achievement.definition.requirementType;
    final requirementValue = achievement.definition.requirementValue;
    
    switch (requirementType) {
      case 'DAYS_SMOKE_FREE':
        return Text(
          l10n.daysToAchieve(requirementValue as int),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: context.subtitleColor,
          ),
        );
      case 'HEALTH_RECOVERY':
        return Text(
          'Health recovery needed',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: context.subtitleColor,
          ),
        );
      case 'MONEY_SAVED':
        return Text(
          '${requirementValue} packs saved',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: context.subtitleColor,
          ),
        );
      case 'CRAVINGS_RESISTED':
        return Text(
          '${requirementValue} cravings resisted',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: context.subtitleColor,
          ),
        );
      case 'LOGIN_STREAK':
        return Text(
          '${requirementValue} day streak',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: context.subtitleColor,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildRequirementSection(BuildContext context, UserAchievement achievement, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Requirements',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.contentColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildRequirementDetails(context, achievement, l10n),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRequirementDetails(BuildContext context, UserAchievement achievement, AppLocalizations l10n) {
    final requirementType = achievement.definition.requirementType;
    final requirementValue = achievement.definition.requirementValue;
    
    IconData iconData;
    String title;
    String description;
    
    switch (requirementType) {
      case 'DAYS_SMOKE_FREE':
        iconData = Icons.calendar_today;
        title = 'Days Without Smoking';
        description = 'Reach ${requirementValue} days without smoking';
        break;
      case 'HEALTH_RECOVERY':
        iconData = Icons.favorite;
        title = 'Health Recovery';
        description = 'Achieve ${requirementValue} health milestone';
        break;
      case 'MONEY_SAVED':
        iconData = Icons.savings;
        title = 'Money Saved';
        description = 'Save the equivalent of ${requirementValue} packs of cigarettes';
        break;
      case 'CRAVINGS_RESISTED':
        iconData = Icons.fitness_center;
        title = 'Cravings Resisted';
        description = 'Successfully resist ${requirementValue} cravings';
        break;
      case 'LOGIN_STREAK':
        iconData = Icons.trending_up;
        title = 'Login Streak';
        description = 'Log in for ${requirementValue} consecutive days';
        break;
      default:
        iconData = Icons.emoji_events;
        title = 'Special Achievement';
        description = 'Complete a special task';
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            size: 24,
            color: context.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.contentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: context.subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRewardSection(BuildContext context, UserAchievement achievement, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rewards',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.contentColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade300,
                        Colors.amber.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stars,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'XP Points',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.contentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${achievement.definition.xpReward} XP for unlocking this achievement',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: context.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTipsSection(BuildContext context, UserAchievement achievement, AppLocalizations l10n) {
    String tipText = _getTipText(achievement.definition);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                Text(
                  'Tips to Unlock',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.contentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tipText,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: context.contentColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.keepGoing,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getTipText(AchievementDefinition definition) {
    switch (definition.requirementType) {
      case 'DAYS_SMOKE_FREE':
        return 'Stay committed to your smoke-free journey. Remember that every day without smoking is an achievement in itself. Try to find activities to replace smoking habits, such as exercise, meditation, or a new hobby.';
      case 'HEALTH_RECOVERY':
        return 'Your body is constantly working to repair itself. Stay consistent with your smoke-free journey, and you\'ll notice health improvements over time. Being aware of these changes can help motivate you to continue.';
      case 'MONEY_SAVED':
        return 'Keep track of the money you\'re saving by not buying cigarettes. Consider setting aside this money for something special or a reward for yourself.';
      case 'CRAVINGS_RESISTED':
        return 'When you feel a craving, use the app to register it instead of smoking. Try the 4D\'s method: Delay, Deep breathe, Drink water, and Do something else.';
      case 'LOGIN_STREAK':
        return 'Make it a habit to open the app daily to track your progress. Setting a regular time each day for this can help maintain your streak.';
      default:
        return 'Keep making progress in your journey and you\'ll unlock this achievement soon!';
    }
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'TIME':
        return Colors.blue;
      case 'HEALTH':
        return Colors.green;
      case 'SAVINGS':
        return Colors.amber.shade700;
      case 'HABITS':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  String _getCategoryName(String category, AppLocalizations l10n) {
    switch (category.toUpperCase()) {
      case 'TIME':
        return l10n.achievementCategoryTime;
      case 'HEALTH':
        return l10n.achievementCategoryHealth;
      case 'SAVINGS':
        return l10n.achievementCategorySavings;
      case 'HABITS':
        return l10n.achievementCategoryHabits;
      default:
        return category;
    }
  }
}