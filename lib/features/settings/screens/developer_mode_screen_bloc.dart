import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/developer_mode/developer_mode_bloc.dart';
import 'package:nicotinaai_flutter/blocs/developer_mode/developer_mode_event.dart';
import 'package:nicotinaai_flutter/blocs/developer_mode/developer_mode_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class DeveloperModeScreenBloc extends StatelessWidget {
  const DeveloperModeScreenBloc({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(localizations.developerMode, style: context.titleStyle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.backgroundColor,
      ),
      body: BlocConsumer<DeveloperModeBloc, DeveloperModeState>(
        listener: (context, state) {
          if (state.status == DeveloperModeStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? localizations.errorOccurred),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    color: context.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: context.borderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.developer,
                            style: context.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.enableDebugging,
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: context.subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SwitchListTile(
                            title: Text(
                              localizations.developerMode,
                              style: context.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.w500,
                                color: context.contentColor,
                              ),
                            ),
                            subtitle: Text(
                              localizations.enableDebugging,
                              style: context.textTheme.bodySmall!.copyWith(
                                color: context.subtitleColor,
                              ),
                            ),
                            value: state.isDeveloperModeEnabled,
                            onChanged: (_) {
                              context.read<DeveloperModeBloc>().add(ToggleDeveloperMode());
                            },
                            activeColor: context.primaryColor,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 8),
                          if (state.isDeveloperModeEnabled) ...[
                            const Divider(),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'Debug Info',
                                style: context.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: context.contentColor,
                                ),
                              ),
                              subtitle: Text(
                                'Status: ${state.status.name}\nInitialized: ${state.isInitialized}',
                                style: context.textTheme.bodySmall!.copyWith(
                                  color: context.subtitleColor,
                                ),
                              ),
                              leading: const Icon(Icons.info_outline),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.isInDevelopmentMode) ...[
                    Card(
                      elevation: 0,
                      color: context.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: context.borderColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Environment Info',
                              style: context.textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.contentColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(context, 'Debug Mode', state.isInDevelopmentMode.toString()),
                            const SizedBox(height: 8),
                            _buildInfoRow(context, 'State Status', state.status.toString()),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              context, 
                              'Developer Mode', 
                              state.isDeveloperModeEnabled ? 'Enabled' : 'Disabled'
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w500,
            color: context.contentColor,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium!.copyWith(
            color: context.subtitleColor,
          ),
        ),
      ],
    );
  }
}