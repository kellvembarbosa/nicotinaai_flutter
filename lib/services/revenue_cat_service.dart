import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();

  factory RevenueCatService() => _instance;

  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Initialize RevenueCat with the provided API key
  Future<void> initialize({required String apiKey, required bool observerMode}) async {
    if (_isInitialized) return;

    try {
      // Configure RevenueCat with the API key
      await Purchases.configure(PurchasesConfiguration(apiKey));

      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize RevenueCat: $e');
      rethrow;
    }
  }

  /// Get customer info
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('❌ Failed to get customer info: $e');
      rethrow;
    }
  }

  /// Get the current active subscriptions for the user
  Future<List<String>> getActiveSubscriptions() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.keys.toList();
    } catch (e) {
      debugPrint('❌ Failed to get active subscriptions: $e');
      return [];
    }
  }

  /// Check if the user has a specific entitlement
  Future<bool> hasEntitlement(String entitlementId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      debugPrint('❌ Failed to check entitlement: $e');
      return false;
    }
  }

  /// Identify the user for RevenueCat
  Future<void> identifyUser(String userId) async {
    try {
      await Purchases.logIn(userId);
      debugPrint('👤 User identified with RevenueCat: $userId');
    } catch (e) {
      debugPrint('❌ Failed to identify user with RevenueCat: $e');
      rethrow;
    }
  }

  /// Reset the user's identification with RevenueCat
  Future<void> resetUser() async {
    try {
      await Purchases.logOut();
      debugPrint('🧹 RevenueCat user reset');
    } catch (e) {
      debugPrint('❌ Failed to reset RevenueCat user: $e');
      rethrow;
    }
  }

  /// Get available offerings from RevenueCat
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('❌ Failed to get offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo;
    } catch (e) {
      debugPrint('❌ Failed to purchase package: $e');
      return null;
    }
  }

  /// Restore purchases
  Future<CustomerInfo?> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      return info;
    } catch (e) {
      debugPrint('❌ Failed to restore purchases: $e');
      return null;
    }
  }

  /// Set Facebook Anonymous ID for RevenueCat for better attribution
  Future<void> setFacebookAnonymousId(String fbAnonymousId) async {
    try {
      await Purchases.setFBAnonymousID(fbAnonymousId);
      debugPrint('📱 Facebook Anonymous ID set in RevenueCat: $fbAnonymousId');
    } catch (e) {
      debugPrint('❌ Failed to set Facebook Anonymous ID in RevenueCat: $e');
      rethrow;
    }
  }

  /// Collect device identifiers for better attribution
  Future<void> collectDeviceIdentifiers() async {
    try {
      await Purchases.collectDeviceIdentifiers();
      debugPrint('📱 Device identifiers collected for RevenueCat');
    } catch (e) {
      debugPrint('❌ Failed to collect device identifiers for RevenueCat: $e');
      rethrow;
    }
  }

  /// Set user attributes in RevenueCat for better customer tracking
  Future<void> setAttributes(Map<String, String> attributes) async {
    try {
      await Purchases.setAttributes(attributes);
      debugPrint('👤 Attributes set in RevenueCat: $attributes');
    } catch (e) {
      debugPrint('❌ Failed to set attributes in RevenueCat: $e');
      rethrow;
    }
  }
}
