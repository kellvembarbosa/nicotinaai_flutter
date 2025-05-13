import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:nicotinaai_flutter/services/analytics/tracking_adapter.dart';

/// Facebook App Events tracking adapter
class FacebookTrackingAdapter implements TrackingAdapter {
  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();
  bool _isInitialized = false;
  bool _isTrackingEnabled = true;
  bool _hasTrackingPermission = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Facebook App Events
      await _facebookAppEvents.setAdvertiserTracking(enabled: true);
      await _facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');

      // Request tracking permission on iOS
      if (Platform.isIOS) {
        final status =
            await AppTrackingTransparency.requestTrackingAuthorization();
        _hasTrackingPermission = status == TrackingStatus.authorized;

        debugPrint(
          '🔍 [FacebookTracking] iOS Tracking Authorization Status: $status',
        );

        // Update Facebook tracking based on permission
        await _facebookAppEvents.setAdvertiserTracking(
          enabled: _hasTrackingPermission,
        );
      } else {
        // On Android, we default to enabling tracking
        _hasTrackingPermission = true;
      }

      debugPrint('✅ [FacebookTracking] Initialized successfully');
      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ [FacebookTracking] Error initializing: $e');
    }
  }

  @override
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isTrackingEnabled) {
      debugPrint(
        '⚠️ [FacebookTracking] Tracking disabled, event not logged: $eventName',
      );
      return;
    }

    try {
      // Only log if we have permission or aren't on iOS (where permission is required)
      if (_hasTrackingPermission || !Platform.isIOS) {
        // Map specific events to Facebook standard events
        if (eventName == 'login') {
          await _facebookAppEvents.logEvent(
            name: 'fb_mobile_login',
            parameters: parameters,
          );
        } else if (eventName == 'sign_up') {
          await _facebookAppEvents.logEvent(
            name: 'fb_mobile_complete_registration',
            parameters: parameters,
          );
        } else {
          await _facebookAppEvents.logEvent(
            name: eventName,
            parameters: parameters,
          );
        }
        debugPrint(
          '📊 [FacebookTracking] Logged event: $eventName with parameters: $parameters',
        );
      } else {
        debugPrint(
          '⚠️ [FacebookTracking] Tracking not authorized, event not logged: $eventName',
        );
      }
    } catch (e) {
      debugPrint('❌ [FacebookTracking] Error logging event: $e');
    }
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isTrackingEnabled) {
      debugPrint(
        '⚠️ [FacebookTracking] Tracking disabled, user properties not set',
      );
      return;
    }

    try {
      if (properties.containsKey('user_id')) {
        await _facebookAppEvents.setUserID(properties['user_id'].toString());
      }

      // Set user properties as parameters in custom event
      await _facebookAppEvents.logEvent(
        name: 'set_user_properties',
        parameters: properties,
      );

      debugPrint('👤 [FacebookTracking] Set user properties: $properties');
    } catch (e) {
      debugPrint('❌ [FacebookTracking] Error setting user properties: $e');
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await _facebookAppEvents.clearUserData();
      await _facebookAppEvents.clearUserID();
      debugPrint('🧹 [FacebookTracking] Cleared user data');
    } catch (e) {
      debugPrint('❌ [FacebookTracking] Error clearing user data: $e');
    }
  }

  @override
  String get adapterName => 'Facebook';

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isTrackingEnabled => _isTrackingEnabled;

  @override
  set isTrackingEnabled(bool value) {
    _isTrackingEnabled = value;
    debugPrint(
      '🔄 [FacebookTracking] Tracking ${value ? 'enabled' : 'disabled'}',
    );
  }

  @override
  Future<void> trackEventOnlyPaid(
    String eventName, {
    Map<String, dynamic>? parameters,
    required VoidCallback onPaidFeature,
  }) async {
    // Implementação específica para eventos pagos
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isTrackingEnabled) {
      debugPrint(
        '⚠️ [FacebookTracking] Tracking disabled, event not logged: $eventName',
      );
      return;
    }

    try {
      // Execute the paid feature callback
      // onPaidFeature?.call();

      // Log the event
      await trackEvent(eventName, parameters: parameters);

      debugPrint('🔒 [FacebookTracking] Tracking paid feature: $eventName');
    } catch (e) {
      debugPrint('❌ [FacebookTracking] Error tracking paid feature: $e');
    }
  }
}

/// Factory for creating Facebook tracking adapters
class FacebookTrackingAdapterFactory implements TrackingAdapterFactory {
  @override
  TrackingAdapter create(TrackingAdapterConfig config) {
    return FacebookTrackingAdapter();
  }

  @override
  String get adapterName => 'Facebook';
}
