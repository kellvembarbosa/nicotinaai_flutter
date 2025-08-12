import 'package:flutter/material.dart';
import '../services/paywall_service.dart';

extension PaywallExtensions on BuildContext {
  /// Opens paywall if user is not premium
  Future<void> openPaywallIfNotPremium({
    required VoidCallback onPremium,
    PaywallPresentationType type = PaywallPresentationType.sheet,
    String placementId = 'default',
    String? source,
  }) async {
    final paywallService = PaywallService.instance;
    
    // Check if user is premium
    final shouldShow = await paywallService.shouldShowPaywall(
      placementId: placementId,
    );
    
    if (!shouldShow) {
      // User is premium, execute callback
      onPremium();
      return;
    }
    
    // User is not premium, show paywall
    if (mounted) {
      await paywallService.showPaywall(
        context: this,
        presentationType: type,
        placementId: placementId,
        source: source,
        onPurchaseComplete: (_) => onPremium(),
      );
    }
  }
  
  /// Shows paywall for a specific premium feature
  Future<void> showPaywallForFeature({
    required String featureName,
    VoidCallback? onUnlocked,
    PaywallPresentationType type = PaywallPresentationType.sheet,
  }) async {
    final paywallService = PaywallService.instance;
    
    await paywallService.showPaywallForPremiumFeature(
      context: this,
      featureName: featureName,
      presentationType: type,
    );
    
    // Check if feature was unlocked after paywall
    final hasAccess = await paywallService.hasAccessToFeature(featureName);
    if (hasAccess && onUnlocked != null) {
      onUnlocked();
    }
  }
}