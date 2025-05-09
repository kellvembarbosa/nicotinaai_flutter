# Skeleton BLoC Usage Example

This document provides a practical example of how to use the new BLoC-based skeleton loading system in your screens.

## Basic Usage

### Step 1: Import Required Files

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/skeleton/skeleton_bloc.dart';
import 'package:nicotinaai_flutter/blocs/skeleton/skeleton_event.dart';
import 'package:nicotinaai_flutter/blocs/skeleton/skeleton_state.dart';
import 'package:nicotinaai_flutter/widgets/skeleton_loading.dart';
import 'package:nicotinaai_flutter/widgets/skeleton_widget.dart';
```

### Step 2: Use the SkeletonWidget in Your Screen

```dart
class HealthRecoveryScreen extends StatelessWidget {
  const HealthRecoveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Recovery'),
      ),
      body: SkeletonWidget<List<HealthRecovery>>(
        fetchData: () => context.read<HealthRecoveryRepository>().getHealthRecoveries(),
        loadingWidget: const RecoveryDetailSkeleton(),
        builder: (context, healthRecoveries) {
          return ListView.builder(
            itemCount: healthRecoveries.length,
            itemBuilder: (context, index) {
              final recovery = healthRecoveries[index];
              return HealthRecoveryItem(recovery: recovery);
            },
          );
        },
        // Optional: Custom error widget
        errorWidget: (context, message) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to load data: $message'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Reload data
                    context.read<SkeletonBloc>().add(LoadData());
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

## Manually Controlling Loading

If you need more control over the loading process:

```dart
class ControlledLoadingScreen extends StatelessWidget {
  const ControlledLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controlled Loading'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Manual reload
              context.read<SkeletonBloc>().add(LoadData());
            },
          ),
        ],
      ),
      body: SkeletonWidget<Data>(
        fetchData: () => fetchDataFromApi(),
        autoLoad: false, // Don't load automatically
        loadingWidget: const CustomLoadingWidget(),
        builder: (context, data) {
          return DataDisplayWidget(data: data);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Start loading when user presses the button
          context.read<SkeletonBloc>().add(LoadData());
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
```

## Using with Pull-to-Refresh

```dart
class RefreshableListScreen extends StatelessWidget {
  const RefreshableListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refreshable List'),
      ),
      body: BlocBuilder<SkeletonBloc, SkeletonState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<SkeletonBloc>().add(ReloadData());
              // Wait for reload to complete
              await Future.delayed(const Duration(seconds: 1));
            },
            child: state is SkeletonLoading && state is! SkeletonLoaded
                ? const ListLoadingSkeleton()
                : state is SkeletonLoaded
                    ? ListView.builder(
                        itemCount: state.data.length,
                        itemBuilder: (context, index) {
                          return ListItem(data: state.data[index]);
                        },
                      )
                    : state is SkeletonError
                        ? ErrorDisplay(message: state.message)
                        : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
```

## Converting from Provider Pattern

### Before (Using Provider):

```dart
class DataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data')),
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return LoadingWidget();
          } else if (provider.hasError) {
            return ErrorWidget(message: provider.errorMessage);
          } else {
            return DataWidget(data: provider.data);
          }
        },
      ),
    );
  }
}
```

### After (Using BLoC):

```dart
class DataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data')),
      body: SkeletonWidget<Data>(
        fetchData: () => context.read<DataRepository>().getData(),
        loadingWidget: LoadingWidget(),
        builder: (context, data) {
          return DataWidget(data: data);
        },
        errorWidget: (context, message) {
          return ErrorWidget(message: message);
        },
      ),
    );
  }
}
```

## Benefits of the BLoC Approach

1. **Separation of Concerns**: Business logic is separated from UI
2. **Testability**: BLoCs are easy to test in isolation
3. **Reusability**: Same BLoC pattern can be used across different screens
4. **Predictable State Management**: All state changes go through a single pipeline
5. **Consistency**: Unified approach to handling loading, error, and success states