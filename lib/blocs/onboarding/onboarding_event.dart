import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';

/// Eventos para o OnboardingBloc
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar o onboarding
class InitializeOnboarding extends OnboardingEvent {}

/// Evento para atualizar o onboarding
class UpdateOnboarding extends OnboardingEvent {
  final OnboardingModel onboarding;

  const UpdateOnboarding(this.onboarding);

  @override
  List<Object?> get props => [onboarding];
}

/// Evento para avançar para a próxima etapa do onboarding
class NextOnboardingStep extends OnboardingEvent {}

/// Evento para voltar para a etapa anterior do onboarding
class PreviousOnboardingStep extends OnboardingEvent {}

/// Evento para ir para uma etapa específica do onboarding
class GoToOnboardingStep extends OnboardingEvent {
  final int step;

  const GoToOnboardingStep(this.step);

  @override
  List<Object?> get props => [step];
}

/// Evento para marcar o onboarding como concluído
class CompleteOnboarding extends OnboardingEvent {}

/// Evento para verificar o status de conclusão do onboarding
class CheckOnboardingStatus extends OnboardingEvent {}

/// Evento para limpar um erro do onboarding
class ClearOnboardingError extends OnboardingEvent {}