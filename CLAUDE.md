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

## Optimistic State Pattern
- The app uses the Optimistic State pattern for "Craving" and "New Record" sheets
- Reference: [Flutter Optimistic State Design Pattern](https://docs.flutter.dev/app-architecture/design-patterns/optimistic-state)
- Implementation principles:
  - Immediately update UI assuming the operation will succeed
  - Capture the current state before the operation for potential rollback
  - Perform the actual operation (API call, DB update) in the background
  - Handle errors by reverting to the previous state if needed
  - Show appropriate feedback (success/error) after the operation completes
- When implementing:
  - Store a backup of the current state before modifying it
  - Update the UI immediately for better user experience
  - Use try/catch blocks to handle potential errors
  - Provide clear visual indicators of success/failure
  - Include undo functionality where appropriate
- Example code structure:
  ```dart
  // 1. Store original state
  final originalState = {..._currentState};
  
  // 2. Update state optimistically
  setState(() {
    _currentState = {..._currentState, ...newChanges};
  });
  
  try {
    // 3. Perform the actual operation
    await repository.saveChanges(newChanges);
    
    // 4. Operation succeeded, show success feedback
    showSuccessMessage('Changes saved successfully');
  } catch (e) {
    // 5. Operation failed, revert to original state
    setState(() {
      _currentState = originalState;
    });
    
    // 6. Show error feedback
    showErrorMessage('Failed to save changes: ${e.message}');
  }
  ```