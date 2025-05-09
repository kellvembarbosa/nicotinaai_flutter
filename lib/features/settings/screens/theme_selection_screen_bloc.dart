import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_bloc.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_event.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class ThemeSelectionScreenBloc extends StatelessWidget {
  static const String routeName = '/settings/theme_bloc';

  const ThemeSelectionScreenBloc({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocConsumer<ThemeBloc, ThemeState>(
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: AppBar(
            backgroundColor: context.backgroundColor,
            title: Text(
              localizations.theme,
              style: context.titleStyle,
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.themeDescription,
                    style: context.textTheme.bodyLarge!.copyWith(
                      color: context.subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Opção de tema claro
                  _buildThemeOption(
                    context,
                    title: localizations.lightTheme,
                    description: localizations.lightThemeDescription,
                    icon: Icons.light_mode,
                    isSelected: state.themeMode == ThemeMode.light,
                    onTap: () {
                      context.read<ThemeBloc>().add(
                        const ChangeThemeMode(ThemeMode.light),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Opção de tema escuro
                  _buildThemeOption(
                    context,
                    title: localizations.darkTheme,
                    description: localizations.darkThemeDescription,
                    icon: Icons.dark_mode,
                    isSelected: state.themeMode == ThemeMode.dark,
                    onTap: () {
                      context.read<ThemeBloc>().add(
                        const ChangeThemeMode(ThemeMode.dark),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Opção de tema do sistema
                  _buildThemeOption(
                    context,
                    title: localizations.systemTheme,
                    description: localizations.systemThemeDescription,
                    icon: Icons.settings_brightness,
                    isSelected: state.themeMode == ThemeMode.system,
                    onTap: () {
                      context.read<ThemeBloc>().add(UseSystemTheme());
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: isSelected
          ? context.primaryColor.withOpacity(0.1)
          : context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? context.primaryColor
              : context.borderColor,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: context.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: context.textTheme.bodySmall!.copyWith(
                        color: context.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: context.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}