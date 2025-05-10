import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/utils/supported_currencies.dart';

enum CurrencyStatus {
  initial,
  loading,
  loaded,
  error,
}

class CurrencyState extends Equatable {
  final CurrencyStatus status;
  final CurrencyInfo? currency;
  final String? errorMessage;
  final bool isInitialized;

  const CurrencyState({
    this.status = CurrencyStatus.initial,
    this.currency,
    this.errorMessage,
    this.isInitialized = false,
  });

  /// Estado inicial do CurrencyBloc
  factory CurrencyState.initial() {
    return const CurrencyState(
      status: CurrencyStatus.initial,
      isInitialized: false,
    );
  }

  /// Estado carregando
  factory CurrencyState.loading() {
    return const CurrencyState(
      status: CurrencyStatus.loading,
      isInitialized: false,
    );
  }

  /// Estado carregado com sucesso
  factory CurrencyState.loaded(CurrencyInfo currency) {
    return CurrencyState(
      status: CurrencyStatus.loaded,
      currency: currency,
      isInitialized: true,
    );
  }

  /// Estado de erro
  factory CurrencyState.error(String message) {
    return CurrencyState(
      status: CurrencyStatus.error,
      errorMessage: message,
      isInitialized: false,
    );
  }

  /// Cria uma cópia do estado com novos valores
  CurrencyState copyWith({
    CurrencyStatus? status,
    CurrencyInfo? currency,
    String? errorMessage,
    bool? isInitialized,
  }) {
    return CurrencyState(
      status: status ?? this.status,
      currency: currency ?? this.currency,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  /// Verifica se há um erro
  bool get hasError => status == CurrencyStatus.error && errorMessage != null;

  /// Retorna a moeda atual ou a moeda padrão
  CurrencyInfo get currentCurrency => currency ?? SupportedCurrencies.defaultCurrency;

  /// Retorna o código da moeda atual
  String get currencyCode => currentCurrency.code;

  /// Retorna o símbolo da moeda atual
  String get currencySymbol => currentCurrency.symbol;

  /// Retorna a locale da moeda atual
  String get currencyLocale => currentCurrency.locale;

  /// Retorna a lista de moedas suportadas
  List<CurrencyInfo> get supportedCurrencies => SupportedCurrencies.all;

  @override
  List<Object?> get props => [status, currency, errorMessage, isInitialized];
}