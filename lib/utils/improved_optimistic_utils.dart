import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// A utility class for implementing optimistic updates with better feedback
/// This class provides helpers for common optimistic update patterns used with BLoC
class ImprovedOptimisticUtils {
  /// Shows a loading overlay during an async operation
  /// 
  /// Returns a function that can be called to dismiss the overlay
  static Function(BuildContext) showLoading(BuildContext context, {String? message}) {
    // Create an overlay entry
    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    message ?? AppLocalizations.of(context).saving,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Insert the overlay
    overlayState.insert(overlayEntry);

    // Return a function to dismiss the overlay
    return (context) {
      overlayEntry.remove();
    };
  }

  /// Shows a snackbar with success or error message and retry option
  static void showResultSnackbar({
    required BuildContext context,
    required bool isSuccess,
    required String successMessage,
    required String errorMessage,
    VoidCallback? onRetry,
  }) {
    final snackBar = SnackBar(
      content: Text(isSuccess ? successMessage : errorMessage),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      duration: const Duration(seconds: 3),
      action: !isSuccess && onRetry != null
          ? SnackBarAction(
              label: AppLocalizations.of(context).retry,
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Generic method to perform an optimistic update with a BloC
  /// 
  /// Type parameters:
  /// - E: Event type for the BloC
  /// - S: State type for the BloC
  /// - T: The entity type being updated
  /// 
  /// Parameters:
  /// - context: The BuildContext
  /// - bloc: The BloC instance
  /// - createEvent: Function to create the event for the update
  /// - createSuccessEvent: Function to create a success event (optional)
  /// - createFailureEvent: Function to create a failure event (optional)
  /// - checkState: Function to check if the operation was successful
  /// - entity: The entity being updated
  /// - successMessage: Message to show on success
  /// - errorMessage: Message to show on failure
  /// - showOverlay: Whether to show a loading overlay
  /// - maxWaitTime: Maximum time to wait for state change
  static Future<bool> performOptimisticUpdate<E, S, T>({
    required BuildContext context,
    required Bloc<E, S> bloc,
    required E Function(T) createEvent,
    E Function(T)? createSuccessEvent,
    E Function(T, dynamic)? createFailureEvent,
    required bool Function(S) checkState,
    required T entity,
    String? successMessage,
    String? errorMessage,
    bool showOverlay = true,
    Duration maxWaitTime = const Duration(seconds: 10),
  }) async {
    // Store the initial state and context before any async operations
    final initialState = bloc.state;
    final l10n = AppLocalizations.of(context);
    
    // Show loading overlay if requested
    Function(BuildContext)? dismissOverlay;
    if (showOverlay) {
      dismissOverlay = showLoading(context);
    }
    
    // Create a completer to handle the asynchronous result
    final completer = Completer<bool>();
    
    // Listen for state changes
    late StreamSubscription<S> subscription;
    
    // Set up timeout
    final timeoutTimer = Timer(maxWaitTime, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        
        // Dismiss overlay if shown
        if (dismissOverlay != null && context.mounted) {
          dismissOverlay(context);
        }
        
        // Show error message
        if (context.mounted) {
          showResultSnackbar(
            context: context,
            isSuccess: false,
            successMessage: successMessage ?? l10n.operationSuccessful,
            errorMessage: errorMessage ?? l10n.operationTimedOut,
            onRetry: () {
              // Retry the operation
              bloc.add(createEvent(entity));
            },
          );
        }
        
        completer.complete(false);
      }
    });
    
    // Listen for state changes
    subscription = bloc.stream.listen((state) {
      // Check if the operation was successful
      final bool isSuccess = checkState(state);
      
      if (isSuccess || state != initialState) {
        // Cancel timeout timer
        timeoutTimer.cancel();
        
        // Only complete once
        if (!completer.isCompleted) {
          // Cancel subscription
          subscription.cancel();
          
          // Dismiss overlay if shown
          if (dismissOverlay != null && context.mounted) {
            dismissOverlay(context);
          }
          
          // Show message if context is still valid
          if (context.mounted && (successMessage != null || errorMessage != null)) {
            showResultSnackbar(
              context: context,
              isSuccess: isSuccess,
              successMessage: successMessage ?? l10n.operationSuccessful,
              errorMessage: errorMessage ?? l10n.operationFailed,
              onRetry: isSuccess 
                  ? null 
                  : () {
                      // Retry the operation
                      bloc.add(createEvent(entity));
                    },
            );
          }
          
          completer.complete(isSuccess);
        }
      }
    });
    
    // Initiate the operation
    bloc.add(createEvent(entity));
    
    // Wait for the result
    return completer.future;
  }
  
  /// Method specifically tailored for optimistic record creation
  /// This is a template method that specializes the generic method for record creation
  static Future<bool> createRecordOptimistically<E, S, T>({
    required BuildContext context,
    required Bloc<E, S> bloc,
    required E Function(T) createEvent,
    required bool Function(S) checkSuccess,
    required T record,
    required String entityName,
  }) async {
    final l10n = AppLocalizations.of(context);
    
    return performOptimisticUpdate<E, S, T>(
      context: context,
      bloc: bloc,
      createEvent: createEvent,
      checkState: checkSuccess,
      entity: record,
      successMessage: l10n.entityCreatedSuccessfully(entityName),
      errorMessage: l10n.failedToCreateEntity(entityName),
      showOverlay: true,
    );
  }
  
  /// Method specifically tailored for optimistic record deletion
  static Future<bool> deleteRecordOptimistically<E, S, T>({
    required BuildContext context,
    required Bloc<E, S> bloc,
    required E Function(String) createEvent,
    required bool Function(S) checkSuccess,
    required String recordId,
    required String entityName,
  }) async {
    final l10n = AppLocalizations.of(context);
    
    return performOptimisticUpdate<E, S, String>(
      context: context,
      bloc: bloc,
      createEvent: createEvent,
      checkState: checkSuccess,
      entity: recordId,
      successMessage: l10n.entityDeletedSuccessfully(entityName),
      errorMessage: l10n.failedToDeleteEntity(entityName),
      showOverlay: false, // Usually don't need overlay for deletion
    );
  }
}