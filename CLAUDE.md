# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Run app: `flutter run`
- Build for production: `flutter build apk` (Android) or `flutter build ios` (iOS)
- Install dependencies: `flutter pub get`

## Test Commands
- Run all tests: `flutter test`
- Run a single test: `flutter test test/path/to/test_file.dart`
- Run with coverage: `flutter test --coverage`

## Lint Commands
- Run analyzer: `flutter analyze`
- Fix formatting: `dart format lib`

## Currency Handling System
- All monetary values in the database are stored in cents (integer values)
- Use `currency_formatter` package for displaying monetary values to users
- Use existing `CurrencyUtils` class in `/lib/utils/currency_utils.dart` for conversions
- The app detects the user's device currency by default
- Users can change their preferred currency in Settings
- When displaying monetary values:
  - Always use the user's preferred currency for display
  - Use `CurrencyFormatter` for input fields
  - Use `CurrencyUtils.format()` for output display
  - Use `CurrencyUtils.parseToCents()` before saving to database
- Key functions:
  - `format(int valueInCents)` - Display formatted currency with symbol
  - `formatCompact(int valueInCents)` - Display without decimal places
  - `parseToCents(String value)` - Convert string to cents for storage
  - `detectDeviceCurrencySymbol()` - Get device currency symbol
  - `detectDeviceCurrencyCode()` - Get device currency code

## Code Style Guidelines
- Follow Flutter's official style guide and linting rules
- Use named parameters for widgets with required annotation
- Prefer const constructors when possible
- Organize imports: dart:core first, then dart:*, then package imports, then relative imports
- Use PascalCase for classes/enums/typedefs, camelCase for variables/methods
- Prefix private members with underscore (_)
- Handle errors with try/catch blocks, use Result pattern or nullable returns
- Comments should explain "why" not "what"
- Use features from latest stable Flutter/Dart versions available

## BLoC Naming Conventions and Structure
- BLoC classes: `<Feature>Bloc` (e.g., `UserBloc`, `SettingsBloc`)
- Event classes: `<Feature>Event` as abstract base, `<Verb><Noun>` for concrete events (e.g., `UserLoadRequested`, `SettingsUpdated`)
- State classes: `<Feature>State` (can be a single class with properties or multiple inheritance-based classes)
- File organization:
  ```
  lib/
  ├── blocs/
  │   ├── <feature>/
  │   │   ├── <feature>_bloc.dart
  │   │   ├── <feature>_event.dart
  │   │   └── <feature>_state.dart
  ```
- Follow consistent event naming: Use past tense for completed actions (e.g., `UserLoggedIn`), imperative for commands (e.g., `LoadUser`)
- State classes should be immutable and use copyWith methods for updates
- Use `equatable` for proper equality comparisons in events and states
- Utilize BLoC event handler methods in the format `_on<EventName>`

## Cursor Rules
- Always place cursor at the relevant position when showing code examples
- When demonstrating a function, position cursor at the function name
- For conditional statements, place cursor at the condition
- When explaining a loop, place cursor at the loop declaration
- For method calls, position cursor at the method name
- When editing widget properties, place cursor at the property being modified
- For errors, place cursor at the exact error location
- When explaining Optimistic State implementation:
  - For state backup, place cursor at the backup variable declaration
  - For state updates, place cursor at the setState call
  - For API/DB operations, place cursor at the await expression
  - For error handling, place cursor at the catch statement
  - For state rollback, place cursor at the rollback setState call

## Navigation and Routing
- Always use the AppRoutes enum for navigation instead of hardcoded strings
- Example: `context.go(AppRoutes.login.path)` instead of `context.go('/login')`
- All routes are defined in `/lib/core/routes/app_routes.dart`
- Available routes:
  - Authentication: `login`, `register`, `forgotPassword`
  - Main navigation: `main` (with tabs)
  - Individual tabs: `home`, `achievements`, `settings`
  - Other routes: `profile`, `editProfile`, `notifications`, `about`
- For navigation with parameters, use `AppRoutes.routeName.withParams({params})`
- When adding new screens, always add the corresponding route to the AppRoutes enum

## BLoC Pattern
- The app uses the BLoC (Business Logic Component) pattern for state management
- Reference: [bloc.dev](https://bloclibrary.dev)
- Core BLoC concepts:
  - **Events**: Input to the BLoC that trigger state changes
  - **States**: Output from the BLoC that represents UI state
  - **BLoC**: Business Logic Component that processes events and emits states
- Key principles:
  - Separation of UI from business logic
  - Unidirectional data flow: Event → BLoC → State
  - Immutable states: Always create new state objects
  - Predictable state changes through event handling
- File structure for each feature:
  - `<feature>_bloc.dart`: Contains BLoC implementation
  - `<feature>_event.dart`: Contains all events for the feature
  - `<feature>_state.dart`: Contains state classes for the feature
- Example implementation:
  ```dart
  // Event
  abstract class CounterEvent {}
  class IncrementEvent extends CounterEvent {}
  
  // State
  class CounterState {
    final int count;
    const CounterState({this.count = 0});
    
    CounterState copyWith({int? count}) {
      return CounterState(count: count ?? this.count);
    }
  }
  
  // BLoC
  class CounterBloc extends Bloc<CounterEvent, CounterState> {
    CounterBloc() : super(const CounterState()) {
      on<IncrementEvent>(_onIncrement);
    }
    
    void _onIncrement(IncrementEvent event, Emitter<CounterState> emit) {
      emit(state.copyWith(count: state.count + 1));
    }
  }
  
  // UI usage with BlocBuilder
  BlocBuilder<CounterBloc, CounterState>(
    builder: (context, state) {
      return Text('${state.count}');
    },
  )
  
  // Dispatch events
  context.read<CounterBloc>().add(IncrementEvent());
  ```
  
## Optimistic Updates with BLoC
- Implement optimistic updates by:
  1. Emitting an immediate state change with expected result
  2. Performing the operation asynchronously
  3. Reverting to previous state if operation fails
- Example code structure:
  ```dart
  // In BLoC event handler
  Future<void> _onAddRecord(AddRecordEvent event, Emitter<RecordsState> emit) async {
    // 1. Store original state
    final originalState = state;
    
    // 2. Update state optimistically
    final newRecord = event.record;
    final updatedRecords = List<Record>.from(state.records)..add(newRecord);
    emit(state.copyWith(records: updatedRecords, status: RecordsStatus.loading));
    
    try {
      // 3. Perform the actual operation
      await repository.saveRecord(newRecord);
      
      // 4. Operation succeeded, emit success state
      emit(state.copyWith(status: RecordsStatus.success));
    } catch (e) {
      // 5. Operation failed, revert to original state
      emit(originalState);
      
      // 6. Emit error state
      emit(state.copyWith(
        status: RecordsStatus.failure,
        errorMessage: 'Failed to save record: ${e.toString()}'
      ));
    }
  }
  ```