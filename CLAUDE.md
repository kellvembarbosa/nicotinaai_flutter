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