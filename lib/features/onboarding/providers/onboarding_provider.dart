import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_state.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:nicotinaai_flutter/services/analytics_service.dart';
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

  // Inicializar o onboarding - versão simplificada
  Future<void> initialize() async {
    // Prevenção contra chamadas concorrentes
    if (_isInitializing) {
      print('⏳ [OnboardingProvider] Inicialização já em andamento, ignorando chamada');
      return;
    }
    
    try {
      _isInitializing = true;
      print('🔍 [OnboardingProvider] Inicializando onboarding');
      
      // Primeira verificação: ver diretamente se o onboarding está completo no Supabase
      print('🔍 [OnboardingProvider] Verificando status de conclusão no Supabase');
      final isCompleteInSupabase = await _repository.hasCompletedOnboarding();
      
      if (isCompleteInSupabase) {
        // Se já está completo no Supabase, marcar como completo imediatamente
        print('✅ [OnboardingProvider] Onboarding COMPLETO no Supabase');
        
        // Buscar dados do onboarding do servidor
        final onboarding = await _repository.getOnboarding();
        
        if (onboarding != null) {
          _state = OnboardingState.completed(onboarding);
        } else {
          // Se não conseguiu buscar, criar um modelo simples completo
          final userId = _getCurrentUserId() ?? '';
          _state = OnboardingState.completed(
            OnboardingModel(userId: userId, completed: true)
          );
        }
        
        notifyListeners();
        _isInitializing = false;
        return;
      }
      
      // Verificação secundária: ler do Supabase
      final onboarding = await _repository.getOnboarding();
      
      if (onboarding != null) {
        print('📝 [OnboardingProvider] Onboarding encontrado no Supabase: ${onboarding.id}');
        
        if (onboarding.completed) {
          _state = OnboardingState.completed(onboarding);
        } else {
          _state = OnboardingState.loaded(onboarding, isNew: false);
        }
        
        notifyListeners();
        _isInitializing = false;
        return;
      }
      
      // Verificação terciária: ler da cache local
      final localOnboarding = await _getLocalOnboarding();
      
      if (localOnboarding != null) {
        print('💾 [OnboardingProvider] Onboarding encontrado na cache local');
        
        if (localOnboarding.completed) {
          _state = OnboardingState.completed(localOnboarding);
          // Tentar sincronizar sem bloquear
          _repository.saveOnboarding(localOnboarding).catchError((e) {
            print('⚠️ [OnboardingProvider] Erro ao sincronizar: $e');
          });
        } else {
          _state = OnboardingState.loaded(localOnboarding, isNew: false);
        }
        
        notifyListeners();
        _isInitializing = false;
        return;
      }
      
      // Caso final: criar novo
      print('🆕 [OnboardingProvider] Criando novo onboarding');
      final userId = _getCurrentUserId();
      
      if (userId == null) {
        print('❌ [OnboardingProvider] Usuário não autenticado');
        _state = OnboardingState.error('Usuário não autenticado');
        notifyListeners();
        _isInitializing = false;
        return;
      }
      
      final newOnboarding = OnboardingModel(userId: userId, completed: false);
      _state = OnboardingState.loaded(newOnboarding, isNew: true);
      
      // Salvar localmente e tentar salvar no servidor
      await _saveLocalOnboarding(newOnboarding);
      _repository.saveOnboarding(newOnboarding).catchError((e) {
        print('⚠️ [OnboardingProvider] Erro ao salvar: $e');
      });
      
      notifyListeners();
      
    } catch (e) {
      print('❌ [OnboardingProvider] Erro ao inicializar: $e');
      _state = OnboardingState.error(e.toString());
      notifyListeners();
    } finally {
      _isInitializing = false;
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
  
  // Completar o onboarding - versão simplificada
  Future<void> completeOnboarding() async {
    try {
      print('🔄 [OnboardingProvider] Completando onboarding');
      
      if (_state.onboarding == null) {
        print('❌ [OnboardingProvider] Não há onboarding para completar');
        return;
      }
      
      // Sempre usar o onboarding atual, apenas atualizando o status para completo
      final updated = _state.onboarding!.copyWith(completed: true);
      
      // Atualizar o estado local PRIMEIRO - isso é o mais importante
      print('✅ [OnboardingProvider] Definindo estado como COMPLETO');
      _state = OnboardingState.completed(updated);
      notifyListeners();
      
      // Salvar localmente
      print('💾 [OnboardingProvider] Salvando status completo localmente');
      await _saveLocalOnboarding(updated);
      
      // Registrar evento de analytics
      AnalyticsService().logCompletedOnboarding().catchError((e) {
        print('⚠️ [OnboardingProvider] Analytics error: $e');
      });
      
      // Salvar no Supabase - não aguardar retorno para não bloquear UI
      print('☁️ [OnboardingProvider] Enviando status completo para Supabase');
      
      // Usamos Future.sync para não bloquear, mas ainda manter o controle de erros
      Future.sync(() async {
        try {
          // Salvar onboarding atualizado
          final savedOnboarding = await _repository.saveOnboarding(updated);
          
          // Marcar como completo explicitamente no servidor
          if (savedOnboarding.id != null) {
            await _repository.completeOnboarding(savedOnboarding.id!);
            print('✅ [OnboardingProvider] Status salvo no Supabase com sucesso');
          }
        } catch (e) {
          print('⚠️ [OnboardingProvider] Erro ao salvar no Supabase: $e');
          // Erro no servidor não afeta a experiência do usuário
          // O estado local já está atualizado para completo
        }
      });
      
    } catch (e) {
      print('❌ [OnboardingProvider] Erro ao completar onboarding: $e');
      // Mesmo em caso de erro, garantir que o estado esteja como completo
      if (_state.onboarding != null) {
        _state = OnboardingState.completed(_state.onboarding!);
        notifyListeners();
      }
    }
  }

  // Verificação de status direto no Supabase - método crítico para determinar navegação
  Future<bool> checkCompletionStatus() async {
    try {
      // IMPORTANTE: Verificar diretamente no Supabase sem usar cache
      print('🔍 [OnboardingProvider] Verificando status de conclusão NO SUPABASE');
      final isCompletedInSupabase = await _repository.hasCompletedOnboarding();
      print('📊 [OnboardingProvider] Status do onboarding no Supabase: ${isCompletedInSupabase ? "COMPLETO" : "INCOMPLETO"}');
      
      // Se estiver completo no servidor, atualizar estado local
      if (isCompletedInSupabase) {
        // SEMPRE sincronizar o estado local com o Supabase
        if (!_state.isCompleted) {
          print('🔄 [OnboardingProvider] Atualizando estado local para COMPLETO para corresponder ao Supabase');
          
          // Buscar os dados completos do onboarding
          final onboarding = await _repository.getOnboarding();
          
          if (onboarding != null) {
            // Usar os dados completos do onboarding do servidor
            final updatedOnboarding = onboarding.copyWith(completed: true);
            _state = OnboardingState.completed(updatedOnboarding);
          } else {
            // Fallback: criar um modelo simples marcado como completo
            final userId = _getCurrentUserId() ?? '';
            _state = OnboardingState.completed(
              OnboardingModel(userId: userId, completed: true)
            );
          }
          
          // Notificar mudança de estado
          notifyListeners();
          
          // Salvar em cache local para acesso offline
          if (_state.onboarding != null) {
            await _saveLocalOnboarding(_state.onboarding!);
          }
        }
        
        // Se está completo no Supabase, retornar true
        return true;
      } else {
        // Se NÃO está completo no Supabase, mas está marcado como completo localmente
        if (_state.isCompleted) {
          // Tentar sincronizar o estado local para o Supabase
          print('⚠️ [OnboardingProvider] Estado INCONSISTENTE: completo localmente, mas incompleto no Supabase');
          
          // Verificar se temos o ID para fazer o update
          final onboarding = _state.onboarding;
          if (onboarding != null && onboarding.id != null) {
            try {
              print('🔄 [OnboardingProvider] Tentando sincronizar estado completo para o Supabase');
              await _repository.completeOnboarding(onboarding.id!);
              return true; // Acabamos de marcar como completo no Supabase
            } catch (e) {
              print('❌ [OnboardingProvider] Falha ao sincronizar para Supabase: $e');
              // O Supabase é a fonte primária da verdade, então retornamos false
              return false;
            }
          }
        }
        
        // Se não está completo no Supabase, retornar false
        return false;
      }
    } catch (e) {
      print('❌ [OnboardingProvider] Erro ao verificar status: $e');
      
      // Em caso de erro de comunicação, usar o estado local como fallback
      // mas avisar claramente no log que estamos usando fallback
      print('⚠️ [OnboardingProvider] FALLBACK: usando estado local: ${_state.isCompleted ? "COMPLETO" : "INCOMPLETO"}');
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