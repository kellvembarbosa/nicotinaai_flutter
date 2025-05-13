import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();

  factory RevenueCatService() => _instance;

  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Initialize RevenueCat with the provided API key
  Future<void> initialize({
    required String apiKey,
    required bool observerMode,
  }) async {
    if (_isInitialized) return;

    try {
      // Configure RevenueCat with the API key
      await Purchases.configure(
        PurchasesConfiguration(apiKey)..observerMode = observerMode,
      );

      // Configure Superwall to work with RevenueCat
      await _configureSuperwallWithRevenueCat();

      _isInitialized = true;
      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize RevenueCat: $e');
      rethrow;
    }
  }

  /// Configure Superwall to work with RevenueCat
  Future<void> _configureSuperwallWithRevenueCat() async {
    // Register RevenueCat purchases with Superwall
    Superwall.instance.subscriptionController.registerStoreKitManager(
      RevenueCatStoreKitManager(),
    );
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
      final result = await Purchases.purchasePackage(package);
      return result.customerInfo;
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

/// RevenueCat StoreKit Manager for Superwall integration
class RevenueCatStoreKitManager extends Superwall.StoreKitManager {
  @override
  Future<void> purchase(
    Superwall.Product product,
    Superwall.PaywallInfo? paywallInfo,
  ) async {
    try {
      // Get offerings from RevenueCat
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        throw Exception("No offerings available");
      }

      // Find the package with matching product ID
      Package? packageToPurchase;

      // First check current offering
      if (offerings.current != null) {
        packageToPurchase = _findPackageWithProductId(
          offerings.current!.availablePackages,
          product.id,
        );
      }

      // If not found in current offering, search all offerings
      if (packageToPurchase == null) {
        for (final offering in offerings.all.values) {
          packageToPurchase = _findPackageWithProductId(
            offering.availablePackages,
            product.id,
          );
          if (packageToPurchase != null) break;
        }
      }

      if (packageToPurchase == null) {
        throw Exception("No package found with product ID: ${product.id}");
      }

      // Purchase the package using RevenueCat
      await Purchases.purchasePackage(packageToPurchase);
    } catch (e) {
      debugPrint('Failed to purchase product: $e');
      rethrow;
    }
  }

  @override
  Future<List<Superwall.Product>> getProducts(List<String> productIds) async {
    try {
      // Get offerings from RevenueCat
      final offerings = await Purchases.getOfferings();
      final products = <Superwall.Product>[];

      // Process all offerings to find matching products
      for (final offering in offerings.all.values) {
        for (final package in offering.availablePackages) {
          final storeProduct = package.storeProduct;

          if (productIds.contains(storeProduct.identifier)) {
            products.add(
              Superwall.Product(
                id: storeProduct.identifier,
                price: storeProduct.price,
                priceFormatter: (price) => storeProduct.priceString,
                title: storeProduct.title,
                description: storeProduct.description,
              ),
            );
          }
        }
      }

      return products;
    } catch (e) {
      debugPrint('Failed to get products: $e');
      return [];
    }
  }

  @override
  Future<bool> isProductPurchased(String productId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      // Check if the product is purchased
      for (final entitlement in customerInfo.entitlements.active.values) {
        if (entitlement.productIdentifier == productId) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Failed to check if product is purchased: $e');
      return false;
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
      rethrow;
    }
  }

  /// Helper method to find a package with matching product ID
  Package? _findPackageWithProductId(List<Package> packages, String productId) {
    for (final package in packages) {
      if (package.storeProduct.identifier == productId) {
        return package;
      }
    }
    return null;
  }
}
