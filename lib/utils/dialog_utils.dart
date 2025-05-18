import 'package:flutter/material.dart';

/// Utility class for managing dialogs
class DialogUtils {
  /// Shows a loading dialog with automatic dismissal after a timeout
  /// 
  /// This is useful to prevent infinite loading states in case of errors
  /// or unresponsive services. The dialog will be dismissed automatically
  /// after [timeoutSeconds] seconds (defaults to 3 seconds).
  /// 
  /// Usage:
  /// ```dart
  /// // Show a loading dialog that auto-dismisses after 3 seconds
  /// DialogUtils.showLoadingWithTimeout(
  ///   context,
  ///   message: 'Carregando...',
  ///   onTimeout: () {
  ///     // Optional: Execute code after timeout
  ///     print('Loading timed out');
  ///   }
  /// );
  /// ```
  static void showLoadingWithTimeout(
    BuildContext context, {
    String? message,
    int timeoutSeconds = 3,
    VoidCallback? onTimeout,
    Color? color,
  }) {
    // Flag to prevent multiple pops
    bool dialogActive = true;
    
    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        // Prevent closure by back button
        onWillPop: () async => false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: color ?? Theme.of(context).primaryColor,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    
    // Set auto-dismiss timer
    Future.delayed(Duration(seconds: timeoutSeconds), () {
      // Check if dialog is still active and context is valid
      if (dialogActive && context.mounted) {
        try {
          Navigator.of(context).pop();
          dialogActive = false;
          
          // Execute timeout callback if provided
          if (onTimeout != null) {
            onTimeout();
          }
        } catch (e) {
          print('Error dismissing dialog: $e');
        }
      }
    });
  }
}