import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/services/paywall_service.dart';
import 'paywall_content.dart';

class PaywallDialog extends StatelessWidget {
  final Offerings offerings;
  final String placementId;
  final OnPurchaseComplete? onPurchaseComplete;
  final String? source;
  final bool allowClose;
  final Map<String, dynamic>? hardPaywallConfig;

  const PaywallDialog({
    super.key,
    required this.offerings,
    required this.placementId,
    this.onPurchaseComplete,
    this.source,
    this.allowClose = true,
    this.hardPaywallConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: PaywallContent(
          offerings: offerings,
          placementId: placementId,
          onPurchaseComplete: onPurchaseComplete,
          source: source,
          allowClose: allowClose,
          hardPaywallConfig: hardPaywallConfig,
        ),
      ),
    );
  }
}