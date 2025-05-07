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
        child: Column(
          children: [
            // Conteúdo principal - ocupa toda a área disponível
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _buildContentArea(context, state, onboardingProvider),
              ),
            ),
            
            // Botões de navegação - sempre visíveis na parte inferior
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildNavigationButtons(context, onboardingProvider),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói a área de conteúdo com base no tipo selecionado
  Widget _buildContentArea(BuildContext context, OnboardingState state, OnboardingProvider onboardingProvider) {
    switch (widget.contentType) {
      case OnboardingContentType.regular:
        return _buildRegularContent(context, state);
      case OnboardingContentType.list:
        return _buildListContent(context, state);
      case OnboardingContentType.scrollable:
        return _buildScrollableContent(context, state);
    }
  }
  
  /// Layout padrão para conteúdo regular
  Widget _buildRegularContent(BuildContext context, OnboardingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho fixo
        _buildHeader(state),
        
        // Conteúdo principal com expansão máxima
        Expanded(
          child: widget.content,
        ),
      ],
    );
  }
  
  /// Layout otimizado para conteúdo com listas ou grids
  Widget _buildListContent(BuildContext context, OnboardingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho fixo
        _buildHeader(state),
        
        // Conteúdo principal (com lista ou grid) usando o máximo de espaço
        Expanded(
          child: widget.content,
        ),
      ],
    );
  }
  
  /// Layout que permite conteúdo com rolagem independente
  Widget _buildScrollableContent(BuildContext context, OnboardingState state) {
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
        
        // Espaçamento adicional para melhor visualização ao fazer scroll
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
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
  
  /// Constrói os botões de navegação com estilo fixo na parte inferior
  Widget _buildNavigationButtons(BuildContext context, OnboardingProvider onboardingProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDarkMode ? context.backgroundColor : Colors.white,
        boxShadow: [
          if (!context.isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: context.isDarkMode
          ? _buildBlurredNavigationRow(context, onboardingProvider)
          : _buildNavigationRow(context, onboardingProvider),
    );
  }
  
  Widget _buildBlurredNavigationRow(BuildContext context, OnboardingProvider onboardingProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: _buildNavigationRow(context, onboardingProvider),
        ),
      ),
    );
  }
  
  Widget _buildNavigationRow(BuildContext context, OnboardingProvider onboardingProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botão voltar
        if (widget.showBackButton)
          OutlinedButton(
            onPressed: () {
              onboardingProvider.previousStep();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.borderColor),
              foregroundColor: context.contentColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 18),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).back,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        else
          const SizedBox(width: 100), // Espaço reservado quando não há botão voltar
        
        // Botão próximo
        ElevatedButton(
          onPressed: widget.canProceed ? widget.onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: context.primaryColor.withOpacity(0.4),
            disabledForegroundColor: Colors.white.withOpacity(0.8),
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.nextButtonText ?? AppLocalizations.of(context).continueButton,
                style: const TextStyle(fontWeight: FontWeight.w600),
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