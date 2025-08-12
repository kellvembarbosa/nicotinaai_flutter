import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../services/revenue_cat_service.dart';
import '../../features/paywall/presentation/pages/paywall_page.dart';
import '../../features/paywall/presentation/widgets/paywall_sheet.dart';
import '../../features/paywall/presentation/widgets/paywall_dialog.dart';

enum PaywallPresentationType { page, sheet, dialog }

typedef OnPurchaseComplete = void Function(CustomerInfo customerInfo);
typedef OnClosePaywall = void Function(bool purchaseMade);

class PaywallService {
  static final PaywallService _instance = PaywallService._internal();
  static PaywallService get instance => _instance;
  
  PaywallService._internal();
  
  RevenueCatService? _revenueCatService;
  
  bool _isPaywallActive = false;
  Timer? _hardPaywallTimer;
  
  static const List<String> _noInterstitialPaywalls = [
    'onboarding',
    'onboarding_paywall',
  ];
  
  void injectDependencies({
    required RevenueCatService revenueCatService,
  }) {
    _revenueCatService = revenueCatService;
  }
  
  Future<bool> shouldShowPaywall({
    String? placementId,
    bool force = false,
  }) async {
    if (force) return true;
    
    try {
      final customerInfo = await _revenueCatService?.getCustomerInfo();
      return customerInfo?.entitlements.active.isEmpty ?? true;
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      return false;
    }
  }
  
  Future<bool> hasAccessToFeature(String featureName) async {
    try {
      final customerInfo = await _revenueCatService?.getCustomerInfo();
      return customerInfo?.entitlements.active.isNotEmpty ?? false;
    } catch (e) {
      debugPrint('Error checking feature access: $e');
      return false;
    }
  }
  
  Future<void> showPaywall({
    required BuildContext context,
    required PaywallPresentationType presentationType,
    required String placementId,
    OnPurchaseComplete? onPurchaseComplete,
    OnClosePaywall? onClosePaywall,
    String? source,
    bool allowClose = true,
    bool force = false,
  }) async {
    if (_isPaywallActive && !force) {
      debugPrint('Paywall already active, skipping');
      return;
    }
    
    final shouldShow = await shouldShowPaywall(
      placementId: placementId,
      force: force,
    );
    
    if (!shouldShow && !force) {
      debugPrint('User has active subscription, skipping paywall');
      onPurchaseComplete?.call(await _revenueCatService!.getCustomerInfo());
      return;
    }
    
    _isPaywallActive = true;
    
    try {
      final offerings = await _revenueCatService?.getOfferings();
      if (offerings == null || offerings.current == null) {
        debugPrint('No offerings available');
        _isPaywallActive = false;
        return;
      }
      
      final bool? purchaseMade = await _showPaywallByType(
        context: context,
        presentationType: presentationType,
        placementId: placementId,
        offerings: offerings,
        onPurchaseComplete: onPurchaseComplete,
        source: source,
        allowClose: allowClose,
      );
      
      onClosePaywall?.call(purchaseMade ?? false);
      
      if (!_noInterstitialPaywalls.contains(placementId) && !(purchaseMade ?? false)) {
        // Here you could show an interstitial ad if configured
      }
    } catch (e) {
      debugPrint('Error showing paywall: $e');
    } finally {
      _isPaywallActive = false;
      _hardPaywallTimer?.cancel();
    }
  }
  
  Future<bool?> _showPaywallByType({
    required BuildContext context,
    required PaywallPresentationType presentationType,
    required String placementId,
    required Offerings offerings,
    OnPurchaseComplete? onPurchaseComplete,
    String? source,
    bool allowClose = true,
  }) async {
    final hardPaywallConfig = _getHardPaywallConfig();
    final effectiveAllowClose = _shouldAllowClose(allowClose, hardPaywallConfig);
    
    switch (presentationType) {
      case PaywallPresentationType.page:
        return Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PaywallPage(
              offerings: offerings,
              placementId: placementId,
              onPurchaseComplete: onPurchaseComplete,
              source: source,
              allowClose: effectiveAllowClose,
              hardPaywallConfig: hardPaywallConfig,
            ),
          ),
        );
        
      case PaywallPresentationType.sheet:
        return showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          isDismissible: effectiveAllowClose,
          enableDrag: effectiveAllowClose,
          backgroundColor: Colors.transparent,
          builder: (_) => PaywallSheet(
            offerings: offerings,
            placementId: placementId,
            onPurchaseComplete: onPurchaseComplete,
            source: source,
            allowClose: effectiveAllowClose,
            hardPaywallConfig: hardPaywallConfig,
          ),
        );
        
      case PaywallPresentationType.dialog:
        return showDialog<bool>(
          context: context,
          barrierDismissible: effectiveAllowClose,
          builder: (_) => PaywallDialog(
            offerings: offerings,
            placementId: placementId,
            onPurchaseComplete: onPurchaseComplete,
            source: source,
            allowClose: effectiveAllowClose,
            hardPaywallConfig: hardPaywallConfig,
          ),
        );
    }
  }
  
  Map<String, dynamic> _getHardPaywallConfig() {
    // For now, return default values
    // TODO: Integrate with remote config service when available
    return {
      'hard_paywall': false,
      'hard_paywall_time': 15,
      'hard_paywall_delay_msg': true,
    };
  }
  
  bool _shouldAllowClose(bool allowClose, Map<String, dynamic> hardPaywallConfig) {
    // Android always allows close due to Play Store policy
    if (Platform.isAndroid) return true;
    
    if (!allowClose) return false;
    
    if (hardPaywallConfig['hard_paywall'] == true) {
      return false; // Will be handled by timer in the widget
    }
    
    return allowClose;
  }
  
  Future<void> showPaywallForPremiumFeature({
    required BuildContext context,
    required String featureName,
    String? placementId,
    PaywallPresentationType presentationType = PaywallPresentationType.sheet,
    bool force = false,
  }) async {
    final hasAccess = await hasAccessToFeature(featureName);
    
    if (hasAccess && !force) {
      debugPrint('User has access to feature: $featureName');
      return;
    }
    
    await showPaywall(
      context: context,
      presentationType: presentationType,
      placementId: placementId ?? 'feature_$featureName',
      source: 'feature_$featureName',
      force: force,
    );
  }
  
  Future<void> showPaywallAfterOnboarding(BuildContext context) async {
    await showPaywall(
      context: context,
      presentationType: PaywallPresentationType.page,
      placementId: 'onboarding_paywall',
      source: 'onboarding_complete',
      allowClose: true,
    );
  }
  
  Future<CustomerInfo?> processPurchase(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('Purchase cancelled by user');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        debugPrint('Purchase not allowed');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        debugPrint('Payment pending');
      } else {
        debugPrint('Purchase error: ${e.message}');
      }
      
      rethrow;
    }
  }
  
  Future<CustomerInfo?> restorePurchases() async {
    try {
      return await _revenueCatService?.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      rethrow;
    }
  }
  
  Future<Offerings?> getOfferings() async {
    try {
      return await _revenueCatService?.getOfferings();
    } catch (e) {
      debugPrint('Error getting offerings: $e');
      rethrow;
    }
  }
  
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      return await processPurchase(package);
    } catch (e) {
      debugPrint('Error purchasing package: $e');
      rethrow;
    }
  }
}