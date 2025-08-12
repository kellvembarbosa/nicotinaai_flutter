import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';
import 'package:nicotinaai_flutter/services/analytics/facebook_tracking_adapter.dart';
import 'package:nicotinaai_flutter/services/revenue_cat_service.dart';
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';

/// A service to manage user identity across multiple platforms
/// This ensures consistent user identification across RevenueCat and analytics services
class IdentityService {
  static final IdentityService _instance = IdentityService._internal();
  factory IdentityService() => _instance;
  IdentityService._internal();

  final AnalyticsService _analyticsService = AnalyticsService();
  final FacebookTrackingAdapter _facebookTrackingAdapter = FacebookTrackingAdapter();
  final RevenueCatService _revenueCatService = RevenueCatService();

  /// Initialize user identity across all platforms
  /// This should be called when a user logs in or signs up
  Future<void> initializeUserIdentity(UserModel user) async {
    final userId = user.id;
    final email = user.email;
    Map<String, dynamic> userAttributes = {'user_id': userId, 'email': email};

    if (user.name != null && user.name!.isNotEmpty) {
      userAttributes['name'] = user.name!;
    }

    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      userAttributes['avatar_url'] = user.avatarUrl!;
    }

    if (user.currencyCode != null && user.currencyCode!.isNotEmpty) {
      userAttributes['currency_code'] = user.currencyCode!;
    }

    await _identifyOnAllPlatforms(userId, email ?? 'null', userAttributes);

    debugPrint('✅ User identity initialized across all platforms for user $userId');
  }

  /// Update user identity data across all platforms
  /// This should be called when user data changes
  Future<void> updateUserIdentity(UserModel user) async {
    return initializeUserIdentity(user);
  }

  /// Reset user identity across all platforms
  /// This should be called when a user logs out
  Future<void> resetUserIdentity() async {
    try {
      // Clear analytics data
      await _analyticsService.clearUserData();

      // Reset RevenueCat identity
      await _revenueCatService.resetUser();

      debugPrint('✅ User identity reset across all platforms');
    } catch (e) {
      debugPrint('⚠️ Error resetting user identity: $e');
      rethrow;
    }
  }

  /// Identify user on all platforms
  Future<void> _identifyOnAllPlatforms(String userId, String email, Map<String, dynamic> attributes) async {
    try {
      // 1. Collect device identifiers for attribution
      await _revenueCatService.collectDeviceIdentifiers();
      
      // 2. Set Facebook Anonymous ID in RevenueCat if available
      try {
        final fbAnonymousId = await _facebookTrackingAdapter.getAnonymousId();
        if (fbAnonymousId != null && fbAnonymousId.isNotEmpty) {
          await _revenueCatService.setFacebookAnonymousId(fbAnonymousId);
          debugPrint('✅ Facebook Anonymous ID set in RevenueCat: $fbAnonymousId');
        } else {
          debugPrint('⚠️ Facebook Anonymous ID not available');
        }
      } catch (fbError) {
        debugPrint('⚠️ Failed to set Facebook Anonymous ID: $fbError');
      }

      // 3. Identify with analytics service (includes PostHog)
      await _analyticsService.setUserProperties(userId: userId, email: email, additionalProperties: attributes);

      // 4. Identify directly with RevenueCat
      await _revenueCatService.identifyUser(userId);

      // 7. Add email and other attributes in RevenueCat
      try {
        final Map<String, String> rcAttributes = {'email': email};
        
        // Add additional useful attributes for better user tracking
        if (attributes.containsKey('name') && attributes['name'] != null) {
          rcAttributes['name'] = attributes['name'].toString();
        }
        
        if (attributes.containsKey('currency_code') && attributes['currency_code'] != null) {
          rcAttributes['currency_code'] = attributes['currency_code'].toString();
        }
        
        await _revenueCatService.setAttributes(rcAttributes);
        debugPrint('✅ User attributes set in RevenueCat');
      } catch (e) {
        debugPrint('⚠️ Failed to set attributes in RevenueCat: $e');
      }

      debugPrint('✅ User identified across all platforms');
    } catch (e) {
      debugPrint('⚠️ Error identifying user across platforms: $e');
      rethrow;
    }
  }

  /// Record a significant user event across all platforms
  /// This can be used for tracking important events consistently
  Future<void> trackSignificantEvent(String eventName, Map<String, dynamic> properties) async {
    try {
      // Track in analytics service (which will forward to all analytics adapters)
      await _analyticsService.trackEvent(eventName, parameters: properties);
      debugPrint('✅ Significant event "$eventName" tracked across all platforms');
    } catch (e) {
      debugPrint('⚠️ Error tracking significant event: $e');
    }
  }

  /// Get current subscription status from RevenueCat
  /// Should be called after purchases or when subscription status might have changed
  Future<bool> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      // Check if the user has any active entitlements
      final hasActiveSubscription = customerInfo.entitlements.active.isNotEmpty;

      if (hasActiveSubscription) {
        debugPrint('✅ User has active subscription');
      } else {
        debugPrint('📝 User has no active subscription');
      }
      
      return hasActiveSubscription;
    } catch (e) {
      debugPrint('⚠️ Failed to get subscription status: $e');
      return false;
    }
  }
}
