import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/features/achievements/models/achievement_definition.dart';
import 'package:nicotinaai_flutter/features/achievements/models/time_period.dart';
import 'package:nicotinaai_flutter/features/achievements/models/user_achievement.dart';

/// Status dos achievements
enum AchievementStatus {
  /// Estado inicial
  initial,
  
  /// Carregando
  loading,
  
  /// Carregado com sucesso
  loaded,
  
  /// Erro ao carregar
  error
}

/// Estado para o AchievementBloc
class AchievementState extends Equatable {
  /// Status atual dos achievements
  final AchievementStatus status;
  
  /// Lista de todas as definições de achievements
  final List<AchievementDefinition> allDefinitions;
  
  /// Lista de achievements do usuário
  final List<UserAchievement> userAchievements;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;
  
  /// Período de tempo selecionado para filtragem
  final TimePeriod selectedTimePeriod;
  
  /// Lista de achievements recém-desbloqueados após uma verificação
  final List<UserAchievement>? newlyUnlockedAchievements;

  /// Construtor
  const AchievementState({
    this.status = AchievementStatus.initial,
    this.allDefinitions = const [],
    this.userAchievements = const [],
    this.errorMessage,
    this.selectedTimePeriod = TimePeriod.allTime,
    this.newlyUnlockedAchievements,
  });

  /// Estado inicial
  factory AchievementState.initial() {
    return const AchievementState();
  }

  /// Estado de carregamento
  factory AchievementState.loading() {
    return const AchievementState(status: AchievementStatus.loading);
  }

  /// Estado carregado
  factory AchievementState.loaded({
    required List<AchievementDefinition> allDefinitions,
    required List<UserAchievement> userAchievements,
    TimePeriod selectedTimePeriod = TimePeriod.allTime,
    List<UserAchievement>? newlyUnlockedAchievements,
  }) {
    return AchievementState(
      status: AchievementStatus.loaded,
      allDefinitions: allDefinitions,
      userAchievements: userAchievements,
      selectedTimePeriod: selectedTimePeriod,
      newlyUnlockedAchievements: newlyUnlockedAchievements,
    );
  }

  /// Estado de erro
  factory AchievementState.error(String message) {
    return AchievementState(
      status: AchievementStatus.error,
      errorMessage: message,
    );
  }

  /// Cria uma cópia do estado com os campos especificados alterados
  AchievementState copyWith({
    AchievementStatus? status,
    List<AchievementDefinition>? allDefinitions,
    List<UserAchievement>? userAchievements,
    String? errorMessage,
    TimePeriod? selectedTimePeriod,
    List<UserAchievement>? newlyUnlockedAchievements,
    bool clearError = false,
    bool clearNewlyUnlocked = false,
  }) {
    return AchievementState(
      status: status ?? this.status,
      allDefinitions: allDefinitions ?? this.allDefinitions,
      userAchievements: userAchievements ?? this.userAchievements,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      selectedTimePeriod: selectedTimePeriod ?? this.selectedTimePeriod,
      newlyUnlockedAchievements: clearNewlyUnlocked ? null : newlyUnlockedAchievements ?? this.newlyUnlockedAchievements,
    );
  }

  /// Filtra achievements por categoria e período de tempo
  List<UserAchievement> getAchievementsByCategory(String category, {TimePeriod? timePeriod}) {
    timePeriod ??= selectedTimePeriod;
    
    // Primeiro filtra por período de tempo, se não for todos os tempos
    List<UserAchievement> filteredByTime = userAchievements;
    if (timePeriod != TimePeriod.allTime) {
      filteredByTime = userAchievements.where((a) {
        // Para achievements desbloqueados, verifica se foram desbloqueados no período especificado
        if (a.isUnlocked && a.unlockedAt != DateTime(9999)) {
          return timePeriod!.contains(a.unlockedAt);
        }
        
        // Sempre inclui achievements em progresso para melhor experiência do usuário
        return a.progress > 0;
      }).toList();
    }
    
    // Depois filtra por categoria
    if (category.toLowerCase() == 'all') {
      return filteredByTime;
    }
    
    return filteredByTime.where(
      (a) => a.definition.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  /// Obtém a quantidade de achievements desbloqueados
  int get unlockedCount {
    if (selectedTimePeriod == TimePeriod.allTime) {
      return userAchievements.where((a) => a.isUnlocked).length;
    }
    
    return userAchievements.where((a) => 
      a.isUnlocked && 
      a.unlockedAt != DateTime(9999) &&
      selectedTimePeriod.contains(a.unlockedAt)
    ).length;
  }

  /// Obtém a quantidade de achievements em progresso
  int get inProgressCount => userAchievements.where((a) => a.progress > 0 && a.progress < 1.0).length;

  /// Obtém a porcentagem de conclusão
  String get completionPercentage {
    if (allDefinitions.isEmpty) return "0%";
    return "${((unlockedCount / allDefinitions.length) * 100).round()}%";
  }

  /// Obtém um achievement pelo ID
  UserAchievement? getAchievementById(String id) {
    try {
      return userAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
    status,
    allDefinitions,
    userAchievements,
    errorMessage,
    selectedTimePeriod,
    newlyUnlockedAchievements,
  ];
}