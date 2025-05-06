import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';

/// Classe utilitária para formatação e manipulação de valores monetários
class CurrencyUtils {
  /// Singleton
  static final CurrencyUtils _instance = CurrencyUtils._internal();
  factory CurrencyUtils() => _instance;
  CurrencyUtils._internal();

  /// Moeda padrão caso o usuário não tenha configurado
  static const String defaultCurrencyCode = 'BRL';
  static const String defaultCurrencySymbol = 'R\$';
  static const String defaultCurrencyLocale = 'pt_BR';

  /// Formata um valor monetário de acordo com as preferências do usuário
  /// [valueInCents] - O valor em centavos (formato de armazenamento)
  /// [user] - O usuário com informações de moeda
  String format(int valueInCents, {UserModel? user}) {
    final double valueInCurrency = valueInCents / 100.0;
    
    // Usar NumberFormat da biblioteca intl para formatação de números
    final formatter = NumberFormat.currency(
      symbol: user?.currencySymbol ?? defaultCurrencySymbol,
      decimalDigits: 2,
      locale: user?.currencyLocale ?? defaultCurrencyLocale,
    );
    
    // Formatar o valor
    return formatter.format(valueInCurrency);
  }
  
  /// Formata um valor monetário para exibição simplificada (sem casas decimais)
  /// Útil para resumos e estatísticas
  String formatCompact(int valueInCents, {UserModel? user}) {
    final double valueInCurrency = valueInCents / 100.0;
    
    // Usar NumberFormat da biblioteca intl para formatação de números sem casas decimais
    final formatter = NumberFormat.currency(
      symbol: user?.currencySymbol ?? defaultCurrencySymbol,
      decimalDigits: 0,  // Sem casas decimais para o formato compacto
      locale: user?.currencyLocale ?? defaultCurrencyLocale,
    );
    
    // Formatar o valor sem decimais
    return formatter.format(valueInCurrency);
  }
  
  /// Converte um valor em string para centavos (formato de armazenamento)
  /// [value] - O valor em formato de string (pode conter símbolos de moeda)
  int parseToCents(String value, {UserModel? user}) {
    // Remove símbolos de moeda e espaços
    String cleanValue = value.replaceAll(user?.currencySymbol ?? defaultCurrencySymbol, '')
        .replaceAll(' ', '')
        .trim();
    
    // Substitui separadores por formato que o double.parse entenda
    final decimalSeparator = _getDecimalSeparator(user?.currencyLocale ?? defaultCurrencyLocale);
    final thousandSeparator = _getThousandSeparator(user?.currencyLocale ?? defaultCurrencyLocale);
    
    if (decimalSeparator != '.') {
      cleanValue = cleanValue.replaceAll(thousandSeparator, '');
      cleanValue = cleanValue.replaceAll(decimalSeparator, '.');
    } else {
      cleanValue = cleanValue.replaceAll(thousandSeparator, '');
    }
    
    // Converte para centavos
    try {
      final double parsedValue = double.parse(cleanValue);
      return (parsedValue * 100).round();
    } catch (e) {
      // Em caso de erro de parsing, retorna zero
      return 0;
    }
  }
  
  /// Formata um valor usando a Locale atual (para moedas locais)
  String formatWithDeviceLocale(int valueInCents, {BuildContext? context}) {
    final locale = context != null 
        ? Localizations.localeOf(context).toString() 
        : PlatformDispatcher.instance.locale.toString();
    
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '', // Símbolo vazio para aplicar depois
    );
    
    final double valueInCurrency = valueInCents / 100.0;
    final String symbol = _getCurrencySymbolFromLocale(locale);
    
    return '$symbol ${formatter.format(valueInCurrency)}';
  }
  
  /// Detecta o separador decimal para uma determinada locale
  String _getDecimalSeparator(String locale) {
    try {
      final numberFormat = NumberFormat.decimalPattern(locale);
      return numberFormat.symbols.DECIMAL_SEP;
    } catch (e) {
      return '.'; // Valor padrão em caso de erro
    }
  }
  
  /// Detecta o separador de milhar para uma determinada locale
  String _getThousandSeparator(String locale) {
    try {
      final numberFormat = NumberFormat.decimalPattern(locale);
      return numberFormat.symbols.GROUP_SEP;
    } catch (e) {
      return ','; // Valor padrão em caso de erro
    }
  }
  
  /// Obtém o símbolo de moeda para uma determinada locale
  String _getCurrencySymbolFromLocale(String locale) {
    // Map de locales comuns para símbolos de moeda
    final Map<String, String> currencySymbols = {
      'pt_BR': 'R\$',
      'en_US': '\$',
      'en_GB': '£',
      'es_ES': '€',
      'fr_FR': '€',
      'de_DE': '€',
      'it_IT': '€',
      'ja_JP': '¥',
      'zh_CN': '¥',
    };
    
    return currencySymbols[locale] ?? defaultCurrencySymbol;
  }
  
  /// Detecta a locale do dispositivo
  static String detectDeviceLocale() {
    final localeString = PlatformDispatcher.instance.locale.toString();
    if (localeString.isEmpty) return defaultCurrencyLocale;
    return localeString;
  }
  
  /// Detecta o símbolo de moeda do dispositivo
  static String detectDeviceCurrencySymbol() {
    final locale = detectDeviceLocale();
    
    try {
      // Usar NumberFormat para obter o símbolo da moeda adequado para a locale
      final formatter = NumberFormat.currency(locale: locale);
      final symbol = formatter.currencySymbol;
      
      // Se o símbolo for obtido com sucesso, retorne-o
      if (symbol.isNotEmpty) {
        return symbol;
      }
    } catch (e) {
      // Em caso de erro, use o mapa de fallback
    }
    
    // Map de fallback para locales comuns
    final Map<String, String> currencySymbols = {
      'pt_BR': 'R\$',
      'en_US': '\$',
      'en_GB': '£',
      'es_ES': '€',
      'fr_FR': '€',
      'de_DE': '€',
      'it_IT': '€',
      'ja_JP': '¥',
      'zh_CN': '¥',
    };
    
    return currencySymbols[locale] ?? defaultCurrencySymbol;
  }
  
  /// Detecta o código da moeda do dispositivo
  static String detectDeviceCurrencyCode() {
    final locale = detectDeviceLocale();
    
    try {
      // Usar NumberFormat para obter o código da moeda adequado para a locale
      final formatter = NumberFormat.currency(locale: locale);
      final currency = formatter.currencyName;
      
      // Se o código for obtido com sucesso, retorne-o
      if (currency != null && currency.isNotEmpty) {
        return currency;
      }
    } catch (e) {
      // Em caso de erro, use o mapa de fallback
    }
    
    // Map de fallback para locales comuns
    final Map<String, String> currencyCodes = {
      'pt_BR': 'BRL',
      'en_US': 'USD',
      'en_GB': 'GBP',
      'es_ES': 'EUR',
      'fr_FR': 'EUR',
      'de_DE': 'EUR',
      'it_IT': 'EUR',
      'ja_JP': 'JPY',
      'zh_CN': 'CNY',
    };
    
    return currencyCodes[locale] ?? defaultCurrencyCode;
  }
}