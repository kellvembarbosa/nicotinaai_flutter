import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/features/achievements/providers/achievement_provider.dart';

class AchievementsScreen extends StatefulWidget {
  static const String routeName = '/achievements';
  
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _categories;

  bool _hasLoadedAchievements = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Carrega achievements apenas uma vez, de forma controlada
    if (!_hasLoadedAchievements) {
      _hasLoadedAchievements = true;
      // Usa microtask para carregar após montagem da UI
      Future.microtask(() {
        // Verifica se já não está carregando achievements em outro lugar
        final achievementProvider = context.read<AchievementProvider>();
        // Só carrega se o estado ainda estiver em initial para evitar recargas desnecessárias
        if (achievementProvider.state.status == AchievementStatus.initial) {
          achievementProvider.loadAchievements();
        }
      });
    }
  }

  @override
  void dispose() {
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
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(l10n),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSummarySection(l10n),
                const SizedBox(height: 24),
                _buildTabBar(),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProgressTracker(l10n),
                const SizedBox(height: 24),
                ..._buildAchievementsList(l10n),
              ]),
            ),
          ),
        ],
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
            // Imagem de fundo com overlay gradiente
            Image.asset(
              'assets/images/smoke-one.png',
              fit: BoxFit.cover,
            ),
            // Overlay gradiente
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
            // Efeito de vidro fosco para título e destaque
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

  Widget _buildSummarySection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: context.isDarkMode 
          ? _buildGlassmorphicSummaryCard(l10n) 
          : _buildRegularSummaryCard(l10n),
    );
  }

  Widget _buildGlassmorphicSummaryCard(AppLocalizations l10n) {
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
          child: _buildSummaryContent(l10n),
        ),
      ),
    );
  }

  Widget _buildRegularSummaryCard(AppLocalizations l10n) {
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
      child: _buildSummaryContent(l10n, textColor: Colors.white),
    );
  }

  Widget _buildSummaryContent(AppLocalizations l10n, {Color? textColor}) {
    final textStyle = textColor ?? context.contentColor;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAchievementCountItem('4', l10n.achievementUnlocked, textStyle),
        _buildDivider(context),
        _buildAchievementCountItem('8', l10n.achievementInProgress, textStyle),
        _buildDivider(context),
        _buildAchievementCountItem('33%', l10n.achievementCompleted, textStyle),
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

  Widget _buildProgressTracker(AppLocalizations l10n) {
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
            ? _buildGlassmorphicProgressCard(l10n)
            : _buildRegularProgressCard(l10n),
      ],
    );
  }

  Widget _buildGlassmorphicProgressCard(AppLocalizations l10n) {
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
          child: _buildProgressContent(l10n),
        ),
      ),
    );
  }

  Widget _buildRegularProgressCard(AppLocalizations l10n) {
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
      child: _buildProgressContent(l10n),
    );
  }

  Widget _buildProgressContent(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.achievementDaysWithoutSmoking(7),
              style: context.titleStyle.copyWith(fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                l10n.achievementLevel(2),
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
        _buildAnimatedProgressBar(0.33),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.achievementNextLevel('2 weeks'),
              style: GoogleFonts.poppins(
                color: context.subtitleColor,
                fontSize: 14,
              ),
            ),
            Text(
              '33%',
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
          // Efeito de brilho (apenas para modo claro)
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
          // Barra de progresso animada
          FractionallySizedBox(
            widthFactor: value,
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
    return Column(
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
    );
  }

  List<Widget> _buildAchievementsList(AppLocalizations l10n) {
    final achievements = [
      _AchievementData(
        title: l10n.achievementFirstDay,
        description: l10n.achievementFirstDayDescription,
        icon: Icons.calendar_today,
        badge: '24h',
        isUnlocked: true,
        category: l10n.achievementCategoryTime,
      ),
      _AchievementData(
        title: l10n.achievementOneWeek,
        description: l10n.achievementOneWeekDescription,
        icon: Icons.celebration,
        badge: '7 dias',
        isUnlocked: true,
        category: l10n.achievementCategoryTime,
      ),
      _AchievementData(
        title: l10n.achievementImprovedCirculation,
        description: l10n.achievementImprovedCirculationDescription,
        icon: Icons.favorite,
        badge: l10n.achievementCategoryHealth,
        isUnlocked: true,
        category: l10n.achievementCategoryHealth,
      ),
      _AchievementData(
        title: l10n.achievementInitialSavings,
        description: l10n.achievementInitialSavingsDescription,
        icon: Icons.savings,
        badge: 'R\$ 25',
        isUnlocked: true,
        category: l10n.achievementCategorySavings,
      ),
      _AchievementData(
        title: l10n.achievementTwoWeeks,
        description: l10n.achievementTwoWeeksDescription,
        icon: Icons.calendar_month,
        badge: '14 dias',
        isUnlocked: false,
        category: l10n.achievementCategoryTime,
        progress: 0.5,
      ),
      _AchievementData(
        title: l10n.achievementSubstantialSavings,
        description: l10n.achievementSubstantialSavingsDescription,
        icon: Icons.attach_money,
        badge: 'R\$ 250',
        isUnlocked: false,
        category: l10n.achievementCategorySavings,
        progress: 0.4,
      ),
      _AchievementData(
        title: l10n.achievementCleanBreathing,
        description: l10n.achievementCleanBreathingDescription,
        icon: Icons.air,
        badge: l10n.achievementCategoryHealth,
        isUnlocked: false,
        category: l10n.achievementCategoryHealth,
        progress: 0.3,
      ),
      _AchievementData(
        title: l10n.achievementOneMonth,
        description: l10n.achievementOneMonthDescription,
        icon: Icons.emoji_events,
        badge: '30 dias',
        isUnlocked: false,
        category: l10n.achievementCategoryTime,
        progress: 0.23,
      ),
      _AchievementData(
        title: l10n.achievementNewHabitExercise,
        description: l10n.achievementNewHabitExerciseDescription,
        icon: Icons.fitness_center,
        badge: l10n.achievementCategoryHabits,
        isUnlocked: false,
        category: l10n.achievementCategoryHabits,
        progress: 0.2,
      ),
    ];
    
    return achievements.map((achievement) => 
      _buildEnhancedAchievementItem(
        context,
        achievement.title,
        achievement.description,
        achievement.icon,
        achievement.isUnlocked,
        badge: achievement.badge,
        progress: achievement.progress,
        l10n: l10n,
      ),
    ).toList();
  }

  Widget _buildEnhancedAchievementItem(
    BuildContext context, 
    String title, 
    String description, 
    IconData icon, 
    bool unlocked, 
    {String? badge, double progress = 0.0, required AppLocalizations l10n}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: context.isDarkMode && unlocked
          ? _buildGlassmorphicAchievementCard(context, title, description, icon, unlocked, badge, progress, l10n)
          : _buildStandardAchievementCard(context, title, description, icon, unlocked, badge, progress, l10n),
    );
  }

  Widget _buildGlassmorphicAchievementCard(
    BuildContext context, 
    String title, 
    String description, 
    IconData icon, 
    bool unlocked, 
    String? badge, 
    double progress,
    AppLocalizations l10n
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: context.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: _buildAchievementContent(context, title, description, icon, unlocked, badge, progress, l10n),
        ),
      ),
    );
  }

  Widget _buildStandardAchievementCard(
    BuildContext context, 
    String title, 
    String description, 
    IconData icon, 
    bool unlocked, 
    String? badge, 
    double progress,
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
      child: _buildAchievementContent(context, title, description, icon, unlocked, badge, progress, l10n),
    );
  }

  Widget _buildAchievementContent(
    BuildContext context, 
    String title, 
    String description, 
    IconData icon, 
    bool unlocked, 
    String? badge, 
    double progress,
    AppLocalizations l10n
  ) {
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
                        title,
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
                  description,
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
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: unlocked
            ? LinearGradient(
                colors: [
                  context.primaryColor.withOpacity(0.8),
                  context.primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: unlocked ? null : Colors.grey[300],
        shape: BoxShape.circle,
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: context.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        color: unlocked ? Colors.white : Colors.grey[600],
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
            widthFactor: value,
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

class _AchievementData {
  final String title;
  final String description;
  final IconData icon;
  final String badge;
  final bool isUnlocked;
  final double progress;
  final String category;

  _AchievementData({
    required this.title,
    required this.description,
    required this.icon,
    required this.badge,
    required this.isUnlocked,
    this.progress = 0.0,
    required this.category,
  });
}