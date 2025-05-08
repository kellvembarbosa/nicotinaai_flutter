import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/add_craving_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/add_smoking_log_screen.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize tracking data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TrackingProvider>().refreshAll();
            },
          ),
        ],
      ),
      body: Consumer<TrackingProvider>(
        builder: (context, provider, child) {
          final state = provider.state;
          
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
                      provider.clearError();
                      provider.initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => provider.refreshAll(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Stats Cards
                _buildStatsGrid(context, state.userStats),
                
                const SizedBox(height: 24),
                
                // Recent Activity
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Recent Smoking Logs
                _buildRecentSmokingLogs(context, state.smokingLogs),
                
                const SizedBox(height: 16),
                
                // Recent Cravings
                _buildRecentCravings(context, state.cravings),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'logCraving',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCravingScreen()),
              );
            },
            icon: const Icon(Icons.sentiment_dissatisfied),
            label: const Text('Log Craving'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'logSmoke',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddSmokingLogScreen()),
              );
            },
            icon: const Icon(Icons.smoking_rooms),
            label: const Text('Log Smoking'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, UserStats? stats) {
    if (stats == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No stats available yet. Start tracking to see your progress!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _statCard(
          context,
          'Current Streak',
          '${stats.currentStreakDays} days',
          Icons.local_fire_department,
          Colors.orange,
        ),
        _statCard(
          context,
          'Cigarettes Avoided',
          stats.cigarettesAvoided.toString(),
          Icons.smoke_free,
          Colors.green,
        ),
        _statCard(
          context,
          'Money Saved',
          stats.formattedMoneySaved,
          Icons.account_balance_wallet,
          Colors.blue,
          subtitle: 'Based on ${stats.cravingsResisted} cravings resisted',
        ),
        _statCard(
          context,
          'Cravings Resisted',
          stats.cravingsResisted.toString(),
          Icons.fitness_center,
          Colors.purple,
          subtitle: '+${stats.cravingsResisted * 5} XP earned',
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, String title, String value, 
      IconData icon, Color color, {String? subtitle}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: color.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSmokingLogs(BuildContext context, List smokingLogs) {
    if (smokingLogs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No smoking logs yet.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Recent Smoking Logs'),
            trailing: TextButton(
              onPressed: () {
                // Navigate to detailed smoking logs screen
              },
              child: const Text('View All'),
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: smokingLogs.length > 3 ? 3 : smokingLogs.length,
            itemBuilder: (context, index) {
              final log = smokingLogs[index];
              final dateFormat = DateFormat('MMM d, h:mm a');
              
              return ListTile(
                leading: const Icon(Icons.smoking_rooms),
                title: Text('${log.quantity} ${_getProductTypeText(log.productType)}'),
                subtitle: Text(dateFormat.format(log.timestamp)),
                trailing: log.location != null ? Text(log.location!) : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCravings(BuildContext context, List cravings) {
    if (cravings.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No cravings logged yet.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Recent Cravings'),
            trailing: TextButton(
              onPressed: () {
                // Navigate to detailed cravings screen
              },
              child: const Text('View All'),
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cravings.length > 3 ? 3 : cravings.length,
            itemBuilder: (context, index) {
              final craving = cravings[index];
              final dateFormat = DateFormat('MMM d, h:mm a');
              
              return ListTile(
                leading: Icon(
                  _getCravingOutcomeIcon(craving.outcome),
                  color: _getCravingOutcomeColor(craving.outcome),
                ),
                title: Text(_getCravingIntensityText(craving.intensity)),
                subtitle: Text(dateFormat.format(craving.timestamp)),
                trailing: Text(_getCravingOutcomeText(craving.outcome)),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getProductTypeText(productType) {
    switch (productType) {
      case 0: // ProductType.cigaretteOnly
        return 'Cigarette';
      case 1: // ProductType.vapeOnly
        return 'Vape';
      case 2: // ProductType.both
        return 'Cigarette & Vape';
      default:
        return 'Unknown';
    }
  }

  String _getCravingIntensityText(intensity) {
    switch (intensity) {
      case 0: // CravingIntensity.low
        return 'Low Intensity';
      case 1: // CravingIntensity.moderate
        return 'Moderate Intensity';
      case 2: // CravingIntensity.high
        return 'High Intensity';
      case 3: // CravingIntensity.veryHigh
        return 'Very High Intensity';
      default:
        return 'Unknown Intensity';
    }
  }

  String _getCravingOutcomeText(outcome) {
    switch (outcome) {
      case 0: // CravingOutcome.resisted
        return 'Resisted';
      case 1: // CravingOutcome.smoked
        return 'Smoked';
      case 2: // CravingOutcome.alternative
        return 'Alternative';
      default:
        return 'Unknown';
    }
  }

  IconData _getCravingOutcomeIcon(outcome) {
    switch (outcome) {
      case 0: // CravingOutcome.resisted
        return Icons.check_circle;
      case 1: // CravingOutcome.smoked
        return Icons.smoking_rooms;
      case 2: // CravingOutcome.alternative
        return Icons.swap_horiz;
      default:
        return Icons.help;
    }
  }

  Color _getCravingOutcomeColor(outcome) {
    switch (outcome) {
      case 0: // CravingOutcome.resisted
        return Colors.green;
      case 1: // CravingOutcome.smoked
        return Colors.red;
      case 2: // CravingOutcome.alternative
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}