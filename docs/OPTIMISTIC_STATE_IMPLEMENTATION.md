# Optimistic State Implementation for Craving and Record Management

This document outlines how to implement the Optimistic State pattern in the "Craving" and "New Record" sheets of the Nicotina.AI application.

## Understanding Optimistic State

The [Optimistic State design pattern](https://docs.flutter.dev/app-architecture/design-patterns/optimistic-state) provides a responsive user experience by immediately reflecting user actions in the UI, even before they are confirmed by backend operations. This pattern:

1. Assumes operations will succeed and updates the UI immediately
2. Performs the actual operation in the background
3. Handles potential failures by reverting to the previous state if necessary

## Implementation in Craving Sheet

The Craving Sheet allows users to record cravings they've experienced or resisted. Here's how to implement Optimistic State:

### Data Models

```dart
class CravingModel {
  final String id;
  final String userId;
  final String location;
  final String trigger;
  final String outcome; // 'RESISTED' or 'SMOKED'
  final DateTime timestamp;
  final int intensity; // 1-5
  final SyncStatus syncStatus; // Add this field

  CravingModel({
    required this.id,
    required this.userId,
    required this.location,
    required this.trigger,
    required this.outcome,
    required this.timestamp,
    required this.intensity,
    this.syncStatus = SyncStatus.synced,
  });

  // Add copy method for state manipulation
  CravingModel copyWith({
    String? id,
    String? userId,
    String? location,
    String? trigger,
    String? outcome,
    DateTime? timestamp,
    int? intensity,
    SyncStatus? syncStatus,
  }) {
    return CravingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      location: location ?? this.location,
      trigger: trigger ?? this.trigger,
      outcome: outcome ?? this.outcome,
      timestamp: timestamp ?? this.timestamp,
      intensity: intensity ?? this.intensity,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

enum SyncStatus {
  synced,     // Item is synced with server
  pending,    // Item is waiting to be synced
  failed,     // Sync failed but will retry
  error       // Permanent error, won't retry
}
```

### Provider Implementation

```dart
class CravingProvider with ChangeNotifier {
  final CravingRepository _repository;
  List<CravingModel> _cravings = [];
  bool _isLoading = false;
  String? _error;

  CravingProvider(this._repository);

  // Getters
  List<CravingModel> get cravings => _cravings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Add craving with optimistic update
  Future<void> addCraving(CravingModel craving) async {
    // Generate a temporary ID for the new craving
    final temporaryId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticCraving = craving.copyWith(
      id: temporaryId,
      syncStatus: SyncStatus.pending
    );
    
    // Add to the list optimistically
    _cravings.add(optimisticCraving);
    notifyListeners();
    
    try {
      // Perform the actual API call
      final createdCraving = await _repository.addCraving(craving);
      
      // Update the temporary item with the real one
      _cravings = _cravings.map((c) => 
        c.id == temporaryId ? createdCraving : c
      ).toList();
      
      notifyListeners();
    } catch (e) {
      // Mark as failed but keep in the list
      _cravings = _cravings.map((c) => 
        c.id == temporaryId ? c.copyWith(syncStatus: SyncStatus.failed) : c
      ).toList();
      
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Retry failed cravings
  Future<void> retrySyncCraving(String id) async {
    final cravingIndex = _cravings.indexWhere((c) => c.id == id);
    if (cravingIndex == -1) return;
    
    // Mark as pending
    _cravings[cravingIndex] = _cravings[cravingIndex].copyWith(
      syncStatus: SyncStatus.pending
    );
    notifyListeners();
    
    try {
      // Get a clean version without the temporary ID
      final cravingToSync = _cravings[cravingIndex].copyWith(
        id: id.startsWith('temp_') ? '' : id
      );
      
      // Perform the actual API call
      final syncedCraving = await _repository.addCraving(cravingToSync);
      
      // Replace with the synced version
      _cravings[cravingIndex] = syncedCraving;
      notifyListeners();
    } catch (e) {
      // Mark as failed again
      _cravings[cravingIndex] = _cravings[cravingIndex].copyWith(
        syncStatus: SyncStatus.failed
      );
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

### UI Implementation

```dart
class RegisterCravingSheet extends StatefulWidget {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RegisterCravingSheet(),
    );
  }
  
  @override
  _RegisterCravingSheetState createState() => _RegisterCravingSheetState();
}

class _RegisterCravingSheetState extends State<RegisterCravingSheet> {
  // Form controllers and state variables here
  
  Future<void> _submitCraving() async {
    if (!_formKey.currentState!.validate()) return;
    
    final newCraving = CravingModel(
      id: '',  // Will be assigned by backend
      userId: context.read<AuthProvider>().currentUser!.id,
      location: _locationController.text,
      trigger: _triggerController.text,
      outcome: _didSmoke ? 'SMOKED' : 'RESISTED',
      timestamp: DateTime.now(),
      intensity: _intensity,
    );
    
    // Optimistically add the craving and close the sheet
    context.read<CravingProvider>().addCraving(newCraving);
    Navigator.of(context).pop();
    
    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).cravingRecorded),
        action: SnackBarAction(
          label: AppLocalizations.of(context).undo,
          onPressed: () {
            // Handle undo action
          },
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Sheet UI implementation
    return Consumer<CravingProvider>(
      builder: (context, provider, _) {
        // Show different UI based on provider state
        return Form(
          key: _formKey,
          child: Column(
            // Form fields
            children: [
              // Other form fields
              
              ElevatedButton(
                onPressed: provider.isLoading ? null : _submitCraving,
                child: Text(AppLocalizations.of(context).saveCraving),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## Implementation in New Record Sheet

The New Record sheet allows users to record smoking incidents. The implementation follows a similar pattern to the Craving sheet.

### Data Models

```dart
class SmokingRecordModel {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String location;
  final String reason;
  final int quantity;
  final SyncStatus syncStatus;

  SmokingRecordModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.location,
    required this.reason,
    required this.quantity,
    this.syncStatus = SyncStatus.synced,
  });

  // Similar copyWith method as CravingModel
}
```

### Provider Implementation

```dart
class SmokingRecordProvider with ChangeNotifier {
  final SmokingRecordRepository _repository;
  List<SmokingRecordModel> _records = [];
  bool _isLoading = false;
  String? _error;

  // Similar implementation as CravingProvider with methods:
  // - addRecord (with optimistic update)
  // - retrySyncRecord
  // - deleteRecord (with optimistic delete)
}
```

## UI Feedback for Sync Status

When displaying lists of cravings or smoking records, show visual indicators for sync status:

```dart
Widget _buildSyncStatusIndicator(SyncStatus status) {
  switch (status) {
    case SyncStatus.synced:
      return Icon(Icons.check_circle, color: Colors.green, size: 16);
    case SyncStatus.pending:
      return SizedBox(
        width: 16, height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    case SyncStatus.failed:
      return IconButton(
        icon: Icon(Icons.error, color: Colors.red, size: 16),
        onPressed: () => _handleRetry(),
      );
    case SyncStatus.error:
      return Icon(Icons.error_outline, color: Colors.orange, size: 16);
  }
}
```

## Background Synchronization

Implement a service to retry failed synchronizations in the background:

```dart
class SyncService {
  final CravingProvider _cravingProvider;
  final SmokingRecordProvider _recordProvider;
  
  SyncService(this._cravingProvider, this._recordProvider);
  
  Future<void> syncPendingItems() async {
    // Sync pending cravings
    final pendingCravings = _cravingProvider.cravings
        .where((c) => c.syncStatus == SyncStatus.failed)
        .toList();
        
    for (final craving in pendingCravings) {
      await _cravingProvider.retrySyncCraving(craving.id);
    }
    
    // Sync pending smoking records
    // Similar implementation
  }
}
```

## Benefits of This Approach

1. **Improved User Experience**: Users get immediate feedback when recording cravings or smoking incidents
2. **Offline Support**: Records are saved locally before being sent to the server
3. **Resilience**: Failed operations are tracked and can be retried
4. **Transparency**: Users see the sync status of their records

## Testing Considerations

When testing the Optimistic State pattern:

1. Test happy path (successful sync)
2. Test network failure scenarios
3. Test recovery from failures
4. Test multiple concurrent operations
5. Test background synchronization