import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/core/theme/theme_provider.dart';

/// Widget para exibir uma tela de configurações de tema completa
class ThemeSettings extends StatelessWidget {
  const ThemeSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentThemeMode = themeProvider.themeMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tema do aplicativo',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: context.contentColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildThemeOption(
          context,
          'Tema claro',
          'Interface com cores claras',
          Icons.light_mode,
          ThemeMode.light,
          currentThemeMode,
          themeProvider,
        ),
        const SizedBox(height: 8),
        _buildThemeOption(
          context,
          'Tema escuro',
          'Interface escura para ambientes com pouca luz',
          Icons.dark_mode,
          ThemeMode.dark,
          currentThemeMode,
          themeProvider,
        ),
        const SizedBox(height: 8),
        _buildThemeOption(
          context,
          'Automático',
          'Segue as configurações do sistema',
          Icons.brightness_auto,
          ThemeMode.system,
          currentThemeMode,
          themeProvider,
        ),
        const SizedBox(height: 16),
        Text(
          'O tema será alterado imediatamente e sua preferência será salva para futuros acessos.',
          style: context.textTheme.bodySmall!.copyWith(
            color: context.subtitleColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    ThemeMode mode,
    ThemeMode currentMode,
    ThemeProvider provider,
  ) {
    final isSelected = mode == currentMode;
    
    return InkWell(
      onTap: () {
        provider.setThemeMode(mode);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? context.primaryColor.withOpacity(context.isDarkMode ? 0.15 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: context.primaryColor)
              : null,
        ),
        child: Row(
          children: [
            Radio<ThemeMode>(
              value: mode,
              groupValue: currentMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  provider.setThemeMode(value);
                }
              },
              activeColor: context.primaryColor,
            ),
            const SizedBox(width: 8),
            Icon(
              icon,
              color: isSelected 
                  ? context.primaryColor
                  : context.isDarkMode
                      ? Colors.grey[300]
                      : Colors.grey[700],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.contentColor,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall!.copyWith(
                      color: context.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}