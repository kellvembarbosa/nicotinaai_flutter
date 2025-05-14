import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/services/analytics/tracking_adapter.dart';
import 'package:nicotinaai_flutter/services/analytics/facebook_tracking_adapter.dart';
import 'package:nicotinaai_flutter/services/analytics/posthog_tracking_adapter.dart';
import 'package:nicotinaai_flutter/services/analytics/superwall_tracking_adapter.dart';

/// Central service for tracking analytics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal() {
    _registerDefaultFactories();
  }

  final List<TrackingAdapter> _adapters = [];
  bool _isInitialized = false;
  final TrackingAdapterRegistry _registry = TrackingAdapterRegistry();

  /// Register default tracking adapter factories
  void _registerDefaultFactories() {
    _registry.registerFactory(FacebookTrackingAdapterFactory());
    _registry.registerFactory(PostHogTrackingAdapterFactory());
    _registry.registerFactory(SuperwallTrackingAdapterFactory());
  }

  /// Initialize the analytics service with default adapters
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Add Facebook adapter by default
    final facebookAdapter = _registry.createAdapter('Facebook');
    if (facebookAdapter != null) {
      _adapters.add(facebookAdapter);
      await facebookAdapter.initialize();
    }

    // Note: PostHog adapter is not added by default since it requires an API key

    // Add Superwall adapter by default
    final superwallAdapter = _registry.createAdapter('Superwall');
    if (superwallAdapter != null) {
      _adapters.add(superwallAdapter);
      await superwallAdapter.initialize();
    }

    debugPrint(
      '✅ [AnalyticsService] Initialized with ${_adapters.length} adapters',
    );
    _isInitialized = true;
  }

  /// Add a tracking adapter
  Future<bool> addAdapter(
    String adapterName, {
    Map<String, dynamic>? config,
  }) async {
    // Check if adapter already exists
    if (_adapters.any((adapter) => adapter.adapterName == adapterName)) {
      debugPrint('⚠️ [AnalyticsService] Adapter $adapterName already exists');
      return false;
    }

    // Create and add adapter
    final adapter = _registry.createAdapter(
      adapterName,
      config != null ? TrackingAdapterConfig(config) : null,
    );

    if (adapter == null) {
      debugPrint('❌ [AnalyticsService] Failed to create adapter: $adapterName');
      return false;
    }

    _adapters.add(adapter);
    await adapter.initialize();

    debugPrint('➕ [AnalyticsService] Added adapter: $adapterName');
    return true;
  }

  /// Remove a tracking adapter
  bool removeAdapter(String adapterName) {
    final initialCount = _adapters.length;
    _adapters.removeWhere((adapter) => adapter.adapterName == adapterName);

    final removed = initialCount != _adapters.length;
    if (removed) {
      debugPrint('➖ [AnalyticsService] Removed adapter: $adapterName');
    } else {
      debugPrint('⚠️ [AnalyticsService] Adapter not found: $adapterName');
    }

    return removed;
  }

  /// Track an event across all adapters
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    debugPrint(
      '📊 [AnalyticsService] Tracking event: $eventName with parameters: $parameters',
    );

    // Track event on all adapters
    for (final adapter in _adapters) {
      await adapter.trackEvent(eventName, parameters: parameters);
    }
  }

  /// Set user properties across all adapters
  Future<void> setUserProperties({
    String? userId,
    String? email,
    int? daysSmokeFree,
    int? cigarettesPerDay,
    double? pricePerPack,
    String? currency,
    Map<String, dynamic>? additionalProperties,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final properties = <String, dynamic>{};

    if (userId != null) properties['user_id'] = userId;
    if (email != null) properties['email'] = email;
    if (daysSmokeFree != null) properties['days_smoke_free'] = daysSmokeFree;
    if (cigarettesPerDay != null)
      properties['cigarettes_per_day'] = cigarettesPerDay;
    if (pricePerPack != null) properties['price_per_pack'] = pricePerPack;
    if (currency != null) properties['currency'] = currency;

    if (additionalProperties != null) {
      properties.addAll(additionalProperties);
    }

    debugPrint('👤 [AnalyticsService] Setting user properties: $properties');

    // Set properties on all adapters
    for (final adapter in _adapters) {
      await adapter.setUserProperties(properties);
    }
  }

  /// Clear user data across all adapters
  Future<void> clearUserData() async {
    for (final adapter in _adapters) {
      await adapter.clearUserData();
    }
    debugPrint('🧹 [AnalyticsService] Cleared user data from all adapters');
  }

  /// Enable or disable tracking for all adapters
  void setTrackingEnabled(bool enabled) {
    for (final adapter in _adapters) {
      adapter.isTrackingEnabled = enabled;
    }
    debugPrint(
      '🔄 [AnalyticsService] ${enabled ? 'Enabled' : 'Disabled'} tracking for all adapters',
    );
  }

  /// Get active adapters
  List<String> get activeAdapters =>
      _adapters.map((adapter) => adapter.adapterName).toList();

  /// Get available adapter types
  List<String> get availableAdapterTypes => _registry.registeredAdapters;

  // Convenience methods for common events

  /// Log app open event
  Future<void> logAppOpen() async {
    await trackEvent('app_open');
  }

  /// Log login event
  Future<void> logLogin({String? method}) async {
    await trackEvent('login', parameters: {'method': method ?? 'email'});
  }

  /// Log signup event
  Future<void> logSignUp({String? method}) async {
    await trackEvent('sign_up', parameters: {'method': method ?? 'email'});
  }

  /// Log smoke-free milestone achievement
  Future<void> logSmokingFreeMilestone(int days) async {
    await trackEvent('smoking_free_milestone', parameters: {'days': days});
  }

  /// Log health recovery achievement
  Future<void> logHealthRecoveryAchieved(String recoveryName) async {
    await trackEvent(
      'health_recovery_achieved',
      parameters: {'recovery_name': recoveryName},
    );
  }

  /// Log craving resisted
  Future<void> logCravingResisted({String? triggerType}) async {
    await trackEvent(
      'craving_resisted',
      parameters: triggerType != null ? {'trigger': triggerType} : null,
    );
  }

  /// Log money saved milestone
  Future<void> logMoneySavedMilestone(double amount, String currency) async {
    await trackEvent(
      'money_saved_milestone',
      parameters: {'amount': amount, 'currency': currency},
    );
  }

  /// Log completed onboarding
  Future<void> logCompletedOnboarding() async {
    await trackEvent('completed_onboarding');
  }

  /// Log feature usage
  Future<void> logFeatureUsage(String featureName) async {
    await trackEvent('feature_used', parameters: {'feature': featureName});
  }
  
  /// Request tracking transparency permission (primarily for iOS)
  /// Returns true if permission was granted, false otherwise
  Future<bool> requestTrackingAuthorization() async {
    // For iOS, we use the Facebook adapter to request tracking permission
    // Try to find the Facebook adapter
    try {
      TrackingAdapter? facebookAdapter;
      for (final adapter in _adapters) {
        if (adapter.adapterName == 'Facebook') {
          facebookAdapter = adapter;
          break;
        }
      }
      
      if (facebookAdapter != null) {
        if (facebookAdapter is FacebookTrackingAdapter) {
          return await facebookAdapter.requestTrackingAuthorization();
        } else {
          debugPrint('🔄 [AnalyticsService] Facebook adapter found but not of correct type');
        }
      } else {
        debugPrint('🔄 [AnalyticsService] Facebook adapter not found');
      }
    } catch (e) {
      debugPrint('🔄 [AnalyticsService] Error requesting tracking authorization: $e');
    }
    
    // On Android or if Facebook adapter is not available, return true by default
    return true;
  }

  /// Track an event on all adapters and handle paid feature access
  /// 
  /// This method can be used to restrict specific features to paid users.
  /// The Superwall adapter will show a paywall when appropriate.
  /// The `onPaidFeature` callback will only be executed for paid users or
  /// after they complete the paywall flow.
  /// 
  /// Example usage:
  /// ```dart
  /// // Example: Restricting craving registration to paid users
  /// final craving = CravingModel(
  ///   trigger: 'stress',
  ///   intensity: 'high',
  ///   location: 'home',
  ///   resisted: true,
  ///   userId: userId,
  /// );
  /// 
  /// analyticsService.trackEventOnlyPaid(
  ///   'register_craving',
  ///   parameters: {
  ///     'trigger': craving.trigger,
  ///     'intensity': craving.intensity,
  ///   },
  ///   onPaidFeature: () {
  ///     // This code only executes for paid users or after paywall completion
  ///     trackingBloc.add(SaveCraving(craving: craving));
  ///     trackingBloc.add(ForceUpdateStats());
  ///     
  ///     // Close the sheet and return result
  ///     Navigator.of(context).pop({'registered': true});
  ///   },
  /// );
  /// ```
  Future<void> trackEventOnlyPaid(
    String eventName, {
    Map<String, dynamic>? parameters,
    required VoidCallback onPaidFeature,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    debugPrint(
      '📊 [AnalyticsService] Tracking event (formerly only paid): $eventName with parameters: $parameters',
    );

    // Track event on all adapters
    for (final adapter in _adapters) {
      await adapter.trackEventOnlyPaid(
        eventName,
        parameters: parameters,
        onPaidFeature: onPaidFeature,
      );
    }
  }
}

// Superwall tracking adapter factory
class SuperwallTrackingAdapterFactory implements TrackingAdapterFactory {
  @override
  String get adapterName => 'Superwall';

  @override
  TrackingAdapter create(TrackingAdapterConfig config) {
    return SuperwallTrackingAdapter();
  }
}
