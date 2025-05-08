import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/widgets/health_recovery_widget.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/health_recovery_utils.dart';

class HealthRecoveryScreen extends StatefulWidget {
  static const String routeName = '/health-recovery';

  const HealthRecoveryScreen({Key? key}) : super(key: key);

  @override
  State<HealthRecoveryScreen> createState() => _HealthRecoveryScreenState();
}

class _HealthRecoveryScreenState extends State<HealthRecoveryScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _allRecoveries = [];
  List<dynamic> _achievedRecoveries = [];
  List<dynamic> _inProgressRecoveries = [];
  String? _errorMessage;
  int _currentStreakDays = 0;
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHealthRecoveries();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadHealthRecoveries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Check for new health recoveries
      try {
        await HealthRecoveryUtils.checkForNewRecoveries();
      } catch (e) {
        print('Error checking for new health recoveries: $e');
        // Continue even if checking fails
      }
      
      // Get health recovery status
      final status = await HealthRecoveryUtils.getUserHealthRecoveryStatus();
      
      // Split recoveries into achieved and in progress
      final recoveries = status['recoveries'] as List;
      final achieved = recoveries.where((r) => r['is_achieved'] == true).toList();
      final inProgress = recoveries.where((r) => r['is_achieved'] != true).toList();
      
      // Sort by days to achieve
      achieved.sort((a, b) => a['days_to_achieve'].compareTo(b['days_to_achieve']));
      inProgress.sort((a, b) => a['days_to_achieve'].compareTo(b['days_to_achieve']));
      
      setState(() {
        _allRecoveries = recoveries;
        _achievedRecoveries = achieved;
        _inProgressRecoveries = inProgress;
        _currentStreakDays = status['current_streak_days'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.healthRecovery),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadHealthRecoveries,
            tooltip: l10n.refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.achievementCategoryAll),
            Tab(text: l10n.achieved),
            Tab(text: l10n.progress),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _loadHealthRecoveries,
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // All Recoveries
                    _buildRecoveriesList(_allRecoveries, l10n.noRecoveriesFound),
                    
                    // Achieved Recoveries
                    _buildRecoveriesList(_achievedRecoveries, l10n.noRecoveriesFound),
                    
                    // In Progress Recoveries
                    _buildRecoveriesList(_inProgressRecoveries, l10n.noRecoveriesFound),
                  ],
                ),
    );
  }
  
  Widget _buildRecoveriesList(List<dynamic> recoveries, String emptyMessage) {
    if (recoveries.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: context.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return ListView.builder(
      itemCount: recoveries.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final recovery = recoveries[index];
        final isAchieved = recovery['is_achieved'] == true;
        final progress = (recovery['progress'] as num?)?.toDouble() ?? 0.0;
        final daysToAchieve = recovery['days_to_achieve'] as int;
        final daysRemaining = recovery['days_remaining'] as int? ?? 0;
        
        return _buildRecoveryCard(
          context,
          recovery['id'],
          recovery['name'], 
          recovery['description'], 
          daysToAchieve, 
          progress,
          isAchieved,
          daysRemaining,
          recovery['icon_name'],
        );
      },
    );
  }
  
  Widget _buildRecoveryCard(
    BuildContext context,
    String id,
    String name,
    String description,
    int daysToAchieve,
    double progress,
    bool isAchieved,
    int daysRemaining,
    String? iconName,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final cardColor = context.cardColor;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navigate to recovery detail screen
          context.push(AppRoutes.healthRecoveryDetail.withParams(
            params: {'recoveryId': id},
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getRecoveryIcon(context, iconName, isAchieved),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isAchieved 
                              ? l10n.achievementCompleted
                              : l10n.daysToAchieve(daysToAchieve),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isAchieved ? Colors.green : context.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAchieved 
                          ? Colors.green.withOpacity(0.1) 
                          : context.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAchieved ? l10n.achieved : '${(progress * 100).toInt()}%',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isAchieved ? Colors.green : context.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
                backgroundColor: Colors.grey.withOpacity(0.2),
                color: isAchieved ? Colors.green : context.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: context.textTheme.bodyMedium,
              ),
              if (!isAchieved && daysRemaining > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: context.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.daysRemaining(daysRemaining),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _getRecoveryIcon(BuildContext context, String? iconName, bool isAchieved) {
    final iconMap = {
      'taste': Icons.restaurant,
      'smell': Icons.air,
      'blood_drop': Icons.bloodtype,
      'lungs': Icons.air_rounded,
      'heart': Icons.favorite,
      'chemical': Icons.science,
      'circulation': Icons.bike_scooter,
    };

    final icon = iconMap[iconName] ?? Icons.check_circle;
    final color = isAchieved ? Colors.green : context.primaryColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAchieved ? Colors.green.withOpacity(0.1) : context.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}