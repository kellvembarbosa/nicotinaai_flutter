# BLoC Migration Plan for NicotinaAI Flutter

This document outlines the plan to migrate the app from Provider/ChangeNotifier pattern to BLoC (Business Logic Component) pattern using the flutter_bloc package.

## Why BLoC?

- **Separation of Concerns**: BLoC separates business logic from UI
- **Testability**: BLoC is highly testable
- **Predictable State Management**: Event-driven architecture makes state changes predictable
- **Reusability**: Business logic can be reused across different UI components
- **Scalability**: Better for complex apps with many features

## BLoC Architecture Overview

1. **Events**: Represent user interactions or system events
2. **States**: Represent the current state of the application
3. **BLoC**: Business Logic Component that processes events and emits states

## Migration Plan

### Phase 1: Setup and Infrastructure

1. **Add Dependencies**
   - Add `flutter_bloc` and `bloc` packages ✅
   - Add `bloc_test` for testing BLoCs

2. **Define Base Architecture**
   - Create base classes/interfaces for events and states
   - Set up BLoC observer for logging/debugging

### Phase 2: Feature by Feature Migration

Start with simpler features like skeletons/loading states, then move to more complex ones:

#### 1. Skeleton Loading Feature

1. **Define Events and States**
   ```dart
   // Events
   abstract class SkeletonEvent {}
   class LoadData extends SkeletonEvent {}
   
   // States
   abstract class SkeletonState {}
   class SkeletonLoading extends SkeletonState {}
   class SkeletonLoaded extends SkeletonState {
     final dynamic data;
     SkeletonLoaded(this.data);
   }
   class SkeletonError extends SkeletonState {
     final String message;
     SkeletonError(this.message);
   }
   ```

2. **Implement BLoC**
   ```dart
   class SkeletonBloc extends Bloc<SkeletonEvent, SkeletonState> {
     final Repository repository;
     
     SkeletonBloc({required this.repository}) : super(SkeletonLoading()) {
       on<LoadData>(_onLoadData);
     }
     
     Future<void> _onLoadData(LoadData event, Emitter<SkeletonState> emit) async {
       emit(SkeletonLoading());
       try {
         final data = await repository.getData();
         emit(SkeletonLoaded(data));
       } catch (e) {
         emit(SkeletonError(e.toString()));
       }
     }
   }
   ```

3. **Update UI**
   ```dart
   // Replace Provider with BlocProvider
   BlocProvider(
     create: (context) => SkeletonBloc(
       repository: context.read<Repository>(),
     )..add(LoadData()),
     child: SkeletonScreen(),
   )
   
   // Replace Consumer with BlocBuilder
   BlocBuilder<SkeletonBloc, SkeletonState>(
     builder: (context, state) {
       if (state is SkeletonLoading) {
         return SkeletonLoadingWidget();
       } else if (state is SkeletonLoaded) {
         return DataWidget(data: state.data);
       } else if (state is SkeletonError) {
         return ErrorWidget(message: state.message);
       }
       return Container();
     },
   )
   ```

#### 2. Auth Feature

Similar approach with Auth-specific events and states.

#### 3. Home Feature (Smoking Records, Cravings)

Update with events for adding/updating records and appropriate states.

#### 4. Tracking Feature

Implement tracking-specific BLoCs.

#### 5. Achievements Feature

Migrate achievements feature to BLoC pattern.

### Phase 3: Global State Management

1. **Implement Global BLoCs** for app-wide state (if needed)
   - User BLoC
   - Theme BLoC
   - Currency BLoC

2. **Use MultiBlocProvider** to provide multiple BLoCs at the app root

### Phase 4: Testing and Optimization

1. **Write Unit Tests** for all BLoCs
2. **Integration Tests** for key user flows
3. **Performance Optimization**

## Feature Migration Order

1. Skeleton/Loading States - Simple UI states
2. Auth Feature - Login/Registration 
3. Home Feature - Core app features
4. Tracking Feature - User statistics
5. Achievements Feature - User achievements
6. Settings Feature - App configuration

## Best Practices

1. **Keep BLoCs Focused**: Each BLoC should handle a specific feature
2. **Immutable States**: States should be immutable
3. **Meaningful Events**: Events should clearly describe user intentions
4. **BLoC Communication**: Use repositories or streams for BLoC-to-BLoC communication
5. **Error Handling**: Handle errors within BLoCs, not in UI

## Sample Implementation: Skeleton Loading

### Directory Structure

```
lib/
├── blocs/
│   ├── skeleton/
│   │   ├── skeleton_bloc.dart
│   │   ├── skeleton_event.dart
│   │   └── skeleton_state.dart
│   └── app_bloc_observer.dart
```

### Implementation Steps

1. Create event, state, and bloc files
2. Update UI components to use BlocBuilder/BlocListener
3. Provide BLoC using BlocProvider
4. Test the implementation

## Optimistic Updates with BLoC

For implementing optimistic updates pattern:

```dart
// Example: Adding a smoking record optimistically
on<AddSmokingRecord>((event, emit) async {
  // 1. Store original state for potential rollback
  final originalState = state;
  
  // 2. Update state optimistically with new record
  final newRecord = event.record;
  final updatedRecords = List<SmokingRecord>.from(state.records)..add(newRecord);
  emit(RecordsLoaded(records: updatedRecords));
  
  try {
    // 3. Perform the actual operation
    await repository.addSmokingRecord(newRecord);
    
    // 4. Operation succeeded - no need to update state again
  } catch (e) {
    // 5. Operation failed, revert to original state
    emit(originalState);
    
    // 6. Emit error state
    emit(RecordsError(message: 'Failed to save record: ${e.toString()}'));
  }
});
```

## Timeline

- **Week 1**: Setup infrastructure and migrate skeleton loading
- **Week 2**: Migrate Auth and Home features
- **Week 3**: Migrate Tracking and Achievement features
- **Week 4**: Testing, optimization, and cleanup

## Conclusion

This migration will improve code organization, testability, and scalability. The BLoC pattern will make it easier to implement complex features and maintain the codebase long-term.