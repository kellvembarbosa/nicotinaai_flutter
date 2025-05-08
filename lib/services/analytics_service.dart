import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

/// Service responsible for handling analytics and tracking events
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  /// Facebook App Events SDK instance
  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();
  
  /// Whether the service has been initialized
  bool _isInitialized = false;
  
  /// Whether the user has granted tracking permission
  bool _hasTrackingPermission = false;
  
  /// Get the tracking authorization status
  Future<bool> get hasTrackingPermission async {
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      return status == TrackingStatus.authorized;
    }
    
    // On Android, we assume tracking is enabled unless explicitly disabled
    return _hasTrackingPermission;
  }

  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Facebook App Events
      await _facebookAppEvents.setAdvertiserTracking(enabled: true);
      await _facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
      
      // Request tracking permission on iOS
      if (Platform.isIOS) {
        final status = await AppTrackingTransparency.requestTrackingAuthorization();
        _hasTrackingPermission = status == TrackingStatus.authorized;
        
        debugPrint('🔍 [AnalyticsService] iOS Tracking Authorization Status: $status');
        
        // Update Facebook tracking based on permission
        await _facebookAppEvents.setAdvertiserTracking(enabled: _hasTrackingPermission);
      } else {
        // On Android, we default to enabling tracking
        _hasTrackingPermission = true;
      }
      
      debugPrint('✅ [AnalyticsService] Initialized successfully');
      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ [AnalyticsService] Error initializing: $e');
    }
  }
  
  /// Log a custom event
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (!_isInitialized) {
      debugPrint('⚠️ [AnalyticsService] Service not initialized. Initializing now...');
      await initialize();
    }
    
    try {
      // Only log if we have permission or aren't on iOS (where permission is required)
      if (_hasTrackingPermission || !Platform.isIOS) {
        await _facebookAppEvents.logEvent(
          name: eventName,
          parameters: parameters,
        );
        debugPrint('📊 [AnalyticsService] Logged event: $eventName with parameters: $parameters');
      } else {
        debugPrint('⚠️ [AnalyticsService] Tracking not authorized, event not logged: $eventName');
      }
    } catch (e) {
      debugPrint('❌ [AnalyticsService] Error logging event: $e');
    }
  }
  
  /// Log app open event
  Future<void> logAppOpen() async {
    await logEvent('app_open');
  }
  
  /// Log login event
  Future<void> logLogin({String? method}) async {
    await _facebookAppEvents.logEvent(
      name: 'fb_mobile_login',
      parameters: {'method': method ?? 'email'},
    );
  }
  
  /// Log signup event
  Future<void> logSignUp({String? method}) async {
    await _facebookAppEvents.logEvent(
      name: 'sign_up',
      parameters: {'method': method ?? 'email'},
    );
  }
  
  /// Log smoke-free milestone achievement
  Future<void> logSmokingFreeMilestone(int days) async {
    await logEvent('smoking_free_milestone', parameters: {'days': days});
  }
  
  /// Log health recovery achievement
  Future<void> logHealthRecoveryAchieved(String recoveryName) async {
    await logEvent('health_recovery_achieved', parameters: {'recovery_name': recoveryName});
  }
  
  /// Log craving resisted
  Future<void> logCravingResisted({String? triggerType}) async {
    await logEvent('craving_resisted', parameters: triggerType != null ? {'trigger': triggerType} : null);
  }
  
  /// Log money saved milestone
  Future<void> logMoneySavedMilestone(double amount, String currency) async {
    await logEvent('money_saved_milestone', parameters: {
      'amount': amount,
      'currency': currency,
    });
  }
  
  /// Log completed onboarding
  Future<void> logCompletedOnboarding() async {
    await logEvent('completed_onboarding');
  }
  
  /// Log feature usage
  Future<void> logFeatureUsage(String featureName) async {
    await logEvent('feature_used', parameters: {'feature': featureName});
  }
  
  /// Set user properties
  Future<void> setUserProperties({
    String? userId,
    String? email,
    int? daysSmokeFree,
    int? cigarettesPerDay,
    double? pricePerPack,
    String? currency,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      if (userId != null) {
        await _facebookAppEvents.setUserID(userId);
      }
      
      final userProperties = <String, dynamic>{};
      
      if (email != null) userProperties['email'] = email;
      if (daysSmokeFree != null) userProperties['days_smoke_free'] = daysSmokeFree.toString();
      if (cigarettesPerDay != null) userProperties['cigarettes_per_day'] = cigarettesPerDay.toString();
      if (pricePerPack != null) userProperties['price_per_pack'] = pricePerPack.toString();
      if (currency != null) userProperties['currency'] = currency;
      
      // Set user properties as parameters in custom event
      await _facebookAppEvents.logEvent(
        name: 'set_user_properties',
        parameters: userProperties,
      );
      
      debugPrint('👤 [AnalyticsService] Set user properties: $userProperties');
    } catch (e) {
      debugPrint('❌ [AnalyticsService] Error setting user properties: $e');
    }
  }
  
  /// Clear user data
  Future<void> clearUserData() async {
    try {
      await _facebookAppEvents.clearUserData();
      await _facebookAppEvents.clearUserID();
      debugPrint('🧹 [AnalyticsService] Cleared user data');
    } catch (e) {
      debugPrint('❌ [AnalyticsService] Error clearing user data: $e');
    }
  }
}