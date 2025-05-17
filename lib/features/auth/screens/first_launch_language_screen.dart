import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_bloc.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_event.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchLanguageScreen extends StatefulWidget {
  static const String routeName = '/first-launch-language';

  const FirstLaunchLanguageScreen({super.key});

  @override
  State<FirstLaunchLanguageScreen> createState() => _FirstLaunchLanguageScreenState();
}

class _FirstLaunchLanguageScreenState extends State<FirstLaunchLanguageScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
      ),
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue() async {
    // Get access to the LocaleBloc
    final localeBloc = context.read<LocaleBloc>();
    
    try {
      // Obtenha o Locale diretamente
      final Locale currentLocale;
      
      // Para novos idiomas, usar apenas código de idioma
      final languageCode = localeBloc.state.locale.languageCode;
      switch (languageCode) {
        case 'de':
        case 'it':
        case 'nl':
        case 'pl':
          currentLocale = Locale(languageCode);
          break;
        case 'en':
          currentLocale = const Locale('en', 'US');
          break;
        case 'es':
          currentLocale = const Locale('es', 'ES');
          break;
        case 'fr':
          currentLocale = const Locale('fr', 'FR');
          break;
        case 'pt':
          currentLocale = const Locale('pt', 'BR');
          break;
        default:
          currentLocale = const Locale('en', 'US');
      }
      
      // Make sure locale is properly saved and applied
      print('🔤 First launch saving locale: ${currentLocale.languageCode}${currentLocale.countryCode != null ? "_${currentLocale.countryCode}" : ""}');
      
      // Force apply locale change first to ensure it's effective
      localeBloc.add(ChangeLocale(currentLocale));
      
      // Give the app a moment to update the locale
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Importante: Marcar como completo ANTES de redirecionar
      await localeBloc.markLanguageSelectionComplete();
      print('✅ Language selection marked as complete');
      
      // Forçar atualização imediata do estado com uma emissão direta
      localeBloc.add(CheckLanguageSelectionStatus());
      
      // Aguardar atualização do estado
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Importante: Verificar novamente para garantir
      final isComplete = await localeBloc.isLanguageSelectionComplete();
      print('🔍 Confirmação final - isLanguageSelectionComplete: $isComplete');
      
      if (!mounted) return;
      
      // Chave: Agora vamos forçar um push de navegação direto, em vez de context.go 
      // que poderia ser interceptado pelo router
      print('🚀 Navegando DIRETAMENTE para tela de login: ${AppRoutes.login.path}');
      
      // Use GoRouter.of(context) instead of context.go to avoid the assertion error
      // This ensures the router is properly retrieved from the context
      final router = GoRouter.of(context);
      if (router != null) {
        router.go(AppRoutes.login.path);
      } else {
        print('⚠️ Router not found in context!');
        // Fallback navigation if GoRouter isn't properly initialized
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      print('⚠️ Error during language selection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if language selection is already completed, redirect if it is
    final localeBloc = context.read<LocaleBloc>();
    localeBloc.isLanguageSelectionComplete().then((isComplete) {
      if (isComplete && mounted) {
        // If already completed, redirect to login using GoRouter.of
        final router = GoRouter.of(context);
        if (router != null) {
          router.go(AppRoutes.login.path);
        } else {
          print('⚠️ Router not found in context during build!');
          // Fallback navigation
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      }
    });
    
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),
                      
                      // Welcome Text and Image
                      Center(
                        child: Image.asset(
                          'assets/images/smoke-one.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        'Welcome to NicotinaAI',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'Select your preferred language',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.contentColor.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Language Options
                      Expanded(
                        child: ListView(
                          children: state.supportedLocales.map((locale) {
                            final String languageName = state.getLanguageName(locale);
                            final bool isSelected = locale.languageCode == state.locale.languageCode && 
                                                  locale.countryCode == state.locale.countryCode;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _LanguageCard(
                                languageName: languageName,
                                isSelected: isSelected,
                                onTap: () {
                                  // Apply the locale change immediately
                                  final localeBloc = context.read<LocaleBloc>();
                                  localeBloc.add(ChangeLocale(locale));
                                  
                                  // Ensure the change is applied to the app immediately
                                  setState(() {});
                                },
                                languageCode: locale.languageCode,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      // Continue Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;
  final String languageCode;

  const _LanguageCard({
    required this.languageName,
    required this.isSelected,
    required this.onTap,
    required this.languageCode,
  });

  String _getFlagEmoji() {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'pt':
        return '🇧🇷';
      case 'fr':
        return '🇫🇷';
      case 'it':
        return '🇮🇹';
      case 'de':
        return '🇩🇪';
      case 'nl':
        return '🇳🇱';
      case 'pl':
        return '🇵🇱';
      default:
        return '🌐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected 
            ? context.primaryColor.withOpacity(0.15) 
            : context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? context.primaryColor : context.borderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: context.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: [
                // Flag emoji
                Text(
                  _getFlagEmoji(),
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 16),
                
                // Language name
                Expanded(
                  child: Text(
                    languageName,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? context.primaryColor : context.contentColor,
                    ),
                  ),
                ),
                
                // Check icon for selected language
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: context.primaryColor,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}