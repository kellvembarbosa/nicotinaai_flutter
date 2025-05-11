import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
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
  
  /// Indica se o botão de avançar está em estado de carregamento
  final bool isLoading;
  
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
    this.isLoading = false,
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
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Barra de progresso no topo com padding reduzido
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: ProgressBar(
                    current: state.currentStep,
                    total: state.totalSteps,
                  ),
                ),
                
                // Conteúdo principal - ocupa toda a área disponível
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: _buildContentArea(context, state),
                  ),
                ),
                
                // Botões de navegação com padding reduzido
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: _buildNavigationButtons(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Constrói a área de conteúdo com base no tipo selecionado
  Widget _buildContentArea(BuildContext context, OnboardingState state) {
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
  
  /// Constrói o cabeçalho com título e subtítulo (barra de progresso movida para o topo)
  Widget _buildHeader(OnboardingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        // Título e subtítulo com spacing reduzido
        Text(
          widget.title,
          style: context.headlineStyle?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 6),
        Text(
          widget.subtitle,
          style: context.subtitleStyle?.copyWith(fontSize: 15),
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }
  
  /// Constrói os botões de navegação diretamente, sem container adicional
  Widget _buildNavigationButtons(BuildContext context, OnboardingState state) {
    return context.isDarkMode
        ? _buildBlurredNavigationRow(context, state)
        : _buildNavigationRow(context, state);
  }
  
  Widget _buildBlurredNavigationRow(BuildContext context, OnboardingState state) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          child: _buildNavigationRow(context, state),
        ),
      ),
    );
  }
  
  Widget _buildNavigationRow(BuildContext context, OnboardingState state) {
    // Se não tiver botão voltar, exibe apenas o botão próximo com largura completa
    if (!widget.showBackButton) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.canProceed ? 
            widget.onNext : 
            () {
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
            },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: null, // Removendo para evitar visual de desabilitado
            disabledForegroundColor: null, // Removendo para evitar visual de desabilitado
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: widget.isLoading
            // Indicador de carregamento quando isLoading for true
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            // Conteúdo normal do botão quando não estiver carregando
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
      );
    }
    
    // Layout com botão de voltar menor e botão de continuar expandido
    return Row(
      children: [
        // Botão voltar (compacto)
        OutlinedButton(
          onPressed: () {
            context.read<OnboardingBloc>().add(PreviousOnboardingStep());
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: context.borderColor),
            foregroundColor: context.contentColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, size: 18),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).back,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        
        // Espaçamento entre os botões
        const SizedBox(width: 12),
        
        // Botão próximo (expandido)
        Expanded(
          child: ElevatedButton(
            onPressed: widget.canProceed ? 
              widget.onNext : 
              () {
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
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: null, // Removendo para evitar visual de desabilitado
              disabledForegroundColor: null, // Removendo para evitar visual de desabilitado
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
              // Indicador de carregamento quando isLoading for true
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              // Conteúdo normal do botão quando não estiver carregando
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
        ),
      ],
    );
  }
}