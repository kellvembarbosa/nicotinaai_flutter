/// Define a class to represent a currency
class CurrencyInfo {
  /// The ISO 4217 currency code
  final String code;
  
  /// The currency symbol
  final String symbol;
  
  /// The display name of the currency
  final String name;
  
  /// The locale string associated with this currency
  final String locale;
  
  /// The number of decimal places typically shown (usually 2)
  final int decimalDigits;
  
  /// Constructor
  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.locale,
    this.decimalDigits = 2,
  });
}

/// A list of supported currencies in the app
class SupportedCurrencies {
  /// Private constructor to prevent instantiation
  SupportedCurrencies._();
  
  /// Brazilian Real
  static const CurrencyInfo brl = CurrencyInfo(
    code: 'BRL',
    symbol: 'R\$',
    name: 'Brazilian Real',
    locale: 'pt_BR',
  );
  
  /// US Dollar
  static const CurrencyInfo usd = CurrencyInfo(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    locale: 'en_US',
  );
  
  /// Euro
  static const CurrencyInfo eur = CurrencyInfo(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    locale: 'es_ES',
  );
  
  /// British Pound
  static const CurrencyInfo gbp = CurrencyInfo(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    locale: 'en_GB',
  );
  
  /// Argentine Peso
  static const CurrencyInfo ars = CurrencyInfo(
    code: 'ARS',
    symbol: '\$',
    name: 'Argentine Peso',
    locale: 'es_AR',
  );
  
  /// Mexican Peso
  static const CurrencyInfo mxn = CurrencyInfo(
    code: 'MXN',
    symbol: '\$',
    name: 'Mexican Peso',
    locale: 'es_MX',
  );
  
  /// Canadian Dollar
  static const CurrencyInfo cad = CurrencyInfo(
    code: 'CAD',
    symbol: '\$',
    name: 'Canadian Dollar',
    locale: 'en_CA',
  );
  
  /// Japanese Yen
  static const CurrencyInfo jpy = CurrencyInfo(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    locale: 'ja_JP',
    decimalDigits: 0, // Yen typically doesn't use decimal places
  );
  
  /// Chinese Yuan
  static const CurrencyInfo cny = CurrencyInfo(
    code: 'CNY',
    symbol: '¥',
    name: 'Chinese Yuan',
    locale: 'zh_CN',
  );
  
  /// Australian Dollar
  static const CurrencyInfo aud = CurrencyInfo(
    code: 'AUD',
    symbol: '\$',
    name: 'Australian Dollar',
    locale: 'en_AU',
  );

  /// List of all supported currencies
  static const List<CurrencyInfo> all = [
    brl,
    usd,
    eur,
    gbp,
    ars,
    mxn,
    cad,
    jpy,
    cny,
    aud,
  ];
  
  /// Get a currency by its code
  static CurrencyInfo? getByCurrencyCode(String code) {
    try {
      return all.firstWhere((currency) => currency.code == code.toUpperCase());
    } catch (e) {
      return null; // Return null if currency not found
    }
  }
  
  /// Get a currency by its locale
  static CurrencyInfo? getByLocale(String locale) {
    try {
      return all.firstWhere((currency) => currency.locale == locale);
    } catch (e) {
      return null; // Return null if locale not found
    }
  }
  
  /// Get default currency (Brazilian Real)
  static CurrencyInfo get defaultCurrency => brl;
}