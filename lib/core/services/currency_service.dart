import 'package:signals/signals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nicotinaai_flutter/utils/supported_currencies.dart';
import 'package:nicotinaai_flutter/utils/currency_utils.dart';

/// CurrencyService manages currency settings for the application using Signals.
/// 
/// This service handles currency selection, persistence, and provides reactive 
/// access to currency-related data.
class CurrencyService {
  // Constants for storage
  static const String _currencyCodePrefsKey = 'currency_code';
  static const String _currencySymbolPrefsKey = 'currency_symbol';
  
  // Signals for currency data
  final currencyCode = Signal<String>('USD');
  final currencySymbol = Signal<String>('\$');
  
  // Computed signal that combines both code and symbol
  late final currencyInfo = computed(() {
    return {
      'code': currencyCode.value,
      'symbol': currencySymbol.value
    };
  });
  
  // Private constructor for singleton
  CurrencyService._();
  
  // Singleton instance
  static final CurrencyService _instance = CurrencyService._();
  
  // Factory constructor to return singleton instance
  factory CurrencyService() => _instance;
  
  /// Initialize the currency service by loading saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load saved currency or detect from device
    final savedCode = prefs.getString(_currencyCodePrefsKey);
    final savedSymbol = prefs.getString(_currencySymbolPrefsKey);
    
    if (savedCode != null && savedSymbol != null) {
      currencyCode.value = savedCode;
      currencySymbol.value = savedSymbol;
    } else {
      // Detect device currency
      final deviceCode = CurrencyUtils.detectDeviceCurrencyCode();
      final deviceSymbol = CurrencyUtils.detectDeviceCurrencySymbol();
      
      currencyCode.value = deviceCode;
      currencySymbol.value = deviceSymbol;
      
      // Save the detected values
      await saveCurrencyPreference(deviceCode, deviceSymbol);
    }
  }
  
  /// Change the currency setting
  Future<void> setCurrency(String code, String symbol) async {
    currencyCode.value = code;
    currencySymbol.value = symbol;
    
    // Persist the setting
    await saveCurrencyPreference(code, symbol);
  }
  
  /// Set currency by map from supported currencies
  Future<void> setCurrencyByMap(Map<String, String> currencyMap) async {
    if (currencyMap.containsKey('code') && currencyMap.containsKey('symbol')) {
      await setCurrency(currencyMap['code']!, currencyMap['symbol']!);
    }
  }
  
  /// Save currency preferences
  Future<void> saveCurrencyPreference(String code, String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyCodePrefsKey, code);
    await prefs.setString(_currencySymbolPrefsKey, symbol);
  }
  
  /// Reset to device currency
  Future<void> resetToDeviceCurrency() async {
    final deviceCode = CurrencyUtils.detectDeviceCurrencyCode();
    final deviceSymbol = CurrencyUtils.detectDeviceCurrencySymbol();
    
    await setCurrency(deviceCode, deviceSymbol);
  }
  
  /// Format amount according to current currency
  String formatAmount(int amountInCents) {
    return CurrencyUtils.format(amountInCents, currencySymbol.value);
  }
  
  /// Format amount in compact form
  String formatCompact(int amountInCents) {
    return CurrencyUtils.formatCompact(amountInCents, currencySymbol.value);
  }
  
  /// Parse string to cents
  int parseToCents(String value) {
    return CurrencyUtils.parseToCents(value);
  }
  
  /// Get the supported currencies list
  List<Map<String, String>> get supportedCurrencies {
    return SupportedCurrencies.currencies;
  }
}

// Global instance for easy access
final currencyService = CurrencyService();