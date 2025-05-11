import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_event.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_state.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/settings/repositories/settings_repository.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// Tela para exclusão de conta
class DeleteAccountScreen extends StatefulWidget {
  static const String routeName = '/settings/delete-account';

  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  /// Controlador do campo de senha
  final TextEditingController _passwordController = TextEditingController();
  
  /// Formulário
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  /// Flag para exibir/ocultar senha
  bool _obscurePassword = true;
  
  /// Flag para confirmação
  bool _confirmDelete = false;
  
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
  
  /// Valida o formulário e exclui a conta
  void _deleteAccount() {
    if (!_confirmDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).confirmDeleteRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SettingsBloc>().add(
        DeleteAccount(password: _passwordController.text),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return BlocProvider(
      create: (context) => SettingsBloc(
        settingsRepository: SettingsRepository(),
      ),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          // Navega para login após exclusão da conta
          if (!state.isDeleteAccountLoading && !state.hasError && state.status == SettingsStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.accountDeleted),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navega para tela de login
            context.go(AppRoutes.login.path);
          }
          
          // Mostra erro se houver
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
                localizations.deleteAccount,
                style: context.titleStyle,
              ),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final user = authState.user;
                    
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ícone de aviso
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                Text(
                                  localizations.deleteAccountWarningTitle,
                                  style: context.textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 8),
                                
                                Text(
                                  localizations.deleteAccountWarning,
                                  style: context.textTheme.bodyMedium!.copyWith(
                                    color: context.contentColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Email do usuário (não editável)
                          Text(
                            localizations.email,
                            style: context.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.borderColor),
                            ),
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            child: Text(
                              user?.email ?? localizations.notSpecified,
                              style: context.textTheme.bodyLarge!.copyWith(
                                color: context.contentColor,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Campo de senha
                          Text(
                            localizations.password,
                            style: context.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.passwordRequired;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.primaryColor, width: 2),
                              ),
                              filled: true,
                              fillColor: context.cardColor,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 16.0,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: context.subtitleColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Checkbox para confirmação
                          CheckboxListTile(
                            value: _confirmDelete,
                            onChanged: (value) {
                              setState(() {
                                _confirmDelete = value ?? false;
                              });
                            },
                            title: Text(
                              localizations.confirmDeleteAccount,
                              style: context.textTheme.bodyMedium!.copyWith(
                                color: context.contentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              localizations.confirmDeleteAccountSubtitle,
                              style: context.textTheme.bodySmall!.copyWith(
                                color: context.subtitleColor,
                              ),
                            ),
                            activeColor: Colors.red,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Botão de exclusão de conta
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isDeleteAccountLoading
                                  ? null 
                                  : _deleteAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.red.withOpacity(0.6),
                              ),
                              child: state.isDeleteAccountLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      localizations.deleteAccount,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Botão para cancelar
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: context.borderColor),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                localizations.cancel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: context.subtitleColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Extensão para adicionar strings que não estão no AppLocalizations
extension _DeleteAccountLocalizations on AppLocalizations {
  String get deleteAccountWarningTitle => 'This Action Cannot Be Undone';
  String get deleteAccountWarning => 'All your data, including tracking history, achievements, and settings will be permanently deleted. This action cannot be reversed.';
  String get confirmDeleteAccount => 'I understand this is permanent';
  String get confirmDeleteAccountSubtitle => 'I understand that all my data will be permanently deleted and cannot be recovered.';
  String get confirmDeleteRequired => 'Please confirm that you understand this action is permanent.';
  String get accountDeleted => 'Your account has been deleted successfully.';
}