import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_state.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/currency_utils.dart';
import 'package:nicotinaai_flutter/widgets/skeleton_loading.dart';

class DashboardScreenWithBloc extends StatelessWidget {
  const DashboardScreenWithBloc({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TrackingBloc>().add(RefreshAllData(forceRefresh: true));
            },
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: BlocConsumer<TrackingBloc, TrackingState>(
        listener: (context, state) {
          // Show error messages if any
          if (state.hasError && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<TrackingBloc>().add(RefreshAllData(forceRefresh: true));
              // Wait a bit to show refresh indicator
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: _buildContent(context, state),
          );
        },
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, TrackingState state) {
    // Show loading screen on initial load
    if (state.isInitial || (state.isLoading && state.userStats == null)) {
      return _buildLoadingScreen();
    }
    
    // Show error if there's an error and no data
    if (state.hasError && state.userStats == null) {
      return _buildErrorScreen(context, state.errorMessage ?? 'Unknown error');
    }
    
    // Show dashboard with loading indicators where needed
    return _buildDashboard(context, state);
  }
  
  Widget _buildLoadingScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SkeletonLoading(
          width: double.infinity,
          height: 24,
          borderRadius: 4,
        ),
        const SizedBox(height: 24),
        
        // Money saved card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoading(
                width: 120,
                height: 16,
                borderRadius: 4,
              ),
              const SizedBox(height: 8),
              SkeletonLoading(
                width: 200,
                height: 32,
                borderRadius: 4,
              ),
              const SizedBox(height: 16),
              SkeletonLoading(
                width: double.infinity,
                height: 8,
                borderRadius: 4,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonLoading(
                    width: 80,
                    height: 14,
                    borderRadius: 4,
                  ),
                  SkeletonLoading(
                    width: 80,
                    height: 14,
                    borderRadius: 4,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: List.generate(4, (_) => _buildStatCardSkeleton()),
        ),
      ],
    );
  }
  
  Widget _buildErrorScreen(BuildContext context, String errorMessage) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingData,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TrackingBloc>().add(RefreshAllData(forceRefresh: true));
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.tryAgain),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDashboard(BuildContext context, TrackingState state) {
    final l10n = AppLocalizations.of(context)!;
    final userStats = state.userStats;
    
    if (userStats == null) {
      return _buildLoadingScreen();
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.yourProgress,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // Money saved card
        _buildMoneySavedCard(context, userStats, state.isStatsLoading),
        const SizedBox(height: 16),
        
        // Stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(
              context,
              l10n.smokeFreeTime,
              _formatDuration(userStats.smokeFreeTime),
              Icons.timer_outlined,
              Colors.green,
              isLoading: state.isStatsLoading,
            ),
            _buildStatCard(
              context,
              l10n.cigarettesNotSmoked,
              userStats.cigarettesAvoided.toString(),
              Icons.smoke_free,
              Colors.blue,
              isLoading: state.isStatsLoading,
            ),
            _buildStatCard(
              context,
              l10n.cravingsResisted,
              state.cravingsResisted.toString(),
              Icons.sentiment_satisfied_outlined,
              Colors.orange,
              isLoading: state.isCravingsLoading,
            ),
            _buildStatCard(
              context,
              l10n.daysSmokeFree,
              '${userStats.smokeFreeStreak}',
              Icons.calendar_today_outlined,
              Colors.purple,
              isLoading: state.isStatsLoading,
            ),
          ],
        ),
        
        // Health Recoveries section (extra BLoC feature)
        if (state.userHealthRecoveries.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.healthRecoveries,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${state.achievedRecoveries.length}/${state.userHealthRecoveries.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.healthRecoveryProgress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ],
    );
  }
  
  Widget _buildMoneySavedCard(BuildContext context, dynamic userStats, bool isLoading) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final formattedMoneySaved = CurrencyUtils.format(userStats.moneySaved);
    final formattedPercentage = '${(userStats.moneySavedPercentage * 100).toInt()}%';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading 
            ? _buildMoneySavedCardSkeleton()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.moneySaved,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedMoneySaved,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: userStats.moneySavedPercentage,
                      backgroundColor: colorScheme.primary.withOpacity(0.2),
                      color: colorScheme.primary,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0%',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        formattedPercentage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '100%',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    {bool isLoading = false}
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? _buildStatCardSkeletonContent()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  Widget _buildStatCardSkeleton() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildStatCardSkeletonContent(),
      ),
    );
  }
  
  Widget _buildStatCardSkeletonContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoading(
          width: 36,
          height: 36,
          borderRadius: 8,
        ),
        const SizedBox(height: 12),
        SkeletonLoading(
          width: 80,
          height: 14,
          borderRadius: 4,
        ),
        const SizedBox(height: 8),
        SkeletonLoading(
          width: 60,
          height: 24,
          borderRadius: 4,
        ),
      ],
    );
  }
  
  Widget _buildMoneySavedCardSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoading(
          width: 120,
          height: 16,
          borderRadius: 4,
        ),
        const SizedBox(height: 8),
        SkeletonLoading(
          width: 200,
          height: 32,
          borderRadius: 4,
        ),
        const SizedBox(height: 16),
        SkeletonLoading(
          width: double.infinity,
          height: 8,
          borderRadius: 4,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonLoading(
              width: 40,
              height: 14,
              borderRadius: 4,
            ),
            SkeletonLoading(
              width: 40,
              height: 14,
              borderRadius: 4,
            ),
            SkeletonLoading(
              width: 40,
              height: 14,
              borderRadius: 4,
            ),
          ],
        ),
      ],
    );
  }
  
  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    if (days > 0) {
      return '$days d $hours h';
    } else if (hours > 0) {
      return '$hours h $minutes m';
    } else {
      return '$minutes m';
    }
  }
}