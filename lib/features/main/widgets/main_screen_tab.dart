import 'package:flutter/material.dart';

/// A classe MainScreenTab é um InheritedWidget que gerencia a navegação entre abas
/// do aplicativo, permitindo que widgets filhos acessem e modifiquem a aba atual.
class MainScreenTab extends InheritedWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const MainScreenTab({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
    required Widget child,
  }) : super(key: key, child: child);

  /// Obtém a instância mais próxima de MainScreenTab acima na árvore de widgets
  static MainScreenTab of(BuildContext context) {
    final MainScreenTab? result = context.dependOnInheritedWidgetOfExactType<MainScreenTab>();
    assert(result != null, 'Nenhum MainScreenTab encontrado no contexto');
    return result!;
  }

  /// Verifica se o widget deve ser reconstruído quando o InheritedWidget é atualizado
  @override
  bool updateShouldNotify(MainScreenTab oldWidget) {
    return oldWidget.currentIndex != currentIndex;
  }

  /// Muda para uma aba específica
  void changeTab(int index) {
    onTabChanged(index);
  }

  /// Muda para a aba Home (índice 0)
  void navigateToHome() {
    onTabChanged(0);
  }

  /// Muda para a aba Achievements (índice 1)
  void navigateToAchievements() {
    onTabChanged(1);
  }

  /// Muda para a aba Settings (índice 2)
  void navigateToSettings() {
    onTabChanged(2);
  }

  /// Retorna se a aba atual é a Home
  bool get isHomeTab => currentIndex == 0;

  /// Retorna se a aba atual é a Achievements
  bool get isAchievementsTab => currentIndex == 1;

  /// Retorna se a aba atual é a Settings
  bool get isSettingsTab => currentIndex == 2;
}