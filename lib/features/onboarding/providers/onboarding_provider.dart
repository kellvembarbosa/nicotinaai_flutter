import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_state.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  final OnboardingRepository _repository;
  
  OnboardingState _state = OnboardingState.initial();
  
  OnboardingProvider({
    required OnboardingRepository repository,
  }) : _repository = repository;
  
  // Getter para o estado atual
  OnboardingState get state => _state;
  
  // Flag para controlar inicialização em andamento
  bool _isInitializing = false;

  // Inicializar o onboarding
  Future<void> initialize() async {
    // Evita inicialização múltipla
    if (_isInitializing || !_state.isInitial && !_state.hasError) {
      return;
    }
    
    try {
      _isInitializing = true;
      _state = OnboardingState.loading();
      notifyListeners();
      
      // Verificar se há onboarding em progresso no armazenamento local
      final localOnboarding = await _getLocalOnboarding();
      
      // Se existir localmente, usar esse
      if (localOnboarding != null) {
        _state = OnboardingState.loaded(localOnboarding, isNew: false);
        notifyListeners();
        _isInitializing = false;
        return;
      }
      
      // Caso contrário, verificar no Supabase
      final onboarding = await _repository.getOnboarding();
      
      // Se não existir no Supabase, criar um novo
      if (onboarding == null) {
        final user = _getCurrentUserId();
        
        if (user == null) {
          _state = OnboardingState.error('User not authenticated');
          notifyListeners();
          _isInitializing = false;
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
      _isInitializing = false;
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
  
  // Ir para uma etapa específica
  void goToStep(int step) {
    if (step < 1 || step > _state.totalSteps) return;
    
    _state = _state.copyWith(
      currentStep: step,
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
  String? _getCurrentUserId() {
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