import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/core/theme/theme_provider.dart';
import 'package:nicotinaai_flutter/core/theme/theme_settings.dart';
import 'package:nicotinaai_flutter/core/localization/locale_provider.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localizations = AppLocalizations.of(context);
    final user = authProvider.currentUser;

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
                side: context.isDarkMode 
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
                        // Navegar para tela de edição de perfil
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(localizations.editProfile),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              onTap: () {
                // Navegação para configurações de notificações
              },
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
                // Navegação para configurações de idioma
                context.push(AppRoutes.language.path);
              },
              trailing: Text(
                localeProvider.currentLanguageName,
                style: context.textTheme.bodySmall!.copyWith(
                  color: context.subtitleColor,
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
                // Abrir diálogo para configurar cigarros por dia
              },
            ),
            _buildSettingItem(
              context,
              localizations.packPrice,
              localizations.setPriceForCalculations,
              Icons.attach_money_outlined,
              onTap: () {
                // Abrir diálogo para configurar preço
              },
            ),
            _buildSettingItem(
              context,
              localizations.startDate,
              localizations.whenYouQuitSmoking,
              Icons.calendar_today_outlined,
              onTap: () {
                // Abrir seletor de data
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
                // Navegação para redefinição de senha
              },
            ),
            _buildSettingItem(
              context,
              localizations.deleteAccount,
              localizations.permanentlyRemoveAccount,
              Icons.delete_outline,
              onTap: () {
                // Mostrar diálogo de confirmação
                _showDeleteAccountDialog(context);
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
                                color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await authProvider.signOut();
                              if (context.mounted) {
                                context.go('/login');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(localizations.logout),
                          ),
                        ],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                // Abrir política de privacidade
              },
            ),
            _buildSettingItem(
              context,
              localizations.termsOfUse,
              localizations.viewTermsOfUse,
              Icons.description_outlined,
              onTap: () {
                // Abrir termos de uso
              },
            ),
            _buildSettingItem(
              context,
              localizations.aboutApp,
              localizations.appInfo,
              Icons.info_outline,
              onTap: () {
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
        leading: Icon(
          icon,
          color: iconColor ?? context.subtitleColor,
        ),
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
        trailing: trailing ?? Icon(
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
                    color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implementar exclusão de conta
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(localizations.delete, style: const TextStyle(color: Colors.white)),
              ),
            ],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
    );
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
            applicationLegalese: '© 2024 NicotinaAI. Todos os direitos reservados.',
            children: [
              const SizedBox(height: 16),
              Text(
                'NicotinaAI é uma aplicação de apoio para parar de fumar, que usa inteligência artificial para ajudar no monitoramento de hábitos e fornecer suporte personalizado durante o processo de parar de fumar.',
                style: context.bodyStyle,
              ),
            ],
          ),
    );
  }
}