import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_state.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/progress_bar.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

enum OnboardingContentType {
  /// Conteúdo regular, sem requisitos especiais de layout
  regular,
  
  /// Conteúdo que contém uma lista de itens ou grid e precisa preencher o espaço disponível
  list,
  
  /// Conteúdo que contém múltiplas seções e precisa de scroll próprio
  scrollable,
}

class OnboardingContainer extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final bool showBackButton;
  final bool canProceed;
  final String? nextButtonText;
  final VoidCallback onNext;
  
  /// Tipo de conteúdo que será exibido
  final OnboardingContentType contentType;
  
  const OnboardingContainer({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.content,
    this.showBackButton = true,
    this.canProceed = true,
    this.nextButtonText,
    required this.onNext,
    this.contentType = OnboardingContentType.regular,
  }) : super(key: key);
  
  @override
  State<OnboardingContainer> createState() => _OnboardingContainerState();
}

class _OnboardingContainerState extends State<OnboardingContainer> {
  /// Scrollcontroller usado para controlar o scroll coordenado entre diferentes
  /// elementos do layout quando o tipo é scrollable
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final state = onboardingProvider.state;
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildByContentType(context, state, onboardingProvider),
        ),
      ),
    );
  }
  
  /// Constrói o layout adequado com base no tipo de conteúdo
  Widget _buildByContentType(BuildContext context, OnboardingState state, OnboardingProvider onboardingProvider) {
    switch (widget.contentType) {
      case OnboardingContentType.regular:
        return _buildRegularLayout(context, state, onboardingProvider);
      case OnboardingContentType.list:
        return _buildListLayout(context, state, onboardingProvider);
      case OnboardingContentType.scrollable:
        return _buildScrollableLayout(context, state, onboardingProvider);
    }
  }
  
  /// Layout padrão para conteúdo regular
  Widget _buildRegularLayout(BuildContext context, OnboardingState state, OnboardingProvider onboardingProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho fixo
        _buildHeader(state),
        
        // Conteúdo principal
        Expanded(
          child: widget.content,
        ),
        
        const SizedBox(height: 24),
        
        // Botões de navegação
        _buildNavigationButtons(context, onboardingProvider),
      ],
    );
  }
  
  /// Layout otimizado para conteúdo com listas ou grids
  Widget _buildListLayout(BuildContext context, OnboardingState state, OnboardingProvider onboardingProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho fixo
        _buildHeader(state),
        
        // Conteúdo principal (com lista ou grid) usando Expanded
        Expanded(
          child: widget.content,
        ),
        
        const SizedBox(height: 24),
        
        // Botões de navegação
        _buildNavigationButtons(context, onboardingProvider),
      ],
    );
  }
  
  /// Layout que permite conteúdo com rolagem independente
  Widget _buildScrollableLayout(BuildContext context, OnboardingState state, OnboardingProvider onboardingProvider) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Cabeçalho fixo
        SliverToBoxAdapter(
          child: _buildHeader(state),
        ),
        
        // Conteúdo principal como sliver
        SliverToBoxAdapter(
          child: widget.content,
        ),
        
        // Espaçamento
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
        
        // Botões de navegação
        SliverToBoxAdapter(
          child: _buildNavigationButtons(context, onboardingProvider),
        ),
      ],
    );
  }
  
  /// Constrói o cabeçalho com barra de progresso, título e subtítulo
  Widget _buildHeader(OnboardingState state) {
    return Column(
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
      ],
    );
  }
  
  /// Constrói os botões de navegação com suporte a glassmorphism no tema escuro
  Widget _buildNavigationButtons(BuildContext context, OnboardingProvider onboardingProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: context.isDarkMode 
          ? _buildBlurredNavigationRow(context, onboardingProvider)
          : _buildNavigationRow(context, onboardingProvider),
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
        child: _buildNavigationRow(context, onboardingProvider),
      ),
    );
  }
  
  Widget _buildNavigationRow(BuildContext context, OnboardingProvider onboardingProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
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
      ),
    );
  }
}