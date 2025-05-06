import 'package:flutter/material.dart';
import 'dart:ui';

/// Extensão que fornece acesso fácil a cores tema e estilos
extension AppTheme on BuildContext {
  /// Acesso à instância de ThemeData
  ThemeData get theme => Theme.of(this);
  
  /// Acesso ao ColorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Acesso ao TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Verifica se está no modo escuro
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Cores primárias e variações
  Color get primaryColor => colorScheme.primary;
  Color get primaryLight => isDarkMode 
      ? HSLColor.fromColor(colorScheme.primary).withLightness(0.6).toColor()
      : HSLColor.fromColor(colorScheme.primary).withLightness(0.7).toColor();
  Color get primaryDark => HSLColor.fromColor(colorScheme.primary).withLightness(0.3).toColor();
  
  /// Cores para cartões e containers com efeitos visual
  Color get cardColor => Theme.of(this).cardTheme.color ?? 
      (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white);
  
  /// Cor de plano de fundo
  Color get backgroundColor => colorScheme.background;
  
  /// Cor de superfície (para cartões, diálogos)
  Color get surfaceColor => colorScheme.surface;
  
  /// Cor para textos e ícones em fundos claros
  Color get contentColor => isDarkMode ? Colors.white : Colors.black;
  
  /// Cor para textos secundários/subtítulos
  Color get subtitleColor => isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
  
  /// Cor para bordas de elementos
  Color get borderColor => isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[300]!;
  
  /// Cor para elementos com destaque sutil
  Color get highlightColor => isDarkMode 
      ? colorScheme.primary.withOpacity(0.15) 
      : colorScheme.primary.withOpacity(0.1);
  
  /// Decoração para criar um efeito de vidro fosco (blur)
  BoxDecoration get frostedGlassDecoration {
    return BoxDecoration(
      color: isDarkMode 
          ? Colors.white.withOpacity(0.05) 
          : Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDarkMode 
            ? Colors.white.withOpacity(0.1) 
            : Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
    );
  }
  
  /// Cria um widget com efeito de vidro fosco (blur)
  Widget frostedGlass({
    required Widget child,
    double blur = 10.0,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.4) 
                : Colors.white.withOpacity(0.4),
            borderRadius: borderRadius,
            border: Border.all(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
  
  /// Decoração padrão para cartões
  BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor),
      boxShadow: isDarkMode ? [] : [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  /// Estilo para títulos principais
  TextStyle get headlineStyle => textTheme.headlineMedium!.copyWith(
    color: contentColor,
    fontWeight: FontWeight.bold,
  );
  
  /// Estilo para títulos médios
  TextStyle get titleStyle => textTheme.titleLarge!.copyWith(
    color: contentColor,
    fontWeight: FontWeight.w600,
  );
  
  /// Estilo para subtítulos
  TextStyle get subtitleStyle => textTheme.titleMedium!.copyWith(
    color: subtitleColor,
    fontWeight: FontWeight.w500,
  );
  
  /// Estilo para texto de corpo principal
  TextStyle get bodyStyle => textTheme.bodyLarge!.copyWith(
    color: contentColor,
  );
  
  /// Estilo para texto secundário
  TextStyle get captionStyle => textTheme.bodySmall!.copyWith(
    color: subtitleColor,
  );
}