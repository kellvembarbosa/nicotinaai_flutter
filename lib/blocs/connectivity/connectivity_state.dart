part of 'connectivity_bloc.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();
  
  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityConnected extends ConnectivityState {
  final List<ConnectivityResult> connectionTypes;

  const ConnectivityConnected(this.connectionTypes);

  @override
  List<Object> get props => [connectionTypes];
}

class ConnectivityDisconnected extends ConnectivityState {}