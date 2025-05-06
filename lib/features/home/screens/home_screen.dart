import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/core/theme/theme_provider.dart';
import 'package:nicotinaai_flutter/core/theme/theme_switch.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/home/widgets/new_record_sheet.dart';
import 'package:nicotinaai_flutter/features/home/widgets/register_craving_sheet.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/dashboard_screen.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/currency_utils.dart';

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
    
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    
    // Load tracking data if needed
    if (trackingProvider.state.isInitial) {
      trackingProvider.initialize();
    }
    
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
      setState(() {
        _userRecoveryIds = newUserRecoveryIds;
        _healthRecoveryStatus = newHealthRecoveryStatus;
        _stats = trackingProvider.state.userStats;
        _daysWithoutSmoking = _stats?.currentStreakDays ?? 0;
        _minutesLifeGained = (_stats?.cigarettesAvoided ?? 0) * 6; // Each cigarette not smoked gives ~6 minutes
        _breathCapacityPercent = _daysWithoutSmoking > 30 ? 40 : (_daysWithoutSmoking > 7 ? 20 : 10);
        _cravingsResisted = _stats?.cravingsResisted ?? 0;
        _dailyMinutesGained = _daysWithoutSmoking == 0 ? 0 : _minutesLifeGained ~/ _daysWithoutSmoking;
        _moneySavedInCents = _stats?.moneySaved ?? 0; // Money saved in cents
      });
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
    
    // Use Consumer para ouvir mudanças no TrackingProvider 
    // sem causar problemas durante o build
    return Consumer<TrackingProvider>(
      builder: (_, trackingProvider, child) {
        // Só acione o recarregamento quando os dados mudam e não está no buildando inicial
        if (trackingProvider.state.isLoaded && 
            (_userRecoveryIds.isEmpty || trackingProvider.state.userHealthRecoveries.length != _userRecoveryIds.length)) {
          // Usar addPostFrameCallback para evitar mudanças durante o build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadData();
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
                        Text(
                          l10n.homeDaysWithoutSmoking(_daysWithoutSmoking),
                          style: context.subtitleStyle,
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
                          RegisterCravingSheet.show(context);
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
                          NewRecordSheet.show(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Indicadores de recuperação de saúde
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.homeHealthRecovery,
                      style: context.titleStyle,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to health recovery screen
                        context.go(AppRoutes.healthRecovery.path);
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
              
              // Indicadores de saúde em linha horizontal com scroll
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildHealthIndicator(context, l10n.homeTaste, _healthRecoveryStatus['taste'] ?? false),
                    _buildHealthIndicator(context, l10n.homeSmell, _healthRecoveryStatus['smell'] ?? false),
                    _buildHealthIndicator(context, l10n.homeCirculation, _healthRecoveryStatus['circulation'] ?? false),
                    _buildHealthIndicator(context, l10n.homeLungs, _healthRecoveryStatus['lungs'] ?? false),
                    _buildHealthIndicator(context, l10n.homeHeart, _healthRecoveryStatus['heart'] ?? false),
                  ],
                ),
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
                    
                  return SizedBox(
                    height: 140,
                    child: hasRecoveries
                        // Mostrar conquistas reais do usuário quando disponíveis
                        ? ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: _buildRecentAchievements(context, l10n),
                          )
                        // Mostrar card motivacional quando não temos conquistas ou estamos carregando
                        : _buildMotivationalCard(context, l10n),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
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
                        // Navigate to dashboard
                        context.go(AppRoutes.dashboard.path);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: context.primaryColor,
                      ),
                      child: Text(
                        'View Dashboard',
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
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
    return Container(
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
    );
  }
  
  Widget _buildGlassMorphicNextMilestone(BuildContext context, AppLocalizations l10n) {
    return ClipRRect(
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
    );
  }
  
  Widget _buildMilestoneContent(BuildContext context, Color textColor, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.flag_rounded,
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
                l10n.homeNextMilestone,
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
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
  
  // Constrói um card motivacional quando não há conquistas
  Widget _buildMotivationalCard(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primaryColor.withOpacity(0.7),
              context.primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.importantAchievements,
                    style: context.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.achievementsDescription,
              style: context.textTheme.bodyMedium!.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.congratulations,
              style: context.textTheme.bodyMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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