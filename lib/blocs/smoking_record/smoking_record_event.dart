import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';

abstract class SmokingRecordEvent extends Equatable {
  const SmokingRecordEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para carregar registros de fumo para um usuário
class LoadSmokingRecordsRequested extends SmokingRecordEvent {
  final String userId;

  const LoadSmokingRecordsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para salvar um novo registro de fumo
class SaveSmokingRecordRequested extends SmokingRecordEvent {
  final SmokingRecordModel record;

  const SaveSmokingRecordRequested({required this.record});

  @override
  List<Object?> get props => [record];
}

/// Evento para tentar sincronizar um registro que falhou
class RetrySyncRecordRequested extends SmokingRecordEvent {
  final String id;

  const RetrySyncRecordRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Evento para remover um registro
class RemoveSmokingRecordRequested extends SmokingRecordEvent {
  final String id;

  const RemoveSmokingRecordRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Evento para sincronizar todos os registros pendentes
class SyncPendingRecordsRequested extends SmokingRecordEvent {}

/// Evento para obter a contagem de registros
class GetRecordCountRequested extends SmokingRecordEvent {
  final String userId;

  const GetRecordCountRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para limpar registros (após logout)
class ClearSmokingRecordsRequested extends SmokingRecordEvent {}

/// Evento para limpar mensagens de erro
class ClearSmokingRecordErrorRequested extends SmokingRecordEvent {}