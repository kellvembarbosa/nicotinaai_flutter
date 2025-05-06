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