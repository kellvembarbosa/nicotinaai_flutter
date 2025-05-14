part of 'connectivity_bloc.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class ConnectivityStarted extends ConnectivityEvent {}

class ConnectivityStatusChanged extends ConnectivityEvent {
  final List<ConnectivityResult> results;

  const ConnectivityStatusChanged(this.results);

  @override
  List<Object> get props => [results];
}