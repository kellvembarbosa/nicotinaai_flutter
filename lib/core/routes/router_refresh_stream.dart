import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Adaptador para fazer BLoCs trabalharem como Listenable para o GoRouter
class RouterRefreshStream<B extends BlocBase<S>, S> extends ChangeNotifier {
  final B _bloc;
  final bool Function(S state)? _shouldRefresh;
  
  late final StreamSubscription<S> _subscription;
  
  RouterRefreshStream(this._bloc, {bool Function(S state)? shouldRefresh}) 
    : _shouldRefresh = shouldRefresh {
    _subscription = _bloc.stream.listen((state) {
      if (_shouldRefresh == null || _shouldRefresh(state)) {
        notifyListeners();
      }
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}