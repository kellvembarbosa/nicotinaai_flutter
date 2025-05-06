import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingRepository {
  final _client = SupabaseConfig.client;
  
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
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return OnboardingModel.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.message.contains('No rows found')) {
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
          .single();
      
      return OnboardingModel.fromJson(response);
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
          .eq('id', onboarding.id!)
          .select()
          .single();
      
      return OnboardingModel.fromJson(response);
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
          .single();
      
      return OnboardingModel.fromJson(response);
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
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }
}