import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum LocaleStatus { initial, loading, loaded, error }

class LocaleState extends Equatable {
  final LocaleStatus status;
  final Locale locale;
  final List<Locale> supportedLocales;
  final bool isInitialized;
  final bool isLanguageSelectionComplete;
  final String? errorMessage;

  const LocaleState({
    required this.status,
    required this.locale,
    required this.supportedLocales,
    required this.isInitialized,
    this.isLanguageSelectionComplete = false,
    this.errorMessage,
  });

  /// Factory method to create the initial state
  factory LocaleState.initial() => const LocaleState(
        status: LocaleStatus.initial,
        locale: Locale('en', 'US'),
        supportedLocales: [
          Locale('en', 'US'), // English (US) - default
          Locale('pt', 'BR'), // Portuguese (Brazil)
          Locale('es', 'ES'), // Spanish (Spain)
          Locale('fr', 'FR'), // French (France)
          Locale('it'), // Italian
          Locale('de'), // German
          Locale('nl'), // Dutch
          Locale('pl'), // Polish
        ],
        isInitialized: false,
        isLanguageSelectionComplete: false,
      );

  /// Returns a copy of the current state with the provided new values
  LocaleState copyWith({
    LocaleStatus? status,
    Locale? locale,
    List<Locale>? supportedLocales,
    bool? isInitialized,
    bool? isLanguageSelectionComplete,
    String? errorMessage,
  }) {
    return LocaleState(
      status: status ?? this.status,
      locale: locale ?? this.locale,
      supportedLocales: supportedLocales ?? this.supportedLocales,
      isInitialized: isInitialized ?? this.isInitialized,
      isLanguageSelectionComplete: isLanguageSelectionComplete ?? this.isLanguageSelectionComplete,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Returns the current language name for display
  String get currentLanguageName => getLanguageName(locale);

  /// Returns the language name for a given locale
  String getLanguageName(Locale locale) {
    // Para compatibilidade, verificamos primeiro pelo código e país
    String fullCode = '${locale.languageCode}_${locale.countryCode}';
    switch (fullCode) {
      case 'pt_BR':
        return 'Português (Brasil)';
      case 'en_US':
        return 'English (US)';
      case 'es_ES':
        return 'Español';
      case 'fr_FR':
        return 'Français';
    }
    
    // Se não encontrou com o código completo, tenta só o código do idioma
    switch (locale.languageCode) {
      case 'pt':
        return 'Português (Brasil)';
      case 'en':
        return 'English (US)';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'it':
        return 'Italiano';
      case 'de':
        return 'Deutsch';
      case 'nl':
        return 'Nederlands';
      case 'pl':
        return 'Polski';
      default:
        return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [
        status,
        locale,
        supportedLocales,
        isInitialized,
        isLanguageSelectionComplete,
        errorMessage,
      ];
}
