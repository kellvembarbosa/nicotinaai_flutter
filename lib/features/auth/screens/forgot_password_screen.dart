import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_bloc.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_event.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_event.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  // Rota definida no AppRoutes
  
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    if (!mounted) return;
    
    context.read<AnalyticsBloc>().add(
      const TrackCustomEvent(
        'forgot_password_back_to_login_clicked',
      ),
    );
    
    // Use GoRouter.of instead of context.go to avoid assertion error
    final router = GoRouter.of(context);
    if (router != null) {
      router.go(AppRoutes.login.path);
    } else {
      print('⚠️ Router not found in context!');
      // Fallback navigation
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login.path, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forgotPassword),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Show error messages
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            
            // Clear the error
            context.read<AuthBloc>().add(const ClearAuthErrorRequested());
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _resetEmailSent ? _buildSuccessView(l10n, theme) : _buildFormView(state, l10n, theme),
          );
        },
      ),
    );
  }
  
  Widget _buildSuccessView(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.primary,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.resetLinkSent,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.checkEmailInstructions,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<AnalyticsBloc>().add(
                const TrackCustomEvent(
                  'forgot_password_success_back_to_login_clicked',
                ),
              );
              _navigateToLogin();
            },
            child: Text(l10n.backToLogin),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFormView(AuthState state, AppLocalizations l10n, ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title and instructions
          Text(
            l10n.forgotPassword,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          Text(
            l10n.forgotPasswordInstructions,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: l10n.email,
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            enabled: !state.isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.emailRequired;
              }
              if (!value.contains('@') || !value.contains('.')) {
                return l10n.emailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Submit Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : () {
              context.read<AnalyticsBloc>().add(
                const TrackCustomEvent(
                  'forgot_password_send_reset_link_clicked',
                ),
              );
              _handleResetPassword();
            },
              child: state.isLoading
                ? const CircularProgressIndicator()
                : Text(l10n.sendResetLink),
            ),
          ),
          const SizedBox(height: 24),
          
          // Back to Login
          TextButton.icon(
            onPressed: state.isLoading ? null : () {
              context.read<AnalyticsBloc>().add(
                const TrackCustomEvent(
                  'forgot_password_back_button_clicked',
                ),
              );
              _navigateToLogin();
            },
            icon: const Icon(Icons.arrow_back),
            label: Text(l10n.backToLogin),
          ),
        ],
      ),
    );
  }
  
  void _handleResetPassword() {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Validate form
    if (_formKey.currentState?.validate() ?? false) {
      // Track password reset request
      context.read<AnalyticsBloc>().add(
        TrackCustomEvent(
          'forgot_password_reset_requested',
          parameters: {'email': _emailController.text.trim()},
        ),
      );
      
      // Dispatch reset password event
      context.read<AuthBloc>().add(PasswordResetRequested(
        email: _emailController.text.trim(),
      ));
      
      // Update UI to show success message
      // In a real app, you might want to wait for success response from BLoC
      // but for better UX we assume it worked
      setState(() {
        _resetEmailSent = true;
      });
    } else {
      // Track validation failure
      context.read<AnalyticsBloc>().add(
        const TrackCustomEvent(
          'forgot_password_validation_failed',
        ),
      );
    }
  }
}