import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/features/achievements/models/time_period.dart';

/// Eventos para o AchievementBloc
abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar os achievements
class InitializeAchievements extends AchievementEvent {}

/// Evento para carregar achievements
class LoadAchievements extends AchievementEvent {}

/// Evento para marcar um achievement como visualizado
class MarkAchievementAsViewed extends AchievementEvent {
  final String achievementId;

  const MarkAchievementAsViewed(this.achievementId);

  @override
  List<Object?> get props => [achievementId];
}

/// Evento para verificar novos achievements
class CheckForNewAchievements extends AchievementEvent {
  final bool forceDailyCheck;
  
  const CheckForNewAchievements({this.forceDailyCheck = false});
  
  @override
  List<Object?> get props => [forceDailyCheck];
}

/// Evento para alterar o período de tempo de filtragem
class ChangeTimePeriod extends AchievementEvent {
  final TimePeriod period;

  const ChangeTimePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Evento para limpar erros
class ClearAchievementError extends AchievementEvent {}