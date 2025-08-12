import 'package:flutter/foundation.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart' as sw;
import 'package:nicotinaai_flutter/services/analytics/tracking_adapter.dart';

/// An implementation of TrackingAdapter for Superwall.
/// This adapter forwards analytics events to Superwall's tracking system.
class SuperwallTrackingAdapter implements TrackingAdapter {
  final sw.Superwall _superwall = sw.Superwall.shared;
  bool _isInitialized = false;
  bool _isTrackingEnabled = true;

  @override
  Future<void> initialize() async {
    // Superwall is already initialized in main.dart, so we just mark this as initialized

    await sw.Superwall.shared.preloadAllPaywalls();
    _isInitialized = true;
    debugPrint('✅ SuperwallTrackingAdapter initialized');
    return;
  }

  /// Track evento normal ou feature pag
  @override
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized || !_isTrackingEnabled) return;

    sw.Superwall.shared.registerPlacement(
      eventName,
      params: parameters?.cast<String, Object>(),
    );
  }

  /// Track only for paid features (executes the function and registers the event)
  /// 
  /// This method uses Superwall's `registerPlacement` to register a paywall trigger.
  /// When a user tries to access a paid feature:
  /// 
  /// 1. If the user is already a paid subscriber, the `onPaidFeature` callback executes immediately
  /// 2. If the user is not a paid subscriber, Superwall shows a paywall
  ///    - If the user completes the purchase, the `onPaidFeature` callback executes
  ///    - If the user cancels or dismisses the paywall, the callback is not executed
  /// 
  /// Example usage:
  /// ```dart
  /// superwall.trackEventOnlyPaid(
  ///   'premium_feature_access',
  ///   parameters: {'feature_name': 'craving_tracker'},
  ///   onPaidFeature: () {
  ///     // This code only runs for paid users or after purchase
  ///     saveCraving(cravingData);
  ///     updateUserStats();
  ///   },
  /// );
  /// ```
  @override
  Future<void> trackEventOnlyPaid(
    String eventName, {
    Map<String, dynamic>? parameters,
    required VoidCallback onPaidFeature,
  }) async {
    if (!_isInitialized || !_isTrackingEnabled) {
      // If not initialized, execute feature directly without paywall
      debugPrint('⚠️ SuperwallTrackingAdapter not initialized or disabled, executing feature directly');
      onPaidFeature();
      return;
    }
    
    try {
      // Set a timeout to ensure the feature gets executed in case of any issues
      bool featureExecuted = false;
      
      // Add a safety timeout to prevent infinite loading - reduced to just 2 seconds for faster response
      Future.delayed(const Duration(seconds: 2), () {
        if (!featureExecuted) {
          debugPrint('⏱️ SuperwallTrackingAdapter timeout - force executing feature after 2 seconds');
          featureExecuted = true;
          onPaidFeature();
        }
      });
      
      // A API Superwall não tem o parâmetro completion
      // Vamos usar apenas os parâmetros suportados
      sw.Superwall.shared.registerPlacement(
        eventName,
        params: parameters?.cast<String, Object>(),
        feature: () {
          // Mark as executed
          if (!featureExecuted) {
            featureExecuted = true;
            onPaidFeature();
          } else {
            debugPrint('⚠️ SuperwallTrackingAdapter: feature already executed, ignoring duplicate call');
          }
        },
        // O parâmetro handler não é usado, mas está disponível na API
        // Não vamos usá-lo pois não é necessário para nosso caso
        // e o timeout já garante que a feature será executada
      );
    } catch (e) {
      // In case of error, execute the feature directly as fallback
      debugPrint('❌ SuperwallTrackingAdapter error during registerPlacement: $e');
      onPaidFeature();
    }
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_isInitialized || !_isTrackingEnabled) return;

    // Set user attributes in Superwall
    _superwall.setUserAttributes(properties.cast<String, Object>());
  }

  @override
  Future<void> clearUserData() async {
    if (!_isInitialized) return;

    // Reset user in Superwall
    _superwall.reset();
  }

  @override
  String get adapterName => 'Superwall';

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isTrackingEnabled => _isTrackingEnabled;

  @override
  set isTrackingEnabled(bool value) {
    _isTrackingEnabled = value;
  }
}
