import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// Extensão simples para `BuildContext` que fornece acesso
/// à instância atual de AppLocalizations com fallbacks para strings ausentes
extension AppLocalizationsExtension on BuildContext {
  /// Obtém a instância localizada de _StringsFallback
  _StringsFallback get strings {
    final l10n = AppLocalizations.of(this);
    return _StringsFallback(l10n);
  }
}

/// Classe de utilitário que armazena fallbacks para todas as strings
class _StringsFallback {
  final AppLocalizations l10n;

  _StringsFallback(this.l10n);

  // Strings já existentes - passadas diretamente do AppLocalizations
  String get appName => l10n.appName;
  String get loading => 'Loading...'; // Fallback se não existir
  String get pageNotFound => l10n.pageNotFound;
  String get welcomeToApp => l10n.welcomeToApp;
  String get selectLanguage => l10n.selectLanguage;
  String get continueButton => l10n.continueButton;
  String get motivationalMessage => 'Keep going! You\'re doing great!';

  // Outras strings com fallbacks
  String get login => 'Login';
  String get loginToContinue => 'Login to continue';
  String get email => 'Email';
  String get password => 'Password';
  String get forgotPassword => 'Forgot Password';
  String get register => 'Register';
  String get welcomeBack => 'Welcome back';
}