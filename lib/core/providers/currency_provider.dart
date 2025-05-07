import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/utils/currency_utils.dart';
import 'package:nicotinaai_flutter/utils/supported_currencies.dart';

/// Provider para gerenciar a moeda usada no aplicativo
class CurrencyProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  /// Construtor que recebe o AuthProvider como dependência
  CurrencyProvider({required AuthProvider authProvider}) 
      : _authProvider = authProvider;
  
  /// A moeda atual selecionada pelo usuário
  CurrencyInfo? _currentCurrency;
  
  /// Status de inicialização do provider
  bool _isInitialized = false;
  
  /// Retorna se o provider foi inicializado
  bool get isInitialized => _isInitialized;
  
  /// Inicializa o provider com a moeda do usuário atual
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (_authProvider.isAuthenticated && _authProvider.currentUser != null) {
      final user = _authProvider.currentUser!;
      
      // Verifica se o usuário já tem uma moeda definida
      if (user.currencyCode != null) {
        _currentCurrency = SupportedCurrencies.getByCurrencyCode(user.currencyCode!);
      }
      
      // Se não, tenta detectar a moeda do dispositivo
      if (_currentCurrency == null) {
        _currentCurrency = _detectDeviceCurrency();
      }
    } else {
      // Se não estiver autenticado, usa a moeda do dispositivo
      _currentCurrency = _detectDeviceCurrency();
    }
    
    // Se nenhuma moeda foi detectada, usa a moeda padrão
    _currentCurrency ??= SupportedCurrencies.defaultCurrency;
    
    _isInitialized = true;
    notifyListeners();
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
  
  /// Retorna a moeda atual selecionada pelo usuário ou a moeda padrão
  CurrencyInfo get currentCurrency => 
      _currentCurrency ?? SupportedCurrencies.defaultCurrency;
  
  /// Retorna o código da moeda atual
  String get currencyCode => currentCurrency.code;
  
  /// Retorna o símbolo da moeda atual
  String get currencySymbol => currentCurrency.symbol;
  
  /// Retorna a locale da moeda atual
  String get currencyLocale => currentCurrency.locale;
  
  /// Altera a moeda usada pelo usuário
  Future<void> changeCurrency(CurrencyInfo newCurrency) async {
    _currentCurrency = newCurrency;
    
    // Se o usuário estiver autenticado, atualiza o perfil no Supabase
    if (_authProvider.isAuthenticated && _authProvider.currentUser != null) {
      final updatedUser = _authProvider.currentUser!.withCurrency(newCurrency);
      await _authProvider.updateUserProfile(updatedUser);
    }
    
    notifyListeners();
  }
  
  /// Formata um valor monetário de acordo com a moeda atual
  String format(int valueInCents) {
    return CurrencyUtils().format(
      valueInCents, 
      user: _authProvider.currentUser,
    );
  }
  
  /// Formata um valor monetário de forma compacta (sem casas decimais)
  String formatCompact(int valueInCents) {
    return CurrencyUtils().formatCompact(
      valueInCents, 
      user: _authProvider.currentUser,
    );
  }
  
  /// Converte um valor em string para centavos
  int parseToCents(String value) {
    return CurrencyUtils().parseToCents(
      value,
      user: _authProvider.currentUser,
    );
  }
  
  /// Retorna a lista de moedas suportadas
  List<CurrencyInfo> get supportedCurrencies => SupportedCurrencies.all;
}