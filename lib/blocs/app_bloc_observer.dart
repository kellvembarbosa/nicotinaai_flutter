import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC observer for debugging purposes
/// Logs all events, transitions, and errors with formatted output
class AppBlocObserver extends BlocObserver {
  // Singleton pattern 
  static final AppBlocObserver _instance = AppBlocObserver._internal();
  
  factory AppBlocObserver() => _instance;
  
  AppBlocObserver._internal();
  
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      print('🟢 BLOC CREATED: ${bloc.runtimeType}');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      print('⏩ EVENT: ${bloc.runtimeType} - ${event.runtimeType} | ${DateTime.now().toIso8601String()}');
      print('    ${event.toString()}');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      print('🔄 STATE CHANGED: ${bloc.runtimeType} | ${DateTime.now().toIso8601String()}');
      print('    From: ${change.currentState.runtimeType}');
      print('    To: ${change.nextState.runtimeType}');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      print('➡️ TRANSITION: ${bloc.runtimeType}');
      print('    Event: ${transition.event.runtimeType}');
      print('    From: ${transition.currentState.runtimeType}');
      print('    To: ${transition.nextState.runtimeType}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('❌ ERROR: ${bloc.runtimeType} - $error | ${DateTime.now().toIso8601String()}');
      print('    ${stackTrace.toString().split('\n').take(3).join('\n    ')}');
    }
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (kDebugMode) {
      print('🔴 BLOC CLOSED: ${bloc.runtimeType}');
    }
  }
}