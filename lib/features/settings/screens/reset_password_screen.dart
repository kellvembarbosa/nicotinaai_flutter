import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_event.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/settings/repositories/settings_repository.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// Tela para redefinição de senha
class ResetPasswordScreen extends StatefulWidget {
  static const String routeName = '/settings/reset-password';

  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  /// Controlador do campo de senha atual
  final TextEditingController _currentPasswordController = TextEditingController();
  
  /// Controlador do campo de nova senha
  final TextEditingController _newPasswordController = TextEditingController();
  
  /// Controlador do campo de confirmação de nova senha
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  /// Formulário
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  /// Flag para exibir/ocultar senha atual
  bool _obscureCurrentPassword = true;
  
  /// Flag para exibir/ocultar nova senha
  bool _obscureNewPassword = true;
  
  /// Flag para exibir/ocultar confirmação de senha
  bool _obscureConfirmPassword = true;
  
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  /// Valida o formulário e altera a senha
  void _changePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      // Verifica se as senhas coincidem
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).passwordsDoNotMatch),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Solicita alteração de senha
      context.read<SettingsBloc>().add(
        ChangePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
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
          // Mostra mensagem de sucesso
          if (state.isChangePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.passwordChangedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
            
            // Volta para a tela anterior
            Navigator.of(context).pop();
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
                localizations.resetPassword,
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
                          // Título da seção
                          Text(
                            localizations.changePassword,
                            style: context.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Descrição
                          Text(
                            localizations.changePasswordDescription,
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: context.subtitleColor,
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
                          
                          // Campo de senha atual
                          Text(
                            localizations.currentPassword,
                            style: context.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrentPassword,
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
                                  _obscureCurrentPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: context.subtitleColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureCurrentPassword = !_obscureCurrentPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Campo de nova senha
                          Text(
                            localizations.newPassword,
                            style: context.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.passwordRequired;
                              }
                              if (value.length < 6) {
                                return localizations.passwordTooShort;
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
                                  _obscureNewPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: context.subtitleColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Campo de confirmação de nova senha
                          Text(
                            localizations.confirmPassword,
                            style: context.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.confirmPasswordRequired;
                              }
                              if (value != _newPasswordController.text) {
                                return localizations.passwordsDoNotMatch;
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
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: context.subtitleColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Botão de alteração de senha
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isChangePasswordLoading
                                  ? null 
                                  : _changePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: context.primaryColor.withOpacity(0.6),
                              ),
                              child: state.isChangePasswordLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      localizations.changePassword,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          
                          // Opção para redefinir via e-mail
                          if (user?.email != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.forgotPasswordTitle,
                                    style: context.textTheme.titleMedium!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.contentColor,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  Text(
                                    localizations.forgotPasswordSubtitle,
                                    style: context.textTheme.bodyMedium!.copyWith(
                                      color: context.subtitleColor,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Botão de redefinição via e-mail
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: state.isResetPasswordLoading
                                          ? null
                                          : () {
                                              context.read<SettingsBloc>().add(
                                                RequestPasswordReset(
                                                  email: user!.email!,
                                                ),
                                              );
                                            },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: context.primaryColor),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: state.isResetPasswordLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              localizations.sendResetLink,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: context.primaryColor,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
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
extension _ResetPasswordLocalizations on AppLocalizations {
  String get currentPassword => 'Current Password';
  String get newPassword => 'New Password';
  String get changePasswordDescription => 'Enter your current password and a new password to update your access credentials.';
  String get passwordChangedSuccessfully => 'Password changed successfully';
  String get forgotPasswordTitle => 'Forgot your password?';
  String get forgotPasswordSubtitle => 'We can send you a link to reset your password via email.';
}