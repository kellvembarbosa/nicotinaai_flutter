import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/utils/health_recovery_utils.dart';
import 'package:nicotinaai_flutter/widgets/skeleton_loading.dart';

class HealthRecoveryDetailScreen extends StatefulWidget {
  final String recoveryId;

  const HealthRecoveryDetailScreen({Key? key, required this.recoveryId}) : super(key: key);

  @override
  State<HealthRecoveryDetailScreen> createState() => _HealthRecoveryDetailScreenState();
}

class _HealthRecoveryDetailScreenState extends State<HealthRecoveryDetailScreen> {
  bool _isLoading = true;
  HealthRecovery? _recovery;
  Map<String, dynamic>? _recoveryStatus;
  DateTime? _achievedAt;
  String? _errorMessage;
  int _currentStreakDays = 0;

  @override
  void initState() {
    super.initState();
    _loadRecoveryDetails();
  }

  Future<void> _loadRecoveryDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = SupabaseConfig.client;

      // Get the health recovery details
      final response = await client.from('health_recoveries').select().eq('id', widget.recoveryId).single();

      final recovery = HealthRecovery.fromJson(response);

      // Get the user's streak information
      final status = await HealthRecoveryUtils.getUserHealthRecoveryStatus();

      // Check if the recovery has been achieved
      final achievedRecoveries = status['achieved_recoveries'] as List;
      Map<String, dynamic>? achievedRecovery;
      try {
        achievedRecovery = achievedRecoveries.firstWhere((r) => r['recovery_id'] == widget.recoveryId) as Map<String, dynamic>;
      } catch (e) {
        // Recovery not found in achieved list, leave achievedRecovery as null
        achievedRecovery = null;
      }

      final achievedAt = achievedRecovery != null ? DateTime.parse(achievedRecovery['achieved_at']) : null;

      // Update the is_viewed flag if the recovery has been achieved
      if (achievedRecovery != null && achievedRecovery['is_viewed'] == false) {
        await client.from('user_health_recoveries').update({'is_viewed': true}).eq('id', achievedRecovery['id']);
      }

      if (!mounted) return;

      setState(() {
        _recovery = recovery;
        _recoveryStatus = status;
        _achievedAt = achievedAt;
        _currentStreakDays = status['current_streak_days'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildProgressSection(HealthRecovery recovery, bool isAchieved) {
    final l10n = AppLocalizations.of(context)!;
    final daysToAchieve = recovery.daysToAchieve;

    // Calculate progress
    final progress =
        isAchieved
            ? 1.0
            : _currentStreakDays >= daysToAchieve
            ? 1.0
            : _currentStreakDays / daysToAchieve;

    // Calculate days remaining
    final daysRemaining =
        isAchieved
            ? 0
            : (daysToAchieve - _currentStreakDays) > 0
            ? (daysToAchieve - _currentStreakDays)
            : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isAchieved ? l10n.achieved : l10n.progress, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
          backgroundColor: Colors.grey.withOpacity(0.2),
          color: isAchieved ? Colors.green : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isAchieved ? l10n.achieved : l10n.daysSmokeFree(_currentStreakDays), style: Theme.of(context).textTheme.bodyMedium),
            Text(l10n.daysToAchieve(daysToAchieve), style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        if (isAchieved)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(l10n.achievedOn(_achievedAt!), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          )
        else if (daysRemaining > 0)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.daysRemaining(daysRemaining), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScienceSection(HealthRecovery recovery) {
    final l10n = AppLocalizations.of(context)!;

    // Map of scientific information for each recovery type
    final scienceInfo = {
      'Taste': l10n.tasteScienceInfo,
      'Smell': l10n.smellScienceInfo,
      'Blood Oxygen Normalization': l10n.bloodOxygenScienceInfo,
      'Carbon Monoxide Eliminated': l10n.carbonMonoxideScienceInfo,
      'Nicotine Expulsion': l10n.nicotineScienceInfo,
      'Improved Breathing': l10n.improvedBreathingScienceInfo,
      'Improved Circulation': l10n.improvedCirculationScienceInfo,
      'Decreased Coughing': l10n.decreasedCoughingScienceInfo,
      'Lung Cilia Recovery': l10n.lungCiliaScienceInfo,
      'Reduced Heart Disease Risk': l10n.reducedHeartDiseaseRiskScienceInfo,
    };

    final scienceText = scienceInfo[recovery.name] ?? l10n.generalHealthScienceInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.scienceBehindIt, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Text(scienceText, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_recovery?.name ?? l10n.healthRecovery),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body:
          _isLoading
              ? RecoveryDetailSkeleton()
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                    TextButton(onPressed: _loadRecoveryDetails, child: Text(l10n.tryAgain)),
                  ],
                ),
              )
              : _recovery == null
              ? Center(child: Text(l10n.recoveryNotFound))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recovery icon and name
                    Row(
                      children: [
                        _getRecoveryIcon(_recovery!.iconName, _achievedAt != null),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_recovery!.name, style: Theme.of(context).textTheme.headlineSmall),
                              Text(_recovery!.description, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Progress section
                    _buildProgressSection(_recovery!, _achievedAt != null),
                    const SizedBox(height: 24),

                    // Scientific information
                    _buildScienceSection(_recovery!),
                    const SizedBox(height: 24),

                    // Encouragement message
                    if (_achievedAt == null)
                      Card(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.keepGoing,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                              ),
                              const SizedBox(height: 8),
                              Text(l10n.encouragementMessage, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      )
                    else
                      Card(
                        color: Colors.green.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.congratulations, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green)),
                              const SizedBox(height: 8),
                              Text(l10n.recoveryAchievedMessage, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  /// Get icon for a recovery
  Widget _getRecoveryIcon(String? iconName, bool isAchieved) {
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
    final color = isAchieved ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isAchieved ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 32),
    );
  }
}
