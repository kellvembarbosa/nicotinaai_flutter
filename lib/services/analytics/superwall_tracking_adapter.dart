import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:nicotinaai_flutter/services/analytics/tracking_adapter.dart';

/// An implementation of TrackingAdapter for Superwall.
/// This adapter forwards analytics events to Superwall's tracking system.
class SuperwallTrackingAdapter implements TrackingAdapter {
  final Superwall _superwall = Superwall.instance;

  @override
  void trackEvent(String name, {Map<String, dynamic>? properties}) {
    // Forward events to Superwall
    _superwall.track(name, properties: properties ?? {});
  }

  @override
  void identify(String userId, {Map<String, dynamic>? traits}) {
    // Identify user in Superwall
    _superwall.setUserAttributes(traits ?? {});
  }

  @override
  void reset() {
    // Reset user in Superwall
    _superwall.reset();
  }

  @override
  void logScreen(String screenName, {Map<String, dynamic>? properties}) {
    // Log screen view in Superwall
    final screenProperties = properties ?? {};
    screenProperties['screen'] = screenName;
    _superwall.track('Screen View', properties: screenProperties);
  }
}
