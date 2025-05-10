import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_event.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final String _localeKey = 'app_locale';

  LocaleBloc() : super(LocaleState.initial()) {
    on<InitializeLocale>(_onInitializeLocale);
    on<ChangeLocale>(_onChangeLocale);
    on<ResetToDefaultLocale>(_onResetToDefaultLocale);
  }

  /// Loads the saved locale from SharedPreferences
  Future<void> _onInitializeLocale(
    InitializeLocale event,
    Emitter<LocaleState> emit,
  ) async {
    emit(state.copyWith(status: LocaleStatus.loading));

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);

      if (savedLocale != null) {
        final parts = savedLocale.split('_');
        if (parts.length == 2) {
          final newLocale = Locale(parts[0], parts[1]);
          
          // Check if the locale is supported
          if (state.supportedLocales.contains(newLocale)) {
            emit(state.copyWith(
              status: LocaleStatus.loaded,
              locale: newLocale,
              isInitialized: true,
            ));
            return;
          }
        }
      }

      // If no valid locale was found, set default (English) and save it
      const defaultLocale = Locale('en', 'US');
      await prefs.setString(_localeKey, 'en_US');
      
      emit(state.copyWith(
        status: LocaleStatus.loaded,
        locale: defaultLocale,
        isInitialized: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LocaleStatus.error,
        errorMessage: 'Failed to load locale: $e',
      ));
    }
  }

  /// Changes the current locale and saves to SharedPreferences
  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<LocaleState> emit,
  ) async {
    // If the locale is not supported, do nothing
    if (!state.supportedLocales.contains(event.locale)) return;

    try {
      // Update state first for responsive UI
      emit(state.copyWith(
        status: LocaleStatus.loaded,
        locale: event.locale,
      ));

      // Save the preference to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _localeKey,
        '${event.locale.languageCode}_${event.locale.countryCode}',
      );
    } catch (e) {
      emit(state.copyWith(
        status: LocaleStatus.error,
        errorMessage: 'Failed to change locale: $e',
      ));
    }
  }

  /// Resets to English (default locale) and saves to SharedPreferences
  Future<void> _onResetToDefaultLocale(
    ResetToDefaultLocale event,
    Emitter<LocaleState> emit,
  ) async {
    try {
      const defaultLocale = Locale('en', 'US');
      
      // Update state first for responsive UI
      emit(state.copyWith(
        status: LocaleStatus.loaded,
        locale: defaultLocale,
      ));

      // Save the preference to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, 'en_US');
    } catch (e) {
      emit(state.copyWith(
        status: LocaleStatus.error,
        errorMessage: 'Failed to reset locale: $e',
      ));
    }
  }
}
