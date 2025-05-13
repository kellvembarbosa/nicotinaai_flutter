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
      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize RevenueCat: $e');
      rethrow;
    }
  }

  /// Get the current active subscriptions for the user
  Future<List<String>> getActiveSubscriptions() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.keys.toList();
    } catch (e) {
      debugPrint('Failed to get active subscriptions: $e');
      return [];
    }
  }

  /// Check if the user has a specific entitlement
  Future<bool> hasEntitlement(String entitlementId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      debugPrint('Failed to check entitlement: $e');
      return false;
    }
  }

  /// Identify the user for RevenueCat
  Future<void> identifyUser(String userId) async {
    try {
      await Purchases.logIn(userId);
      debugPrint('User identified with RevenueCat: $userId');
    } catch (e) {
      debugPrint('Failed to identify user with RevenueCat: $e');
      rethrow;
    }
  }

  /// Reset the user's identification with RevenueCat
  Future<void> resetUser() async {
    try {
      await Purchases.logOut();
      debugPrint('RevenueCat user reset');
    } catch (e) {
      debugPrint('Failed to reset RevenueCat user: $e');
      rethrow;
    }
  }

  /// Get available offerings from RevenueCat
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Failed to get offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo;
    } catch (e) {
      debugPrint('Failed to purchase package: $e');
      return null;
    }
  }

  /// Restore purchases
  Future<CustomerInfo?> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      return info;
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
      return null;
    }
  }
}
