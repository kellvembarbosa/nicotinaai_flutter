import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_bloc.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_event.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_event.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_bloc.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_state.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_bloc.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_state.dart'
    as locale_state;
import 'package:nicotinaai_flutter/blocs/theme/theme_bloc.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_state.dart' as theme_state;
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/core/theme/theme_settings.dart';
import 'package:nicotinaai_flutter/features/tracking/screens/statistics_dashboard_screen.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';
import 'package:nicotinaai_flutter/services/feedback_trigger_service.dart';
import 'package:nicotinaai_flutter/utils/url_launcher_utils.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification service and state
  final NotificationService _notificationService = NotificationService();
  final FeedbackTriggerService _feedbackService = FeedbackTriggerService();
  bool _areNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    
    // Track screen visit for feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _feedbackService.trackScreenVisit();
      _checkForFeedback();
    });
  }
  
  // Check if feedback should be shown
  Future<void> _checkForFeedback() async {
    if (mounted) {
      await _feedbackService.checkAndTriggerFeedback(context);
    }
  }

  Future<void> _loadNotificationSettings() async {
    _areNotificationsEnabled =
        await _notificationService.areNotificationsEnabled();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // Usar BLoCs em vez de Providers
    final authState = context.watch<AuthBloc>().state;
    final themeState = context.watch<ThemeBloc>().state;
    final localeState = context.watch<LocaleBloc>().state;
    final user = authState.user;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(localizations.settings, style: context.titleStyle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.backgroundColor,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Perfil do usuário
            Card(
              elevation: context.isDarkMode ? 0 : 2,
              color: context.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side:
                    context.isDarkMode
                        ? BorderSide(color: context.borderColor)
                        : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: context.primaryColor.withOpacity(0.2),
                      child: Text(
                        user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? localizations.profile,
                      style: context.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    Text(
                      user?.email ?? 'email@exemplo.com',
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: context.subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Track edit profile button click
                        final analyticsBloc = context.read<AnalyticsBloc>();
                        analyticsBloc.add(
                          const TrackCustomEvent(
                            'edit_profile_clicked',
                            parameters: {'source': 'settings_screen'},
                          ),
                        );

                        // Navegar para tela de edição de perfil
                        // Use GoRouter.of instead of context.push to avoid assertion error
                        final router = GoRouter.of(context);
                        if (router != null) {
                          router.push(AppRoutes.editProfile.path);
                        } else {
                          print('⚠️ Router not found in context!');
                          // Fallback navigation
                          Navigator.pushNamed(context, AppRoutes.editProfile.path);
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(localizations.editProfile),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Seção de configurações do app
            _buildSectionHeader(context, localizations.appSettings),
            _buildSettingItem(
              context,
              localizations.notifications,
              localizations.manageNotifications,
              Icons.notifications_outlined,
              onTap: () async {
                final newValue = !_areNotificationsEnabled;

                // Track notification toggle
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(
                  TrackCustomEvent(
                    'notifications_toggled',
                    parameters: {
                      'new_state': newValue ? 'enabled' : 'disabled',
                      'method': 'tile_tap',
                    },
                  ),
                );

                await _notificationService.setNotificationsEnabled(newValue);
                setState(() {
                  _areNotificationsEnabled = newValue;
                });
              },
              trailing: Switch(
                value: _areNotificationsEnabled,
                onChanged: (value) async {
                  // Track notification toggle
                  final analyticsBloc = context.read<AnalyticsBloc>();
                  analyticsBloc.add(
                    TrackCustomEvent(
                      'notifications_toggled',
                      parameters: {
                        'new_state': value ? 'enabled' : 'disabled',
                        'method': 'switch',
                      },
                    ),
                  );

                  await _notificationService.setNotificationsEnabled(value);
                  setState(() {
                    _areNotificationsEnabled = value;
                  });
                },
              ),
            ),

            // Configuração de tema com ThemeSettings
            Card(
              elevation: 0,
              color: context.cardColor,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: context.borderColor),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: ThemeSettings(),
              ),
            ),

            _buildSettingItem(
              context,
              localizations.language,
              localizations.changeLanguage,
              Icons.language_outlined,
              onTap: () {
                // Track language settings clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(
                  TrackCustomEvent(
                    'language_settings_clicked',
                    parameters: {
                      'current_language':
                          context.read<LocaleBloc>().state.currentLanguageName,
                      'source': 'settings_screen',
                    },
                  ),
                );

                // Use GoRouter.of instead of context.push to avoid assertion error
                final router = GoRouter.of(context);
                if (router != null) {
                  router.push(AppRoutes.languageBloc.path);
                } else {
                  print('⚠️ Router not found in context!');
                  // Fallback navigation
                  Navigator.pushNamed(context, AppRoutes.languageBloc.path);
                }
              },
              trailing: BlocBuilder<LocaleBloc, locale_state.LocaleState>(
                builder:
                    (context, state) => Text(
                      state.currentLanguageName,
                      style: context.textTheme.bodySmall!.copyWith(
                        color: context.subtitleColor,
                      ),
                    ),
              ),
            ),
            _buildSettingItem(
              context,
              localizations.theme,
              localizations.theme,
              Icons.color_lens_outlined,
              onTap: () {
                // Track theme settings clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                final themeState = context.read<ThemeBloc>().state;
                analyticsBloc.add(
                  TrackCustomEvent(
                    'theme_settings_clicked',
                    parameters: {
                      'current_theme': _getThemeModeName(
                        themeState.themeMode,
                        localizations,
                      ),
                      'source': 'settings_screen',
                    },
                  ),
                );

                // Use GoRouter.of instead of context.push to avoid assertion error
                final router = GoRouter.of(context);
                if (router != null) {
                  router.push(AppRoutes.themeBloc.path);
                } else {
                  print('⚠️ Router not found in context!');
                  // Fallback navigation
                  Navigator.pushNamed(context, AppRoutes.themeBloc.path);
                }
              },
              trailing: BlocBuilder<ThemeBloc, theme_state.ThemeState>(
                builder:
                    (context, state) => Text(
                      _getThemeModeName(state.themeMode, localizations),
                      style: context.textTheme.bodySmall!.copyWith(
                        color: context.subtitleColor,
                      ),
                    ),
              ),
            ),

            const SizedBox(height: 24),

            // Seção de rastreamento de hábitos
            _buildSectionHeader(context, localizations.habitTracking),
            _buildSettingItem(
              context,
              localizations.cigarettesPerDay,
              localizations.configureHabits,
              Icons.smoking_rooms_outlined,
              onTap: () {
                // Track cigarettes per day settings clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(
                  const TrackCustomEvent(
                    'cigarettes_per_day_settings_clicked',
                    parameters: {'source': 'settings_screen'},
                  ),
                );

                // Navegar para tela de configuração de cigarros por dia
                // Use GoRouter.of instead of context.push to avoid assertion error
                final router = GoRouter.of(context);
                if (router != null) {
                  router.push(AppRoutes.cigarettesPerDay.path);
                } else {
                  print('⚠️ Router not found in context!');
                  // Fallback navigation
                  Navigator.pushNamed(context, AppRoutes.cigarettesPerDay.path);
                }
              },
            ),
            _buildSettingItem(
              context,
              localizations.packPrice,
              localizations.setPriceForCalculations,
              Icons.attach_money_outlined,
              onTap: () {
                // Track pack price settings clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(
                  const TrackCustomEvent(
                    'pack_price_settings_clicked',
                    parameters: {'source': 'settings_screen'},
                  ),
                );

                // Navegar para tela de configuração de preço do maço
                // Use GoRouter.of instead of context.push to avoid assertion error
                final router = GoRouter.of(context);
                if (router != null) {
                  router.push(AppRoutes.packPrice.path);
                } else {
                  print('⚠️ Router not found in context!');
                  // Fallback navigation
                  Navigator.pushNamed(context, AppRoutes.packPrice.path);
                }
              },
            ),
            _buildSettingItem(
              context,
              localizations.currency,
              localizations.setCurrencyForCalculations,
              Icons.currency_exchange,
              onTap: () {
                // Track currency settings clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                final currencyState = context.read<CurrencyBloc>().state;
                analyticsBloc.add(
                  TrackCustomEvent(
                    'currency_settings_clicked',
                    parameters: {
                      'current_currency': currencyState.currencyCode,
                      'source': 'settings_screen',
                    },
                  ),
                );

                // Use GoRouter.of instead of context.push to avoid assertion error
                final router = GoRouter.of(context);
                if (router != null) {
                  router.push(AppRoutes.currencyBloc.path);
                } else {
                  print('⚠️ Router not found in context!');
                  // Fallback navigation
                  Navigator.pushNamed(context, AppRoutes.currencyBloc.path);
                }
              },
              trailing: BlocBuilder<CurrencyBloc, CurrencyState>(
                builder:
                    (context, state) => Text(
                      state.currencyCode,
                      style: context.textTheme.bodySmall!.copyWith(
                        color: context.subtitleColor,
                      ),
                    ),
              ),
            ),
            _buildSettingItem(
              context,
              localizations.startDate,
              localizations.whenYouQuitSmoking,
              Icons.calendar_today_outlined,
              onTap: () {
                // Track quit date settings clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(
                  const TrackCustomEvent(
                    'quit_date_settings_clicked',
                    parameters: {'source': 'settings_screen'},
                  ),
                );

                // Navegar para tela de configuração de data de parada
                // Use GoRouter.of instead of context.push to avoid assertion error
                final router = GoRouter.of(context);
                if (router != null) {
                  router.push(AppRoutes.quitDate.path);
                } else {
                  print('⚠️ Router not found in context!');
                  // Fallback navigation
                  Navigator.pushNamed(context, AppRoutes.quitDate.path);
                }
              },
            ),

            const SizedBox(height: 24),

            // Seção de conta
            _buildSectionHeader(context, localizations.account),
            _buildSettingItem(
              context,
              localizations.resetPassword,
              localizations.changePassword,
              Icons.lock_outline,
              onTap: () {
                // Track reset password clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(
                  const TrackCustomEvent(
                    'reset_password_clicked',
                    parameters: {'source': 'settings_screen'},
                  ),
                );

                // Navegar para tela de redefinição de senha
                // Use GoRouter.of instead of context.push to avoid assertion error
                final router = GoRouter.of(context);
                if (router != null) {
                  router.push(AppRoutes.resetPassword.path);
                } else {
                  print('⚠️ Router not found in context!');
                  // Fallback navigation
                  Navigator.pushNamed(context, AppRoutes.resetPassword.path);
                }
              },
            ),
            _buildSettingItem(
              context,
              localizations.deleteAccount,
              localizations.permanentlyRemoveAccount,
              Icons.delete_outline,
              onTap: () {
                // Track delete account clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(
                  const TrackCustomEvent(
                    'delete_account_clicked',
                    parameters: {'source': 'settings_screen'},
                  ),
                );

                // Navegar para tela de exclusão de conta
                // Use GoRouter.of instead of context.push to avoid assertion error
                final router = GoRouter.of(context);
                if (router != null) {
                  router.push(AppRoutes.deleteAccount.path);
                } else {
                  print('⚠️ Router not found in context!');
                  // Fallback navigation
                  Navigator.pushNamed(context, AppRoutes.deleteAccount.path);
                }
              },
              textColor: Colors.red,
              iconColor: Colors.red,
            ),
            _buildSettingItem(
              context,
              localizations.logout,
              localizations.logoutFromAccount,
              Icons.logout,
              onTap: () async {
                // Track logout clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(
                  const TrackCustomEvent(
                    'logout_clicked',
                    parameters: {'source': 'settings_screen'},
                  ),
                );

                // Confirmar logout
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        backgroundColor: context.cardColor,
                        title: Text(
                          localizations.logoutTitle,
                          style: context.textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.contentColor,
                          ),
                        ),
                        content: Text(
                          localizations.logoutConfirmation,
                          style: context.bodyStyle,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              localizations.cancel,
                              style: context.textTheme.labelLarge!.copyWith(
                                color:
                                    context.isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // Track logout confirmed
                              final analyticsBloc =
                                  context.read<AnalyticsBloc>();
                              analyticsBloc.add(
                                const TrackCustomEvent(
                                  'logout_confirmed',
                                  parameters: {'source': 'settings_screen'},
                                ),
                              );

                              // First close the dialog
                              Navigator.of(context).pop();
                              
                              // Perform a direct logout using a combination of Repository and navigation
                              try {
                                // Get the AuthBloc
                                final authBloc = context.read<AuthBloc>();
                                
                                // Declare the subscription variable before assigning it
                                late final StreamSubscription subscription;
                                
                                // Add a listener to the AuthBloc to detect when logout is complete
                                subscription = authBloc.stream.listen((state) {
                                  if (!state.isAuthenticated && context.mounted) {
                                    print('✅ Logout complete, user is no longer authenticated.');
                                    
                                    // Cancel subscription to avoid memory leaks
                                    subscription.cancel();
                                    
                                    // Manual navigation after logout is complete
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      print('🚀 Manually navigating to login screen after logout');
                                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login.path, (route) => false);
                                    });
                                  }
                                });
                                
                                // Trigger the logout
                                authBloc.add(const LogoutRequested());
                                print('🔄 Logout requested, waiting for completion...');
                                
                              } catch (e) {
                                print('⚠️ Error during logout: $e');
                                // Fallback navigation on error
                                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login.path, (route) => false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(localizations.logout),
                          ),
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                );
              },
              textColor: context.primaryColor,
              iconColor: context.primaryColor,
            ),

            const SizedBox(height: 24),

            // Seção de sobre
            _buildSectionHeader(context, localizations.about),
            _buildSettingItem(
              context,
              localizations.privacyPolicy,
              localizations.readPrivacyPolicy,
              Icons.privacy_tip_outlined,
              onTap: () {
                // Track privacy policy clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(
                  const TrackCustomEvent(
                    'privacy_policy_clicked',
                    parameters: {'source': 'settings_screen'},
                  ),
                );

                // Abrir política de privacidade
                UrlLauncherUtils.launchURL(
                  'https://nicotina.ai/legal/privacy-policy',
                  context: context,
                );
              },
            ),
            _buildSettingItem(
              context,
              localizations.termsOfUse,
              localizations.viewTermsOfUse,
              Icons.description_outlined,
              onTap: () {
                // Track terms of use clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(
                  const TrackCustomEvent(
                    'terms_of_use_clicked',
                    parameters: {'source': 'settings_screen'},
                  ),
                );

                // Abrir termos de uso
                UrlLauncherUtils.launchURL(
                  'https://nicotina.ai/legal/terms-of-service',
                  context: context,
                );
              },
            ),
            _buildSettingItem(
              context,
              localizations.aboutApp,
              localizations.appInfo,
              Icons.info_outline,
              onTap: () {
                // Track about app clicked
                final analyticsBloc = context.read<AnalyticsBloc>();
                analyticsBloc.add(
                  const TrackCustomEvent(
                    'about_app_clicked',
                    parameters: {'source': 'settings_screen'},
                  ),
                );

                // Mostrar diálogo com informações
                _showAboutDialog(context);
              },
            ),

            const SizedBox(height: 16),

            // Versão do app
            Center(
              child: Text(
                localizations.version('1.0.0'),
                style: context.textTheme.bodySmall!.copyWith(
                  color: context.subtitleColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: context.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: context.contentColor,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
  }) {
    return Card(
      elevation: 0,
      color: context.cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor ?? context.subtitleColor),
        title: Text(
          title,
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w500,
            color: textColor ?? context.contentColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: context.textTheme.bodySmall!.copyWith(
            color: context.subtitleColor,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.subtitleColor,
            ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: context.cardColor,
            title: Text(
              localizations.deleteAccountTitle,
              style: context.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: context.contentColor,
              ),
            ),
            content: Text(
              localizations.deleteAccountConfirmation,
              style: context.bodyStyle,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  localizations.cancel,
                  style: context.textTheme.labelLarge!.copyWith(
                    color:
                        context.isDarkMode
                            ? Colors.grey[300]
                            : Colors.grey[700],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implementar exclusão de conta
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  localizations.delete,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }

  // Retorna o nome localizado do modo de tema
  String _getThemeModeName(ThemeMode mode, AppLocalizations localizations) {
    switch (mode) {
      case ThemeMode.light:
        return localizations.light;
      case ThemeMode.dark:
        return localizations.dark;
      case ThemeMode.system:
        return localizations.system;
    }
  }

  void _showAboutDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AboutDialog(
            applicationName: localizations.appName,
            applicationVersion: '1.0.0',
            applicationIcon: const FlutterLogo(size: 50),
            applicationLegalese:
                '© 2024 Nicotina,AI. Todos os direitos reservados.',
            children: [
              const SizedBox(height: 16),
              Text(
                'Nicotina,AI é uma aplicação de apoio para parar de fumar, que usa inteligência artificial para ajudar no monitoramento de hábitos e fornecer suporte personalizado durante o processo de parar de fumar.',
                style: context.bodyStyle,
              ),
            ],
          ),
    );
  }
}
