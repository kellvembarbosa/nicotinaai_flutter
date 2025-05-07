import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeService manages the application theme settings using Signals.
/// 
/// This service stores the theme setting in SharedPreferences and 
/// provides reactive access to the theme state via signals.
class ThemeService {
  // Constants for storage
  static const String _themePrefsKey = 'theme_mode';
  
  // Theme mode signal that notifies listeners when changed
  final themeMode = Signal<ThemeMode>(ThemeMode.system);
  
  // Computed signal to determine if dark mode is currently active
  late final isDarkMode = computed(() {
    return themeMode.value == ThemeMode.dark;
  });
  
  // Private constructor for singleton
  ThemeService._();
  
  // Singleton instance
  static final ThemeService _instance = ThemeService._();
  
  // Factory constructor to return singleton instance
  factory ThemeService() => _instance;
  
  /// Initialize the theme service by loading saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt(_themePrefsKey);
    
    if (savedThemeIndex != null) {
      themeMode.value = ThemeMode.values[savedThemeIndex];
    }
  }
  
  /// Set the theme mode and save to preferences
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    
    // Persist the setting
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePrefsKey, mode.index);
  }
  
  /// Check if a specific theme mode is active
  bool isActive(ThemeMode mode) {
    return themeMode.value == mode;
  }
  
  /// Toggle between light and dark modes
  Future<void> toggleTheme() async {
    if (themeMode.value == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
  
  /// Reset theme to system default
  Future<void> resetToSystemDefault() async {
    await setThemeMode(ThemeMode.system);
  }
}

// Global instance for easy access
final themeService = ThemeService();