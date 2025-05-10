import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/health_recovery_utils.dart';
import 'package:nicotinaai_flutter/widgets/skeleton_loading.dart';

class HealthRecoveryWidget extends StatefulWidget {
  /// Optional callback when a recovery is tapped
  final Function(HealthRecovery recovery, bool isAchieved)? onRecoveryTap;

  /// Whether to show all recoveries or just the highlighted ones
  final bool showAllRecoveries;

  /// Whether to automatically refresh recoveries on mount
  final bool autoRefresh;
  
  /// Whether to show the header with title and see all button
  final bool showHeader;

  const HealthRecoveryWidget({
    Key? key,
    this.onRecoveryTap,
    this.showAllRecoveries = false,
    this.autoRefresh = true,
    this.showHeader = true,
  }) : super(key: key);

  @override
  State<HealthRecoveryWidget> createState() => _HealthRecoveryWidgetState();
}

class _HealthRecoveryWidgetState extends State<HealthRecoveryWidget> {
  bool _isLoading = true;
  List<dynamic> _recoveries = [];
  String? _errorMessage;
  int _currentStreakDays = 0;

  @override
  void initState() {
    super.initState();
    if (widget.autoRefresh) {
      _loadHealthRecoveries();
    }
  }

  Future<void> _loadHealthRecoveries() async {
    // Check if the widget is still mounted before setting state
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the user's health recovery status
      final status = await HealthRecoveryUtils.getUserHealthRecoveryStatus();
      
      // Check if the widget is still mounted before setting state
      if (!mounted) return;
      
      // Se as listas estiverem vazias mas isso for válido (usuário sem data de último cigarro),
      // mostre uma UI vazia mas sem erro
      if (status['recoveries'] == null || (status['recoveries'] as List).isEmpty) {
        setState(() {
          _recoveries = [];
          _currentStreakDays = status['current_streak_days'] ?? 0;
          _isLoading = false;
          _errorMessage = null; // Não é erro, apenas não há dados ainda
        });
        return;
      }
      
      setState(() {
        _recoveries = status['recoveries'];
        _currentStreakDays = status['current_streak_days'] ?? 0;
        _isLoading = false;
      });
      
      // Verifica se devemos checar por novas recuperações
      // Só faz isso se tivermos uma data de último cigarro
      if (widget.autoRefresh && status['last_smoke_date'] != null) {
        try {
          await HealthRecoveryUtils.checkForNewRecoveries();
          // Reload the data to reflect any new achievements
          final updatedStatus = await HealthRecoveryUtils.getUserHealthRecoveryStatus();
          
          // Check if the widget is still mounted before setting state
          if (mounted) {
            setState(() {
              _recoveries = updatedStatus['recoveries'];
              _currentStreakDays = updatedStatus['current_streak_days'] ?? 0;
            });
          }
        } catch (checkError) {
          // Just log the error, don't update UI state
          print('Error checking for new health recoveries: $checkError');
        }
      }
    } catch (e) {
      // Check if the widget is still mounted before setting state
      if (!mounted) return;
      
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _recoveries = []; // Certifique-se de que não há dados inválidos
      });
    }
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAchieved ? Colors.green.withAlpha(26) : Colors.grey.withAlpha(26), // Equivalent to opacity 0.1 (255 * 0.1 = 25.5 ≈ 26)
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (_isLoading) {
      return _buildSkeletonLoading(l10n);
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingData,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: _loadHealthRecoveries,
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      );
    }

    if (_recoveries.isEmpty) {
      return Center(
        child: Text(
          l10n.noRecoveriesFound,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    // Filter recoveries based on showAllRecoveries setting
    final recoveriesToShow = widget.showAllRecoveries
        ? _recoveries
        : _recoveries.where((r) {
            final isAchieved = r['is_achieved'] == true;
            final isInProgress = r['progress'] > 0 && r['progress'] < 1;
            final isNextMilestone = !isAchieved && 
                r['days_to_achieve'] > _currentStreakDays && 
                (r['days_to_achieve'] - _currentStreakDays) <= 7; // Show if within 7 days
            
            return isAchieved || isInProgress || isNextMilestone;
          }).toList();

    if (recoveriesToShow.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.noRecentRecoveries,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (!widget.showAllRecoveries)
                TextButton(
                  onPressed: () {
                    // Navigate to full recovery list or show all recoveries
                    widget.onRecoveryTap?.call(
                      HealthRecovery(
                        id: 'all',
                        name: 'All',
                        description: 'All health recoveries',
                        daysToAchieve: 0,
                      ),
                      false,
                    );
                  },
                  child: Text(l10n.viewAllRecoveries),
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.healthRecovery,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (!widget.showAllRecoveries)
                  TextButton(
                    onPressed: () {
                      // Navigate to full recovery list
                      widget.onRecoveryTap?.call(
                        HealthRecovery(
                          id: 'all',
                          name: 'All',
                          description: 'All health recoveries',
                          daysToAchieve: 0,
                        ),
                        false,
                      );
                    },
                    child: Text(l10n.seeAll),
                  ),
              ],
            ),
          ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recoveriesToShow.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              final recovery = recoveriesToShow[index];
              final isAchieved = recovery['is_achieved'] == true;
              final progress = (recovery['progress'] as num?)?.toDouble() ?? 0.0;
              
              return GestureDetector(
                onTap: () {
                  widget.onRecoveryTap?.call(
                    HealthRecovery(
                      id: recovery['id'],
                      name: recovery['name'],
                      description: recovery['description'],
                      daysToAchieve: recovery['days_to_achieve'],
                      iconName: recovery['icon_name'],
                    ),
                    isAchieved,
                  );
                },
                child: Container(
                  width: 110,
                  margin: EdgeInsets.only(right: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13), // Equivalent to opacity 0.05 (255 * 0.05 = 12.75 ≈ 13)
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 64,
                            width: 64,
                            child: CircularProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.withAlpha(51), // Equivalent to opacity 0.2 (255 * 0.2 = 51)
                              color: isAchieved ? Colors.green : Colors.blue,
                              strokeWidth: 4,
                            ),
                          ),
                          _getRecoveryIcon(recovery['icon_name'], isAchieved),
                        ],
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          recovery['name'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isAchieved && progress < 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  /// Build skeleton loading UI for health recovery widget
  Widget _buildSkeletonLoading(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.healthRecovery,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (!widget.showAllRecoveries)
                  TextButton(
                    onPressed: null, // Disabled during loading
                    child: Text(l10n.seeAll),
                  ),
              ],
            ),
          ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Show 5 skeleton items
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              return RecoveryItemSkeleton();
            },
          ),
        ),
      ],
    );
  }
}