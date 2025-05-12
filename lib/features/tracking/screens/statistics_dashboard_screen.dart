import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_bloc.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_event.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_state.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_state.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/tracking/models/craving.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/widgets/statistics_skeleton.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatisticsDashboardScreen extends StatefulWidget {
  static const String routeName = '/statistics-dashboard';
  
  const StatisticsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsDashboardScreen> createState() => _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize tracking data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingBloc>().add(InitializeTracking());
      
      // Garante que o CurrencyBloc também esteja inicializado
      final currencyState = context.read<CurrencyBloc>().state;
      if (!currencyState.isInitialized) {
        context.read<CurrencyBloc>().add(InitializeCurrency());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.dashboard,
          style: context.titleStyle,
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppRoutes.main.path);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TrackingBloc>().add(RefreshAllData(forceRefresh: true));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.primaryColor,
          unselectedLabelColor: context.subtitleColor,
          indicatorColor: context.primaryColor,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Savings'),
            Tab(text: 'Cravings'),
            Tab(text: 'Health'),
          ],
        ),
      ),
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const StatisticsDashboardSkeleton();
          }
          
          if (state.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TrackingBloc>().add(ClearError());
                      context.read<TrackingBloc>().add(InitializeTracking());
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<TrackingBloc>().add(RefreshAllData(forceRefresh: true));
              // Esperar pelo menos 500ms para dar feedback visual ao usuário
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, state.userStats),
                _buildSavingsTab(context, state.userStats),
                _buildCravingsTab(context, state.cravings),
                _buildHealthTab(context, state.userStats, state.userHealthRecoveries),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, UserStats? stats) {
    final l10n = AppLocalizations.of(context);
    
    // Use BlocBuilder para o CurrencyBloc para atualizar quando a moeda mudar
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, currencyState) {
        // Debug para verificar qual moeda está sendo usada
        if (stats?.moneySaved != null) {
          debugPrint('🔄 Moeda atual: ${currencyState.currencySymbol} (${currencyState.currencyCode}) - Economia: ${stats!.moneySaved} centavos');
        }
        
        if (stats == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No stats available yet. Start tracking to see your progress!'),
            ),
          );
        }
        
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Key stats
            const SizedBox(height: 16),
            _buildSectionHeader(context, l10n.achievementCurrentProgress),
            const SizedBox(height: 16),
            
            // Current streak card
            _buildStatsCard(
              context,
              l10n.homeDaysWithoutSmoking(stats.currentStreakDays),
              stats.currentStreakDays.toString(),
              Icons.local_fire_department,
              Colors.orange,
              suffix: l10n.days,
            ),
            
            const SizedBox(height: 16),
            
            // Dual stats cards
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    context,
                    l10n.homeCravingsResisted,
                    stats.cravingsResisted.toString(),
                    Icons.smoke_free,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    context,
                    l10n.cigarettesPerDay,
                    (stats.cigarettesPerDay ?? 0).toString(),
                    Icons.check_circle_outline,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // More stats
            _buildSectionHeader(context, l10n.homeNextMilestone),
            const SizedBox(height: 16),
            
            _buildStatsCard(
              context,
              l10n.homeMinutesLifeGained,
              '${stats.cigarettesAvoided * 7}',
              Icons.favorite,
              Colors.red,
              suffix: 'minutes',
            ),
            
            const SizedBox(height: 16),
            
            // Money savings
            _buildStatsCard(
              context,
              l10n.potentialMonthlySavings,
              context.read<CurrencyBloc>().format(stats.moneySaved),
              Icons.account_balance_wallet,
              Colors.blue,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSavingsTab(BuildContext context, UserStats? stats) {
    final l10n = AppLocalizations.of(context);
    
    // Use BlocBuilder para o CurrencyBloc para atualizar quando a moeda mudar
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, currencyState) {
        // Debug para verificar qual moeda está sendo usada
        if (stats?.moneySaved != null) {
          debugPrint('🔄 Moeda atual: ${currencyState.currencySymbol} (${currencyState.currencyCode}) - Economia: ${stats!.moneySaved} centavos');
        }
        
        if (stats == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No savings data available yet.'),
            ),
          );
        }

        // Generate some mock data for the chart
        final days = stats.currentStreakDays > 0 ? stats.currentStreakDays : 7;
        final averageDailySavings = stats.moneySaved / (days > 0 ? days : 1);
        
        final List<FlSpot> savingsSpots = List.generate(
          days > 0 ? days : 7,
          (index) => FlSpot(index.toDouble(), (index + 1) * averageDailySavings / 100),
        );
        
        final currencyBloc = context.read<CurrencyBloc>();
        
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader(context, l10n.potentialMonthlySavings),
            const SizedBox(height: 16),
            
            // Money saved card
            _buildStatsCard(
              context,
              l10n.savingsCalculator,
              currencyBloc.format(stats.moneySaved),
              Icons.account_balance_wallet,
              Colors.blue,
            ),
            
            const SizedBox(height: 24),
            
            // Projected savings
            _buildSectionHeader(context, l10n.potentialMonthlySavings),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    context,
                    'Month',
                    currencyBloc.format(stats.moneySaved * 30 ~/ (days > 0 ? days : 30)),
                    Icons.calendar_month,
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    context,
                    'Year',
                    currencyBloc.format(stats.moneySaved * 365 ~/ (days > 0 ? days : 30)),
                    Icons.cake,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Savings chart
            _buildSectionHeader(context, l10n.achievementCategorySavings),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 250,
              child: Container(
                padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 7 == 0 || value == days - 1) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${value.toInt() + 1}d',
                                style: TextStyle(
                                  color: context.subtitleColor,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '${(value * 100).toInt()}',
                              style: TextStyle(
                                color: context.subtitleColor,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: savingsSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withAlpha(26),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: 16),
            Text(
              l10n.savingsCalculatorDescription,
              style: TextStyle(
                color: context.subtitleColor,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCravingsTab(BuildContext context, List<Craving> cravings) {
    final l10n = AppLocalizations.of(context);
    
    if (cravings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(l10n.emptyNotificationsDescription),
        ),
      );
    }
    
    // Calculate stats
    int resistedCount = 0;
    int smokedCount = 0;
    int alternativeCount = 0;
    
    for (final craving in cravings) {
      if (craving.outcome == CravingOutcome.resisted) {
        resistedCount++;
      } else if (craving.outcome == CravingOutcome.smoked) {
        smokedCount++;
      } else if (craving.outcome == CravingOutcome.alternative) {
        alternativeCount++;
      }
    }
    
    final totalCravings = resistedCount + smokedCount + alternativeCount;
    final resistedPercentage = totalCravings > 0 ? (resistedCount / totalCravings * 100).round() : 0;
    
    // Data will be directly used in the pie chart sections
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader(context, l10n.homeCravingsResisted),
        const SizedBox(height: 16),
        
        // Success rate card
        _buildStatsCard(
          context,
          l10n.achievementUnlocked,
          '$resistedPercentage%',
          Icons.trending_up,
          Colors.blue,
          subtitle: l10n.achievementCompleted,
        ),
        
        const SizedBox(height: 16),
        
        // Cravings stats
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                context,
                'Resisted',
                resistedCount.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                context,
                'Total Cravings',
                totalCravings.toString(),
                Icons.analytics,
                Colors.purple,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Cravings chart
        _buildSectionHeader(context, 'Craving Outcomes'),
        const SizedBox(height: 16),
        
        SizedBox(
          height: 250,
          child: Container(
            padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: resistedCount.toDouble(),
                  title: '$resistedCount',
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: smokedCount.toDouble(),
                  title: '$smokedCount',
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.blue,
                  value: alternativeCount.toDouble(),
                  title: '$alternativeCount',
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 0,
            ),
          ),
        )),
        
        const SizedBox(height: 16),
        
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(context, l10n.yes, Colors.green),
            const SizedBox(width: 24),
            _buildLegendItem(context, l10n.no, Colors.red),
            const SizedBox(width: 24),
            _buildLegendItem(context, 'Alternative', Colors.blue),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Recent cravings
        _buildSectionHeader(context, 'Recent Cravings'),
        const SizedBox(height: 16),
        
        ...cravings.take(5).map((craving) => _buildCravingListItem(context, craving)),
      ],
    );
  }

  Widget _buildHealthTab(BuildContext context, UserStats? stats, List<UserHealthRecovery> healthRecoveries) {
    final l10n = AppLocalizations.of(context);
    
    if (stats == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(l10n.noRecoveriesFound),
        ),
      );
    }
    
    final daysSmokeFree = stats.currentStreakDays;
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader(context, l10n.homeHealthRecovery),
        const SizedBox(height: 16),
        
        // Days smoke free
        _buildStatsCard(
          context,
          l10n.daysSmokeFree(daysSmokeFree),
          daysSmokeFree.toString(),
          Icons.health_and_safety,
          Colors.teal,
          suffix: l10n.days,
        ),
        
        const SizedBox(height: 24),
        
        // Health indicators
        _buildSectionHeader(context, 'Health Indicators'),
        const SizedBox(height: 16),
        
        // Health stats
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                context,
                l10n.homeMinutesLifeGained,
                '${stats.cigarettesAvoided * 7}',
                Icons.favorite,
                Colors.red,
                suffix: 'minutes',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                context,
                'Breath capacity',
                '${_calculateBreathCapacity(daysSmokeFree)}%',
                Icons.air,
                Colors.blue,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Health recovery timeline
        healthRecoveries.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Recovery Timeline'),
                  const SizedBox(height: 16),
                  ...healthRecoveries
                      .take(5)
                      .map((recovery) => _buildHealthRecoveryItem(context, recovery, daysSmokeFree)),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(l10n.noRecentRecoveries),
                ),
              ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.primaryColor,
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_upward,
                color: Colors.green,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.contentColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                  child: Text(
                    suffix,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.subtitleColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: context.subtitleColor,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: context.subtitleColor.withAlpha(179),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCravingListItem(BuildContext context, Craving craving) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    final outcomeColors = [Colors.green, Colors.red, Colors.blue];
    final outcomeIcons = [Icons.check_circle, Icons.smoking_rooms, Icons.swap_horiz];
    final outcomeTexts = ['Resisted', 'Smoked', 'Alternative'];
    
    // Convert CravingOutcome enum to int index
    int outcomeIndex = 0; // Default to resisted
    if (craving.outcome == CravingOutcome.resisted) {
      outcomeIndex = 0;
    } else if (craving.outcome == CravingOutcome.smoked) {
      outcomeIndex = 1;
    } else if (craving.outcome == CravingOutcome.alternative) {
      outcomeIndex = 2;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: outcomeColors[outcomeIndex].withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: outcomeColors[outcomeIndex].withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              outcomeIcons[outcomeIndex],
              color: outcomeColors[outcomeIndex],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getCravingIntensityText(craving.intensity),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    Text(
                      outcomeTexts[outcomeIndex],
                      style: TextStyle(
                        color: outcomeColors[outcomeIndex],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(craving.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.subtitleColor,
                  ),
                ),
                if (craving.location != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    craving.location!,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.subtitleColor.withAlpha(179),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecoveryItem(BuildContext context, UserHealthRecovery recovery, int daysSmokeFree) {
    final l10n = AppLocalizations.of(context);
    final bool isAchieved = recovery.isAchieved;
    final Color statusColor = isAchieved ? Colors.green : Colors.orange;
    
    // Get the recovery details from TrackingBloc state
    final trackingState = context.read<TrackingBloc>().state;
    final recoveryDetails = trackingState.healthRecoveries
        .firstWhere((r) => r.id == recovery.recoveryId,
            orElse: () => HealthRecovery(
              id: recovery.recoveryId,
              name: 'Unknown Recovery',
              description: '',
              daysToAchieve: recovery.daysToAchieve,
            ));
    
    // Calculate percentage
    int daysRequired = recovery.daysToAchieve;
    double percentage = daysSmokeFree / daysRequired;
    if (percentage > 1) percentage = 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recoveryDetails.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAchieved 
                          ? l10n.achievedOn(recovery.achievedAt)
                          : l10n.daysToAchieve(daysRequired),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAchieved ? l10n.achieved : l10n.progress,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isAchieved) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.withAlpha(51),
                color: statusColor,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.daysRemaining((daysRequired - daysSmokeFree).clamp(0, daysRequired)),
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.subtitleColor,
          ),
        ),
      ],
    );
  }

  String _getCravingIntensityText(CravingIntensity intensity) {
    if (intensity == CravingIntensity.low) {
      return 'Low Intensity';
    } else if (intensity == CravingIntensity.moderate) {
      return 'Moderate Intensity';
    } else if (intensity == CravingIntensity.high) {
      return 'High Intensity';
    } else {
      return 'Very High Intensity';
    }
  }

  int _calculateBreathCapacity(int days) {
    if (days <= 0) return 10;
    if (days < 7) return 15;
    if (days < 14) return 25;
    if (days < 30) return 35;
    if (days < 90) return 50;
    if (days < 180) return 75;
    return 90;
  }
}