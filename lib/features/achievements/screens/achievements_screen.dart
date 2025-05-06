import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';

class AchievementsScreen extends StatefulWidget {
  static const String routeName = '/achievements';
  
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['Todos', 'Saúde', 'Tempo', 'Economia', 'Hábitos'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSummarySection(),
                const SizedBox(height: 24),
                _buildTabBar(),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProgressTracker(),
                const SizedBox(height: 24),
                ..._buildAchievementsList(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: context.backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Conquistas',
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

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: context.isDarkMode 
          ? _buildGlassmorphicSummaryCard() 
          : _buildRegularSummaryCard(),
    );
  }

  Widget _buildGlassmorphicSummaryCard() {
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
          child: _buildSummaryContent(),
        ),
      ),
    );
  }

  Widget _buildRegularSummaryCard() {
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
      child: _buildSummaryContent(textColor: Colors.white),
    );
  }

  Widget _buildSummaryContent({Color? textColor}) {
    final textStyle = textColor ?? context.contentColor;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAchievementCountItem('4', 'Desbloqueadas', textStyle),
        _buildDivider(context),
        _buildAchievementCountItem('8', 'Em progresso', textStyle),
        _buildDivider(context),
        _buildAchievementCountItem('33%', 'Concluídas', textStyle),
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

  Widget _buildProgressTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          child: Text(
            'Seu Progresso Atual',
            style: context.titleStyle.copyWith(fontSize: 20),
          ),
        ),
        context.isDarkMode
            ? _buildGlassmorphicProgressCard()
            : _buildRegularProgressCard(),
      ],
    );
  }

  Widget _buildGlassmorphicProgressCard() {
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
          child: _buildProgressContent(),
        ),
      ),
    );
  }

  Widget _buildRegularProgressCard() {
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
      child: _buildProgressContent(),
    );
  }

  Widget _buildProgressContent() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '7 dias sem fumar',
              style: context.titleStyle.copyWith(fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Nível 2',
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
              'Próximo nível: 2 semanas',
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
        _buildHealthBenefits(),
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

  Widget _buildHealthBenefits() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBenefitItem('CO2 Normal', Icons.air, Colors.green),
        _buildBenefitItem('Paladar Melhorado', Icons.restaurant, Colors.orange),
        _buildBenefitItem('Circulação +15%', Icons.favorite, Colors.red),
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

  List<Widget> _buildAchievementsList() {
    final achievements = [
      _AchievementData(
        title: 'Primeiro Dia',
        description: 'Complete 24 horas sem fumar',
        icon: Icons.calendar_today,
        badge: '24h',
        isUnlocked: true,
        category: 'Tempo',
      ),
      _AchievementData(
        title: 'Uma Semana',
        description: 'Uma semana sem fumar!',
        icon: Icons.celebration,
        badge: '7 dias',
        isUnlocked: true,
        category: 'Tempo',
      ),
      _AchievementData(
        title: 'Circulação Melhorada',
        description: 'Níveis de oxigênio normalizados',
        icon: Icons.favorite,
        badge: 'Saúde',
        isUnlocked: true,
        category: 'Saúde',
      ),
      _AchievementData(
        title: 'Economia Inicial',
        description: 'Economize o equivalente a 1 maço de cigarros',
        icon: Icons.savings,
        badge: 'R\$ 25',
        isUnlocked: true,
        category: 'Economia',
      ),
      _AchievementData(
        title: 'Duas Semanas',
        description: 'Duas semanas completas sem fumar!',
        icon: Icons.calendar_month,
        badge: '14 dias',
        isUnlocked: false,
        category: 'Tempo',
        progress: 0.5,
      ),
      _AchievementData(
        title: 'Economia Substancial',
        description: 'Economize o equivalente a 10 maços de cigarros',
        icon: Icons.attach_money,
        badge: 'R\$ 250',
        isUnlocked: false,
        category: 'Economia',
        progress: 0.4,
      ),
      _AchievementData(
        title: 'Respiração Limpa',
        description: 'Capacidade pulmonar aumentada em 30%',
        icon: Icons.air,
        badge: 'Saúde',
        isUnlocked: false,
        category: 'Saúde',
        progress: 0.3,
      ),
      _AchievementData(
        title: 'Um Mês',
        description: 'Um mês inteiro sem fumar!',
        icon: Icons.emoji_events,
        badge: '30 dias',
        isUnlocked: false,
        category: 'Tempo',
        progress: 0.23,
      ),
      _AchievementData(
        title: 'Novo Hábito: Exercícios',
        description: 'Registre 5 dias de exercícios',
        icon: Icons.fitness_center,
        badge: 'Hábitos',
        isUnlocked: false,
        category: 'Hábitos',
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
      ),
    ).toList();
  }

  Widget _buildEnhancedAchievementItem(
    BuildContext context, 
    String title, 
    String description, 
    IconData icon, 
    bool unlocked, 
    {String? badge, double progress = 0.0}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: context.isDarkMode && unlocked
          ? _buildGlassmorphicAchievementCard(context, title, description, icon, unlocked, badge, progress)
          : _buildStandardAchievementCard(context, title, description, icon, unlocked, badge, progress),
    );
  }

  Widget _buildGlassmorphicAchievementCard(
    BuildContext context, 
    String title, 
    String description, 
    IconData icon, 
    bool unlocked, 
    String? badge, 
    double progress
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
          child: _buildAchievementContent(context, title, description, icon, unlocked, badge, progress),
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
    double progress
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
      child: _buildAchievementContent(context, title, description, icon, unlocked, badge, progress),
    );
  }

  Widget _buildAchievementContent(
    BuildContext context, 
    String title, 
    String description, 
    IconData icon, 
    bool unlocked, 
    String? badge, 
    double progress
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
                    '${(progress * 100).toInt()}% concluído',
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