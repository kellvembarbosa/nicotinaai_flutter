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
    _isInitialized = true;
    debugPrint('✅ SuperwallTrackingAdapter initialized');
    return;
  }

  /// Track evento normal ou feature pag
  @override
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (!_isInitialized || !_isTrackingEnabled) return;

    sw.Superwall.shared.registerPlacement(eventName, params: parameters?.cast<String, Object>());
  }

  /// Track apenas para features pagas (executa a função e registra o evento)
  Future<void> trackEventOnlyPaid(String eventName, {Map<String, dynamic>? parameters, required VoidCallback onPaidFeature}) async {
    if (!_isInitialized || !_isTrackingEnabled) return;
    sw.Superwall.shared.registerPlacement(eventName, params: parameters?.cast<String, Object>(), feature: onPaidFeature);
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
