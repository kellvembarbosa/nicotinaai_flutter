import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/utils/supported_currencies.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar o CurrencyBloc
class InitializeCurrency extends CurrencyEvent {}

/// Evento para alterar a moeda
class ChangeCurrency extends CurrencyEvent {
  final CurrencyInfo currency;

  const ChangeCurrency({required this.currency});

  @override
  List<Object?> get props => [currency];
}

/// Evento para detectar a moeda do dispositivo
class DetectDeviceCurrency extends CurrencyEvent {}