import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum LocaleStatus { initial, loading, loaded, error }

class LocaleState extends Equatable {
  final LocaleStatus status;
  final Locale locale;
  final List<Locale> supportedLocales;
  final bool isInitialized;
  final String? errorMessage;

  const LocaleState({
    required this.status,
    required this.locale,
    required this.supportedLocales,
    required this.isInitialized,
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
        ],
        isInitialized: false,
      );

  /// Returns a copy of the current state with the provided new values
  LocaleState copyWith({
    LocaleStatus? status,
    Locale? locale,
    List<Locale>? supportedLocales,
    bool? isInitialized,
    String? errorMessage,
  }) {
    return LocaleState(
      status: status ?? this.status,
      locale: locale ?? this.locale,
      supportedLocales: supportedLocales ?? this.supportedLocales,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Returns the current language name for display
  String get currentLanguageName => getLanguageName(locale);

  /// Returns the language name for a given locale
  String getLanguageName(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode}') {
      case 'pt_BR':
        return 'Português (Brasil)';
      case 'en_US':
        return 'English (US)';
      case 'es_ES':
        return 'Español';
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
        errorMessage,
      ];
}
