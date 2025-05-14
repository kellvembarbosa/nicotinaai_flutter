import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityBloc() : super(ConnectivityInitial()) {
    on<ConnectivityStarted>(_onConnectivityStarted);
    on<ConnectivityStatusChanged>(_onConnectivityStatusChanged);
  }

  Future<void> _onConnectivityStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    await _connectivitySubscription?.cancel();
    
    // Verificar estado inicial de conectividade
    final initialResults = await _connectivity.checkConnectivity();
    _updateConnectionStatus(initialResults, emit);

    // Escutar mudanças na conectividade
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        add(ConnectivityStatusChanged(results));
      },
    );
  }

  void _onConnectivityStatusChanged(
    ConnectivityStatusChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    _updateConnectionStatus(event.results, emit);
  }

  void _updateConnectionStatus(
    List<ConnectivityResult> results,
    Emitter<ConnectivityState> emit,
  ) {
    // Verifica se há pelo menos uma conexão válida
    final hasValidConnection = results.any((result) => 
      result == ConnectivityResult.wifi || 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.vpn ||
      result == ConnectivityResult.ethernet
    );
    
    if (hasValidConnection) {
      emit(ConnectivityConnected(results));
    } else {
      emit(ConnectivityDisconnected());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}