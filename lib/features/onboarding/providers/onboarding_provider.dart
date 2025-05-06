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
    if (_isInitializing) {
      return;
    }
    
    // Se já estiver carregado e não tiver erro, não precisa inicializar novamente
    // a menos que seja forçado com force: true
    if (!_state.isInitial && !_state.hasError) {
      return;
    }
    
    try {
      _isInitializing = true;
      print('🔍 [OnboardingProvider] Inicializando onboarding');
      _state = OnboardingState.loading();
      notifyListeners();
      
      // Verificar se há onboarding no Supabase primeiro
      print('🔍 [OnboardingProvider] Verificando onboarding no Supabase');
      final onboarding = await _repository.getOnboarding();
      
      if (onboarding != null) {
        print('✅ [OnboardingProvider] Onboarding encontrado no Supabase: ${onboarding.id}');
        print('📊 [OnboardingProvider] Status de conclusão: ${onboarding.completed}');
        
        if (onboarding.completed) {
          print('🎉 [OnboardingProvider] Onboarding já concluído');
          _state = OnboardingState.completed(onboarding);
        } else {
          print('⏳ [OnboardingProvider] Onboarding em andamento');
          _state = OnboardingState.loaded(onboarding, isNew: false);
          // Atualizar cache local para uso offline
          await _saveLocalOnboarding(onboarding);
        }
        
        notifyListeners();
        _isInitializing = false;
        return;
      }
      
      print('❓ [OnboardingProvider] Onboarding não encontrado no Supabase');
      
      // Verificar se há onboarding em progresso no armazenamento local
      print('🔍 [OnboardingProvider] Verificando cache local');
      final localOnboarding = await _getLocalOnboarding();
      
      // Se existir localmente, usar esse
      if (localOnboarding != null) {
        print('✅ [OnboardingProvider] Onboarding encontrado no cache local');
        
        // Tentar sincronizar com o Supabase
        if (localOnboarding.completed) {
          try {
            print('🔄 [OnboardingProvider] Tentando sincronizar onboarding concluído');
            await _repository.saveOnboarding(localOnboarding);
            print('✅ [OnboardingProvider] Sincronização concluída');
            _state = OnboardingState.completed(localOnboarding);
          } catch (e) {
            print('❌ [OnboardingProvider] Erro ao sincronizar: $e');
            _state = OnboardingState.completed(localOnboarding);
          }
        } else {
          _state = OnboardingState.loaded(localOnboarding, isNew: false);
        }
        
        notifyListeners();
        _isInitializing = false;
        return;
      }
      
      // Se não existir nem no Supabase nem localmente, criar um novo
      print('🆕 [OnboardingProvider] Criando novo onboarding');
      final user = _getCurrentUserId();
      
      if (user == null) {
        print('❌ [OnboardingProvider] Usuário não autenticado');
        _state = OnboardingState.error('User not authenticated');
        notifyListeners();
        _isInitializing = false;
        return;
      }
      
      final newOnboarding = OnboardingModel(
        userId: user,
        completed: false,
      );
      
      print('✅ [OnboardingProvider] Novo onboarding criado');
      _state = OnboardingState.loaded(newOnboarding, isNew: true);
      
      // Salvar localmente
      await _saveLocalOnboarding(newOnboarding);
      
      // Tentar salvar no Supabase
      try {
        print('🔄 [OnboardingProvider] Salvando novo onboarding no Supabase');
        final savedOnboarding = await _repository.saveOnboarding(newOnboarding);
        print('✅ [OnboardingProvider] Onboarding salvo com ID: ${savedOnboarding.id}');
        _state = OnboardingState.loaded(savedOnboarding, isNew: true);
      } catch (e) {
        print('⚠️ [OnboardingProvider] Erro ao salvar no Supabase: $e');
        // Manteremos o estado local, tentaremos sincronizar mais tarde
      }
      
    } catch (e) {
      print('❌ [OnboardingProvider] Erro ao inicializar: $e');
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
      
      print('🔄 [OnboardingProvider] Atualizando onboarding');
      
      // Salvar localmente primeiro
      await _saveLocalOnboarding(updated);
      
      // Depois tentar salvar no Supabase se houver conexão
      try {
        print('🔄 [OnboardingProvider] Salvando no Supabase');
        final savedOnboarding = await _repository.saveOnboarding(updated);
        print('✅ [OnboardingProvider] Onboarding atualizado com sucesso no Supabase');
        _state = _state.copyWith(
          status: OnboardingStatus.loaded,
          onboarding: savedOnboarding,
        );
      } catch (e) {
        print('⚠️ [OnboardingProvider] Erro ao salvar no Supabase: $e');
        // Se falhar o salvamento no Supabase, manter o estado como loaded
        // mas com os dados do armazenamento local
        _state = _state.copyWith(
          status: OnboardingStatus.loaded,
          onboarding: updated,
        );
      }
    } catch (e) {
      print('❌ [OnboardingProvider] Erro ao atualizar: $e');
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
      if (_state.onboarding == null) {
        print('❌ [OnboardingProvider] Não há onboarding para completar');
        return;
      }
      
      print('🔄 [OnboardingProvider] Completando onboarding');
      
      final updated = _state.onboarding!.copyWith(completed: true);
      
      _state = _state.copyWith(
        status: OnboardingStatus.saving,
        onboarding: updated,
      );
      notifyListeners();
      
      // Salvar localmente primeiro
      await _saveLocalOnboarding(updated);
      
      // Tentar salvar no Supabase
      try {
        print('🔄 [OnboardingProvider] Salvando status completo no Supabase');
        final savedOnboarding = await _repository.saveOnboarding(updated);
        
        if (savedOnboarding.id != null) {
          print('🔄 [OnboardingProvider] Marcando como completo no Supabase ID: ${savedOnboarding.id}');
          // Marcar como completo no Supabase
          await _repository.completeOnboarding(savedOnboarding.id!);
          print('✅ [OnboardingProvider] Onboarding marcado como completo no Supabase');
        }
        
        _state = OnboardingState.completed(savedOnboarding);
      } catch (e) {
        print('⚠️ [OnboardingProvider] Erro ao sincronizar com Supabase: $e');
        // Se falhar, usar versão local
        _state = OnboardingState.completed(updated);
      }
      
      // Manter os dados locais para caso haja problemas de sincronização
      
    } catch (e) {
      print('❌ [OnboardingProvider] Erro ao completar onboarding: $e');
      _state = _state.copyWith(
        status: OnboardingStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      notifyListeners();
    }
  }

  // Forçar verificação de status no Supabase
  Future<bool> checkCompletionStatus() async {
    try {
      print('🔍 [OnboardingProvider] Verificando status de conclusão no Supabase');
      final isCompleted = await _repository.hasCompletedOnboarding();
      print('📊 [OnboardingProvider] Status do onboarding no Supabase: ${isCompleted ? "Completo" : "Incompleto"}');
      
      if (isCompleted && !_state.isCompleted) {
        // Atualizar o estado local se estiver desatualizado
        print('🔄 [OnboardingProvider] Atualizando estado local para completo');
        final onboarding = await _repository.getOnboarding();
        if (onboarding != null) {
          _state = OnboardingState.completed(onboarding);
          notifyListeners();
        }
      }
      
      return isCompleted;
    } catch (e) {
      print('⚠️ [OnboardingProvider] Erro ao verificar status: $e');
      // Se houver erro, usar o estado local
      return _state.isCompleted;
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
      print('⚠️ [OnboardingProvider] Erro ao ler dados locais: $e');
      return null;
    }
  }
  
  Future<void> _saveLocalOnboarding(OnboardingModel onboarding) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(onboarding.toJson());
      await prefs.setString('onboarding_data', json);
      print('✅ [OnboardingProvider] Dados salvos localmente');
    } catch (e) {
      print('⚠️ [OnboardingProvider] Erro ao salvar dados locais: $e');
    }
  }
  
  Future<void> _removeLocalOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_data');
      print('✅ [OnboardingProvider] Dados locais removidos');
    } catch (e) {
      print('⚠️ [OnboardingProvider] Erro ao remover dados locais: $e');
    }
  }
}