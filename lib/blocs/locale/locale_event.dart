import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the locale from saved preferences
class InitializeLocale extends LocaleEvent {}

/// Event to change the current locale
class ChangeLocale extends LocaleEvent {
  final Locale locale;

  const ChangeLocale(this.locale);

  @override
  List<Object?> get props => [locale];
}

/// Event to reset to English (default locale)
class ResetToDefaultLocale extends LocaleEvent {}