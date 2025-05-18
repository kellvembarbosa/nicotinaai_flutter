import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:nicotinaai_flutter/services/analytics_service.dart';
import 'package:nicotinaai_flutter/services/onboarding_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_event.dart';
import 'onboarding_state.dart';

/// BLoC para gerenciar o onboarding
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository _repository;
  
  // Flag para controlar inicialização em andamento
  bool _isInitializing = false;
  
  /// Construtor
  OnboardingBloc({
    required OnboardingRepository repository,
  }) : _repository = repository,
      super(OnboardingState.initial()) {
    on<InitializeOnboarding>(_onInitializeOnboarding);
    on<UpdateOnboarding>(_onUpdateOnboarding);
    on<NextOnboardingStep>(_onNextOnboardingStep);
    on<PreviousOnboardingStep>(_onPreviousOnboardingStep);
    on<GoToOnboardingStep>(_onGoToOnboardingStep);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<ClearOnboardingError>(_onClearOnboardingError);
  }

  /// Manipulador do evento InitializeOnboarding
  Future<void> _onInitializeOnboarding(
    InitializeOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    // Prevenção contra chamadas concorrentes
    if (_isInitializing) {
      debugPrint('⏳ [OnboardingBloc] Inicialização já em andamento, ignorando chamada');
      return;
    }
    
    try {
      _isInitializing = true;
      debugPrint('🔍 [OnboardingBloc] Inicializando onboarding');
      
      emit(OnboardingState.loading());
      
      // Primeira verificação: ver diretamente se o onboarding está completo no Supabase
      debugPrint('🔍 [OnboardingBloc] Verificando status de conclusão no Supabase');
      final isCompleteInSupabase = await _repository.hasCompletedOnboarding();
      
      if (isCompleteInSupabase) {
        // Se já está completo no Supabase, marcar como completo imediatamente
        debugPrint('✅ [OnboardingBloc] Onboarding COMPLETO no Supabase');
        
        // Buscar dados do onboarding do servidor
        final onboarding = await _repository.getOnboarding();
        
        if (onboarding != null) {
          emit(OnboardingState.completed(onboarding));
        } else {
          // Se não conseguiu buscar, criar um modelo simples completo
          final userId = _getCurrentUserId() ?? '';
          emit(OnboardingState.completed(
            OnboardingModel(userId: userId, completed: true)
          ));
        }
        
        _isInitializing = false;
        return;
      }
      
      // Verificação secundária: ler do Supabase
      final onboarding = await _repository.getOnboarding();
      
      if (onboarding != null) {
        debugPrint('📝 [OnboardingBloc] Onboarding encontrado no Supabase: ${onboarding.id}');
        
        if (onboarding.completed) {
          emit(OnboardingState.completed(onboarding));
        } else {
          // Verificar se há um passo atual salvo localmente para restaurar
          final savedStep = await _getLocalCurrentStep();
          
          // Buscar dados de progresso do servidor para comparar
          final serverProgress = await _repository.getOnboardingProgress();
          final serverStep = serverProgress != null ? serverProgress['current_step'] as int : null;
          
          // Decidir qual passo usar (local ou servidor), priorizando o maior valor
          int stepToUse = 1; // Valor padrão
          
          if (savedStep != null && serverStep != null) {
            // Se temos ambos, usar o maior
            stepToUse = savedStep > serverStep ? savedStep : serverStep;
            debugPrint('🔄 [OnboardingBloc] Comparando passos - Local: $savedStep, Servidor: $serverStep, Escolhido: $stepToUse');
          } else if (savedStep != null) {
            // Se só temos o valor local
            stepToUse = savedStep;
            debugPrint('📱 [OnboardingBloc] Usando passo salvo localmente: $stepToUse');
          } else if (serverStep != null) {
            // Se só temos o valor do servidor
            stepToUse = serverStep;
            debugPrint('☁️ [OnboardingBloc] Usando passo do servidor: $stepToUse');
          }
          
          // Validar o passo - não deve ser maior que o total de etapas
          if (stepToUse > 16) {
            debugPrint('⚠️ [OnboardingBloc] Passo $stepToUse inválido, resetando para 1');
            stepToUse = 1;
          }
          
          emit(OnboardingState.loaded(onboarding, isNew: false, currentStep: stepToUse));
          
          // Se restauramos de um passo salvo, atualizar o servidor para manter sincronizado
          if (savedStep != null && (serverStep == null || savedStep > serverStep)) {
            try {
              await _repository.saveOnboardingProgress(
                currentStep: stepToUse,
                lastCompletedStep: stepToUse > 1 ? stepToUse - 1 : 0,
                totalSteps: 16,
                onboardingId: onboarding.id,
              );
              debugPrint('✅ [OnboardingBloc] Progresso atualizado no servidor após restaurar passo local');
            } catch (e) {
              debugPrint('⚠️ [OnboardingBloc] Erro ao atualizar progresso no servidor: $e');
            }
          }
        }
        
        _isInitializing = false;
        return;
      }
      
      // Verificação terciária: ler da cache local
      final localOnboarding = await _getLocalOnboarding();
      
      if (localOnboarding != null) {
        debugPrint('💾 [OnboardingBloc] Onboarding encontrado na cache local');
        
        if (localOnboarding.completed) {
          emit(OnboardingState.completed(localOnboarding));
          // Tentar sincronizar sem bloquear
          _repository.saveOnboarding(localOnboarding).catchError((e) {
            debugPrint('⚠️ [OnboardingBloc] Erro ao sincronizar: $e');
            return localOnboarding; // Retornar o objeto local em caso de erro
          });
        } else {
          // Verificar se há um passo atual salvo
          final savedStep = await _getLocalCurrentStep();
          if (savedStep != null) {
            // Validar o passo
            final validStep = savedStep > 16 ? 1 : savedStep;
            debugPrint('📱 [OnboardingBloc] Restaurando passo salvo localmente: $validStep');
            emit(OnboardingState.loaded(localOnboarding, isNew: false, currentStep: validStep));
          } else {
            emit(OnboardingState.loaded(localOnboarding, isNew: false));
          }
        }
        
        _isInitializing = false;
        return;
      }
      
      // Caso final: criar novo
      debugPrint('🆕 [OnboardingBloc] Criando novo onboarding');
      final userId = _getCurrentUserId();
      
      if (userId == null) {
        debugPrint('❌ [OnboardingBloc] Usuário não autenticado');
        emit(OnboardingState.error('Usuário não autenticado'));
        _isInitializing = false;
        return;
      }
      
      final newOnboarding = OnboardingModel(userId: userId, completed: false);
      emit(OnboardingState.loaded(newOnboarding, isNew: true));
      
      // Salvar localmente e tentar salvar no servidor
      await _saveLocalOnboarding(newOnboarding);
      _repository.saveOnboarding(newOnboarding).catchError((e) {
        debugPrint('⚠️ [OnboardingBloc] Erro ao salvar: $e');
        return newOnboarding; // Retornar o objeto local em caso de erro
      });
      
    } catch (e) {
      debugPrint('❌ [OnboardingBloc] Erro ao inicializar: $e');
      emit(OnboardingState.error(e.toString()));
    } finally {
      _isInitializing = false;
    }
  }

  /// Manipulador do evento UpdateOnboarding
  Future<void> _onUpdateOnboarding(
    UpdateOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      // Verificar valores críticos e aplicar valores padrão se nulos
      OnboardingModel onboardingToSave = event.onboarding;
      bool valuesWereNull = false;
      
      // Verificar packPrice
      if (onboardingToSave.packPrice == null && 
          onboardingToSave.cigarettesPerPack == null) {
        // Se ambos são nulos, verificamos a origem para decidir o que fazer
        
        // Verificar se estamos na tela de preço do maço (aqui deveríamos ter packPrice)
        final isPackPriceScreen = state.currentStep == 6;
        // Verificar se estamos na tela de cigarros por maço (aqui deveríamos ter cigarettesPerPack)
        final isCigarettesPerPackScreen = state.currentStep == 7;
        
        if (isPackPriceScreen) {
          debugPrint('⚠️ [OnboardingBloc] packPrice é null na tela de preço do maço!');
          // Usar valor padrão de 10,00
          onboardingToSave = onboardingToSave.copyWith(packPrice: 1000);
          valuesWereNull = true;
        }
        
        if (isCigarettesPerPackScreen) {
          debugPrint('⚠️ [OnboardingBloc] cigarettesPerPack é null na tela de cigarros por maço!');
          // Usar valor padrão de 20 cigarros
          onboardingToSave = onboardingToSave.copyWith(cigarettesPerPack: 20);
          valuesWereNull = true;
        }
      } else {
        // Verificações individuais
        if (onboardingToSave.packPrice == null) {
          debugPrint('⚠️ [OnboardingBloc] ALERTA: packPrice é null, usando valor padrão');
          // Verificar se já temos um valor salvo no estado
          final currentPrice = state.onboarding?.packPrice;
          onboardingToSave = onboardingToSave.copyWith(
            packPrice: currentPrice ?? 1000 // 10,00 valor padrão
          );
          valuesWereNull = true;
        }
        
        if (onboardingToSave.cigarettesPerPack == null) {
          debugPrint('⚠️ [OnboardingBloc] ALERTA: cigarettesPerPack é null, usando valor padrão');
          // Verificar se já temos um valor salvo no estado
          final currentCigarettesPerPack = state.onboarding?.cigarettesPerPack;
          onboardingToSave = onboardingToSave.copyWith(
            cigarettesPerPack: currentCigarettesPerPack ?? 20 // 20 cigarros padrão
          );
          valuesWereNull = true;
        }
      }
      
      if (valuesWereNull) {
        debugPrint('🔄 [OnboardingBloc] Valores nulos detectados e corrigidos:');
        debugPrint('  - packPrice: ${onboardingToSave.packPrice} centavos (era: ${event.onboarding.packPrice})');
        debugPrint('  - cigarettesPerPack: ${onboardingToSave.cigarettesPerPack} cigarros (era: ${event.onboarding.cigarettesPerPack})');
      }
      
      // Atualizar estado com o modelo corrigido
      emit(state.copyWith(
        status: OnboardingStatus.saving,
        onboarding: onboardingToSave,
      ));
      
      // Log detalhado para depuração
      debugPrint('🔄 [OnboardingBloc] Atualizando onboarding com:');
      debugPrint('  - packPrice: ${onboardingToSave.packPrice} centavos');
      debugPrint('  - cigarettesPerPack: ${onboardingToSave.cigarettesPerPack} cigarros');
      debugPrint('  - cigarettesPerDayCount: ${onboardingToSave.cigarettesPerDayCount}');
      debugPrint('  - packPriceCurrency: ${onboardingToSave.packPriceCurrency}');
      
      // Salvar localmente primeiro
      await _saveLocalOnboarding(onboardingToSave);
      
      // Depois tentar salvar no Supabase se houver conexão
      try {
        debugPrint('🔄 [OnboardingBloc] Salvando no Supabase');
        final savedOnboarding = await _repository.saveOnboarding(onboardingToSave);
        
        // Verificar se os dados foram salvos corretamente
        debugPrint('✅ [OnboardingBloc] Onboarding atualizado com sucesso no Supabase');
        debugPrint('  - ID: ${savedOnboarding.id}');
        debugPrint('  - packPrice salvo: ${savedOnboarding.packPrice} centavos');
        debugPrint('  - cigarettesPerPack salvo: ${savedOnboarding.cigarettesPerPack} cigarros');
        
        // Verificar se os valores foram preservados corretamente
        final packPricePreserved = savedOnboarding.packPrice == onboardingToSave.packPrice;
        final cigarettesPerPackPreserved = savedOnboarding.cigarettesPerPack == onboardingToSave.cigarettesPerPack;
        
        if (!packPricePreserved || !cigarettesPerPackPreserved) {
          debugPrint('⚠️ [OnboardingBloc] ALERTA: Valores não preservados após salvamento!');
          debugPrint('  - packPrice preservado: $packPricePreserved');
          debugPrint('  - cigarettesPerPack preservado: $cigarettesPerPackPreserved');
          
          // Se os valores não foram preservados, usar versão local
          emit(state.copyWith(
            status: OnboardingStatus.loaded,
            onboarding: onboardingToSave,
          ));
        } else {
          // Valores preservados, usar versão do servidor
          emit(state.copyWith(
            status: OnboardingStatus.loaded,
            onboarding: savedOnboarding,
          ));
        }
      } catch (e) {
        debugPrint('⚠️ [OnboardingBloc] Erro ao salvar no Supabase: $e');
        // Se falhar o salvamento no Supabase, manter o estado como loaded
        // mas com os dados do armazenamento local
        emit(state.copyWith(
          status: OnboardingStatus.loaded,
          onboarding: onboardingToSave,
        ));
      }
    } catch (e) {
      debugPrint('❌ [OnboardingBloc] Erro ao atualizar: $e');
      emit(state.copyWith(
        status: OnboardingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Manipulador do evento NextOnboardingStep
  Future<void> _onNextOnboardingStep(
    NextOnboardingStep event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!state.canAdvance) return;
    
    final nextStep = state.currentStep + 1;
    
    emit(state.copyWith(
      currentStep: nextStep,
    ));
    
    // Salvar o passo atual localmente para poder restaurar ao reabrir o app
    await _saveCurrentStep(nextStep);
    
    // Atualizar o progresso no banco de dados - assume que essa etapa foi concluída
    try {
      final lastCompletedStep = state.currentStep - 1; // A etapa que estava antes de avançar
      
      await _repository.saveOnboardingProgress(
        currentStep: nextStep,
        lastCompletedStep: lastCompletedStep,
        totalSteps: state.totalSteps,
        onboardingId: state.onboarding?.id,
      );
      
      debugPrint('✅ [OnboardingBloc] Progresso salvo: etapa atual=$nextStep, última completada=$lastCompletedStep');
    } catch (e) {
      debugPrint('⚠️ [OnboardingBloc] Erro ao salvar progresso: $e');
      // Não mudar o estado em caso de erro para não interromper o fluxo do usuário
    }
  }

  /// Manipulador do evento PreviousOnboardingStep
  Future<void> _onPreviousOnboardingStep(
    PreviousOnboardingStep event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!state.canGoBack) return;
    
    final prevStep = state.currentStep - 1;
    
    emit(state.copyWith(
      currentStep: prevStep,
    ));
    
    // Salvar o passo atual localmente para poder restaurar ao reabrir o app
    await _saveCurrentStep(prevStep);
    
    // Atualizar apenas o currentStep, sem alterar o lastCompletedStep
    try {
      // Obter o progresso atual
      final progress = await _repository.getOnboardingProgress();
      
      if (progress != null) {
        await _repository.saveOnboardingProgress(
          currentStep: prevStep,
          // Manter o último step completado
          lastCompletedStep: progress['last_completed_step'] ?? 0,
          totalSteps: state.totalSteps,
          onboardingId: state.onboarding?.id,
        );
        
        debugPrint('✅ [OnboardingBloc] Progresso atualizado ao voltar: etapa atual=$prevStep');
      }
    } catch (e) {
      debugPrint('⚠️ [OnboardingBloc] Erro ao atualizar progresso ao voltar: $e');
    }
  }

  /// Manipulador do evento GoToOnboardingStep
  Future<void> _onGoToOnboardingStep(
    GoToOnboardingStep event,
    Emitter<OnboardingState> emit,
  ) async {
    if (event.step < 1 || event.step > state.totalSteps) return;
    
    emit(state.copyWith(
      currentStep: event.step,
    ));
    
    // Salvar o passo atual localmente para poder restaurar ao reabrir o app
    await _saveCurrentStep(event.step);
    
    // Atualizar apenas o currentStep, sem alterar o lastCompletedStep
    try {
      // Obter o progresso atual
      final progress = await _repository.getOnboardingProgress();
      
      if (progress != null) {
        await _repository.saveOnboardingProgress(
          currentStep: event.step,
          // Manter o último step completado
          lastCompletedStep: progress['last_completed_step'] ?? 0,
          totalSteps: state.totalSteps,
          onboardingId: state.onboarding?.id,
        );
        
        debugPrint('✅ [OnboardingBloc] Progresso atualizado ao ir para etapa específica: etapa atual=${event.step}');
      }
    } catch (e) {
      debugPrint('⚠️ [OnboardingBloc] Erro ao atualizar progresso ao ir para etapa específica: $e');
    }
  }

  /// Manipulador do evento CompleteOnboarding
  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    // Limpar todos os dados locais ao completar o onboarding
    await _removeLocalOnboarding();
    try {
      debugPrint('🔄 [OnboardingBloc] Verificando requisitos para completar onboarding');
      
      if (state.onboarding == null) {
        debugPrint('❌ [OnboardingBloc] Não há onboarding para completar');
        return;
      }
      
      // Verificar valores do onboarding antes de completar
      final onboarding = state.onboarding!;
      debugPrint('📋 [OnboardingBloc] Valores do onboarding a serem salvos:');
      debugPrint('   - packPrice: ${onboarding.packPrice} centavos');
      debugPrint('   - cigarettesPerPack: ${onboarding.cigarettesPerPack} cigarros');
      debugPrint('   - cigarettesPerDayCount: ${onboarding.cigarettesPerDayCount} cigarros');
      
      // Verificar se temos os valores necessários para concluir o onboarding
      if (onboarding.packPrice == null || onboarding.cigarettesPerPack == null) {
        debugPrint('⚠️ [OnboardingBloc] ALERTA: Valores importantes são nulos!');
        
        // Criar uma cópia com valores padrão para campos nulos
        OnboardingModel updatedOnboarding = onboarding.copyWith(
          packPrice: onboarding.packPrice ?? 1000, // 10,00 valor padrão
          cigarettesPerPack: onboarding.cigarettesPerPack ?? 20, // 20 cigarros padrão
          cigarettesPerDayCount: onboarding.cigarettesPerDayCount ?? 10, // 10 cigarros/dia padrão
        );
        
        // Salvar a versão atualizada
        await _saveLocalOnboarding(updatedOnboarding);
        
        // Atualizar estado com valores preenchidos
        emit(state.copyWith(
          onboarding: updatedOnboarding,
        ));
        
        // Garantir que a versão atualizada seja salva no Supabase
        try {
          final savedOnboarding = await _repository.saveOnboarding(updatedOnboarding);
          // Atualizar o estado com a versão salva no servidor
          emit(state.copyWith(
            onboarding: savedOnboarding,
          ));
          debugPrint('✅ [OnboardingBloc] Valores padrão salvos com sucesso no onboarding');
        } catch (e) {
          debugPrint('⚠️ [OnboardingBloc] Erro ao salvar valores padrão: $e');
          // Continuar mesmo com erro, usaremos a versão local atualizada
        }
      }
      
      // Verificar se estamos na tela de conclusão (última etapa)
      final isCompletionScreen = state.currentStep == state.totalSteps;
      
      if (isCompletionScreen) {
        // Se estamos na tela de conclusão, podemos completar sem verificações adicionais
        debugPrint('✅ [OnboardingBloc] Estamos na tela de conclusão, completando diretamente...');
        
        // Forçar a atualização do progresso para marcar a última etapa como concluída
        try {
          await _repository.saveOnboardingProgress(
            currentStep: state.totalSteps,
            lastCompletedStep: state.totalSteps - 1, // Marca a última etapa como completa
            totalSteps: state.totalSteps,
            onboardingId: state.onboarding?.id,
          );
          debugPrint('✅ [OnboardingBloc] Progresso atualizado para última etapa');
        } catch (e) {
          debugPrint('⚠️ [OnboardingBloc] Erro ao atualizar progresso da última etapa: $e');
          // Continuar mesmo com erro
        }
      } else {
        // NOVA VALIDAÇÃO: Verificar se todas as etapas foram realmente concluídas
        final allStepsCompleted = await _repository.hasCompletedAllSteps(
          totalSteps: state.totalSteps
        );
        
        // Se não completou todas as etapas, atualiza o progresso com a etapa atual
        // e retorna sem completar o onboarding
        if (!allStepsCompleted) {
          debugPrint('⚠️ [OnboardingBloc] Tentativa de completar onboarding sem finalizar todas as etapas!');
          
          // Atualizar progresso para a etapa atual
          try {
            await _repository.saveOnboardingProgress(
              currentStep: state.currentStep,
              lastCompletedStep: state.currentStep - 1,
              totalSteps: state.totalSteps,
              onboardingId: state.onboarding?.id,
            );
            
            // Notificar o usuário que ele precisa completar todas as etapas
            final remainingSteps = state.totalSteps - state.currentStep;
            debugPrint('ℹ️ [OnboardingBloc] Faltam $remainingSteps etapas para completar o onboarding');
            
            // Não atualizar o estado, deixe o usuário continuar navegando normalmente
            return;
          } catch (e) {
            debugPrint('⚠️ [OnboardingBloc] Erro ao atualizar progresso: $e');
            // Continuar com o código para completar o onboarding mesmo com o erro
          }
        }
      }
      
      // Se chegou aqui, todas as etapas foram completadas ou ocorreu um erro na verificação
      debugPrint('✅ [OnboardingBloc] Todas as etapas foram completadas, finalizando onboarding');
      
      // Marca explicitamente a última etapa como completa
      try {
        await _repository.saveOnboardingProgress(
          currentStep: state.totalSteps,
          lastCompletedStep: state.totalSteps - 1, // A última etapa (índice 0-based)
          totalSteps: state.totalSteps,
          onboardingId: state.onboarding?.id,
        );
      } catch (e) {
        debugPrint('⚠️ [OnboardingBloc] Erro ao atualizar última etapa: $e');
        // Continuar mesmo com erro
      }
      
      // Sempre usar o onboarding atual, apenas atualizando o status para completo
      final updated = state.onboarding!.copyWith(completed: true);
      
      // Log dos valores que serão sincronizados
      debugPrint('📊 [OnboardingBloc] Dados finais do onboarding:');
      debugPrint('   - packPrice: ${updated.packPrice} centavos');
      debugPrint('   - cigarettesPerPack: ${updated.cigarettesPerPack} cigarros');
      debugPrint('   - cigarettesPerDayCount: ${updated.cigarettesPerDayCount} cigarros');
      
      // Atualizar o estado local PRIMEIRO - isso é o mais importante
      debugPrint('✅ [OnboardingBloc] Definindo estado como COMPLETO');
      emit(OnboardingState.completed(updated));
      
      // Salvar localmente
      debugPrint('💾 [OnboardingBloc] Salvando status completo localmente');
      await _saveLocalOnboarding(updated);
      
      // Registrar evento de analytics
      AnalyticsService().logCompletedOnboarding().catchError((e) {
        debugPrint('⚠️ [OnboardingBloc] Analytics error: $e');
        return false; // Return value to satisfy the Future<bool>
      });
      
      // Salvar no Supabase - não aguardar retorno para não bloquear UI
      debugPrint('☁️ [OnboardingBloc] Enviando status completo para Supabase');
      
      // MÚLTIPLAS TENTATIVAS DE SINCRONIZAÇÃO
      int syncAttempts = 0;
      bool syncSuccess = false;
      
      // Usamos Future.sync para não bloquear, mas ainda manter o controle de erros
      Future.sync(() async {
        try {
          // Salvar onboarding atualizado
          final savedOnboarding = await _repository.saveOnboarding(updated);
          
          // Marcar como completo explicitamente no servidor
          if (savedOnboarding.id != null) {
            await _repository.completeOnboarding(savedOnboarding.id!);
            debugPrint('✅ [OnboardingBloc] Status salvo no Supabase com sucesso');
            
            // PRIMEIRA TENTATIVA DE SINCRONIZAÇÃO
            debugPrint('🔄 [OnboardingBloc] Primeira tentativa de sincronização (1/3)');
            final syncService = OnboardingSyncService();
            syncSuccess = await syncService.syncOnboardingDataToUserStats();
            syncAttempts++;
            
            if (syncSuccess) {
              debugPrint('✅ [OnboardingBloc] Dados sincronizados com sucesso na tentativa $syncAttempts');
            } else {
              // SEGUNDA TENTATIVA APÓS DELAY
              debugPrint('⚠️ [OnboardingBloc] Primeira tentativa falhou, tentando de novo (2/3)...');
              await Future.delayed(const Duration(milliseconds: 500));
              
              syncSuccess = await syncService.syncOnboardingDataToUserStats();
              syncAttempts++;
              
              if (syncSuccess) {
                debugPrint('✅ [OnboardingBloc] Dados sincronizados com sucesso na tentativa $syncAttempts');
              } else {
                // TERCEIRA TENTATIVA APÓS DELAY MAIOR
                debugPrint('⚠️ [OnboardingBloc] Segunda tentativa falhou, tentando final (3/3)...');
                await Future.delayed(const Duration(seconds: 1));
                
                syncSuccess = await syncService.syncOnboardingDataToUserStats();
                syncAttempts++;
                
                if (syncSuccess) {
                  debugPrint('✅ [OnboardingBloc] Dados sincronizados com sucesso na tentativa $syncAttempts');
                } else {
                  debugPrint('❌ [OnboardingBloc] Todas as $syncAttempts tentativas de sincronização falharam');
                }
              }
            }
          }
        } catch (e) {
          debugPrint('⚠️ [OnboardingBloc] Erro ao salvar no Supabase: $e');
          // Erro no servidor não afeta a experiência do usuário
          // O estado local já está atualizado para completo
          
          // Última tentativa de sincronização após erro
          debugPrint('🔄 [OnboardingBloc] Tentativa de sincronização após erro de salvamento');
          
          final syncService = OnboardingSyncService();
          try {
            syncSuccess = await syncService.syncOnboardingDataToUserStats();
            if (syncSuccess) {
              debugPrint('✅ [OnboardingBloc] Dados sincronizados com sucesso após erro');
            } else {
              debugPrint('❌ [OnboardingBloc] Falha na sincronização após erro');
            }
          } catch (syncError) {
            debugPrint('❌ [OnboardingBloc] Erro na sincronização: $syncError');
          }
        }
      });
      
    } catch (e) {
      debugPrint('❌ [OnboardingBloc] Erro ao completar onboarding: $e');
      // Mesmo em caso de erro, garantir que o estado esteja como completo
      if (state.onboarding != null) {
        emit(OnboardingState.completed(state.onboarding!));
      }
    }
  }

  /// Manipulador do evento CheckOnboardingStatus
  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      // IMPORTANTE: Verificar diretamente no Supabase sem usar cache
      debugPrint('🔍 [OnboardingBloc] Verificando status de conclusão NO SUPABASE');
      final isCompletedInSupabase = await _repository.hasCompletedOnboarding();
      debugPrint('📊 [OnboardingBloc] Status do onboarding no Supabase: ${isCompletedInSupabase ? "COMPLETO" : "INCOMPLETO"}');
      
      // Se estiver completo no servidor, atualizar estado local
      if (isCompletedInSupabase) {
        // SEMPRE sincronizar o estado local com o Supabase
        if (!state.isCompleted) {
          debugPrint('🔄 [OnboardingBloc] Atualizando estado local para COMPLETO para corresponder ao Supabase');
          
          // Buscar os dados completos do onboarding
          final onboarding = await _repository.getOnboarding();
          
          if (onboarding != null) {
            // Usar os dados completos do onboarding do servidor
            final updatedOnboarding = onboarding.copyWith(completed: true);
            emit(OnboardingState.completed(updatedOnboarding));
          } else {
            // Fallback: criar um modelo simples marcado como completo
            final userId = _getCurrentUserId() ?? '';
            emit(OnboardingState.completed(
              OnboardingModel(userId: userId, completed: true)
            ));
          }
          
          // Salvar em cache local para acesso offline
          if (state.onboarding != null) {
            await _saveLocalOnboarding(state.onboarding!);
          }
        }
      } else {
        // Se NÃO está completo no Supabase, mas está marcado como completo localmente
        if (state.isCompleted) {
          // Tentar sincronizar o estado local para o Supabase
          debugPrint('⚠️ [OnboardingBloc] Estado INCONSISTENTE: completo localmente, mas incompleto no Supabase');
          
          // Verificar se temos o ID para fazer o update
          final onboarding = state.onboarding;
          if (onboarding != null && onboarding.id != null) {
            try {
              debugPrint('🔄 [OnboardingBloc] Tentando sincronizar estado completo para o Supabase');
              await _repository.completeOnboarding(onboarding.id!);
              debugPrint('✅ [OnboardingBloc] Onboarding marcado como completo no Supabase');
            } catch (e) {
              debugPrint('❌ [OnboardingBloc] Falha ao sincronizar para Supabase: $e');
              // O Supabase é a fonte primária da verdade
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [OnboardingBloc] Erro ao verificar status: $e');
      
      // Em caso de erro de comunicação, usar o estado local como fallback
      // mas avisar claramente no log que estamos usando fallback
      debugPrint('⚠️ [OnboardingBloc] FALLBACK: usando estado local: ${state.isCompleted ? "COMPLETO" : "INCOMPLETO"}');
    }
  }

  /// Manipulador do evento ClearOnboardingError
  void _onClearOnboardingError(
    ClearOnboardingError event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.hasError) {
      emit(state.copyWith(
        status: state.onboarding != null 
            ? OnboardingStatus.loaded 
            : OnboardingStatus.initial,
        clearError: true,
      ));
    }
  }

  // Métodos auxiliares
  
  /// Obtém o ID do usuário atual
  String? _getCurrentUserId() {
    final user = SupabaseConfig.client.auth.currentUser;
    return user?.id;
  }
  
  /// Obtém o onboarding salvo localmente
  Future<OnboardingModel?> _getLocalOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('onboarding_data');
      
      if (json == null) return null;
      
      final data = jsonDecode(json);
      return OnboardingModel.fromJson(data);
    } catch (e) {
      debugPrint('⚠️ [OnboardingBloc] Erro ao ler dados locais: $e');
      return null;
    }
  }
  
  /// Salva o onboarding localmente
  Future<void> _saveLocalOnboarding(OnboardingModel onboarding) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(onboarding.toJson());
      await prefs.setString('onboarding_data', json);
      debugPrint('✅ [OnboardingBloc] Dados salvos localmente');
    } catch (e) {
      debugPrint('⚠️ [OnboardingBloc] Erro ao salvar dados locais: $e');
    }
  }
  
  /// Salva apenas o passo atual do onboarding
  Future<void> _saveCurrentStep(int step) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('onboarding_current_step', step);
      debugPrint('✅ [OnboardingBloc] Passo atual ($step) salvo localmente');
    } catch (e) {
      debugPrint('⚠️ [OnboardingBloc] Erro ao salvar passo atual: $e');
    }
  }
  
  /// Recupera o passo atual do onboarding
  Future<int?> _getLocalCurrentStep() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final step = prefs.getInt('onboarding_current_step');
      if (step != null) {
        debugPrint('✅ [OnboardingBloc] Passo atual ($step) recuperado localmente');
      }
      return step;
    } catch (e) {
      debugPrint('⚠️ [OnboardingBloc] Erro ao recuperar passo atual: $e');
      return null;
    }
  }
  
  /// Remove o onboarding salvo localmente
  Future<void> _removeLocalOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_data');
      await prefs.remove('onboarding_current_step'); // Remove o passo salvo também
      debugPrint('✅ [OnboardingBloc] Dados locais removidos');
    } catch (e) {
      debugPrint('⚠️ [OnboardingBloc] Erro ao remover dados locais: $e');
    }
  }
}