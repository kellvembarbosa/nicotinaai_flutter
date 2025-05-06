import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/progress_bar.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class OnboardingContainer extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final bool showBackButton;
  final bool canProceed;
  final String? nextButtonText;
  final VoidCallback onNext;
  
  const OnboardingContainer({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.content,
    this.showBackButton = true,
    this.canProceed = true,
    this.nextButtonText,
    required this.onNext,
  }) : super(key: key);
  
  @override
  State<OnboardingContainer> createState() => _OnboardingContainerState();
}

class _OnboardingContainerState extends State<OnboardingContainer> {
  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final state = onboardingProvider.state;
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              ProgressBar(
                current: state.currentStep,
                total: state.totalSteps,
              ),
              
              const SizedBox(height: 24),
              
              // Título e subtítulo
              Text(
                widget.title,
                style: context.headlineStyle,
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: context.subtitleStyle,
              ),
              
              const SizedBox(height: 32),
              
              // Conteúdo principal
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: widget.content,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botões de navegação (com efeito de vidro no tema escuro)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: context.isDarkMode 
                    ? _buildBlurredNavigationRow(context, onboardingProvider)
                    : _buildNavigationRow(context, onboardingProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBlurredNavigationRow(BuildContext context, OnboardingProvider onboardingProvider) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: _buildNavigationButtons(context, onboardingProvider),
      ),
    );
  }
  
  Widget _buildNavigationRow(BuildContext context, OnboardingProvider onboardingProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: _buildNavigationButtons(context, onboardingProvider),
    );
  }
  
  Widget _buildNavigationButtons(BuildContext context, OnboardingProvider onboardingProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.showBackButton)
          OutlinedButton(
            onPressed: () {
              onboardingProvider.previousStep();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.borderColor),
              foregroundColor: context.contentColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 18),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context).back),
              ],
            ),
          )
        else
          const SizedBox(width: 85),
        
        ElevatedButton(
          onPressed: widget.canProceed ? widget.onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: context.primaryColor.withOpacity(0.4),
            disabledForegroundColor: Colors.white.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: Row(
            children: [
              Text(widget.nextButtonText ?? AppLocalizations.of(context).continueButton),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}