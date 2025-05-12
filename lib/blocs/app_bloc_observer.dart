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
      
      // Logando detalhes específicos para SaveCravingRequested
      if (event.toString().contains('SaveCravingRequested')) {
        print('    🔍 IMPORTANTE: Evento de salvamento de craving detectado');
        print('    🔍 TEMPO: ${DateTime.now().toIso8601String()}');
        print('    🔍 BLOC ATUAL: ${bloc.runtimeType}');
        print('    🔍 ESTADO ATUAL: ${bloc.state.runtimeType}');
      }
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      print('🔄 STATE CHANGED: ${bloc.runtimeType} | ${DateTime.now().toIso8601String()}');
      print('    From: ${change.currentState.runtimeType}');
      print('    To: ${change.nextState.runtimeType}');
      
      // Logando detalhes específicos para estados do CravingBloc
      if (bloc.runtimeType.toString().contains('CravingBloc')) {
        print('    🔍 MUDANÇA DE ESTADO DO CRAVINGBLOC DETECTADA');
        print('    🔍 TEMPO: ${DateTime.now().toIso8601String()}');
        print('    🔍 DE: ${change.currentState.toString().substring(0, change.currentState.toString().length.clamp(0, 100))}');
        print('    🔍 PARA: ${change.nextState.toString().substring(0, change.nextState.toString().length.clamp(0, 100))}');
      }
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
      
      // Logando detalhes específicos para erros no CravingBloc
      if (bloc.runtimeType.toString().contains('CravingBloc')) {
        print('❗️❗️❗️ ERRO CRÍTICO NO CRAVINGBLOC ❗️❗️❗️');
        print('⏱️ TEMPO DO ERRO: ${DateTime.now().toIso8601String()}');
        print('📋 DETALHES DO ERRO: $error');
        print('📋 ESTADO ATUAL DO BLOC: ${bloc.state}');
        print('📋 STACKTRACE COMPLETO:');
        final st = stackTrace.toString().split('\n');
        for (var i = 0; i < st.length.clamp(0, 20); i++) {
          print('   ${i + 1}: ${st[i]}');
        }
        print('❗️❗️❗️ FIM DO ERRO CRÍTICO NO CRAVINGBLOC ❗️❗️❗️');
      }
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