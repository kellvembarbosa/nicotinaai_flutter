import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_bloc.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_event.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_event.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/features/auth/screens/login_screen.dart';
import 'package:nicotinaai_flutter/features/auth/screens/splash_screen.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';
import 'package:nicotinaai_flutter/widgets/app_icon_widget.dart';
import 'package:nicotinaai_flutter/widgets/platform_loading_indicator.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/url_launcher_utils.dart';
import 'package:nicotinaai_flutter/features/paywall/presentation/widgets/post_signup_paywall.dart';

class RegisterScreen extends StatefulWidget {
  // Rota definida no AppRoutes
  
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _termsAccepted = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    // Track navigation to login
    context.read<AnalyticsBloc>().add(
      const TrackCustomEvent(
        'register_login_clicked',
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

  void _showPostSignupPaywall(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostSignupPaywall(
              onPurchaseComplete: () {
                if (mounted && context.mounted) {
                  _navigateToSplash();
                }
              },
              onClose: () {
                if (mounted && context.mounted) {
                  _navigateToSplash();
                }
              },
            ),
            fullscreenDialog: true,
          ),
        );
      }
    });
  }

  void _navigateToSplash() {
    final router = GoRouter.of(context);
    router.go('/splash');
  }

  @override
  Widget build(BuildContext context) {
    // Force refresh the localization context to ensure we get the latest translations
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    final currentLocale = Localizations.localeOf(context);
    // Debug print to check current locale
    print('🔍 RegisterScreen building with locale: $currentLocale');
    print('🔍 Current translations test - Register: ${l10n.register}, CreateAccount: ${l10n.createAccount}');
    
    // Log all the translations being used on this screen to identify any issues
    print('🔍 Testing all register screen translations:');
    print('  - Register: ${l10n.register}');
    print('  - CreateAccount: ${l10n.createAccount}');
    print('  - FillInformation: ${l10n.fillInformation}');
    print('  - Name: ${l10n.name}');
    print('  - Email: ${l10n.email}');
    print('  - Password: ${l10n.password}');
    print('  - ConfirmPassword: ${l10n.confirmPassword}');
    print('  - TermsConditions: ${l10n.termsConditionsAgree}');
    print('  - Login: ${l10n.login}');
    print('  - AlreadyAccount: ${l10n.alreadyAccount}');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.register),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Handle navigation on successful registration
          if (state.isAuthenticated) {
            // Request tracking transparency after successful registration (iOS only)
            final analyticsService = AnalyticsService();
            analyticsService.requestTrackingAuthorization();
            
            // Show post-signup paywall before proceeding
            _showPostSignupPaywall(context);
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
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    l10n.createAccount,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    l10n.fillInformation,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    enabled: !state.isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.nameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
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
                              'register_password_visibility_toggled',
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
                  const SizedBox(height: 16),
                  
                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: l10n.confirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible 
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          context.read<AnalyticsBloc>().add(
                            TrackCustomEvent(
                              'register_confirm_password_visibility_toggled',
                              parameters: {'visible': !_confirmPasswordVisible},
                            ),
                          );
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_confirmPasswordVisible,
                    enabled: !state.isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.confirmPasswordRequired;
                      }
                      if (value != _passwordController.text) {
                        return l10n.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Terms Acceptance
                  Row(
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        onChanged: state.isLoading
                          ? null
                          : (value) {
                              context.read<AnalyticsBloc>().add(
                                TrackCustomEvent(
                                  'register_terms_checkbox_toggled',
                                  parameters: {'accepted': value},
                                ),
                              );
                              setState(() {
                                _termsAccepted = value ?? false;
                              });
                            },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<AnalyticsBloc>().add(
                              TrackCustomEvent(
                                'register_terms_text_clicked',
                                parameters: {'current_state': _termsAccepted},
                              ),
                            );
                            setState(() {
                              _termsAccepted = !_termsAccepted;
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: theme.textTheme.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: l10n.termsConditionsAgree,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              Wrap(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      context.read<AnalyticsBloc>().add(
                                        const TrackCustomEvent(
                                          'terms_link_clicked',
                                          parameters: {'source': 'register_screen'},
                                        ),
                                      );
                                      UrlLauncherUtils.launchURL(
                                        l10n.termsOfServiceUrl,
                                        context: context,
                                      );
                                    },
                                    child: Text(
                                      l10n.termsOfUse,
                                      style: theme.textTheme.bodySmall!.copyWith(
                                        color: theme.colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    l10n.textSeparator,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.read<AnalyticsBloc>().add(
                                        const TrackCustomEvent(
                                          'privacy_policy_clicked',
                                          parameters: {'source': 'register_screen'},
                                        ),
                                      );
                                      UrlLauncherUtils.launchURL(
                                        l10n.privacyPolicyUrl,
                                        context: context,
                                      );
                                    },
                                    child: Text(
                                      l10n.privacyPolicy,
                                      style: theme.textTheme.bodySmall!.copyWith(
                                        color: theme.colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Register Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isLoading || !_termsAccepted
                        ? null 
                        : () {
                            context.read<AnalyticsBloc>().add(
                              const TrackCustomEvent(
                                'register_button_clicked',
                              ),
                            );
                            _handleRegister();
                          },
                      child: state.isLoading
                        ? const PlatformLoadingIndicator(size: 24)
                        : Text(l10n.createAccount),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.alreadyAccount),
                      TextButton(
                        onPressed: state.isLoading 
                          ? null 
                          : _navigateToLogin,
                        child: Text(l10n.login),
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
  
  void _handleRegister() {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Validate form
    if (_formKey.currentState?.validate() ?? false) {
      if (!_termsAccepted) {
        context.read<AnalyticsBloc>().add(
          const TrackCustomEvent(
            'register_terms_not_accepted_error',
          ),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).termsConditionsRequired),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      
      // Track successful signup
      context.read<AnalyticsBloc>().add(
        const LogSignUpEvent(method: 'email'),
      );
      
      // Dispatch register event
      context.read<AuthBloc>().add(SignUpRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ));
    } else {
      // Track failed validation
      context.read<AnalyticsBloc>().add(
        const TrackCustomEvent(
          'register_validation_failed',
        ),
      );
    }
  }
}