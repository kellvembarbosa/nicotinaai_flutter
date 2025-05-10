import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_event.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final String _localeKey = 'app_locale';

  LocaleBloc() : super(LocaleState.initial()) {
    on<InitializeLocale>(_onInitializeLocale);
    on<ChangeLocale>(_onChangeLocale);
    on<ResetToDefaultLocale>(_onResetToDefaultLocale);
  }

  /// Loads the saved locale from SharedPreferences and Supabase
  Future<void> _onInitializeLocale(
    InitializeLocale event,
    Emitter<LocaleState> emit,
  ) async {
    emit(state.copyWith(status: LocaleStatus.loading));

    try {
      // First check if we can get the locale from Supabase (this takes precedence)
      String? savedLocale;
      
      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;
        
        if (user != null) {
          // Try to get user preferences from Supabase
          final response = await supabase
              .from('user_preferences')
              .select('locale')
              .eq('user_id', user.id)
              .single()
              .catchError((e) => null);
          
          if (response != null && response['locale'] != null) {
            savedLocale = response['locale'] as String;
            print('✅ Loaded locale from Supabase: $savedLocale');
          }
        }
      } catch (supabaseError) {
        // Just log the error but continue with SharedPreferences
        print('⚠️ Error loading locale from Supabase: $supabaseError');
      }
      
      // If we couldn't get locale from Supabase, try SharedPreferences
      if (savedLocale == null) {
        final prefs = await SharedPreferences.getInstance();
        savedLocale = prefs.getString(_localeKey);
        
        if (savedLocale != null) {
          print('✅ Loaded locale from SharedPreferences: $savedLocale');
        }
      }

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
            
            // Make sure SharedPreferences is in sync
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_localeKey, savedLocale);
            
            return;
          }
        }
      }

      // If no valid locale was found, set default (English) and save it
      const defaultLocale = Locale('en', 'US');
      await _saveLocaleToPreferences(defaultLocale);
      
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
  
  /// Helper to save locale to SharedPreferences and Supabase
  Future<void> _saveLocaleToPreferences(Locale locale) async {
    final localeString = '${locale.languageCode}_${locale.countryCode}';
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, localeString);
    
    // Try to save to Supabase
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        await supabase.from('user_preferences').upsert({
          'user_id': user.id,
          'locale': localeString,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      }
    } catch (e) {
      // Just log the error
      print('⚠️ Failed to save locale to Supabase: $e');
    }
  }

  /// Changes the current locale and saves to SharedPreferences and Supabase
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

      // Use helper to save the locale
      await _saveLocaleToPreferences(event.locale);
    } catch (e) {
      emit(state.copyWith(
        status: LocaleStatus.error,
        errorMessage: 'Failed to change locale: $e',
      ));
    }
  }

  /// Resets to English (default locale) and saves to SharedPreferences and Supabase
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

      // Use helper to save the locale
      await _saveLocaleToPreferences(defaultLocale);
    } catch (e) {
      emit(state.copyWith(
        status: LocaleStatus.error,
        errorMessage: 'Failed to reset locale: $e',
      ));
    }
  }
}
