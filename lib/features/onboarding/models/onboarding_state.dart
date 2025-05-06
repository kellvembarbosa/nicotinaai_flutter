import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';

enum OnboardingStatus {
  initial,
  loading,
  loaded,
  saving,
  completed,
  error,
}

class OnboardingState {
  final OnboardingStatus status;
  final OnboardingModel? onboarding;
  final String? errorMessage;
  final int currentStep;
  final int totalSteps;
  final bool isNew; // se é novo onboarding ou continuação

  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.onboarding,
    this.errorMessage,
    this.currentStep = 1,
    this.totalSteps = 13, // total de telas
    this.isNew = true,
  });

  // Estados factory
  factory OnboardingState.initial() {
    return const OnboardingState();
  }

  factory OnboardingState.loading() {
    return const OnboardingState(status: OnboardingStatus.loading);
  }

  factory OnboardingState.loaded(OnboardingModel onboarding, {bool isNew = false}) {
    return OnboardingState(
      status: OnboardingStatus.loaded,
      onboarding: onboarding,
      isNew: isNew,
    );
  }

  factory OnboardingState.saving(OnboardingModel onboarding, int currentStep) {
    return OnboardingState(
      status: OnboardingStatus.saving,
      onboarding: onboarding,
      currentStep: currentStep,
    );
  }

  factory OnboardingState.completed(OnboardingModel onboarding) {
    return OnboardingState(
      status: OnboardingStatus.completed,
      onboarding: onboarding,
      currentStep: 13, // última tela
    );
  }

  factory OnboardingState.error(String message) {
    return OnboardingState(
      status: OnboardingStatus.error,
      errorMessage: message,
    );
  }

  // Construtor de cópia
  OnboardingState copyWith({
    OnboardingStatus? status,
    OnboardingModel? onboarding,
    String? errorMessage,
    int? currentStep,
    int? totalSteps,
    bool? isNew,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      onboarding: onboarding ?? this.onboarding,
      errorMessage: errorMessage ?? this.errorMessage,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      isNew: isNew ?? this.isNew,
    );
  }

  // Helpers
  bool get isInitial => status == OnboardingStatus.initial;
  bool get isLoading => status == OnboardingStatus.loading;
  bool get isLoaded => status == OnboardingStatus.loaded;
  bool get isSaving => status == OnboardingStatus.saving;
  bool get isCompleted => status == OnboardingStatus.completed;
  bool get hasError => status == OnboardingStatus.error;
  
  // Verifica se pode avançar para o próximo passo
  bool get canAdvance => currentStep < totalSteps;
  
  // Verifica se pode voltar para o passo anterior
  bool get canGoBack => currentStep > 1;
  
  // Calcula a porcentagem de progresso
  double get progress => currentStep / totalSteps;
}