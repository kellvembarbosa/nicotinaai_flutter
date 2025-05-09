# BLoC Pattern Implementation

This directory contains the BLoC (Business Logic Component) implementation for the app.

## Structure

Each feature has its own directory with:

- `<feature>_bloc.dart` - The BLoC class that processes events and emits states
- `<feature>_event.dart` - Events that represent user actions or system events
- `<feature>_state.dart` - States that represent the UI state

## Usage

### 1. Providing a BLoC

```dart
BlocProvider(
  create: (context) => FeatureBloc(
    repository: context.read<Repository>(),
  )..add(InitialEvent()),
  child: FeatureScreen(),
)
```

### 2. Accessing a BLoC

```dart
// Read BLoC (one-time access)
final bloc = context.read<FeatureBloc>();

// Watch BLoC (access with dependencies)
final bloc = context.watch<FeatureBloc>();

// Access from a builder
BlocBuilder<FeatureBloc, FeatureState>(
  builder: (context, state) {
    final bloc = context.read<FeatureBloc>();
    // Use bloc here
  },
)
```

### 3. Dispatching Events

```dart
context.read<FeatureBloc>().add(SomeEvent());
```

### 4. Responding to States

```dart
BlocBuilder<FeatureBloc, FeatureState>(
  builder: (context, state) {
    if (state is LoadingState) {
      return LoadingIndicator();
    } else if (state is LoadedState) {
      return DataWidget(data: state.data);
    } else if (state is ErrorState) {
      return ErrorWidget(message: state.message);
    }
    return SizedBox.shrink();
  },
)
```

## Handling UI Side Effects

For UI side effects like showing snackbars or navigation:

```dart
BlocListener<FeatureBloc, FeatureState>(
  listener: (context, state) {
    if (state is SuccessState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Success!')),
      );
    }
  },
  child: YourWidget(),
)
```

## Combined Builder and Listener

```dart
BlocConsumer<FeatureBloc, FeatureState>(
  listener: (context, state) {
    if (state is SuccessState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Success!')),
      );
    }
  },
  builder: (context, state) {
    if (state is LoadingState) {
      return LoadingIndicator();
    } else if (state is LoadedState) {
      return DataWidget(data: state.data);
    }
    return SizedBox.shrink();
  },
)
```

## Testing BLoCs

See the `test/blocs` directory for examples of BLoC tests.