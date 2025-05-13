import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool canGoBack;
  final bool disableNext;
  final String? nextText;
  final String? screenName;
  
  const NavigationButtons({
    Key? key,
    required this.onBack,
    required this.onNext,
    this.canGoBack = true,
    this.disableNext = false,
    this.nextText,
    this.screenName,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Se não tiver botão voltar, exibe apenas o botão próximo com largura completa
    if (!canGoBack) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: disableNext ? 
            () {
              // Trackear tentativa sem preenchimento dos campos
              AnalyticsService().trackEvent(
                'onboarding_incomplete_attempt',
                parameters: {
                  'screen': screenName ?? 'unknown',
                  'button': nextText ?? 'continue',
                },
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).pleaseCompleteAllFields),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: AppLocalizations.of(context).understood,
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            } : () {
              // Trackear clique no botão de continuar
              AnalyticsService().trackEvent(
                'onboarding_next',
                parameters: {
                  'screen': screenName ?? 'unknown',
                  'button': nextText ?? 'continue',
                },
              );
              onNext();
            },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2962FF), // Azul primário
            foregroundColor: Colors.white,
            disabledBackgroundColor: null, // Removendo para evitar visual de desabilitado
            disabledForegroundColor: null, // Removendo para evitar visual de desabilitado
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nextText ?? AppLocalizations.of(context).continueButton,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      );
    }
    
    // Layout com botão de voltar menor e botão de continuar expandido
    return Row(
      children: [
        // Botão voltar (compacto)
        OutlinedButton(
          onPressed: () {
            // Trackear clique no botão voltar
            AnalyticsService().trackEvent(
              'onboarding_back',
              parameters: {
                'screen': screenName ?? 'unknown',
              },
            );
            onBack();
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, size: 18),
              const SizedBox(width: 8),
              Text(
                'Voltar',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Espaçamento entre os botões
        const SizedBox(width: 12),
        
        // Botão próximo (expandido)
        Expanded(
          child: ElevatedButton(
            onPressed: disableNext ? 
              () {
                // Trackear tentativa sem preenchimento dos campos
                AnalyticsService().trackEvent(
                  'onboarding_incomplete_attempt',
                  parameters: {
                    'screen': screenName ?? 'unknown',
                    'button': nextText ?? 'continue',
                  },
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).pleaseCompleteAllFields),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.redAccent,
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context).understood,
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              } : () {
                // Trackear clique no botão de continuar
                AnalyticsService().trackEvent(
                  'onboarding_next',
                  parameters: {
                    'screen': screenName ?? 'unknown',
                    'button': nextText ?? 'continue',
                  },
                );
                onNext();
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2962FF), // Azul primário
              foregroundColor: Colors.white,
              disabledBackgroundColor: null, // Removendo para evitar visual de desabilitado
              disabledForegroundColor: null, // Removendo para evitar visual de desabilitado
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nextText ?? AppLocalizations.of(context).continueButton,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}