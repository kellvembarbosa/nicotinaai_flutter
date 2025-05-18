import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/repositories/onboarding_repository.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/features/tracking/repositories/tracking_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço para sincronizar dados do onboarding com o UserStats
/// Este serviço é responsável por transferir dados como preço do maço,
/// cigarros por maço, etc. do onboarding para o UserStats
class OnboardingSyncService {
  final OnboardingRepository _onboardingRepository;
  final TrackingRepository _trackingRepository;

  // Construtor com injeção de dependência para facilitar testes
  OnboardingSyncService({
    OnboardingRepository? onboardingRepository,
    TrackingRepository? trackingRepository,
  }) : _onboardingRepository = onboardingRepository ?? OnboardingRepository(),
       _trackingRepository = trackingRepository ?? TrackingRepository();

  /// Sincroniza dados do onboarding para UserStats
  /// Retorna true se a sincronização for bem-sucedida
  Future<bool> syncOnboardingDataToUserStats() async {
    try {
      // Buscar dados do onboarding
      final onboarding = await _onboardingRepository.getOnboarding();
      
      if (onboarding == null) {
        debugPrint('⚠️ [OnboardingSyncService] Não foi possível obter dados do onboarding');
        return false;
      }
      
      // Log detalhado dos valores no onboarding antes da sincronização
      debugPrint('📋 [OnboardingSyncService] Dados do onboarding a serem sincronizados:');
      debugPrint('   - ID: ${onboarding.id}');
      debugPrint('   - UserID: ${onboarding.userId}');
      debugPrint('   - PackPrice: ${onboarding.packPrice} centavos');
      debugPrint('   - CigarettesPerPack: ${onboarding.cigarettesPerPack} cigarros');
      debugPrint('   - CigarettesPerDay: ${onboarding.cigarettesPerDayCount} cigarros');
      debugPrint('   - Currency: ${onboarding.packPriceCurrency}');
      debugPrint('   - Completed: ${onboarding.completed}');

      // Buscar estatísticas do usuário inicial para comparação
      final initialStats = await _trackingRepository.getUserStats();
      
      // Log dos valores atuais em UserStats, se existirem
      if (initialStats != null) {
        debugPrint('📊 [OnboardingSyncService] Valores ATUAIS em UserStats:');
        debugPrint('   - ID: ${initialStats.id}');
        debugPrint('   - PackPrice: ${initialStats.packPrice} centavos');
        debugPrint('   - CigarettesPerPack: ${initialStats.cigarettesPerPack} cigarros');
        debugPrint('   - CigarettesPerDay: ${initialStats.cigarettesPerDay} cigarros');
        debugPrint('   - Currency: ${initialStats.currencyCode}');
      }
      
      // Usar a função RPC para sincronizar diretamente
      debugPrint('🔄 [OnboardingSyncService] Chamando função RPC para sincronização direta');
      
      try {
        final result = await Supabase.instance.client.rpc(
          'sync_onboarding_to_user_stats',
          params: {
            'user_id_param': onboarding.userId,
          },
        );
        
        // Verificar o resultado
        final success = result as bool;
        if (success) {
          debugPrint('✅ [OnboardingSyncService] Sincronização via RPC concluída com sucesso');
        } else {
          debugPrint('⚠️ [OnboardingSyncService] Sincronização via RPC retornou falso');
        }
      } catch (rpcError) {
        debugPrint('❌ [OnboardingSyncService] Erro na sincronização via RPC: $rpcError');
        
        // Tentar abordagem mais tradicional
        if (initialStats == null) {
          // Se não havia stats, criar novo
          await _createUserStatsFromOnboarding(onboarding);
        } else {
          // Se havia stats, atualizar
          await _updateUserStatsFromOnboarding(initialStats, onboarding);
        }
      }
      
      // Verificação final: buscar UserStats atualizado para confirmar se valores foram salvos
      final updatedStats = await _trackingRepository.getUserStats();
      if (updatedStats != null) {
        debugPrint('✅ [OnboardingSyncService] Valores APÓS atualização em UserStats:');
        debugPrint('   - PackPrice: ${updatedStats.packPrice} centavos');
        debugPrint('   - CigarettesPerPack: ${updatedStats.cigarettesPerPack} cigarros');
        debugPrint('   - CigarettesPerDay: ${updatedStats.cigarettesPerDay} cigarros');
        debugPrint('   - Currency: ${updatedStats.currencyCode}');
        
        // Verificar se os valores foram salvos corretamente
        final packPriceOk = updatedStats.packPrice == onboarding.packPrice;
        final cigarettesPerPackOk = updatedStats.cigarettesPerPack == onboarding.cigarettesPerPack;
        
        if (packPriceOk && cigarettesPerPackOk) {
          debugPrint('✅ [OnboardingSyncService] Sincronização COMPLETA e VERIFICADA com sucesso!');
        } else {
          debugPrint('⚠️ [OnboardingSyncService] ATENÇÃO: Valores não correspondem após sincronização!');
          debugPrint('   - PackPrice OK: $packPriceOk');
          debugPrint('   - CigarettesPerPack OK: $cigarettesPerPackOk');
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ [OnboardingSyncService] Erro ao sincronizar dados: $e');
      return false;
    }
  }

  /// Cria um novo UserStats com dados do onboarding
  Future<void> _createUserStatsFromOnboarding(OnboardingModel onboarding) async {
    try {
      // Verificar valores antes da criação
      if (onboarding.packPrice == null) {
        debugPrint('⚠️ [OnboardingSyncService] ALERTA: packPrice é null no onboarding para criação!');
      }
      
      if (onboarding.cigarettesPerPack == null) {
        debugPrint('⚠️ [OnboardingSyncService] ALERTA: cigarettesPerPack é null no onboarding para criação!');
      }
      
      // Definir valores padrão para campos obrigatórios se estiverem nulos
      final cigarettesPerDayCount = onboarding.cigarettesPerDayCount ?? 10;
      final cigarettesPerPack = onboarding.cigarettesPerPack ?? 20;
      final packPrice = onboarding.packPrice ?? 1000; // Default 10,00 em centavos
      
      // Dados para UserStats a partir do onboarding
      final initialUserStats = {
        'user_id': onboarding.userId,
        'cigarettes_per_day': cigarettesPerDayCount,
        'cigarettes_per_pack': cigarettesPerPack,
        'pack_price': packPrice,
        'currency_code': onboarding.packPriceCurrency,
        'money_saved': 0,
        'cigarettes_avoided': 0,
        'cigarettes_smoked': 0,
        'smoking_records_count': 0,
        'cravings_count': 0,
        'cravings_resisted': 0,
        'current_streak_days': 0,
      };
      
      // Log detalhado para depuração
      debugPrint('🔄 [OnboardingSyncService] Criando novo UserStats:');
      debugPrint('   - user_id: ${initialUserStats['user_id']}');
      debugPrint('   - cigarros por dia: ${initialUserStats['cigarettes_per_day']}');
      debugPrint('   - cigarros por maço: ${initialUserStats['cigarettes_per_pack']}');
      debugPrint('   - preço do maço: ${initialUserStats['pack_price']}¢');
      debugPrint('   - moeda: ${initialUserStats['currency_code']}');

      // Executar SQL para criar UserStats e retornar os dados inseridos
      try {
        final response = await Supabase.instance.client
            .from('user_stats')
            .insert(initialUserStats)
            .select();
            
        // Log da resposta do insert para verificar se funcionou
        debugPrint('📊 [OnboardingSyncService] Resposta da criação:');
        if (response.isNotEmpty) {
          final createdData = response[0];
          debugPrint('   - ID criado: ${createdData['id']}');
          debugPrint('   - packPrice criado: ${createdData['pack_price']}¢');
          debugPrint('   - cigarettesPerPack criado: ${createdData['cigarettes_per_pack']}');
        } else {
          debugPrint('⚠️ [OnboardingSyncService] Insert não retornou dados, verificando se funcionou...');
        }
      } catch (sqlError) {
        debugPrint('❌ [OnboardingSyncService] Erro SQL na criação: $sqlError');
        
        // Tentar abordagem alternativa com insert direto
        debugPrint('🔄 [OnboardingSyncService] Tentando criação direta...');
        
        try {
          // Executar uma RPC direta para garantir a criação
          await Supabase.instance.client.rpc('create_user_stats_from_onboarding', params: {
            'user_id_param': onboarding.userId,
            'cigarettes_per_day_param': cigarettesPerDayCount,
            'cigarettes_per_pack_param': cigarettesPerPack,
            'pack_price_param': packPrice,
            'currency_code_param': onboarding.packPriceCurrency,
          });
          
          debugPrint('✅ [OnboardingSyncService] Criação via RPC concluída');
        } catch (rpcError) {
          debugPrint('❌ [OnboardingSyncService] Erro na RPC de criação: $rpcError');
          // Se a RPC falhar, tentar uma última abordagem com SQL bruto
          try {
            // Usar a nova função RPC que criamos na migração
            await Supabase.instance.client.rpc(
              'sync_onboarding_to_user_stats',
              params: {
                'user_id_param': onboarding.userId,
              },
            );
            debugPrint('✅ [OnboardingSyncService] Criação via SQL direto concluída');
          } catch (finalError) {
            debugPrint('❌ [OnboardingSyncService] Todas as tentativas de criação falharam: $finalError');
            throw finalError;
          }
        }
      }

      debugPrint('✅ [OnboardingSyncService] Novo UserStats criado com dados do onboarding');
    } catch (e) {
      debugPrint('❌ [OnboardingSyncService] Erro ao criar UserStats: $e');
      rethrow;
    }
  }

  /// Atualiza UserStats existente com dados do onboarding
  Future<void> _updateUserStatsFromOnboarding(UserStats userStats, OnboardingModel onboarding) async {
    try {
      // Verificar valores antes da atualização
      if (onboarding.packPrice == null) {
        debugPrint('⚠️ [OnboardingSyncService] ALERTA: packPrice é null no onboarding!');
      }
      
      if (onboarding.cigarettesPerPack == null) {
        debugPrint('⚠️ [OnboardingSyncService] ALERTA: cigarettesPerPack é null no onboarding!');
      }
      
      // Valores a serem atualizados (eliminando valores nulos)
      final Map<String, dynamic> updatedValues = {};
      
      // Adicionar apenas valores não nulos
      if (onboarding.cigarettesPerDayCount != null) {
        updatedValues['cigarettes_per_day'] = onboarding.cigarettesPerDayCount;
      }
      
      if (onboarding.cigarettesPerPack != null) {
        updatedValues['cigarettes_per_pack'] = onboarding.cigarettesPerPack;
      }
      
      if (onboarding.packPrice != null) {
        updatedValues['pack_price'] = onboarding.packPrice;
      }
      
      // A moeda deve sempre ter um valor, mesmo que seja o padrão 'BRL'
      updatedValues['currency_code'] = onboarding.packPriceCurrency;
      
      // Log detalhado para depuração
      debugPrint('🔄 [OnboardingSyncService] Atualizando UserStats:');
      debugPrint('   - cigarros por dia: ${updatedValues['cigarettes_per_day']}');
      debugPrint('   - cigarros por maço: ${updatedValues['cigarettes_per_pack']}');
      debugPrint('   - preço do maço: ${updatedValues['pack_price']}¢');
      debugPrint('   - moeda: ${updatedValues['currency_code']}');
      
      // Verificar se temos valores para atualizar
      if (updatedValues.isEmpty) {
        debugPrint('⚠️ [OnboardingSyncService] Sem valores válidos para atualizar!');
        return;
      }

      // Executar SQL para atualizar UserStats
      try {
        final response = await Supabase.instance.client
            .from('user_stats')
            .update(updatedValues)
            .eq('user_id', userStats.userId)
            .select();
        
        // Log da resposta do update para verificar se funcionou
        debugPrint('📊 [OnboardingSyncService] Resposta da atualização:');
        if (response.isNotEmpty) {
          final updatedData = response[0];
          debugPrint('   - ID: ${updatedData['id']}');
          debugPrint('   - packPrice atualizado: ${updatedData['pack_price']}¢');
          debugPrint('   - cigarettesPerPack atualizado: ${updatedData['cigarettes_per_pack']}');
        } else {
          debugPrint('⚠️ [OnboardingSyncService] Update não retornou dados, verificando se funcionou...');
        }
      } catch (sqlError) {
        debugPrint('❌ [OnboardingSyncService] Erro SQL: $sqlError');
        
        // Tentar abordagem alternativa com update direto
        debugPrint('🔄 [OnboardingSyncService] Tentando atualização direta com SQL...');
        
        try {
          // Executar uma RPC direta para garantir a atualização
          await Supabase.instance.client.rpc('update_user_stats_onboarding', params: {
            'user_id_param': userStats.userId,
            'cigarettes_per_day_param': updatedValues['cigarettes_per_day'],
            'cigarettes_per_pack_param': updatedValues['cigarettes_per_pack'],
            'pack_price_param': updatedValues['pack_price'],
            'currency_code_param': updatedValues['currency_code'],
          });
          
          debugPrint('✅ [OnboardingSyncService] Atualização via RPC concluída');
        } catch (rpcError) {
          debugPrint('❌ [OnboardingSyncService] Erro na RPC: $rpcError');
          // Se a RPC falhar, tentar uma última abordagem com SQL bruto
          try {
            // Usar a nova função RPC que criamos na migração
            await Supabase.instance.client.rpc(
              'sync_onboarding_to_user_stats',
              params: {
                'user_id_param': userStats.userId,
              },
            );
            debugPrint('✅ [OnboardingSyncService] Atualização via SQL direto concluída');
          } catch (finalError) {
            debugPrint('❌ [OnboardingSyncService] Todas as tentativas falharam: $finalError');
            throw finalError;
          }
        }
      }

      debugPrint('✅ [OnboardingSyncService] UserStats atualizado com dados do onboarding');
    } catch (e) {
      debugPrint('❌ [OnboardingSyncService] Erro ao atualizar UserStats: $e');
      rethrow;
    }
  }
}