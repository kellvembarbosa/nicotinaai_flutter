import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciar o modo de desenvolvedor
class DeveloperModeProvider extends ChangeNotifier {
  bool _isDeveloperModeEnabled = false;
  final String _key = 'developer_mode_enabled';

  /// Retorna se o modo desenvolvedor está ativado
  bool get isDeveloperModeEnabled => _isDeveloperModeEnabled;

  /// Verifica se o aplicativo está em modo de desenvolvimento
  bool get isInDevelopmentMode => kDebugMode || kProfileMode;

  /// Inicializa o provider a partir das preferências salvas
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDeveloperModeEnabled = prefs.getBool(_key) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar configuração de modo desenvolvedor: $e');
    }
  }

  /// Ativa ou desativa o modo desenvolvedor
  Future<void> toggleDeveloperMode() async {
    try {
      _isDeveloperModeEnabled = !_isDeveloperModeEnabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, _isDeveloperModeEnabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar configuração de modo desenvolvedor: $e');
    }
  }
}