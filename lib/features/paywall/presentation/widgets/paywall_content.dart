import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/services/paywall_service.dart';

class PaywallContent extends StatefulWidget {
  final Offerings offerings;
  final String placementId;
  final OnPurchaseComplete? onPurchaseComplete;
  final String? source;
  final bool allowClose;
  final Map<String, dynamic>? hardPaywallConfig;
  final VoidCallback? onClose;

  const PaywallContent({
    super.key,
    required this.offerings,
    required this.placementId,
    this.onPurchaseComplete,
    this.source,
    this.allowClose = true,
    this.hardPaywallConfig,
    this.onClose,
  });

  @override
  State<PaywallContent> createState() => _PaywallContentState();
}

class _PaywallContentState extends State<PaywallContent> {
  Package? selectedPackage;
  bool isLoading = false;
  bool showCloseButton = false;
  int? remainingTime;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    showCloseButton = widget.allowClose;
    _initializePackages();
    _setupHardPaywallTimer();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _initializePackages() {
    final currentOffering = widget.offerings.current;
    if (currentOffering != null && currentOffering.availablePackages.isNotEmpty) {
      setState(() {
        selectedPackage = currentOffering.availablePackages.first;
      });
    }
  }
  
  void _setupHardPaywallTimer() {
    if (!widget.allowClose && 
        widget.hardPaywallConfig?['hard_paywall'] == true &&
        !Platform.isAndroid) {
      final seconds = widget.hardPaywallConfig?['hard_paywall_time'] ?? 15;
      setState(() {
        remainingTime = seconds;
      });
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (remainingTime! > 0) {
              remainingTime = remainingTime! - 1;
            } else {
              showCloseButton = true;
              timer.cancel();
            }
          });
        }
      });
    }
  }
  
  Future<void> handlePurchase() async {
    if (selectedPackage == null) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final customerInfo = await PaywallService.instance.processPurchase(selectedPackage!);
      if (customerInfo != null && customerInfo.entitlements.active.isNotEmpty) {
        widget.onPurchaseComplete?.call(customerInfo);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  Future<void> handleRestore() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final customerInfo = await PaywallService.instance.restorePurchases();
      if (customerInfo != null && customerInfo.entitlements.active.isNotEmpty) {
        widget.onPurchaseComplete?.call(customerInfo);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No subscription to restore')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentOffering = widget.offerings.current;
    if (currentOffering == null || currentOffering.availablePackages.isEmpty) {
      return const Center(
        child: Text('No offers available'),
      );
    }
    
    final packages = currentOffering.availablePackages;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          if (showCloseButton || Platform.isAndroid)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: remainingTime != null && remainingTime! > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${remainingTime}s',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          widget.onClose?.call();
                          Navigator.of(context).pop(false);
                        },
                      ),
              ),
            ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              (currentOffering.metadata['title'] as String?) ?? 'Unlock Premium',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              (currentOffering.metadata['description'] as String?) ?? 'Get access to all premium features',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Features list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                _buildFeatureItem(Icons.block, 'No Ads', primaryColor),
                _buildFeatureItem(Icons.insights, 'Advanced Statistics', primaryColor),
                _buildFeatureItem(Icons.emoji_events, 'Exclusive Achievements', primaryColor),
                _buildFeatureItem(Icons.psychology, 'AI Motivation', primaryColor),
                _buildFeatureItem(Icons.favorite, 'Health Tracking', primaryColor),
                _buildFeatureItem(Icons.cloud_sync, 'Cloud Sync', primaryColor),
              ],
            ),
          ),
          
          // Package selection
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: packages.map((package) {
                final isSelected = selectedPackage == package;
                return GestureDetector(
                  onTap: () => setState(() => selectedPackage = package),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? primaryColor.withOpacity(0.1) : null,
                    ),
                    child: Row(
                      children: [
                        Radio<Package>(
                          value: package,
                          groupValue: selectedPackage,
                          onChanged: (value) => setState(() => selectedPackage = value),
                          activeColor: primaryColor,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                package.storeProduct.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                package.storeProduct.description,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          package.storeProduct.priceString,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Purchase button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(
              onPressed: isLoading ? null : handlePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Start Free Trial',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          // Restore button
          TextButton(
            onPressed: isLoading ? null : handleRestore,
            child: Text(
              'Restore Purchases',
              style: TextStyle(
                color: Colors.grey.shade600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String text, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}