import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';
import 'package:nicotinaai_flutter/services/revenue_cat_service.dart';
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';

/// A service to manage user identity across multiple platforms
/// This ensures consistent user identification across RevenueCat, Superwall, and analytics services
class IdentityService {
  static final IdentityService _instance = IdentityService._internal();
  factory IdentityService() => _instance;
  IdentityService._internal();

  final AnalyticsService _analyticsService = AnalyticsService();
  final RevenueCatService _revenueCatService = RevenueCatService();

  /// Initialize user identity across all platforms
  /// This should be called when a user logs in or signs up
  Future<void> initializeUserIdentity(UserModel user) async {
    final userId = user.id;
    final email = user.email;
    Map<String, dynamic> userAttributes = {
      'user_id': userId,
      'email': email,
    };

    if (user.name != null && user.name!.isNotEmpty) {
      userAttributes['name'] = user.name!;
    }

    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      userAttributes['avatar_url'] = user.avatarUrl!;
    }

    if (user.currencyCode != null && user.currencyCode!.isNotEmpty) {
      userAttributes['currency_code'] = user.currencyCode!;
    }

    // Add cigarettes per day data if available (important for analytics)
    if (user.cigarettesPerDay != null) {
      userAttributes['cigarettes_per_day'] = user.cigarettesPerDay;
    }

    // Add price per pack data if available (important for analytics)
    if (user.pricePerPack != null) {
      userAttributes['price_per_pack'] = user.pricePerPack;
    }

    await _identifyOnAllPlatforms(userId, email, userAttributes);
    
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
      
      // Reset Superwall identity
      Superwall.instance.reset();
      
      debugPrint('✅ User identity reset across all platforms');
    } catch (e) {
      debugPrint('⚠️ Error resetting user identity: $e');
      rethrow;
    }
  }

  /// Identify user on all platforms
  Future<void> _identifyOnAllPlatforms(
    String userId,
    String email,
    Map<String, dynamic> attributes,
  ) async {
    try {
      // 1. Identify with analytics service (includes PostHog and Superwall)
      await _analyticsService.setUserProperties(
        userId: userId,
        email: email,
        additionalProperties: attributes,
      );
      
      // 2. Identify directly with RevenueCat
      await _revenueCatService.identifyUser(userId);
      
      // 3. Set user attributes directly in Superwall
      // Even though the analytics adapter already does this, setting it directly ensures consistency
      Superwall.instance.setUserAttributes(attributes);
      
      // 4. Add email as an alias in RevenueCat (helps with subscription management)
      try {
        await Purchases.setAttributes({'email': email});
        debugPrint('✅ Email attribute set in RevenueCat');
      } catch (e) {
        debugPrint('⚠️ Failed to set email attribute in RevenueCat: $e');
      }
      
      debugPrint('✅ User identified across all platforms');
    } catch (e) {
      debugPrint('⚠️ Error identifying user across platforms: $e');
      rethrow;
    }
  }
  
  /// Record a significant user event across all platforms
  /// This can be used for tracking important events consistently
  Future<void> trackSignificantEvent(
    String eventName, 
    Map<String, dynamic> properties,
  ) async {
    try {
      // Track in analytics service (which will forward to all analytics adapters)
      await _analyticsService.trackEvent(eventName, parameters: properties);
      debugPrint('✅ Significant event "$eventName" tracked across all platforms');
    } catch (e) {
      debugPrint('⚠️ Error tracking significant event: $e');
    }
  }
}