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

      // Buscar estatísticas do usuário
      final userStats = await _trackingRepository.getUserStats();
      
      // Se não existir estatísticas, cria um novo objeto com dados do onboarding
      if (userStats == null) {
        debugPrint('⚠️ [OnboardingSyncService] UserStats não encontrado, criando novo com dados do onboarding');
        await _createUserStatsFromOnboarding(onboarding);
        return true;
      }

      // Atualizar valores nas estatísticas existentes
      await _updateUserStatsFromOnboarding(userStats, onboarding);
      return true;
    } catch (e) {
      debugPrint('❌ [OnboardingSyncService] Erro ao sincronizar dados: $e');
      return false;
    }
  }

  /// Cria um novo UserStats com dados do onboarding
  Future<void> _createUserStatsFromOnboarding(OnboardingModel onboarding) async {
    try {
      // Dados obrigatórios para UserStats a partir do onboarding
      final initialUserStats = {
        'user_id': onboarding.userId,
        'cigarettes_per_day': onboarding.cigarettesPerDayCount,
        'cigarettes_per_pack': onboarding.cigarettesPerPack,
        'pack_price': onboarding.packPrice,
        'currency_code': onboarding.packPriceCurrency,
        'money_saved': 0,
        'cigarettes_avoided': 0,
        'cigarettes_smoked': 0,
        'smoking_records_count': 0,
        'cravings_count': 0,
        'cravings_resisted': 0,
        'current_streak_days': 0,
      };

      // Executar SQL para criar UserStats
      await Supabase.instance.client
          .from('user_stats')
          .insert(initialUserStats);

      debugPrint('✅ [OnboardingSyncService] Novo UserStats criado com dados do onboarding');
    } catch (e) {
      debugPrint('❌ [OnboardingSyncService] Erro ao criar UserStats: $e');
      rethrow;
    }
  }

  /// Atualiza UserStats existente com dados do onboarding
  Future<void> _updateUserStatsFromOnboarding(UserStats userStats, OnboardingModel onboarding) async {
    try {
      // Valores a serem atualizados
      final updatedValues = {
        'cigarettes_per_day': onboarding.cigarettesPerDayCount,
        'cigarettes_per_pack': onboarding.cigarettesPerPack,
        'pack_price': onboarding.packPrice,
        'currency_code': onboarding.packPriceCurrency,
      };

      // Log detalhado para depuração
      debugPrint('🔄 [OnboardingSyncService] Atualizando UserStats:');
      debugPrint('   - cigarros por dia: ${onboarding.cigarettesPerDayCount}');
      debugPrint('   - cigarros por maço: ${onboarding.cigarettesPerPack}');
      debugPrint('   - preço do maço: ${onboarding.packPrice}¢');
      debugPrint('   - moeda: ${onboarding.packPriceCurrency}');

      // Executar SQL para atualizar UserStats
      await Supabase.instance.client
          .from('user_stats')
          .update(updatedValues)
          .eq('user_id', userStats.userId);

      debugPrint('✅ [OnboardingSyncService] UserStats atualizado com dados do onboarding');
    } catch (e) {
      debugPrint('❌ [OnboardingSyncService] Erro ao atualizar UserStats: $e');
      rethrow;
    }
  }
}