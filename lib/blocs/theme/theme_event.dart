import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar o tema
class InitializeTheme extends ThemeEvent {}

/// Evento para alterar o tema
class ChangeThemeMode extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// Evento para detectar e usar o tema do sistema
class UseSystemTheme extends ThemeEvent {}