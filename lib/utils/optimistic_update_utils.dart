import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_state.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// Utility functions for optimistic updates
class OptimisticUpdateUtils {
  /// Show a snackbar with retry action for failed operations
  static void showRetrySnackbar({
    required BuildContext context,
    required String successMessage,
    required String errorMessage,
    required VoidCallback retryAction,
    required bool hasError,
    Color? successColor = Colors.green,
    Color? errorColor = Colors.red,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hasError ? errorMessage : successMessage),
        backgroundColor: hasError ? errorColor : successColor,
        duration: duration,
        action: hasError ? SnackBarAction(
          label: AppLocalizations.of(context).retry,
          onPressed: retryAction,
        ) : null,
      ),
    );
  }
  
  /// Show a loading overlay during operations
  static Future<void> showLoadingOverlay({
    required BuildContext context,
    required Future<void> Function() operation,
    String? loadingMessage,
  }) async {
    // Get overlay reference before async operation
    final overlay = Overlay.of(context);
    
    final overlayEntry = OverlayEntry(
      builder: (builderContext) => Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (loadingMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                loadingMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
    
    // Add overlay to the screen using the cached reference
    overlay.insert(overlayEntry);
    
    try {
      // Perform the operation
      await operation();
    } finally {
      // Remove the overlay regardless of success/failure
      overlayEntry.remove();
    }
  }
  
  /// Register a craving with optimistic update
  static Future<void> registerCravingOptimistically({
    required BuildContext context, 
    required CravingModel craving,
  }) async {
    // Get the TrackingBloc
    final trackingBloc = context.read<TrackingBloc>();
    final l10n = AppLocalizations.of(context);
    
    // Cache values needed after the asynchronous operation
    final bool didResist = craving.resisted;
    final String successMsg = didResist ? l10n.cravingResistedRecorded : l10n.cravingRecorded;
    final String errorMsg = l10n.errorSavingCraving;
    final Color successClr = didResist ? Colors.green : Colors.blue;
    
    // Save scaffold messenger reference to use after async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Dispatch event to save craving
    trackingBloc.add(SaveCraving(craving: craving));
    
    // Listen for state changes to determine success/failure
    late final StreamSubscription<TrackingState> subscription;
    subscription = trackingBloc.stream.listen((state) {
      // Only respond to state changes related to this operation
      if (state.status == TrackingStatus.error || state.status == TrackingStatus.loaded) {
        subscription.cancel();
        
        final hasError = state.status == TrackingStatus.error;
        
        // Create retry action that works even after the async gap
        void retryAction() {
          if (state.failedCravings.isNotEmpty) {
            final failedCraving = state.failedCravings.first;
            if (failedCraving.id != null) {
              // Retry saving the failed craving
              trackingBloc.add(RetrySyncCraving(id: failedCraving.id!));
            }
          }
        }
        
        // Show snackbar using the cached scaffold messenger
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(hasError ? errorMsg : successMsg),
            backgroundColor: hasError ? Colors.red : successClr,
            duration: const Duration(seconds: 3),
            action: hasError ? SnackBarAction(
              label: l10n.retry,
              onPressed: retryAction,
            ) : null,
          ),
        );
      }
    });
    
    // Cancel subscription after a timeout to prevent memory leaks
    Future.delayed(const Duration(seconds: 10), () {
      subscription.cancel();
    });
  }
}