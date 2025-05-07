import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class SyncStatusIndicator extends StatelessWidget {
  final SyncStatus status;
  final VoidCallback? onRetry;
  final double size;

  const SyncStatusIndicator({
    super.key,
    required this.status,
    this.onRetry,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    switch (status) {
      case SyncStatus.synced:
        return Icon(Icons.check_circle, color: Colors.green, size: size);
        
      case SyncStatus.pending:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: size / 8,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
        
      case SyncStatus.failed:
        return GestureDetector(
          onTap: onRetry,
          child: Tooltip(
            message: l10n.tapToRetry,
            child: Icon(Icons.error, color: Colors.red, size: size),
          ),
        );
        
      case SyncStatus.error:
        return Tooltip(
          message: l10n.syncError,
          child: Icon(Icons.error_outline, color: Colors.orange, size: size),
        );
    }
  }
}