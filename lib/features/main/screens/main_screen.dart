import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/achievements/screens/updated_achievements_screen.dart';
import 'package:nicotinaai_flutter/features/achievements/helpers/achievement_helper.dart';
import 'package:nicotinaai_flutter/features/home/screens/home_screen.dart';
import 'package:nicotinaai_flutter/features/settings/screens/settings_screen.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

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
  
  // List of screens for the tabs
  final List<Widget> _screens = [
    const HomeScreen(),
    const AchievementsScreen(),
    const SettingsScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    // Schedule achievement initialization for after the first frame
    // Using a delayed execution to prevent initialization during router redirects
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _initializeAchievementsOnce();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.name ?? 'User';
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
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
          setState(() {
            _currentIndex = index;
          });
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