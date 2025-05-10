import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_bloc.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_event.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';

/// Widget para alternar entre temas (claro, escuro, sistema)
class ThemeSwitch extends StatelessWidget {
  final bool useIcons;
  
  const ThemeSwitch({
    this.useIcons = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final currentThemeMode = state.themeMode;
        
        if (useIcons) {
          return IconButton(
            icon: Icon(
              currentThemeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : currentThemeMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.brightness_auto,
              color: context.isDarkMode ? Colors.white : Colors.black87,
            ),
            tooltip: currentThemeMode == ThemeMode.dark
                ? 'Mudar para tema claro'
                : currentThemeMode == ThemeMode.light
                    ? 'Mudar para tema automático'
                    : 'Mudar para tema escuro',
            onPressed: () {
              _changeTheme(context, currentThemeMode);
            },
          );
        }
        
        return PopupMenuButton<ThemeMode>(
          initialValue: currentThemeMode,
          icon: Icon(
            currentThemeMode == ThemeMode.dark
                ? Icons.dark_mode
                : currentThemeMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.brightness_auto,
            color: context.isDarkMode ? Colors.white : Colors.black87,
          ),
          tooltip: 'Selecionar tema',
          onSelected: (ThemeMode mode) {
            context.read<ThemeBloc>().add(ChangeThemeMode(mode));
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Tema claro'),
                selected: currentThemeMode == ThemeMode.light,
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Tema escuro'),
                selected: currentThemeMode == ThemeMode.dark,
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: const Text('Automático'),
                selected: currentThemeMode == ThemeMode.system,
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _changeTheme(BuildContext context, ThemeMode currentThemeMode) {
    switch (currentThemeMode) {
      case ThemeMode.light:
        context.read<ThemeBloc>().add(const ChangeThemeMode(ThemeMode.system));
        break;
      case ThemeMode.system:
        context.read<ThemeBloc>().add(const ChangeThemeMode(ThemeMode.dark));
        break;
      case ThemeMode.dark:
        context.read<ThemeBloc>().add(const ChangeThemeMode(ThemeMode.light));
        break;
    }
  }
}

/// Widget para exibir uma tela de configurações de tema completa
class ThemeSettings extends StatelessWidget {
  const ThemeSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final currentThemeMode = state.themeMode;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Tema do aplicativo',
                style: context.titleStyle,
              ),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Tema claro'),
              secondary: const Icon(Icons.light_mode),
              value: ThemeMode.light,
              groupValue: currentThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  context.read<ThemeBloc>().add(ChangeThemeMode(value));
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Tema escuro'),
              secondary: const Icon(Icons.dark_mode),
              value: ThemeMode.dark,
              groupValue: currentThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  context.read<ThemeBloc>().add(ChangeThemeMode(value));
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Igual ao sistema'),
              secondary: const Icon(Icons.brightness_auto),
              value: ThemeMode.system,
              groupValue: currentThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  context.read<ThemeBloc>().add(ChangeThemeMode(value));
                }
              },
            ),
            
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'O tema do aplicativo será alterado imediatamente e sua preferência será salva para futuros acessos.',
                style: context.captionStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}