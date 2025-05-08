import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/core/theme/theme_provider.dart';
import 'package:nicotinaai_flutter/core/theme/theme_switch.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/home/providers/craving_provider.dart';
import 'package:nicotinaai_flutter/features/home/providers/smoking_record_provider.dart';
import 'package:nicotinaai_flutter/features/home/widgets/new_record_sheet.dart';
import 'package:nicotinaai_flutter/features/home/widgets/register_craving_sheet.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/dashboard_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/widgets/health_recovery_widget.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/currency_utils.dart';
import 'package:nicotinaai_flutter/utils/health_recovery_utils.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables to store stats
  int _daysWithoutSmoking = 0;
  int _minutesLifeGained = 0;
  int _breathCapacityPercent = 0;
  int _cravingsResisted = 0;
  int _dailyMinutesGained = 0;
  int _moneySavedInCents = 0;
  UserStats? _stats;
  // Health recovery IDs
  List<String> _userRecoveryIds = [];
  Map<String, bool> _healthRecoveryStatus = {
    'taste': false,
    'smell': false,
    'circulation': false,
    'lungs': false,
    'heart': false,
  };
  // Next health recovery milestone
  Map<String, dynamic>? _nextHealthMilestone;
  // Flag para evitar múltiplas chamadas de atualização simultâneas
  bool _isUpdating = false;
  // Currency formatter
  final CurrencyUtils _currencyUtils = CurrencyUtils();
  
  @override
  void initState() {
    super.initState();
    // Evite chamar Provider.of() diretamente em initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    if (!mounted) return;
    
    // Evitar múltiplas chamadas simultâneas
    if (_isUpdating) {
      if (kDebugMode) {
        print('🚫 Atualização já em andamento, ignorando chamada duplicada');
      }
      return;
    }
    
    setState(() {
      _isUpdating = true;
    });
    
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    
    // Verificar explicitamente se a última data de fumo está atualizada
    if (kDebugMode) {
      if (trackingProvider.state.userStats?.lastSmokeDate != null) {
        print('📅 Data do último cigarro no provider: ${trackingProvider.state.userStats!.lastSmokeDate}');
      } else {
        print('⚠️ Data do último cigarro não disponível no provider');
      }
    }
    
    // Usamos um método simples de get sem força update
    try {
      // Get health recoveries
      final userRecoveries = trackingProvider.state.userHealthRecoveries;
      final allRecoveries = trackingProvider.state.healthRecoveries;
      
      // Map recovery IDs to their types
      Map<String, String> recoveryTypeMap = {};
      for (var recovery in allRecoveries) {
        String type = '';
        
        if (recovery.name.toLowerCase().contains('taste')) type = 'taste';
        else if (recovery.name.toLowerCase().contains('smell')) type = 'smell';
        else if (recovery.name.toLowerCase().contains('circulation')) type = 'circulation';
        else if (recovery.name.toLowerCase().contains('lung') || 
                 recovery.name.toLowerCase().contains('breathing')) type = 'lungs';
        else if (recovery.name.toLowerCase().contains('heart')) type = 'heart';
        
        if (type.isNotEmpty) {
          recoveryTypeMap[recovery.id] = type;
        }
      }
      
      // Get list of recovery IDs user has achieved
      final newUserRecoveryIds = userRecoveries.map((recovery) => recovery.recoveryId).toList();
      
      // Reset health status
      final Map<String, bool> newHealthRecoveryStatus = {
        'taste': false,
        'smell': false,
        'circulation': false,
        'lungs': false,
        'heart': false,
      };
      
      // Update recovery status based on user's achievements
      for (var recoveryId in newUserRecoveryIds) {
        final type = recoveryTypeMap[recoveryId];
        if (type != null && newHealthRecoveryStatus.containsKey(type)) {
          newHealthRecoveryStatus[type] = true;
        }
      }
      
      // Update state variables from provider
      if (mounted) {
        // Obter estatísticas atualizadas diretamente do provider
        final updatedStats = trackingProvider.state.userStats;
        final updatedCravingsResisted = updatedStats?.cravingsResisted ?? 0;
        final updatedDaysWithoutSmoking = updatedStats?.currentStreakDays ?? 0;
        final updatedMoneySaved = updatedStats?.moneySaved ?? 0;
        
        if (kDebugMode && updatedStats?.lastSmokeDate != null && _stats?.lastSmokeDate != null) {
          // Verificar se a data mudou para debug
          final oldDate = _stats!.lastSmokeDate!;
          final newDate = updatedStats!.lastSmokeDate!;
          if (oldDate != newDate) {
            print('🔄 Data do último cigarro atualizada: ${oldDate.toIso8601String()} -> ${newDate.toIso8601String()}');
          }
        }
        
        setState(() {
          _userRecoveryIds = newUserRecoveryIds;
          _healthRecoveryStatus = newHealthRecoveryStatus;
          _stats = updatedStats;
          _daysWithoutSmoking = updatedDaysWithoutSmoking;
          _minutesLifeGained = (_stats?.cigarettesAvoided ?? 0) * 6; // Each cigarette not smoked gives ~6 minutes
          _breathCapacityPercent = _daysWithoutSmoking > 30 ? 40 : (_daysWithoutSmoking > 7 ? 20 : 10);
          _cravingsResisted = updatedCravingsResisted;
          _dailyMinutesGained = _daysWithoutSmoking == 0 ? 0 : _minutesLifeGained ~/ _daysWithoutSmoking;
          _moneySavedInCents = updatedMoneySaved; // Money saved in cents
          
          // Load the next health milestone
          _loadNextHealthMilestone();
          
          _isUpdating = false;
        });
      } else {
        _isUpdating = false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Erro ao atualizar dados: $error');
      }
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      } else {
        _isUpdating = false;
      }
    }
  }
  
  /// Load the next health milestone from the server
  Future<void> _loadNextHealthMilestone() async {
    if (!mounted) return;
    
    try {
      // Get the next health milestone
      final nextMilestone = await HealthRecoveryUtils.getNextHealthRecoveryMilestone(_daysWithoutSmoking);
      
      if (mounted) {
        setState(() {
          _nextHealthMilestone = nextMilestone;
        });
      }
    } catch (e) {
      print('Error loading next health milestone: $e');
      // Don't update state on error, keep previous milestone if any
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nada aqui para evitar problemas com Provider durante o build
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final l10n = AppLocalizations.of(context);
    
    // Use Selector em vez de Consumer para observar apenas mudanças específicas
    // e evitar reconstruções e atualizações desnecessárias
    return Selector<TrackingProvider, Map<String, dynamic>>(
      // Seleciona apenas os dados específicos que interessam para esta tela
      selector: (_, provider) => {
        'userStats': provider.state.userStats,
        'isLoaded': provider.state.isLoaded,
        'healthRecoveriesCount': provider.state.userHealthRecoveries.length,
        'cravingsResisted': provider.state.userStats?.cravingsResisted ?? 0,
        'daysWithoutSmoking': provider.state.userStats?.currentStreakDays ?? 0,
        'moneySaved': provider.state.userStats?.moneySaved ?? 0,
        'lastSmokeDate': provider.state.userStats?.lastSmokeDate?.millisecondsSinceEpoch ?? 0,
      },
      // Só reconstrua se algo relevante mudar
      builder: (_, data, child) {
        // Detecta eventos reais de mudança para atualizar
        final bool shouldUpdate = data['isLoaded'] && (
          _stats?.cravingsResisted != data['cravingsResisted'] || 
          _stats?.currentStreakDays != data['daysWithoutSmoking'] ||
          _stats?.moneySaved != data['moneySaved'] ||
          (_stats?.lastSmokeDate?.millisecondsSinceEpoch ?? 0) != data['lastSmokeDate'] ||
          (_userRecoveryIds.isEmpty && data['healthRecoveriesCount'] > 0)
        );
        
        // Atualiza apenas quando há mudanças reais nos dados
        if (shouldUpdate && !_isUpdating) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isUpdating) {
              _loadData();
            }
          });
        }
        
        return child!;
      },
      child: Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: context.titleStyle,
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        actions: const [
          ThemeSwitch(useIcons: true),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com saudação e contador de dias
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeGreeting(user?.name?.split(' ')[0] ?? 'Usuário'),
                          style: context.headlineStyle,
                        ),
                        const SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeDaysWithoutSmoking(_daysWithoutSmoking),
                              style: context.subtitleStyle,
                            ),
                            if (_stats?.lastSmokeDate != null)
                              Text(
                                'Último: ${_formatLastSmokeDate(_stats!.lastSmokeDate!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.subtitleColor.withOpacity(0.8),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: context.primaryColor.withOpacity(0.2),
                      child: Text(
                        user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Estatísticas diárias
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.homeTodayStats,
                      style: context.titleStyle,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to statistics dashboard
                        context.go(AppRoutes.statisticsDashboard.path);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: context.primaryColor,
                      ),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cards de estatísticas diárias
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDailyStatCard(
                        context,
                        '$_cravingsResisted',
                        l10n.homeCravingsResisted,
                        Colors.orange,
                        Icons.smoke_free,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDailyStatCard(
                        context,
                        _dailyMinutesGained > 0 ? '$_dailyMinutesGained min' : '0',
                        l10n.homeMinutesGainedToday,
                        Colors.teal,
                        Icons.favorite,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Botões de registro
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        l10n.registerCraving,
                        l10n.registerCravingSubtitle,
                        Colors.redAccent,
                        Icons.air,
                        () {
                          RegisterCravingSheet.show(context).then((registered) {
                            // Só atualiza se um craving foi realmente registrado
                            if (registered) {
                              if (kDebugMode) {
                                print("🔄 Atualizando após registrar craving");
                              }
                              // Trigger immediate update
                              _loadData();
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        l10n.newRecord,
                        l10n.newRecordSubtitle,
                        Colors.blueAccent,
                        Icons.smoking_rooms,
                        () {
                          NewRecordSheet.show(context).then((registered) {
                            // Só atualiza se um record foi realmente registrado
                            if (registered) {
                              if (kDebugMode) {
                                print("🔄 Atualizando após registrar cigarro");
                              }
                              // Resetar o flag de atualização para permitir nova atualização
                              setState(() {
                                _isUpdating = false;
                              });
                              
                              // Forçar atualização completa das estatísticas para atualizar última data de fumo
                              final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
                              trackingProvider.refreshUserStats().then((_) {
                                // Depois de atualizar as estatísticas, carregar todos os dados na UI
                                if (mounted) {
                                  _loadData();
                                }
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Health Recovery Section
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.healthRecovery,
                          style: context.titleStyle,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to health recovery screen
                            context.push(AppRoutes.healthRecovery.path);
                          },
                          child: Text(
                            l10n.seeAll,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Health Recovery Widget
                  HealthRecoveryWidget(
                    showAllRecoveries: false,
                    autoRefresh: true,
                    showHeader: false,
                    onRecoveryTap: (recovery, isAchieved) {
                      if (recovery.id == 'all') {
                        // Navigate to all health recoveries screen
                        context.push(AppRoutes.healthRecovery.path);
                      } else {
                        // Navigate to specific health recovery detail
                        context.push(AppRoutes.healthRecoveryDetail.withParams(
                          params: {'recoveryId': recovery.id},
                        ));
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Cards de estatísticas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatisticCard(
                        context,
                        '$_minutesLifeGained',
                        l10n.homeMinutesLifeGained,
                        Colors.green,
                        Icons.access_time,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatisticCard(
                        context,
                        '$_breathCapacityPercent%',
                        l10n.homeLungCapacity,
                        Colors.blue,
                        Icons.air,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Money saved card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMoneyStatisticCard(
                  context,
                  _moneySavedInCents,
                  l10n.savingsCalculator,
                  Colors.amber,
                  Icons.savings,
                  user,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Próximo marco
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: context.isDarkMode 
                    ? _buildGlassMorphicNextMilestone(context, l10n)
                    : _buildNextMilestone(context, l10n),
              ),
              
              const SizedBox(height: 24),
              
              // Conquistas recentes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.homeRecentAchievements,
                      style: context.titleStyle,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to achievements screen
                        context.go(AppRoutes.achievements.path);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: context.primaryColor,
                      ),
                      child: Text(
                        l10n.homeSeeAll,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Cards de conquistas
              Consumer<TrackingProvider>(
                builder: (context, trackingProvider, _) {
                  // Verifica se o provider está carregado e temos conquistas
                  bool hasRecoveries = trackingProvider.state.isLoaded && 
                    trackingProvider.state.userHealthRecoveries.isNotEmpty;
                    
                  return hasRecoveries
                      // Mostrar conquistas reais do usuário quando disponíveis
                      ? SizedBox(
                          height: 140,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: _buildRecentAchievements(context, l10n),
                          ),
                        )
                      // Mostrar card motivacional quando não temos conquistas ou estamos carregando
                      : _buildMotivationalCard(context, l10n);
                },
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
    );
  }
  
  Widget _buildHealthIndicator(BuildContext context, String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: isActive 
                ? context.primaryColor.withOpacity(0.15) 
                : context.isDarkMode 
                    ? Colors.grey[800] 
                    : Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive 
                  ? context.primaryColor 
                  : context.isDarkMode
                      ? Colors.grey[700]!
                      : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.check_circle,
              color: isActive 
                ? context.primaryColor 
                : context.isDarkMode
                    ? Colors.grey[600]
                    : Colors.grey[400],
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive 
                ? context.primaryColor 
                : context.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatisticCard(BuildContext context, String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(context.isDarkMode ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color.withOpacity(context.isDarkMode ? 0.9 : 1.0),
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: context.contentColor,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall!.copyWith(
              color: context.subtitleColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextMilestone(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _onNextMilestoneTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primaryColor.withOpacity(0.7), 
              context.primaryColor
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildMilestoneContent(context, Colors.white, l10n),
      ),
    );
  }
  
  Widget _buildGlassMorphicNextMilestone(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _onNextMilestoneTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: _buildMilestoneContent(context, Colors.white, l10n),
          ),
        ),
      ),
    );
  }
  
  /// Handle tap on the next milestone card
  void _onNextMilestoneTap() {
    if (_nextHealthMilestone != null) {
      // Navigate to the health recovery detail screen for this milestone
      context.push(AppRoutes.healthRecoveryDetail.withParams(
        params: {'recoveryId': _nextHealthMilestone!['id']},
      ));
    } else {
      // Navigate to the health recovery list screen if we don't have a specific milestone
      context.push(AppRoutes.healthRecovery.path);
    }
  }
  
  Widget _buildMilestoneContent(BuildContext context, Color textColor, AppLocalizations l10n) {
    // If we have a next milestone, display it, otherwise use the default static content
    final hasMilestone = _nextHealthMilestone != null;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            hasMilestone 
                ? _nextHealthMilestone!['icon'] as IconData 
                : Icons.flag_rounded,
            color: textColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasMilestone 
                    ? '${_nextHealthMilestone!['name']}' 
                    : l10n.homeNextMilestone,
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              if (hasMilestone)
                Text(
                  'In ${_nextHealthMilestone!['daysRemaining']} days: ${_nextHealthMilestone!['description']}',
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: textColor.withOpacity(0.85),
                  ),
                )
              else
                Text(
                  l10n.homeNextMilestoneDescription(_daysWithoutSmoking < 7 ? (7 - _daysWithoutSmoking).toInt() : 
                                             _daysWithoutSmoking < 14 ? (14 - _daysWithoutSmoking).toInt() : 
                                             _daysWithoutSmoking < 30 ? (30 - _daysWithoutSmoking).toInt() : 1),
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: textColor.withOpacity(0.85),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementCard(BuildContext context, String milestone, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 160,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(context.isDarkMode ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              milestone,
              style: context.textTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: color.withOpacity(context.isDarkMode ? 0.9 : 1.0),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: context.contentColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: context.textTheme.bodySmall!.copyWith(
              color: context.subtitleColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDailyStatCard(BuildContext context, String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(context.isDarkMode ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color.withOpacity(context.isDarkMode ? 0.9 : 1.0),
                  size: 18,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_upward,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 2),
              Text(
                _getStreakPercentage(),
                style: context.textTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: context.contentColor,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall!.copyWith(
              color: context.subtitleColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, 
    String title,
    String subtitle,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: context.isDarkMode ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.contentColor,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.subtitleColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to safely calculate streak percentage
  String _getStreakPercentage() {
    if (_stats == null) return "--";
    
    final days = _stats!.currentStreakDays;
    if (days <= 0) return "--";
    
    final percentage = (days * 3).clamp(1, 30);
    return "$percentage%";
  }
  
  // Formata a data do último cigarro de forma legível
  String _formatLastSmokeDate(DateTime date) {
    // Hoje
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Data do último cigarro sem horário
    final smokeDate = DateTime(date.year, date.month, date.day);
    
    // Diferença em dias
    final difference = today.difference(smokeDate).inDays;
    
    if (difference == 0) {
      // Se for hoje, mostrar "Hoje às HH:MM"
      return 'Hoje às ${_formatTime(date)}';
    } else if (difference == 1) {
      // Se for ontem
      return 'Ontem às ${_formatTime(date)}';
    } else if (difference < 7) {
      // Se for nos últimos 7 dias, mostrar o dia da semana
      final weekday = _getDayOfWeek(date.weekday);
      return '$weekday às ${_formatTime(date)}';
    } else {
      // Formato completo para datas mais antigas
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${_formatTime(date)}';
    }
  }
  
  // Formata hora e minuto
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  // Retorna o nome do dia da semana
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return 'Segunda';
      case 2: return 'Terça';
      case 3: return 'Quarta';
      case 4: return 'Quinta';
      case 5: return 'Sexta';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return '';
    }
  }
  
  // Constrói um card motivacional quando não há conquistas
  Widget _buildMotivationalCard(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.primaryColor.withOpacity(0.08),
          border: Border.all(
            color: context.primaryColor.withOpacity(0.2),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: context.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.importantAchievements,
                  style: context.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.achievementsDescription,
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.contentColor,
              height: 1.4,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.congratulations,
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
      ),
    );
  }
  
  // Constrói uma lista de conquistas reais baseadas nos recoveries do usuário
  List<Widget> _buildRecentAchievements(BuildContext context, AppLocalizations l10n) {
    final achievements = <Widget>[];
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    final userRecoveries = trackingProvider.state.userHealthRecoveries;
    final allRecoveries = trackingProvider.state.healthRecoveries;
    
    // Map para armazenar detalhes dos recoveries pelo ID
    Map<String, HealthRecovery> recoveryDetailsMap = {};
    for (var recovery in allRecoveries) {
      recoveryDetailsMap[recovery.id] = recovery;
    }
    
    // Lista de conquistas baseadas nos health recoveries do usuário
    for (var userRecovery in userRecoveries) {
      final recoveryDetails = recoveryDetailsMap[userRecovery.recoveryId];
      if (recoveryDetails != null) {
        // Determinar cor baseada no tipo de recovery
        Color cardColor = context.primaryColor;
        if (recoveryDetails.name.toLowerCase().contains('taste')) {
          cardColor = Colors.purple;
        } else if (recoveryDetails.name.toLowerCase().contains('smell')) {
          cardColor = Colors.teal;
        } else if (recoveryDetails.name.toLowerCase().contains('circulation')) {
          cardColor = Colors.red;
        } else if (recoveryDetails.name.toLowerCase().contains('lung') || 
                   recoveryDetails.name.toLowerCase().contains('breathing')) {
          cardColor = Colors.blue;
        } else if (recoveryDetails.name.toLowerCase().contains('heart')) {
          cardColor = Colors.pink;
        }
        
        // Criar card de conquista
        achievements.add(
          _buildAchievementCard(
            context,
            '${recoveryDetails.daysToAchieve} ${l10n.days}',
            recoveryDetails.name,
            recoveryDetails.description,
            cardColor,
          ),
        );
      }
    }
    
    // Lista de conquistas básicas baseadas nos dias sem fumar
    if (_daysWithoutSmoking >= 1) {
      achievements.add(
        _buildAchievementCard(
          context,
          '24h',
          l10n.homeFirstDay,
          l10n.homeFirstDayDescription,
          Colors.amber,
        ),
      );
    }
    
    if (_daysWithoutSmoking >= 3) {
      achievements.add(
        _buildAchievementCard(
          context,
          '3 ${l10n.days}',
          l10n.homeOvercoming,
          l10n.homeOvercomingDescription,
          Colors.green,
        ),
      );
    }
    
    if (_daysWithoutSmoking >= 7) {
      achievements.add(
        _buildAchievementCard(
          context,
          '7 ${l10n.days}',
          l10n.homePersistence,
          l10n.homePersistenceDescription,
          context.primaryColor,
        ),
      );
    }
    
    // Conquistas de economia baseadas no dinheiro economizado
    if (_moneySavedInCents >= 2500) {
      achievements.add(
        _buildAchievementCard(
          context,
          _currencyUtils.formatWithDeviceLocale(2500, context: context),
          l10n.achievementInitialSavings,
          l10n.achievementInitialSavingsDescription,
          Colors.amber.shade700,
        ),
      );
    }
    
    // Se não houver conquistas específicas, adicione no mínimo uma mensagem motivacional
    if (achievements.isEmpty) {
      achievements.add(
        _buildAchievementCard(
          context,
          l10n.supportWhenNeeded,
          l10n.homeNextMilestone,
          l10n.homeNextMilestoneDescription(1),
          context.primaryColor,
        ),
      );
    }
    
    return achievements;
  }
  
  // Money statistic card with proper currency formatting using device locale
  Widget _buildMoneyStatisticCard(
    BuildContext context, 
    int valueInCents, 
    String label, 
    Color color, 
    IconData icon,
    dynamic user, // Can be null, will use device locale
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(context.isDarkMode ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color.withOpacity(context.isDarkMode ? 0.9 : 1.0),
                  size: 24,
                ),
              ),
              const Spacer(),
              if (_daysWithoutSmoking > 0) ...[
                Icon(
                  Icons.arrow_upward,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 2),
                Text(
                  _getStreakPercentage(),
                  style: context.textTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            // Use device locale if user is null
            user == null 
                ? _currencyUtils.formatWithDeviceLocale(valueInCents, context: context)
                : _currencyUtils.format(valueInCents, user: user),
            style: context.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: context.contentColor,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.subtitleColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}