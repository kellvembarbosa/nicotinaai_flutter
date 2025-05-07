import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LocaleService manages application language settings using Signals.
/// 
/// This service handles locale selection, persistence, and provides reactive 
/// access to locale data.
class LocaleService {
  // Constants for storage
  static const String _localePrefsKey = 'app_locale';
  
  // Signal for the current locale
  final currentLocale = Signal<Locale?>(null);
  
  // Computed signal for the locale code (e.g., 'en', 'pt')
  late final localeCode = computed(() {
    return currentLocale.value?.languageCode ?? 'en';
  });
  
  // Supported locales in the application
  final List<Locale> supportedLocales = const [
    Locale('en'), // English
    Locale('pt'), // Portuguese
  ];
  
  // Maps language codes to their names for UI display
  final Map<String, String> languageNames = const {
    'en': 'English',
    'pt': 'Português',
  };
  
  // Private constructor for singleton
  LocaleService._();
  
  // Singleton instance
  static final LocaleService _instance = LocaleService._();
  
  // Factory constructor to return singleton instance
  factory LocaleService() => _instance;
  
  /// Initialize the locale service by loading saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localePrefsKey);
    
    if (savedLocale != null) {
      currentLocale.value = Locale(savedLocale);
    } else {
      // Default to device locale or English if not supported
      // Note: This would typically check against device locale
      currentLocale.value = const Locale('en');
    }
  }
  
  /// Change the application locale
  Future<void> setLocale(Locale locale) async {
    if (isSupported(locale)) {
      currentLocale.value = locale;
      
      // Persist the setting
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localePrefsKey, locale.languageCode);
    }
  }
  
  /// Set locale by language code
  Future<void> setLocaleByLanguageCode(String languageCode) async {
    final locale = Locale(languageCode);
    await setLocale(locale);
  }
  
  /// Check if a locale is supported
  bool isSupported(Locale locale) {
    return supportedLocales.contains(Locale(locale.languageCode));
  }
  
  /// Get the display name for a locale
  String getLanguageName(Locale locale) {
    return languageNames[locale.languageCode] ?? 'Unknown';
  }
  
  /// Get the display name for the current locale
  String get currentLanguageName {
    return getLanguageName(currentLocale.value ?? const Locale('en'));
  }
  
  /// Get the list of supported languages with their codes and names
  List<Map<String, String>> get supportedLanguages {
    return supportedLocales.map((locale) {
      return {
        'code': locale.languageCode,
        'name': languageNames[locale.languageCode] ?? 'Unknown',
      };
    }).toList();
  }
}

// Global instance for easy access
final localeService = LocaleService();