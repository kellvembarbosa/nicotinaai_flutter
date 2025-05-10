import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart' as bloc_auth;
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';
import 'package:nicotinaai_flutter/utils/currency_utils.dart';
import 'package:nicotinaai_flutter/utils/supported_currencies.dart';

import 'currency_event.dart';
import 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final AuthBloc _authBloc;
  final AuthRepository _authRepository;

  CurrencyBloc({
    required AuthBloc authBloc,
    required AuthRepository authRepository,
  }) : _authBloc = authBloc,
       _authRepository = authRepository,
       super(CurrencyState.initial()) {
    on<InitializeCurrency>(_onInitializeCurrency);
    on<ChangeCurrency>(_onChangeCurrency);
    on<DetectDeviceCurrency>(_onDetectDeviceCurrency);
  }

  Future<void> _onInitializeCurrency(
    InitializeCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    if (state.isInitialized) return;

    emit(CurrencyState.loading());

    try {
      CurrencyInfo? selectedCurrency;
      
      // Verifica se o usuário está autenticado
      final authState = _authBloc.state;
      if (authState.status == bloc_auth.AuthStatus.authenticated && authState.user != null) {
        final user = authState.user!;
        
        // Verifica se o usuário já tem uma moeda definida
        if (user.currencyCode != null) {
          selectedCurrency = SupportedCurrencies.getByCurrencyCode(user.currencyCode!);
        }
      }

      // Se não estiver autenticado ou não tiver moeda definida, detecta a moeda do dispositivo
      // O método _detectDeviceCurrency já inclui o fallback para moeda padrão
      selectedCurrency = selectedCurrency ?? _detectDeviceCurrency();

      emit(CurrencyState.loaded(selectedCurrency));
    } catch (e) {
      debugPrint('❌ [CurrencyBloc] Error initializing currency: $e');
      emit(CurrencyState.error(e.toString()));
    }
  }

  Future<void> _onChangeCurrency(
    ChangeCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(state.copyWith(
      status: CurrencyStatus.loading,
    ));

    try {
      // Salva a nova moeda no estado
      emit(state.copyWith(
        status: CurrencyStatus.loaded,
        currency: event.currency,
      ));

      // Verifica se o usuário está autenticado para atualizar o perfil
      final authState = _authBloc.state;
      if (authState.status == bloc_auth.AuthStatus.authenticated && authState.user != null) {
        final user = authState.user!;
        final updatedUser = user.copyWith(
          currencyCode: event.currency.code,
          currencySymbol: event.currency.symbol,
        );

        // Atualiza o perfil do usuário
        await _authRepository.updateUserProfile(updatedUser);
      }
    } catch (e) {
      debugPrint('❌ [CurrencyBloc] Error changing currency: $e');
      // Mantém a moeda anterior em caso de erro
      emit(state.copyWith(
        status: CurrencyStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDetectDeviceCurrency(
    DetectDeviceCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    final deviceCurrency = _detectDeviceCurrency();
    emit(state.copyWith(
      status: CurrencyStatus.loaded,
      currency: deviceCurrency,
    ));
  }

  /// Detecta a moeda do dispositivo
  CurrencyInfo _detectDeviceCurrency() {
    final deviceLocale = PlatformDispatcher.instance.locale.toString();
    
    // Tenta encontrar a moeda pela locale do dispositivo
    final currency = SupportedCurrencies.getByLocale(deviceLocale);
    if (currency != null) {
      return currency;
    }
    
    // Se não encontrar, usa a moeda padrão
    return SupportedCurrencies.defaultCurrency;
  }

  /// Formata um valor monetário de acordo com a moeda atual
  String format(int valueInCents) {
    return CurrencyUtils().format(
      valueInCents, 
      currencyCode: state.currencyCode,
      currencySymbol: state.currencySymbol,
      currencyLocale: state.currencyLocale,
    );
  }
  
  /// Formata um valor monetário de forma compacta (sem casas decimais)
  String formatCompact(int valueInCents) {
    return CurrencyUtils().formatCompact(
      valueInCents, 
      currencyCode: state.currencyCode,
      currencySymbol: state.currencySymbol,
      currencyLocale: state.currencyLocale,
    );
  }
  
  /// Converte um valor em string para centavos
  int parseToCents(String value) {
    return CurrencyUtils().parseToCents(
      value,
      currencyCode: state.currencyCode,
      currencySymbol: state.currencySymbol,
      currencyLocale: state.currencyLocale,
    );
  }
}