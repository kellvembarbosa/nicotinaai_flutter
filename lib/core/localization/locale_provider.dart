import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');
  final String _localeKey = 'app_locale';

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;

  // Idiomas suportados pelo aplicativo
  List<Locale> get supportedLocales => const [
        Locale('en', 'US'), // Inglês (EUA) - primeiro por ser o idioma padrão
        Locale('pt', 'BR'), // Português (Brasil)
      ];

  // Carrega o idioma salvo das preferências
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        _locale = Locale(parts[0], parts[1]);
        notifyListeners();
      }
    } else {
      // Se não houver idioma salvo, definir inglês explicitamente e salvar
      _locale = const Locale('en', 'US');
      await prefs.setString(_localeKey, 'en_US');
    }
  }
  
  // Limpa as preferências de idioma e redefine para inglês
  Future<void> resetToDefaultLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, 'en_US');
    _locale = const Locale('en', 'US');
    notifyListeners();
  }

  // Altera o idioma do aplicativo
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _locale = locale;
    notifyListeners();
    
    // Salva a preferência de idioma
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, '${locale.languageCode}_${locale.countryCode}');
  }

  // Retorna o nome do idioma para exibição
  String getLanguageName(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode}') {
      case 'pt_BR':
        return 'Português (Brasil)';
      case 'en_US':
        return 'English (US)';
      default:
        return 'Unknown';
    }
  }

  // Retorna o nome do idioma atual
  String get currentLanguageName => getLanguageName(_locale);
}