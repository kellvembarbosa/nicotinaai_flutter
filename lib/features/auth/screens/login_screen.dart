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
import 'package:nicotinaai_flutter/widgets/app_icon_widget.dart';
import 'package:nicotinaai_flutter/widgets/platform_loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  // Rota definida no AppRoutes
  
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Handle navigation based on auth state
          if (state.isAuthenticated) {
            context.go(AppRoutes.main.path);
          }
          
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo
                  const Center(
                    child: AppIconWidget(size: 100, borderRadius: 22),
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    l10n.welcomeBack,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    l10n.loginToContinue,
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
                    textInputAction: TextInputAction.next,
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
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible 
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          context.read<AnalyticsBloc>().add(
                            TrackCustomEvent(
                              'login_password_visibility_toggled',
                              parameters: {'visible': !_passwordVisible},
                            ),
                          );
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_passwordVisible,
                    enabled: !state.isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.passwordRequired;
                      }
                      if (value.length < 6) {
                        return l10n.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Forgot Password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: state.isLoading 
                        ? null
                        : () {
                            context.read<AnalyticsBloc>().add(
                              const TrackCustomEvent(
                                'login_forgot_password_clicked',
                              ),
                            );
                            context.push(AppRoutes.forgotPassword.path);
                          },
                      child: Text(l10n.forgotPassword),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Login Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isLoading 
                        ? null 
                        : () {
                            context.read<AnalyticsBloc>().add(
                              const TrackCustomEvent(
                                'login_button_clicked',
                              ),
                            );
                            _handleLogin();
                          },
                      child: state.isLoading
                        ? const PlatformLoadingIndicator(size: 24)
                        : Text(l10n.login),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.noAccount),
                      TextButton(
                        onPressed: state.isLoading 
                          ? null 
                          : () {
                              context.read<AnalyticsBloc>().add(
                                const TrackCustomEvent(
                                  'login_register_clicked',
                                ),
                              );
                              context.push(AppRoutes.register.path);
                            },
                        child: Text(l10n.register),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _handleLogin() {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Validate form
    if (_formKey.currentState?.validate() ?? false) {
      // Track successful login attempt
      context.read<AnalyticsBloc>().add(
        const LogLoginEvent(method: 'email'),
      );
      
      // Dispatch login event
      context.read<AuthBloc>().add(LoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ));
    } else {
      // Track failed validation
      context.read<AnalyticsBloc>().add(
        const TrackCustomEvent(
          'login_validation_failed',
        ),
      );
    }
  }
}