import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool canGoBack;
  final bool disableNext;
  final String? nextText;
  
  const NavigationButtons({
    Key? key,
    required this.onBack,
    required this.onNext,
    this.canGoBack = true,
    this.disableNext = false,
    this.nextText,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (canGoBack)
          OutlinedButton(
            onPressed: onBack,
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
          )
        else
          const SizedBox(width: 85),
        
        ElevatedButton(
          onPressed: disableNext ? null : onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2962FF), // Azul primário
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF2962FF).withOpacity(0.4),
            disabledForegroundColor: Colors.white.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: Row(
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
      ],
    );
  }
}