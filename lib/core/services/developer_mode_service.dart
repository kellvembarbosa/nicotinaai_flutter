import 'package:signals/signals.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// DeveloperModeService manages developer settings using Signals.
/// 
/// This service provides signals for tracking developer mode and other
/// developer-specific features.
class DeveloperModeService {
  // Constants for storage
  static const String _devModePrefsKey = 'developer_mode';
  
  // Signal for developer mode state
  final isDeveloperMode = Signal<bool>(false);
  
  // Private constructor for singleton
  DeveloperModeService._();
  
  // Singleton instance
  static final DeveloperModeService _instance = DeveloperModeService._();
  
  // Factory constructor to return singleton instance
  factory DeveloperModeService() => _instance;
  
  /// Initialize the developer mode service by loading saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDevMode = prefs.getBool(_devModePrefsKey);
    
    if (savedDevMode != null) {
      isDeveloperMode.value = savedDevMode;
    }
  }
  
  /// Toggle developer mode on/off
  Future<void> toggleDeveloperMode() async {
    isDeveloperMode.value = !isDeveloperMode.value;
    
    // Persist the setting
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_devModePrefsKey, isDeveloperMode.value);
  }
  
  /// Set developer mode explicitly
  Future<void> setDeveloperMode(bool enabled) async {
    isDeveloperMode.value = enabled;
    
    // Persist the setting
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_devModePrefsKey, enabled);
  }
  
  /// Reset developer mode to disabled
  Future<void> reset() async {
    await setDeveloperMode(false);
  }
}

// Global instance for easy access
final developerModeService = DeveloperModeService();