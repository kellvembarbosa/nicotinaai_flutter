# Migration Plan: Provider to Signals

This document outlines the comprehensive plan to migrate NicotinaAI Flutter application from Provider to Signals for state management.

## Table of Contents
- [Introduction](#introduction)
- [Benefits of Migration](#benefits-of-migration)
- [Implementation Phases](#implementation-phases)
- [Migration Patterns](#migration-patterns)
- [Testing Strategy](#testing-strategy)
- [Potential Issues](#potential-issues)
- [Rollback Strategy](#rollback-strategy)

## Introduction

The NicotinaAI Flutter app currently uses Provider for state management. We're migrating to Signals to leverage its advantages of fine-grained reactivity, reduced boilerplate code, and improved performance through more efficient re-renders.

## Benefits of Migration

1. **Fine-grained reactivity**: Only rebuild widgets that depend on changed state
2. **Reduced boilerplate**: Simpler state management with less code
3. **Improved performance**: More efficient change tracking and rendering
4. **Better TypeScript-like experience**: More type safety and IDE support
5. **Easier testing**: Simpler mocking and state manipulation in tests

## Implementation Phases

We'll implement the migration in phases, starting with simpler providers and moving to more complex ones.

### Phase 1: Simple Providers (Week 1)
- `DeveloperModeProvider`
- `ThemeProvider`
- `LocaleProvider`
- `CurrencyProvider`

### Phase 2: Feature-specific Providers (Week 2-3)
- `AuthProvider` (Login-related functionality)
- `OnboardingProvider`
- `SmokingRecordProvider`
- `CravingProvider`

### Phase 3: Core Application Providers (Week 4)
- `TrackingProvider`
- Any remaining providers

## Migration Patterns

### Pattern 1: Simple Value Provider to Signal

**Before (Provider):**
```dart
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

// Usage
final themeProvider = Provider.of<ThemeProvider>(context);
themeProvider.setThemeMode(ThemeMode.dark);
Text('Current theme: ${themeProvider.themeMode}');
```

**After (Signals):**
```dart
class ThemeService {
  final themeMode = Signal<ThemeMode>(ThemeMode.system);
  
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }
}

// Create global instance
final themeService = ThemeService();

// Usage
themeService.setThemeMode(ThemeMode.dark);
Text('Current theme: ${useSignalValue(themeService.themeMode)}');
```

### Pattern 2: Complex State Provider to Computed Signals

**Before (Provider):**
```dart
class TrackingProvider extends ChangeNotifier {
  final List<SmokingLog> _smokingLogs = [];
  final List<Craving> _cravings = [];
  UserStats? _userStats;
  
  List<SmokingLog> get smokingLogs => _smokingLogs;
  List<Craving> get cravings => _cravings;
  UserStats? get userStats => _userStats;
  
  int get totalCigarettesSmoked => _smokingLogs.length;
  int get totalCravingsResisted => _cravings.where((c) => c.resisted).length;
  
  Future<void> addSmokingLog(SmokingLog log) async {
    _smokingLogs.add(log);
    await _repository.addSmokingLog(log);
    notifyListeners();
  }
}
```

**After (Signals):**
```dart
class TrackingService {
  final smokingLogs = Signal<List<SmokingLog>>([]);
  final cravings = Signal<List<Craving>>([]);
  final userStats = Signal<UserStats?>(null);
  
  // Computed signals for derived state
  late final totalCigarettesSmoked = computed(() => smokingLogs.value.length);
  late final totalCravingsResisted = computed(
    () => cravings.value.where((c) => c.resisted).length
  );
  
  Future<void> addSmokingLog(SmokingLog log) async {
    smokingLogs.value = [...smokingLogs.value, log];
    await _repository.addSmokingLog(log);
  }
}

// Create global instance
final trackingService = TrackingService();
```

### Pattern 3: Loading/Error States with Effect

**Before (Provider):**
```dart
class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  User? _user;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _user = await _repository.login(email, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**After (Signals):**
```dart
class AuthService {
  final isLoading = Signal<bool>(false);
  final error = Signal<String?>(null);
  final user = Signal<User?>(null);
  
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    error.value = null;
    
    try {
      user.value = await _repository.login(email, password);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

// Create global instance
final authService = AuthService();

// Usage with effect
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use effect to handle error messages
    useEffect(() {
      final errorValue = authService.error.value;
      if (errorValue != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorValue))
        );
      }
      
      return null;
    }, [authService.error.value]);
    
    return Scaffold(
      body: useSignalBuilder(
        signal: authService.isLoading,
        builder: (context, isLoading) {
          return isLoading 
            ? CircularProgressIndicator() 
            : LoginForm();
        },
      ),
    );
  }
}
```

### Pattern 4: Signal for Collection with Optimistic Updates

```dart
class CravingService {
  final cravings = Signal<List<CravingModel>>([]);
  final isLoading = Signal<bool>(false);
  final error = Signal<String?>(null);
  
  Future<void> saveCraving(CravingModel craving) async {
    // Create temporary ID for optimistic update
    final temporaryId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticCraving = craving.copyWith(
      id: temporaryId,
      syncStatus: SyncStatus.pending,
    );
    
    // Update UI immediately with optimistic update
    cravings.value = [optimisticCraving, ...cravings.value];
    
    try {
      // Perform the actual API call
      final savedCraving = await _repository.saveCraving(craving);
      
      // Replace optimistic entry with real one
      cravings.value = cravings.value.map((c) => 
        c.id == temporaryId ? savedCraving : c
      ).toList();
      
      error.value = null;
    } catch (e) {
      // Mark as failed but keep in the list
      cravings.value = cravings.value.map((c) => 
        c.id == temporaryId 
          ? c.copyWith(syncStatus: SyncStatus.failed) 
          : c
      ).toList();
      
      error.value = e.toString();
    }
  }
}
```

## Testing Strategy

1. **Unit Tests**: Update existing unit tests to work with Signals
2. **Widget Tests**: Ensure UI components correctly respond to Signal changes
3. **Integration Tests**: Validate that full features work with the new state management

Example of unit test for a Signal-based service:

```dart
void main() {
  group('ThemeService Tests', () {
    late ThemeService themeService;
    
    setUp(() {
      themeService = ThemeService();
    });
    
    test('should have system theme by default', () {
      expect(themeService.themeMode.value, equals(ThemeMode.system));
    });
    
    test('should change theme mode', () {
      themeService.setThemeMode(ThemeMode.dark);
      expect(themeService.themeMode.value, equals(ThemeMode.dark));
      
      themeService.setThemeMode(ThemeMode.light);
      expect(themeService.themeMode.value, equals(ThemeMode.light));
    });
  });
}
```

## Potential Issues

1. **Memory Management**:
   - Provider automatically disposes of state, but Signals requires more manual management
   - Solution: Ensure proper disposal of signals in `dispose` methods when needed

2. **Context-Based Access**:
   - Provider uses BuildContext for state access, Signals uses global instances
   - Solution: Consider using service locator pattern to maintain testability

3. **Multiple Instances**:
   - Global Signal instances can cause issues in tests
   - Solution: Add reset methods or factory constructors for testing

4. **Migration Complexity**:
   - Converting complex providers might be challenging
   - Solution: Consider a hybrid approach temporarily for complex cases

## Rollback Strategy

1. Keep Provider-based implementation in separate files during initial phases
2. Use feature flags to switch between Provider and Signals implementations
3. Implement A/B testing to compare performance and stability
4. If issues arise, revert to Provider implementation for affected features

## Implementation Guidelines

1. Start with a small, isolated feature to test the migration approach
2. Create utility helpers for common patterns
3. Document patterns and best practices as you discover them
4. Use a consistent naming convention (Service vs Repository vs Store)
5. Update documentation as you migrate each component

## Timeline

- **Week 1**: Set up Signals infrastructure and migrate simple providers
- **Week 2-3**: Migrate feature-specific providers and update tests
- **Week 4**: Migrate core application providers and comprehensive testing
- **Week 5**: Performance optimization and cleanup

## Conclusion

This migration will enhance application performance and developer experience. By following a phased approach and established patterns, we can minimize risks while maximizing benefits.