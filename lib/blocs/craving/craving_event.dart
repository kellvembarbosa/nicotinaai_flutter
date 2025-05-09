import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';

abstract class CravingEvent extends Equatable {
  const CravingEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para carregar cravings para um usuário
class LoadCravingsRequested extends CravingEvent {
  final String userId;

  const LoadCravingsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para salvar um novo craving
class SaveCravingRequested extends CravingEvent {
  final CravingModel craving;

  const SaveCravingRequested({required this.craving});

  @override
  List<Object?> get props => [craving];
}

/// Evento para tentar sincronizar um craving que falhou
class RetrySyncCravingRequested extends CravingEvent {
  final String id;

  const RetrySyncCravingRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Evento para remover um craving
class RemoveCravingRequested extends CravingEvent {
  final String id;

  const RemoveCravingRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Evento para sincronizar todos os cravings pendentes
class SyncPendingCravingsRequested extends CravingEvent {}

/// Evento para obter a contagem de cravings
class GetCravingCountRequested extends CravingEvent {
  final String userId;

  const GetCravingCountRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para limpar cravings (após logout)
class ClearCravingsRequested extends CravingEvent {}

/// Evento para limpar mensagens de erro
class ClearCravingErrorRequested extends CravingEvent {}