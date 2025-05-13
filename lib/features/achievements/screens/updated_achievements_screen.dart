import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_bloc.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_event.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_state.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_bloc.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_event.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';

import '../models/user_achievement.dart';
import '../models/time_period.dart';
import '../models/achievement_definition.dart';
import '../widgets/time_period_selector.dart';

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

  // Flag para controlar carga única de achievements
  bool _hasLoadedAchievements = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Load achievements quando a tela inicializa
    _loadAchievements();
  }
  
  // Time tracking for achievement loading
  static DateTime? _lastScreenLoadTime;
  static const _minScreenLoadIntervalMs = 60000; // 1 minuto entre carregamentos
  
  /// Verifica se podemos recarregar achievements baseado no tempo decorrido desde o último carregamento de tela
  bool get _canReloadAchievements {
    if (_lastScreenLoadTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(_lastScreenLoadTime!).inMilliseconds;
    return difference > _minScreenLoadIntervalMs;
  }
  
  void _loadAchievements() {
    // Atualizar o tempo de última carga da tela
    _lastScreenLoadTime = DateTime.now();
    
    // Forçar carregamento de achievements quando a tela é aberta, mas com limites
    Future.microtask(() {
      final achievementBloc = context.read<AchievementBloc>();
      final state = achievementBloc.state;
      
      // Verificar o estado atual
      if (state.status == AchievementStatus.initial ||
          state.userAchievements.isEmpty) {
        // Primeira carga - sempre executar
        debugPrint('🔄 [AchievementsScreen] Carregando achievements pela primeira vez');
        _hasLoadedAchievements = true;
        achievementBloc.add(InitializeAchievements());
      } else if (!_hasLoadedAchievements && _canReloadAchievements) {
        // Ainda não carregou nesta sessão e passou tempo suficiente
        debugPrint('🔄 [AchievementsScreen] Recarregando achievements após intervalo');
        _hasLoadedAchievements = true;
        achievementBloc.add(InitializeAchievements());
      } else {
        debugPrint('ℹ️ [AchievementsScreen] Usando achievements em cache: ${state.userAchievements.length}');
      }
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final newCategory = _categories[_tabController.index].toLowerCase();
      
      // Track category change
      final analyticsBloc = context.read<AnalyticsBloc>();
      analyticsBloc.add(TrackCustomEvent(
        'achievement_category_changed',
        parameters: {
          'category': newCategory,
          'previous_category': _currentCategory,
        }
      ));
      
      setState(() {
        _currentCategory = newCategory;
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
    
    _categories = [
      l10n.achievementCategoryAll,
      l10n.achievementCategoryHealth,
      l10n.achievementCategoryTime,
      l10n.achievementCategorySavings,
      l10n.achievementCategoryHabits
    ];
    
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          body: state.status == AchievementStatus.loading 
              ? _buildLoadingIndicator()
              : state.status == AchievementStatus.error
                  ? _buildErrorView(state.errorMessage ?? 'Unknown error')
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildSliverAppBar(l10n),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              _buildSummarySection(l10n, state),
                              const SizedBox(height: 16),
                              const TimePeriodSelector(),
                              const SizedBox(height: 16),
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
      },
    );
  }
  
  // Loading indicator with progress spinner
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading achievements...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: context.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
  
  // Error view with retry button
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error loading achievements',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.contentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: context.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Track retry button click
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(const TrackCustomEvent(
                  'achievement_retry_clicked',
                  parameters: {'source': 'error_view'},
                ));
                
                context.read<AchievementBloc>().add(InitializeAchievements());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: context.backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          l10n.achievements,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: context.contentColor,
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with gradient overlay
            Image.asset(
              'assets/images/smoke-one.png',
              fit: BoxFit.cover,
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.3),
                    context.backgroundColor,
                  ],
                ),
              ),
            ),
            // Frosted glass effect for title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 60,
                    color: context.isDarkMode 
                        ? Colors.black.withOpacity(0.2) 
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(AppLocalizations l10n, AchievementState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: context.isDarkMode 
          ? _buildGlassmorphicSummaryCard(l10n, state) 
          : _buildRegularSummaryCard(l10n, state),
    );
  }

  Widget _buildGlassmorphicSummaryCard(AppLocalizations l10n, AchievementState state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: _buildSummaryContent(l10n, state),
        ),
      ),
    );
  }

  Widget _buildRegularSummaryCard(AppLocalizations l10n, AchievementState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primaryColor.withOpacity(0.8),
            context.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _buildSummaryContent(l10n, state, textColor: Colors.white),
    );
  }

  Widget _buildSummaryContent(AppLocalizations l10n, AchievementState state, {Color? textColor}) {
    final textStyle = textColor ?? context.contentColor;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAchievementCountItem('${state.unlockedCount}', l10n.achievementUnlocked, textStyle),
        _buildDivider(context),
        _buildAchievementCountItem('${state.inProgressCount}', l10n.achievementInProgress, textStyle),
        _buildDivider(context),
        _buildAchievementCountItem(state.completionPercentage, l10n.achievementCompleted, textStyle),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: context.isDarkMode 
          ? Colors.white.withOpacity(0.2) 
          : Colors.white.withOpacity(0.5),
    );
  }

  Widget _buildAchievementCountItem(String value, String label, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: textColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: context.primaryColor,
        unselectedLabelColor: context.subtitleColor,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: context.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _categories.map((category) => Tab(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              category,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildProgressTracker(AppLocalizations l10n, AchievementState state) {
    // Verificar se temos dados de achievements carregados
    if (state.status == AchievementStatus.loading) {
      return Center(child: CircularProgressIndicator());
    }
    
    // Get days smoke-free from time achievements
    UserAchievement timeDaysAchievement;
    
    try {
      // Verificar primeiro se há dados disponíveis
      if (state.userAchievements.isEmpty && state.allDefinitions.isEmpty) {
        // Se não houver dados, lançar exceção para usar o fallback
        throw Exception('No achievements or definitions available');
      }
      
      // Primeiro tentamos encontrar nos achievements do usuário
      timeDaysAchievement = state.userAchievements.firstWhere(
        (a) => a.definition.requirementType == 'DAYS_SMOKE_FREE' && a.definition.requirementValue == 30,
        orElse: () {
          // Se não encontrado nas conquistas do usuário, tentamos encontrar na definição
          if (state.allDefinitions.isNotEmpty) {
            // Tentamos encontrar uma definição específica para dias sem fumar
            AchievementDefinition? definition;
            try {
              definition = state.allDefinitions.firstWhere(
                (d) => d.requirementType == 'DAYS_SMOKE_FREE' && d.requirementValue == 30,
                // Não usamos first aqui pois pode causar erro se a lista estiver vazia
              );
            } catch (e) {
              // Se não encontrarmos a definição específica e a lista não estiver vazia,
              // usamos a primeira definição disponível
              if (state.allDefinitions.isNotEmpty) {
                definition = state.allDefinitions.first;
              } else {
                // Se não houver definições, lançamos exceção para usar o fallback
                throw Exception('No suitable achievement definition found');
              }
            }
            
            // Se encontramos uma definição, criamos um achievement temporário
            if (definition != null) {
              return UserAchievement(
                id: 'placeholder',
                definition: definition,
                unlockedAt: DateTime.now(),
                isViewed: false,
                progress: 0.0,
              );
            }
          }
          
          // Se chegamos aqui, não encontramos nenhuma definição adequada
          throw Exception('No achievement definitions available');
        },
      );
    } catch (e) {
      // Fallback for any error scenario
      print('Error finding smoke-free achievement: $e');
      // Create a placeholder achievement with default values
      timeDaysAchievement = UserAchievement(
        id: 'error-placeholder',
        definition: AchievementDefinition(
          id: 'error-placeholder',
          name: l10n.achievementDaysWithoutSmoking(0),
          description: 'Track your smoke-free days',
          iconName: 'access_time',
          requirementType: 'DAYS_SMOKE_FREE',
          requirementValue: 30,
          badgeText: 'Health',
          category: 'health',
          orderIndex: 0,
          xpReward: 100,
        ),
        unlockedAt: DateTime.now(),
        isViewed: false,
        progress: 0.0,
      );
    }
    
    final daysSmokeFreee = (timeDaysAchievement.progress * 30).round();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          child: Text(
            l10n.achievementCurrentProgress,
            style: context.titleStyle.copyWith(fontSize: 20),
          ),
        ),
        context.isDarkMode
            ? _buildGlassmorphicProgressCard(l10n, daysSmokeFreee, timeDaysAchievement.progress)
            : _buildRegularProgressCard(l10n, daysSmokeFreee, timeDaysAchievement.progress),
      ],
    );
  }

  Widget _buildGlassmorphicProgressCard(AppLocalizations l10n, int days, double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: _buildProgressContent(l10n, days, progress),
        ),
      ),
    );
  }

  Widget _buildRegularProgressCard(AppLocalizations l10n, int days, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
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
      child: _buildProgressContent(l10n, days, progress),
    );
  }

  Widget _buildProgressContent(AppLocalizations l10n, int days, double progress) {
    // Calculate next level based on days
    String nextLevel = '2 weeks';
    int level = 1;
    
    if (days >= 180) {
      nextLevel = '1 year';
      level = 6;
    } else if (days >= 90) {
      nextLevel = '6 months';
      level = 5;
    } else if (days >= 30) {
      nextLevel = '3 months';
      level = 4;
    } else if (days >= 14) {
      nextLevel = '1 month';
      level = 3;
    } else if (days >= 7) {
      nextLevel = '2 weeks';
      level = 2;
    } else {
      nextLevel = '1 week';
      level = 1;
    }
    
    // Get the current time period filter from bloc
    final achievementBloc = context.read<AchievementBloc>();
    final timePeriod = achievementBloc.state.selectedTimePeriod;
    final bool isFiltered = timePeriod != TimePeriod.allTime;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.achievementDaysWithoutSmoking(days),
                style: context.titleStyle.copyWith(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isFiltered)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        timePeriod.icon,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timePeriod.displayName(context),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                l10n.achievementLevel(level),
                style: GoogleFonts.poppins(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildAnimatedProgressBar(progress),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.achievementNextLevel(nextLevel),
              style: GoogleFonts.poppins(
                color: context.subtitleColor,
                fontSize: 14,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: GoogleFonts.poppins(
                color: context.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildHealthBenefits(l10n),
      ],
    );
  }

  Widget _buildAnimatedProgressBar(double value) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          // Shine effect (light mode only)
          if (!context.isDarkMode)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.7),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.5],
                  ),
                ),
              ),
            ),
          // Animated progress bar
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
                    color: context.primaryColor.withOpacity(0.5),
                    blurRadius: 6,
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

  Widget _buildHealthBenefits(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBenefitItem(l10n.achievementBenefitCO2, Icons.air, Colors.green),
        _buildBenefitItem(l10n.achievementBenefitTaste, Icons.restaurant, Colors.orange),
        _buildBenefitItem(l10n.achievementBenefitCirculation, Icons.favorite, Colors.red),
      ],
    );
  }

  Widget _buildBenefitItem(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // Track health benefit click
        final analyticsBloc = context.read<AnalyticsBloc>();
        analyticsBloc.add(TrackCustomEvent(
          'health_benefit_clicked',
          parameters: {
            'benefit_type': label,
            'source': 'achievements_screen',
          }
        ));
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(context.isDarkMode ? 0.15 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAchievementsList(AppLocalizations l10n, AchievementState state) {
    final timePeriod = state.selectedTimePeriod;
    final achievements = state.getAchievementsByCategory(_currentCategory);
    
    if (achievements.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined, 
                  size: 48, 
                  color: context.isDarkMode ? Colors.grey[600] : Colors.grey[400]
                ),
                const SizedBox(height: 16),
                timePeriod == TimePeriod.allTime
                  ? Text(
                      'No achievements in this category yet',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: context.subtitleColor,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      'No achievements in ${timePeriod.displayName(context).toLowerCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: context.subtitleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                const SizedBox(height: 8),
                if (timePeriod != TimePeriod.allTime)
                  TextButton(
                    onPressed: () {
                      // Track show all achievements click
                      final analyticsBloc = context.read<AnalyticsBloc>();
                      analyticsBloc.add(TrackCustomEvent(
                        'show_all_achievements_clicked',
                        parameters: {
                          'previous_filter': timePeriod.name,
                          'category': _currentCategory,
                        },
                      ));
                      
                      context.read<AchievementBloc>().add(ChangeTimePeriod(TimePeriod.allTime));
                    },
                    child: Text('Show all achievements'),
                  ),
              ],
            ),
          ),
        ),
      ];
    }
    
    return achievements.map((achievement) => 
      _buildEnhancedAchievementItem(
        context,
        achievement,
        l10n,
      ),
    ).toList();
  }

  Widget _buildEnhancedAchievementItem(
    BuildContext context, 
    UserAchievement achievement,
    AppLocalizations l10n
  ) {
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
    final unlocked = achievement.isUnlocked;
    final progress = achievement.progress;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Track achievement item click
          final analyticsBloc = context.read<AnalyticsBloc>();
          analyticsBloc.add(TrackCustomEvent(
            'achievement_item_clicked',
            parameters: {
              'achievement_id': achievement.id,
              'achievement_name': achievement.definition.name,
              'achievement_category': achievement.definition.category,
              'is_unlocked': achievement.isUnlocked,
              'progress': (achievement.progress * 100).toInt(),
            },
          ));
          
          // Navigate to achievement detail screen using push to maintain history
          HapticFeedback.lightImpact();
          context.push(AppRoutes.achievementDetail.withParams(params: {
            'achievementId': achievement.id,
          }));
        },
        borderRadius: BorderRadius.circular(16),
        child: context.isDarkMode && unlocked
            ? _buildGlassmorphicAchievementCard(context, achievement, iconData, l10n)
            : _buildStandardAchievementCard(context, achievement, iconData, l10n),
      ),
    );
  }

  Widget _buildGlassmorphicAchievementCard(
    BuildContext context, 
    UserAchievement achievement,
    IconData icon,
    AppLocalizations l10n
  ) {
    final primaryColor = context.primaryColor;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: _buildAchievementContent(context, achievement, icon, l10n),
        ),
      ),
    );
  }

  Widget _buildStandardAchievementCard(
    BuildContext context, 
    UserAchievement achievement,
    IconData icon,
    AppLocalizations l10n
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: context.isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: _buildAchievementContent(context, achievement, icon, l10n),
    );
  }

  Widget _buildAchievementContent(
    BuildContext context, 
    UserAchievement achievement,
    IconData icon,
    AppLocalizations l10n
  ) {
    final unlocked = achievement.isUnlocked;
    final progress = achievement.progress;
    final badge = achievement.definition.badgeText;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildAchievementIcon(context, icon, unlocked),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.definition.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: unlocked ? context.contentColor : context.subtitleColor,
                        ),
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: unlocked
                              ? context.primaryColor.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: unlocked
                                ? context.primaryColor
                                : context.subtitleColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.definition.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: unlocked ? context.subtitleColor : context.subtitleColor.withOpacity(0.8),
                  ),
                ),
                if (!unlocked && progress > 0) ...[
                  const SizedBox(height: 12),
                  _buildAdvancedProgressBar(progress),
                  const SizedBox(height: 6),
                  Text(
                    l10n.percentCompleted((progress * 100).toInt()),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: context.subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (unlocked)
            _buildUnlockedIndicator(context),
        ],
      ),
    );
  }

  Widget _buildAchievementIcon(BuildContext context, IconData icon, bool unlocked) {
    final primaryColor = context.primaryColor;
    
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: unlocked
            ? LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.8),
                  primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: unlocked ? null : context.isDarkMode ? Colors.grey[700] : Colors.grey[300],
        shape: BoxShape.circle,
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        color: unlocked ? Colors.white : context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
        size: 30,
      ),
    );
  }

  Widget _buildUnlockedIndicator(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[300]!,
            Colors.green,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildAdvancedProgressBar(double value) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[300]!,
                    context.primaryColor,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4),
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
}