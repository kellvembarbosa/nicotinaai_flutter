import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/services/paywall_service.dart';
import '../widgets/paywall_content.dart';

class PaywallPage extends StatelessWidget {
  final Offerings offerings;
  final String placementId;
  final OnPurchaseComplete? onPurchaseComplete;
  final String? source;
  final bool allowClose;
  final Map<String, dynamic>? hardPaywallConfig;

  const PaywallPage({
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
    return Scaffold(
      body: PaywallContent(
        offerings: offerings,
        placementId: placementId,
        onPurchaseComplete: onPurchaseComplete,
        source: source,
        allowClose: allowClose,
        hardPaywallConfig: hardPaywallConfig,
      ),
    );
  }
}