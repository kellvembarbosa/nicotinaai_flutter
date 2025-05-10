import 'package:equatable/equatable.dart';

/// Eventos de gerenciamento do modo desenvolvedor
abstract class DeveloperModeEvent extends Equatable {
  const DeveloperModeEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar o modo desenvolvedor com o valor salvo
class InitializeDeveloperMode extends DeveloperModeEvent {}

/// Evento para alternar entre o modo desenvolvedor ativado/desativado
class ToggleDeveloperMode extends DeveloperModeEvent {}