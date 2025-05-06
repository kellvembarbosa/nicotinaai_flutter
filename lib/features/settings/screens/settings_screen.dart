import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Configurações', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), centerTitle: true, elevation: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Perfil do usuário
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Text(
                        user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(user?.name ?? 'Usuário', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(user?.email ?? 'email@exemplo.com', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navegar para tela de edição de perfil
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Perfil'),
                      style: ElevatedButton.styleFrom(
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
            _buildSectionHeader(context, 'Configurações do Aplicativo'),
            _buildSettingItem(
              context,
              'Notificações',
              'Gerenciar notificações',
              Icons.notifications_outlined,
              onTap: () {
                // Navegação para configurações de notificações
              },
            ),
            _buildSettingItem(
              context,
              'Tema',
              'Alternar entre temas claro e escuro',
              Icons.palette_outlined,
              onTap: () {
                // Alternar tema
              },
              trailing: Switch(
                value: false, // Tema claro por padrão
                onChanged: (value) {
                  // Alternar tema
                },
              ),
            ),
            _buildSettingItem(
              context,
              'Idioma',
              'Alterar o idioma do aplicativo',
              Icons.language_outlined,
              onTap: () {
                // Navegação para configurações de idioma
              },
            ),

            const SizedBox(height: 24),

            // Seção de rastreamento de hábitos
            _buildSectionHeader(context, 'Rastreamento de Hábitos'),
            _buildSettingItem(
              context,
              'Cigarros por dia antes de parar',
              'Configure seus hábitos anteriores',
              Icons.smoking_rooms_outlined,
              onTap: () {
                // Abrir diálogo para configurar cigarros por dia
              },
            ),
            _buildSettingItem(
              context,
              'Preço do maço',
              'Definir o preço para cálculos de economia',
              Icons.attach_money_outlined,
              onTap: () {
                // Abrir diálogo para configurar preço
              },
            ),
            _buildSettingItem(
              context,
              'Data de início',
              'Quando você parou de fumar',
              Icons.calendar_today_outlined,
              onTap: () {
                // Abrir seletor de data
              },
            ),

            const SizedBox(height: 24),

            // Seção de conta
            _buildSectionHeader(context, 'Conta'),
            _buildSettingItem(
              context,
              'Redefinir senha',
              'Altere sua senha de acesso',
              Icons.lock_outline,
              onTap: () {
                // Navegação para redefinição de senha
              },
            ),
            _buildSettingItem(
              context,
              'Excluir conta',
              'Remover permanentemente sua conta',
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
              'Sair',
              'Desconectar da sua conta',
              Icons.logout,
              onTap: () async {
                // Confirmar logout
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Sair da conta', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        content: Text('Tem certeza que deseja sair da sua conta?', style: GoogleFonts.poppins()),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar', style: GoogleFonts.poppins())),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await authProvider.signOut();
                              if (context.mounted) {
                                context.go('/login');
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                            child: Text('Sair', style: GoogleFonts.poppins(color: Colors.white)),
                          ),
                        ],
                      ),
                );
              },
              textColor: Theme.of(context).primaryColor,
              iconColor: Theme.of(context).primaryColor,
            ),

            const SizedBox(height: 24),

            // Seção de sobre
            _buildSectionHeader(context, 'Sobre'),
            _buildSettingItem(
              context,
              'Política de Privacidade',
              'Leia nossa política de privacidade',
              Icons.privacy_tip_outlined,
              onTap: () {
                // Abrir política de privacidade
              },
            ),
            _buildSettingItem(
              context,
              'Termos de Uso',
              'Veja os termos de uso do aplicativo',
              Icons.description_outlined,
              onTap: () {
                // Abrir termos de uso
              },
            ),
            _buildSettingItem(
              context,
              'Sobre o App',
              'Versão e informações do aplicativo',
              Icons.info_outline,
              onTap: () {
                // Mostrar diálogo com informações
                _showAboutDialog(context);
              },
            ),

            const SizedBox(height: 16),

            // Versão do app
            Center(child: Text('Versão 1.0.0', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
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
      color: Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor ?? Colors.grey[600]),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: textColor)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Excluir Conta', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text(
              'Tem certeza que deseja excluir sua conta? Esta ação é irreversível e todos os seus dados serão perdidos.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar', style: GoogleFonts.poppins())),
              ElevatedButton(
                onPressed: () {
                  // Implementar exclusão de conta
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Excluir', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AboutDialog(
            applicationName: 'NicotinaAI',
            applicationVersion: '1.0.0',
            applicationIcon: FlutterLogo(size: 50),
            applicationLegalese: '© 2024 NicotinaAI. Todos os direitos reservados.',
            children: [
              const SizedBox(height: 16),
              Text(
                'NicotinaAI é uma aplicação de apoio para parar de fumar, que usa inteligência artificial para ajudar no monitoramento de hábitos e fornecer suporte personalizado durante o processo de parar de fumar.',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
    );
  }
}
