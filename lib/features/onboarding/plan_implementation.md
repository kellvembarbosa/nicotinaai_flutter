# Plano de Implementação do Onboarding - NicotinaAI Flutter

Este documento descreve o plano de implementação para o fluxo de onboarding do aplicativo NicotinaAI, baseado nos requisitos e designs fornecidos.

## 1. Estrutura de Diretórios

```
lib/
├── features/
│   ├── onboarding/
│   │   ├── models/
│   │   │   ├── onboarding_model.dart
│   │   │   └── onboarding_state.dart
│   │   ├── providers/
│   │   │   └── onboarding_provider.dart
│   │   ├── repositories/
│   │   │   └── onboarding_repository.dart
│   │   ├── screens/
│   │   │   ├── onboarding_container.dart
│   │   │   ├── introduction_screen.dart
│   │   │   ├── personalize_screen.dart
│   │   │   ├── interests_screen.dart
│   │   │   ├── locations_screen.dart
│   │   │   ├── help_screen.dart
│   │   │   ├── cigarettes_per_day_screen.dart
│   │   │   ├── pack_price_screen.dart
│   │   │   ├── cigarettes_per_pack_screen.dart
│   │   │   ├── goal_screen.dart
│   │   │   ├── timeline_screen.dart
│   │   │   ├── challenge_screen.dart
│   │   │   ├── product_type_screen.dart
│   │   │   └── completion_screen.dart
│   │   └── widgets/
│   │       ├── option_card.dart
│   │       ├── multi_select_option_card.dart
│   │       ├── interest_card.dart
│   │       ├── progress_bar.dart
│   │       ├── number_selector.dart
│   │       ├── price_input.dart
│   │       ├── onboarding_title.dart
│   │       ├── onboarding_button.dart
│   │       ├── back_button.dart
│   │       └── navigation_buttons.dart
```

## 2. Integração com Supabase

### 2.1 Criação da Tabela no Supabase

Execute a seguinte migração SQL no Supabase:

```sql
-- Criar enums
CREATE TYPE ENUM_CONSUMPTION_LEVEL AS ENUM ('LOW', 'MODERATE', 'HIGH', 'VERY_HIGH');
CREATE TYPE ENUM_GOAL_TYPE AS ENUM ('REDUCE', 'QUIT');
CREATE TYPE ENUM_GOAL_TIMELINE AS ENUM ('SEVEN_DAYS', 'FOURTEEN_DAYS', 'THIRTY_DAYS', 'NO_DEADLINE');
CREATE TYPE ENUM_QUIT_CHALLENGE AS ENUM ('STRESS', 'HABIT', 'SOCIAL', 'ADDICTION');
CREATE TYPE ENUM_PRODUCT_TYPE AS ENUM ('CIGARETTE_ONLY', 'VAPE_ONLY', 'BOTH');

-- Criar tabela
CREATE TABLE public.user_onboarding (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  
  -- Core onboarding questions
  cigarettes_per_day ENUM_CONSUMPTION_LEVEL DEFAULT NULL,
  cigarettes_per_day_count INTEGER DEFAULT NULL,
  pack_price INTEGER DEFAULT NULL, -- Stored in cents to avoid floating-point issues
  pack_price_currency TEXT DEFAULT 'BRL',
  cigarettes_per_pack INTEGER DEFAULT NULL,
  
  -- Goals
  goal ENUM_GOAL_TYPE DEFAULT NULL,
  goal_timeline ENUM_GOAL_TIMELINE DEFAULT NULL,
  
  -- Challenges and preferences
  quit_challenge ENUM_QUIT_CHALLENGE DEFAULT NULL,
  
  -- App help preferences (stored as an array to allow multiple selections)
  help_preferences TEXT[] DEFAULT NULL,
  
  -- Product type
  product_type ENUM_PRODUCT_TYPE DEFAULT NULL,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Extra JSON field for future additions without schema changes
  additional_data JSONB DEFAULT '{}'::JSONB
);

-- Índices
CREATE INDEX idx_user_onboarding_user_id ON public.user_onboarding(user_id);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_onboarding_modtime
BEFORE UPDATE ON public.user_onboarding
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- RLS (Row Level Security) Policies
ALTER TABLE public.user_onboarding ENABLE ROW LEVEL SECURITY;

-- Policy para visualização
CREATE POLICY "Users can view their own onboarding data" 
  ON public.user_onboarding
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy para inserção
CREATE POLICY "Users can insert their own onboarding data" 
  ON public.user_onboarding
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy para atualização
CREATE POLICY "Users can update their own onboarding data" 
  ON public.user_onboarding
  FOR UPDATE
  USING (auth.uid() = user_id);
```

## 3. Modelos de Dados

### 3.1 OnboardingModel

```dart
// lib/features/onboarding/models/onboarding_model.dart

enum ConsumptionLevel { low, moderate, high, veryHigh }
enum GoalType { reduce, quit }
enum GoalTimeline { sevenDays, fourteenDays, thirtyDays, noDeadline }
enum QuitChallenge { stress, habit, social, addiction }
enum ProductType { cigaretteOnly, vapeOnly, both }

class OnboardingModel {
  final String? id;
  final String userId;
  final bool completed;
  
  // Core questions
  final ConsumptionLevel? cigarettesPerDay;
  final int? cigarettesPerDayCount;
  final int? packPrice; // em centavos
  final String packPriceCurrency;
  final int? cigarettesPerPack;
  
  // Goals
  final GoalType? goal;
  final GoalTimeline? goalTimeline;
  
  // Challenges and preferences
  final QuitChallenge? quitChallenge;
  final List<String> helpPreferences;
  final ProductType? productType;
  
  // Additional data
  final Map<String, dynamic> additionalData;
  
  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OnboardingModel({
    this.id,
    required this.userId,
    this.completed = false,
    this.cigarettesPerDay,
    this.cigarettesPerDayCount,
    this.packPrice,
    this.packPriceCurrency = 'BRL',
    this.cigarettesPerPack,
    this.goal,
    this.goalTimeline,
    this.quitChallenge,
    this.helpPreferences = const [],
    this.productType,
    this.additionalData = const {},
    this.createdAt,
    this.updatedAt,
  });

  // Construtor de cópia
  OnboardingModel copyWith({
    String? id,
    String? userId,
    bool? completed,
    ConsumptionLevel? cigarettesPerDay,
    int? cigarettesPerDayCount,
    int? packPrice,
    String? packPriceCurrency,
    int? cigarettesPerPack,
    GoalType? goal,
    GoalTimeline? goalTimeline,
    QuitChallenge? quitChallenge,
    List<String>? helpPreferences,
    ProductType? productType,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OnboardingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      completed: completed ?? this.completed,
      cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
      cigarettesPerDayCount: cigarettesPerDayCount ?? this.cigarettesPerDayCount,
      packPrice: packPrice ?? this.packPrice,
      packPriceCurrency: packPriceCurrency ?? this.packPriceCurrency,
      cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
      goal: goal ?? this.goal,
      goalTimeline: goalTimeline ?? this.goalTimeline,
      quitChallenge: quitChallenge ?? this.quitChallenge,
      helpPreferences: helpPreferences ?? this.helpPreferences,
      productType: productType ?? this.productType,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // De JSON para Modelo
  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      id: json['id'],
      userId: json['user_id'],
      completed: json['completed'] ?? false,
      cigarettesPerDay: json['cigarettes_per_day'] != null
          ? _stringToConsumptionLevel(json['cigarettes_per_day'])
          : null,
      cigarettesPerDayCount: json['cigarettes_per_day_count'],
      packPrice: json['pack_price'],
      packPriceCurrency: json['pack_price_currency'] ?? 'BRL',
      cigarettesPerPack: json['cigarettes_per_pack'],
      goal: json['goal'] != null ? _stringToGoalType(json['goal']) : null,
      goalTimeline: json['goal_timeline'] != null
          ? _stringToGoalTimeline(json['goal_timeline'])
          : null,
      quitChallenge: json['quit_challenge'] != null
          ? _stringToQuitChallenge(json['quit_challenge'])
          : null,
      helpPreferences: json['help_preferences'] != null
          ? List<String>.from(json['help_preferences'])
          : [],
      productType: json['product_type'] != null
          ? _stringToProductType(json['product_type'])
          : null,
      additionalData: json['additional_data'] ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // De Modelo para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'completed': completed,
      'cigarettes_per_day': cigarettesPerDay != null
          ? _consumptionLevelToString(cigarettesPerDay!)
          : null,
      'cigarettes_per_day_count': cigarettesPerDayCount,
      'pack_price': packPrice,
      'pack_price_currency': packPriceCurrency,
      'cigarettes_per_pack': cigarettesPerPack,
      'goal': goal != null ? _goalTypeToString(goal!) : null,
      'goal_timeline':
          goalTimeline != null ? _goalTimelineToString(goalTimeline!) : null,
      'quit_challenge':
          quitChallenge != null ? _quitChallengeToString(quitChallenge!) : null,
      'help_preferences': helpPreferences,
      'product_type':
          productType != null ? _productTypeToString(productType!) : null,
      'additional_data': additionalData,
    };
  }

  // Métodos de conversão entre enum e string
  static ConsumptionLevel _stringToConsumptionLevel(String value) {
    switch (value) {
      case 'LOW':
        return ConsumptionLevel.low;
      case 'MODERATE':
        return ConsumptionLevel.moderate;
      case 'HIGH':
        return ConsumptionLevel.high;
      case 'VERY_HIGH':
        return ConsumptionLevel.veryHigh;
      default:
        return ConsumptionLevel.moderate;
    }
  }

  static String _consumptionLevelToString(ConsumptionLevel level) {
    switch (level) {
      case ConsumptionLevel.low:
        return 'LOW';
      case ConsumptionLevel.moderate:
        return 'MODERATE';
      case ConsumptionLevel.high:
        return 'HIGH';
      case ConsumptionLevel.veryHigh:
        return 'VERY_HIGH';
    }
  }

  static GoalType _stringToGoalType(String value) {
    switch (value) {
      case 'REDUCE':
        return GoalType.reduce;
      case 'QUIT':
        return GoalType.quit;
      default:
        return GoalType.quit;
    }
  }

  static String _goalTypeToString(GoalType type) {
    switch (type) {
      case GoalType.reduce:
        return 'REDUCE';
      case GoalType.quit:
        return 'QUIT';
    }
  }

  static GoalTimeline _stringToGoalTimeline(String value) {
    switch (value) {
      case 'SEVEN_DAYS':
        return GoalTimeline.sevenDays;
      case 'FOURTEEN_DAYS':
        return GoalTimeline.fourteenDays;
      case 'THIRTY_DAYS':
        return GoalTimeline.thirtyDays;
      case 'NO_DEADLINE':
        return GoalTimeline.noDeadline;
      default:
        return GoalTimeline.thirtyDays;
    }
  }

  static String _goalTimelineToString(GoalTimeline timeline) {
    switch (timeline) {
      case GoalTimeline.sevenDays:
        return 'SEVEN_DAYS';
      case GoalTimeline.fourteenDays:
        return 'FOURTEEN_DAYS';
      case GoalTimeline.thirtyDays:
        return 'THIRTY_DAYS';
      case GoalTimeline.noDeadline:
        return 'NO_DEADLINE';
    }
  }

  static QuitChallenge _stringToQuitChallenge(String value) {
    switch (value) {
      case 'STRESS':
        return QuitChallenge.stress;
      case 'HABIT':
        return QuitChallenge.habit;
      case 'SOCIAL':
        return QuitChallenge.social;
      case 'ADDICTION':
        return QuitChallenge.addiction;
      default:
        return QuitChallenge.habit;
    }
  }

  static String _quitChallengeToString(QuitChallenge challenge) {
    switch (challenge) {
      case QuitChallenge.stress:
        return 'STRESS';
      case QuitChallenge.habit:
        return 'HABIT';
      case QuitChallenge.social:
        return 'SOCIAL';
      case QuitChallenge.addiction:
        return 'ADDICTION';
    }
  }

  static ProductType _stringToProductType(String value) {
    switch (value) {
      case 'CIGARETTE_ONLY':
        return ProductType.cigaretteOnly;
      case 'VAPE_ONLY':
        return ProductType.vapeOnly;
      case 'BOTH':
        return ProductType.both;
      default:
        return ProductType.cigaretteOnly;
    }
  }

  static String _productTypeToString(ProductType type) {
    switch (type) {
      case ProductType.cigaretteOnly:
        return 'CIGARETTE_ONLY';
      case ProductType.vapeOnly:
        return 'VAPE_ONLY';
      case ProductType.both:
        return 'BOTH';
    }
  }
}
```

### 3.2 OnboardingState

```dart
// lib/features/onboarding/models/onboarding_state.dart

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
```

## 4. Repositório para Supabase

```dart
// lib/features/onboarding/repositories/onboarding_repository.dart

import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingRepository {
  final SupabaseClient _client = SupabaseConfig.client;
  
  // Obter onboarding do usuário atual
  Future<OnboardingModel?> getOnboarding() async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final response = await _client
          .from('user_onboarding')
          .select()
          .eq('user_id', user.id)
          .single()
          .execute();
      
      if (response.error != null) {
        // Se o erro for "No rows found", retornamos null
        if (response.error!.message.contains('No rows found')) {
          return null;
        }
        throw response.error!;
      }
      
      if (response.data == null) {
        return null;
      }
      
      return OnboardingModel.fromJson(response.data);
    } catch (e) {
      if (e is PostgrestError && e.message.contains('No rows found')) {
        return null;
      }
      rethrow;
    }
  }
  
  // Criar novo onboarding
  Future<OnboardingModel> createOnboarding(OnboardingModel onboarding) async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final data = onboarding.toJson();
      data['user_id'] = user.id;
      
      final response = await _client
          .from('user_onboarding')
          .insert(data)
          .select()
          .single()
          .execute();
      
      if (response.error != null) {
        throw response.error!;
      }
      
      return OnboardingModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Atualizar onboarding existente
  Future<OnboardingModel> updateOnboarding(OnboardingModel onboarding) async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      if (onboarding.id == null) {
        throw Exception('Onboarding ID is required for update');
      }
      
      final data = onboarding.toJson();
      data['user_id'] = user.id;
      
      final response = await _client
          .from('user_onboarding')
          .update(data)
          .eq('id', onboarding.id)
          .select()
          .single()
          .execute();
      
      if (response.error != null) {
        throw response.error!;
      }
      
      return OnboardingModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Salvar onboarding (cria ou atualiza)
  Future<OnboardingModel> saveOnboarding(OnboardingModel onboarding) async {
    try {
      if (onboarding.id != null) {
        return await updateOnboarding(onboarding);
      } else {
        return await createOnboarding(onboarding);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Marcar onboarding como concluído
  Future<OnboardingModel> completeOnboarding(String onboardingId) async {
    try {
      final response = await _client
          .from('user_onboarding')
          .update({'completed': true})
          .eq('id', onboardingId)
          .select()
          .single()
          .execute();
      
      if (response.error != null) {
        throw response.error!;
      }
      
      return OnboardingModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Verificar se o usuário atual já completou o onboarding
  Future<bool> hasCompletedOnboarding() async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        return false;
      }
      
      final response = await _client
          .from('user_onboarding')
          .select('completed')
          .eq('user_id', user.id)
          .eq('completed', true)
          .execute();
      
      if (response.error != null) {
        throw response.error!;
      }
      
      return response.data != null && (response.data as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
```

## 5. Provider para Gerenciamento de Estado

```dart
// lib/features/onboarding/providers/onboarding_provider.dart

import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_state.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OnboardingProvider extends ChangeNotifier {
  final OnboardingRepository _repository;
  
  OnboardingState _state = OnboardingState.initial();
  
  OnboardingProvider({
    required OnboardingRepository repository,
  }) : _repository = repository;
  
  // Getter para o estado atual
  OnboardingState get state => _state;
  
  // Inicializar o onboarding
  Future<void> initialize() async {
    try {
      _state = OnboardingState.loading();
      notifyListeners();
      
      // Verificar se há onboarding em progresso no armazenamento local
      final localOnboarding = await _getLocalOnboarding();
      
      // Se existir localmente, usar esse
      if (localOnboarding != null) {
        _state = OnboardingState.loaded(localOnboarding, isNew: false);
        notifyListeners();
        return;
      }
      
      // Caso contrário, verificar no Supabase
      final onboarding = await _repository.getOnboarding();
      
      // Se não existir no Supabase, criar um novo
      if (onboarding == null) {
        final user = await _getCurrentUserId();
        
        if (user == null) {
          _state = OnboardingState.error('User not authenticated');
          notifyListeners();
          return;
        }
        
        final newOnboarding = OnboardingModel(
          userId: user,
          completed: false,
        );
        
        _state = OnboardingState.loaded(newOnboarding, isNew: true);
      } else {
        // Se já existir no Supabase mas não estiver completo
        if (!onboarding.completed) {
          _state = OnboardingState.loaded(onboarding, isNew: false);
        } else {
          // Se estiver completo, não mostrar onboarding
          _state = OnboardingState.completed(onboarding);
        }
      }
    } catch (e) {
      _state = OnboardingState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }
  
  // Atualizar dados do onboarding
  Future<void> updateOnboarding(OnboardingModel updated) async {
    try {
      _state = _state.copyWith(
        status: OnboardingStatus.saving,
        onboarding: updated,
      );
      notifyListeners();
      
      // Salvar localmente primeiro
      await _saveLocalOnboarding(updated);
      
      // Depois tentar salvar no Supabase se houver conexão
      try {
        final savedOnboarding = await _repository.saveOnboarding(updated);
        _state = _state.copyWith(
          status: OnboardingStatus.loaded,
          onboarding: savedOnboarding,
        );
      } catch (e) {
        // Se falhar o salvamento no Supabase, manter o estado como loaded
        // mas com os dados do armazenamento local
        _state = _state.copyWith(
          status: OnboardingStatus.loaded,
          onboarding: updated,
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        status: OnboardingStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      notifyListeners();
    }
  }
  
  // Avançar para próxima etapa
  Future<void> nextStep() async {
    if (!_state.canAdvance) return;
    
    _state = _state.copyWith(
      currentStep: _state.currentStep + 1,
    );
    notifyListeners();
  }
  
  // Voltar para etapa anterior
  void previousStep() {
    if (!_state.canGoBack) return;
    
    _state = _state.copyWith(
      currentStep: _state.currentStep - 1,
    );
    notifyListeners();
  }
  
  // Completar o onboarding
  Future<void> completeOnboarding() async {
    try {
      if (_state.onboarding == null) return;
      
      final updated = _state.onboarding!.copyWith(completed: true);
      
      _state = _state.copyWith(
        status: OnboardingStatus.saving,
        onboarding: updated,
      );
      notifyListeners();
      
      // Tentar salvar no Supabase
      try {
        final savedOnboarding = await _repository.saveOnboarding(updated);
        
        if (updated.id != null) {
          // Marcar como completo no Supabase
          await _repository.completeOnboarding(updated.id!);
        }
        
        _state = OnboardingState.completed(savedOnboarding);
      } catch (e) {
        // Se falhar, salvar localmente
        await _saveLocalOnboarding(updated);
        _state = OnboardingState.completed(updated);
      }
      
      // Remover dados locais
      await _removeLocalOnboarding();
    } catch (e) {
      _state = _state.copyWith(
        status: OnboardingStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      notifyListeners();
    }
  }
  
  // Limpar erro
  void clearError() {
    if (_state.hasError) {
      _state = _state.copyWith(
        status: _state.onboarding != null 
            ? OnboardingStatus.loaded 
            : OnboardingStatus.initial,
        errorMessage: null,
      );
      notifyListeners();
    }
  }
  
  // Métodos auxiliares
  Future<String?> _getCurrentUserId() async {
    final user = SupabaseConfig.client.auth.currentUser;
    return user?.id;
  }
  
  Future<OnboardingModel?> _getLocalOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('onboarding_data');
      
      if (json == null) return null;
      
      final data = jsonDecode(json);
      return OnboardingModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> _saveLocalOnboarding(OnboardingModel onboarding) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(onboarding.toJson());
      await prefs.setString('onboarding_data', json);
    } catch (e) {
      // Ignorar erro
    }
  }
  
  Future<void> _removeLocalOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_data');
    } catch (e) {
      // Ignorar erro
    }
  }
}
```

## 6. Componentes de UI Reutilizáveis

### 6.1 ProgressBar

```dart
// lib/features/onboarding/widgets/progress_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  
  const ProgressBar({
    Key? key, 
    required this.current, 
    required this.total,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final progress = (current / total) * 100;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Passo $current de $total',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${progress.round()}%',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: progress / 100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### 6.2 OptionCard

```dart
// lib/features/onboarding/widgets/option_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onPress;
  final String label;
  final String? description;
  final Widget? child;
  
  const OptionCard({
    Key? key,
    required this.selected,
    required this.onPress,
    required this.label,
    this.description,
    this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.deepPurple : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.deepPurple : Colors.grey[400]!,
                      width: 1.5,
                    ),
                    color: selected ? Colors.deepPurple : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[900],
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (child != null) ...[
              const SizedBox(height: 12),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
```

### 6.3 MultiSelectOptionCard

```dart
// lib/features/onboarding/widgets/multi_select_option_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MultiSelectOptionCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onPress;
  final String label;
  final String? description;
  final Widget? child;
  
  const MultiSelectOptionCard({
    Key? key,
    required this.selected,
    required this.onPress,
    required this.label,
    this.description,
    this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.deepPurple : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: selected ? Colors.deepPurple : Colors.grey[400]!,
                      width: 1.5,
                    ),
                    color: selected ? Colors.deepPurple : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[900],
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (child != null) ...[
              const SizedBox(height: 12),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
```

### 6.4 NavigationButtons

```dart
// lib/features/onboarding/widgets/navigation_buttons.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool canGoBack;
  final bool disableNext;
  final String nextText;
  
  const NavigationButtons({
    Key? key,
    required this.onBack,
    required this.onNext,
    this.canGoBack = true,
    this.disableNext = false,
    this.nextText = 'Continuar',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (canGoBack)
          OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Voltar',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox(width: 85),
        
        ElevatedButton(
          onPressed: disableNext ? null : onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.deepPurple.withOpacity(0.4),
            disabledForegroundColor: Colors.white.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: Row(
            children: [
              Text(
                nextText,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}
```

### 6.5 NumberSelector

```dart
// lib/features/onboarding/widgets/number_selector.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumberSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  
  const NumberSelector({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: value <= min 
              ? null 
              : () => onChanged(value - step),
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey[800],
            disabledBackgroundColor: Colors.grey[100],
            disabledForegroundColor: Colors.grey[400],
            padding: EdgeInsets.zero,
            minimumSize: const Size(36, 36),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            value.toString(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButton(
          onPressed: value >= max 
              ? null 
              : () => onChanged(value + step),
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey[800],
            disabledBackgroundColor: Colors.grey[100],
            disabledForegroundColor: Colors.grey[400],
            padding: EdgeInsets.zero,
            minimumSize: const Size(36, 36),
          ),
        ),
      ],
    );
  }
}
```

## 7. Telas do Onboarding

### 7.1 OnboardingContainer

```dart
// lib/features/onboarding/screens/onboarding_container.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingContainer extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final bool showBackButton;
  final bool disableNextButton;
  final String nextButtonText;
  final VoidCallback onNext;
  
  const OnboardingContainer({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.content,
    this.showBackButton = true,
    this.disableNextButton = false,
    this.nextButtonText = 'Continuar',
    required this.onNext,
  }) : super(key: key);
  
  @override
  State<OnboardingContainer> createState() => _OnboardingContainerState();
}

class _OnboardingContainerState extends State<OnboardingContainer> {
  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final state = onboardingProvider.state;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              ProgressBar(
                current: state.currentStep,
                total: state.totalSteps,
              ),
              
              const SizedBox(height: 24),
              
              // Title and subtitle
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: widget.content,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.showBackButton)
                    OutlinedButton(
                      onPressed: () {
                        onboardingProvider.previousStep();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Voltar',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 85),
                  
                  ElevatedButton(
                    onPressed: widget.disableNextButton ? null : widget.onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.deepPurple.withOpacity(0.4),
                      disabledForegroundColor: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          widget.nextButtonText,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 8. Integração com o Sistema de Rotas

Atualize o AppRouter para incluir a verificação de onboarding:

```dart
// lib/core/routes/app_router.dart (atualização)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_screen.dart';

class AppRouter {
  final AuthProvider authProvider;
  final OnboardingProvider onboardingProvider;
  
  AppRouter({
    required this.authProvider,
    required this.onboardingProvider,
  });
  
  late final GoRouter router = GoRouter(
    // ... configuração existente ...
    
    // Atualizar o redirect para verificar o onboarding
    redirect: (context, state) async {
      // Primeiro verificar autenticação
      final bool isLoggedIn = authProvider.isAuthenticated;
      final bool isLoginRoute = state.location == AppRoutes.login;
      final bool isRegisterRoute = state.location == AppRoutes.register;
      final bool isForgotPasswordRoute = state.location == AppRoutes.forgotPassword;
      final bool isAuthRoute = isLoginRoute || isRegisterRoute || isForgotPasswordRoute;
      
      // Se não estiver logado e não estiver em rota de autenticação
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }
      
      // Se estiver logado e estiver em rota de autenticação
      if (isLoggedIn && isAuthRoute) {
        // Verificar se completou onboarding
        final onboardingCompleted = onboardingProvider.state.isCompleted;
        
        if (!onboardingCompleted) {
          return AppRoutes.onboarding;
        }
        
        return AppRoutes.main;
      }
      
      // Se estiver logado e não estiver em onboarding, mas precisa fazer onboarding
      if (isLoggedIn && state.location != AppRoutes.onboarding) {
        final onboardingCompleted = onboardingProvider.state.isCompleted;
        
        if (!onboardingCompleted) {
          return AppRoutes.onboarding;
        }
      }
      
      return null;
    },
    
    // Adicionar rota de onboarding
    routes: [
      // ... rotas existentes ...
      
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
    ],
  );
}

// Adicionar rota de onboarding
class AppRoutes {
  // ... rotas existentes ...
  static const String onboarding = '/onboarding';
}
```

## 9. Próximos Passos e Plano de Implementação

### 9.1 Sequência de Implementação

1. **Configuração do Banco de Dados Supabase**
   - Executar o script SQL para criar tabelas e RLS
   
2. **Implementação dos Modelos e Repositórios**
   - Criar OnboardingModel e OnboardingState
   - Implementar OnboardingRepository para Supabase
   
3. **Provider para Gerenciamento de Estado**
   - Implementar OnboardingProvider
   
4. **Componentes Reutilizáveis**
   - Implementar ProgressBar, OptionCard, MultiSelectOptionCard, etc.
   
5. **Telas de Onboarding**
   - Criar cada tela de onboarding seguindo o design
   - Implementar a validação e navegação entre telas
   
6. **Integração com Sistema de Rotas**
   - Atualizar o AppRouter para detectar e redirecionar ao onboarding
   
7. **Testes**
   - Testar fluxo completo de onboarding
   - Testar cenários de interrupção e retomada
   - Validar salvamento de dados no Supabase

### 9.2 Integração com o Projeto Atual

1. Atualize o `main.dart` para incluir o OnboardingProvider:

```dart
// lib/main.dart (atualização)

void main() async {
  // ... código existente ...
  
  // Criar repositórios
  final authRepository = AuthRepository();
  final onboardingRepository = OnboardingRepository();
  
  runApp(MyApp(
    authRepository: authRepository,
    onboardingRepository: onboardingRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  
  const MyApp({
    required this.authRepository,
    required this.onboardingRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: authRepository,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OnboardingProvider>(
          create: (_) => OnboardingProvider(
            repository: onboardingRepository,
          ),
          update: (_, authProvider, previousOnboardingProvider) {
            // Se o usuário mudou, reinicializar o provider de onboarding
            if (previousOnboardingProvider == null || 
                previousOnboardingProvider.state.onboarding?.userId != authProvider.currentUser?.id) {
              return OnboardingProvider(
                repository: onboardingRepository,
              )..initialize();
            }
            return previousOnboardingProvider;
          },
        ),
      ],
      child: Consumer2<AuthProvider, OnboardingProvider>(
        builder: (context, authProvider, onboardingProvider, _) {
          // Criamos o router dentro do Consumer para reconstruir quando o estado mudar
          final appRouter = AppRouter(
            authProvider: authProvider,
            onboardingProvider: onboardingProvider,
          );
          
          return MaterialApp.router(
            // ... código existente ...
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
```

## Conclusão

Este plano de implementação fornece uma abordagem estruturada para adicionar o fluxo de onboarding ao aplicativo NicotinaAI Flutter. 

A implementação segue as melhores práticas:

1. **Arquitetura organizada** com separação clara de responsabilidades (modelos, repositórios, providers, widgets)
2. **Persistência robusta** com salvamento local e remoto
3. **Design consistente** com o restante do aplicativo
4. **Gerenciamento de estado eficiente** usando Provider
5. **Navegação integrada** com o sistema de rotas existente

Após a implementação deste plano, o aplicativo terá um fluxo completo de onboarding que coleta informações essenciais dos usuários para personalizar sua experiência no aplicativo NicotinaAI.