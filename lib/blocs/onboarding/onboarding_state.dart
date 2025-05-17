import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';

/// Status do onboarding
enum OnboardingStatus {
  /// Estado inicial antes da carregamento das preferências
  initial,
  
  /// Carregando as preferências
  loading,
  
  /// Dados carregados com sucesso
  loaded,
  
  /// Salvando dados
  saving,
  
  /// Onboarding concluído
  completed,
  
  /// Erro ao carregar ou salvar dados
  error
}

/// Estado para o OnboardingBloc
class OnboardingState extends Equatable {
  /// Status atual do onboarding
  final OnboardingStatus status;
  
  /// Modelo de dados do onboarding
  final OnboardingModel? onboarding;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;
  
  /// Etapa atual do onboarding
  final int currentStep;
  
  /// Total de etapas do onboarding
  final int totalSteps;
  
  /// Indica se é um novo onboarding ou uma continuação
  final bool isNew;

  /// Construtor
  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.onboarding,
    this.errorMessage,
    this.currentStep = 1,
    this.totalSteps = 16, // total de telas (incluindo seleção de moeda, feedback e permissão de notificação)
    this.isNew = true,
  });

  /// Estado inicial
  factory OnboardingState.initial() {
    return const OnboardingState();
  }

  /// Estado de carregamento
  factory OnboardingState.loading() {
    return const OnboardingState(status: OnboardingStatus.loading);
  }

  /// Estado com dados carregados
  factory OnboardingState.loaded(OnboardingModel onboarding, {bool isNew = false, int currentStep = 1}) {
    return OnboardingState(
      status: OnboardingStatus.loaded,
      onboarding: onboarding,
      isNew: isNew,
      currentStep: currentStep,
    );
  }

  /// Estado durante o salvamento
  factory OnboardingState.saving(OnboardingModel onboarding, int currentStep) {
    return OnboardingState(
      status: OnboardingStatus.saving,
      onboarding: onboarding,
      currentStep: currentStep,
    );
  }

  /// Estado de onboarding concluído
  factory OnboardingState.completed(OnboardingModel onboarding) {
    return OnboardingState(
      status: OnboardingStatus.completed,
      onboarding: onboarding,
      currentStep: 16, // última etapa
    );
  }

  /// Estado de erro
  factory OnboardingState.error(String message) {
    return OnboardingState(
      status: OnboardingStatus.error,
      errorMessage: message,
    );
  }

  /// Cria uma cópia do estado com os campos especificados alterados
  OnboardingState copyWith({
    OnboardingStatus? status,
    OnboardingModel? onboarding,
    String? errorMessage,
    int? currentStep,
    int? totalSteps,
    bool? isNew,
    bool clearError = false,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      onboarding: onboarding ?? this.onboarding,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      isNew: isNew ?? this.isNew,
    );
  }

  // Helpers
  
  /// Verifica se o estado é inicial
  bool get isInitial => status == OnboardingStatus.initial;
  
  /// Verifica se está carregando
  bool get isLoading => status == OnboardingStatus.loading;
  
  /// Verifica se os dados foram carregados
  bool get isLoaded => status == OnboardingStatus.loaded;
  
  /// Verifica se está salvando
  bool get isSaving => status == OnboardingStatus.saving;
  
  /// Verifica se o onboarding foi concluído
  bool get isCompleted => status == OnboardingStatus.completed;
  
  /// Verifica se ocorreu um erro
  bool get hasError => status == OnboardingStatus.error;
  
  /// Verifica se pode avançar para o próximo passo
  bool get canAdvance => currentStep < totalSteps;
  
  /// Verifica se pode voltar para o passo anterior
  bool get canGoBack => currentStep > 1;
  
  /// Calcula a porcentagem de progresso
  double get progress => currentStep / totalSteps;

  @override
  List<Object?> get props => [
    status,
    onboarding,
    errorMessage,
    currentStep,
    totalSteps,
    isNew,
  ];
}