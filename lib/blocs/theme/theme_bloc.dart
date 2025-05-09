import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_constants.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {

  ThemeBloc() : super(ThemeState.initial()) {
    on<InitializeTheme>(_onInitializeTheme);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<UseSystemTheme>(_onUseSystemTheme);
  }

  Future<void> _onInitializeTheme(
    InitializeTheme event,
    Emitter<ThemeState> emit,
  ) async {
    if (state.isInitialized) return;

    emit(ThemeState.loading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(ThemeConstants.themeKey);

      ThemeMode themeMode = ThemeMode.system;
      if (savedTheme != null) {
        switch (savedTheme) {
          case ThemeConstants.lightTheme:
            themeMode = ThemeMode.light;
            break;
          case ThemeConstants.darkTheme:
            themeMode = ThemeMode.dark;
            break;
          case ThemeConstants.systemTheme:
          default:
            themeMode = ThemeMode.system;
            break;
        }
      }

      emit(ThemeState.loaded(themeMode));
      _updateStatusBar();
    } catch (e) {
      emit(ThemeState.error(e.toString()));
    }
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeMode event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: ThemeStatus.loading,
      ));

      final prefs = await SharedPreferences.getInstance();
      
      String themeString;
      switch (event.themeMode) {
        case ThemeMode.light:
          themeString = ThemeConstants.lightTheme;
          break;
        case ThemeMode.dark:
          themeString = ThemeConstants.darkTheme;
          break;
        case ThemeMode.system:
        default:
          themeString = ThemeConstants.systemTheme;
          break;
      }
      
      await prefs.setString(ThemeConstants.themeKey, themeString);
      
      emit(state.copyWith(
        status: ThemeStatus.loaded,
        themeMode: event.themeMode,
      ));
      
      _updateStatusBar();
    } catch (e) {
      emit(state.copyWith(
        status: ThemeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUseSystemTheme(
    UseSystemTheme event,
    Emitter<ThemeState> emit,
  ) async {
    add(ChangeThemeMode(ThemeMode.system));
  }

  /// Atualiza a barra de status com base no tema atual
  void _updateStatusBar() {
    final isDark = state.isDarkMode;
    
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? Colors.black : Colors.white,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }
}