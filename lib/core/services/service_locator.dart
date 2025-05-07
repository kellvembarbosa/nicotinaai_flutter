import 'package:flutter/material.dart';

import 'package:nicotinaai_flutter/core/services/theme_service.dart';
import 'package:nicotinaai_flutter/core/services/currency_service.dart';
import 'package:nicotinaai_flutter/core/services/developer_mode_service.dart';
import 'package:nicotinaai_flutter/core/services/locale_service.dart';

/// ServiceLocator initializes and provides access to all application services.
/// 
/// This class handles the initialization sequence and dependencies between services.
class ServiceLocator {
  // Private constructor for singleton
  ServiceLocator._();
  
  // Singleton instance
  static final ServiceLocator _instance = ServiceLocator._();
  
  // Factory constructor to return singleton instance
  factory ServiceLocator() => _instance;
  
  // Flag to track initialization status
  bool _isInitialized = false;
  
  /// Initializes all services in the correct order
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Run in a specific sequence if there are dependencies between services
    await Future.wait([
      themeService.initialize(),
      currencyService.initialize(),
      developerModeService.initialize(),
      localeService.initialize(),
    ]);
    
    _isInitialized = true;
  }
  
  /// Reset all services (useful for testing)
  Future<void> reset() async {
    await developerModeService.reset();
    await themeService.resetToSystemDefault();
    await currencyService.resetToDeviceCurrency();
    await localeService.setLocaleByLanguageCode('en');
  }
  
  /// Check if services are initialized
  bool get isInitialized => _isInitialized;
}

/// Services provider widget to make services available in the widget tree.
/// 
/// This widget should be placed high in the widget tree to provide
/// access to services throughout the application.
class ServicesProvider extends StatelessWidget {
  final Widget child;
  
  const ServicesProvider({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return child;
  }
  
  /// Create the ServicesProvider with initialization
  static Future<ServicesProvider> create({
    required Widget child,
  }) async {
    await ServiceLocator().initialize();
    return ServicesProvider(child: child);
  }
}

// Global instance for easy access
final serviceLocator = ServiceLocator();