import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/achievements/screens/updated_achievements_screen.dart';
import 'package:nicotinaai_flutter/features/achievements/helpers/achievement_helper.dart';
import 'package:nicotinaai_flutter/features/home/screens/home_screen.dart';
import 'package:nicotinaai_flutter/features/main/widgets/main_screen_tab.dart';
import 'package:nicotinaai_flutter/features/settings/screens/settings_screen.dart';
// Unused import removed - dashboard screen is now accessed via statisticsDashboard route
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/feedback_trigger_service.dart';

/// MainScreen with tab navigation
class MainScreen extends StatefulWidget {
  static const String routeName = '/main';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _hasInitializedAchievements = false;
  
  // Feedback trigger service
  final FeedbackTriggerService _feedbackService = FeedbackTriggerService();
  
  // Always use the standard HomeScreen implementation
  Widget get _homeScreen => const HomeScreen();
  
  // List of screens for the tabs (using a getter to ensure we always get the current home screen)
  List<Widget> get _screens => [
    _homeScreen,
    const AchievementsScreen(),
    const SettingsScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    // Initialize the feedback service
    _feedbackService.init();
    
    // Schedule achievement initialization for after the first frame
    // Using a delayed execution to prevent initialization during router redirects
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _initializeAchievementsOnce();
        
        // Track screen visit
        _feedbackService.trackScreenVisit();
        
        // Check if feedback should be shown
        _checkForFeedback();
      }
    });
  }
  
  // Check if feedback should be shown
  Future<void> _checkForFeedback() async {
    if (mounted) {
      await _feedbackService.checkAndTriggerFeedback(context);
    }
  }
  
  // Initialize achievements only once with additional safeguards
  void _initializeAchievementsOnce() {
    if (!_hasInitializedAchievements && mounted) {
      print('🏆 MainScreen: Initializing achievements');
      _hasInitializedAchievements = true;
      AchievementHelper.initializeAchievements(context);
    } else {
      print('🏆 MainScreen: Achievements already initialized');
    }
  }

  // Método para mudar para uma aba específica
  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Track screen visit when changing tabs
    _feedbackService.trackScreenVisit();
    
    // Check if feedback should be shown after tab change
    // We use a small delay to allow the tab change animation to complete
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _checkForFeedback();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState.user?.name ?? 'User';
    
    // Key for the home screen
    final Key homeKey = const ValueKey('home_screen');
    
    // Envolver todo o conteúdo com o MainScreenTab InheritedWidget
    return MainScreenTab(
      currentIndex: _currentIndex,
      onTabChanged: _changeTab,
      child: Scaffold(
        body: IndexedStack(
          key: homeKey,
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }
  
  Widget _buildBottomNavigationBar(BuildContext context) {
    final isDark = context.isDarkMode;
    final localizations = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF333333) : Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _changeTab(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: localizations.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events_outlined),
            activeIcon: const Icon(Icons.emoji_events),
            label: localizations.achievements,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: localizations.settings,
          ),
        ],
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        selectedItemColor: context.primaryColor,
        unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}