import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/craving/craving_bloc.dart';
import 'package:nicotinaai_flutter/blocs/craving/craving_event.dart';
import 'package:nicotinaai_flutter/blocs/smoking_record/smoking_record_bloc.dart';
import 'package:nicotinaai_flutter/blocs/smoking_record/smoking_record_event.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_bloc.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_event.dart';

/// Gerenciador de eventos do roteador
/// Responsável por coordenar ações entre diferentes blocs
class RouterEvents {
  /// Limpa todos os dados de usuário em todos os BLoCs
  /// Deve ser chamado quando o usuário faz logout
  static void clearAllUserData(BuildContext context) {
    if (kDebugMode) {
      print('🧹 [RouterEvents] Limpando todos os dados de usuário...');
    }
    
    try {
      // Limpar dados de cravings
      if (context.read<CravingBloc>() != null) {
        context.read<CravingBloc>().add(ClearCravingsRequested());
        if (kDebugMode) {
          print('✅ [RouterEvents] Dados de cravings limpos');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [RouterEvents] Erro ao limpar cravings: $e');
      }
    }
    
    try {
      // Limpar dados de registros de fumo
      if (context.read<SmokingRecordBloc>() != null) {
        context.read<SmokingRecordBloc>().add(ClearSmokingRecordsRequested());
        if (kDebugMode) {
          print('✅ [RouterEvents] Dados de registros de fumo limpos');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [RouterEvents] Erro ao limpar registros de fumo: $e');
      }
    }
    
    try {
      // Limpar dados de tracking
      if (context.read<TrackingBloc>() != null) {
        context.read<TrackingBloc>().add(ResetTrackingData());
        if (kDebugMode) {
          print('✅ [RouterEvents] Dados de tracking limpos');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [RouterEvents] Erro ao limpar tracking: $e');
      }
    }
    
    try {
      // Limpar dados de conquistas
      if (context.read<AchievementBloc>() != null) {
        context.read<AchievementBloc>().add(ResetAchievements());
        if (kDebugMode) {
          print('✅ [RouterEvents] Dados de conquistas limpos');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [RouterEvents] Erro ao limpar conquistas: $e');
      }
    }
    
    if (kDebugMode) {
      print('✅ [RouterEvents] Todos os dados de usuário foram limpos');
    }
  }
}