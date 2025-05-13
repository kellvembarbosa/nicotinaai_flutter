import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/navigation_buttons.dart';
import 'package:nicotinaai_flutter/features/onboarding/widgets/progress_bar.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';

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
  
  /// Nome da tela para analytics
  final String? screenName;
  
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
    this.screenName,
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
    // Se o botão estiver em status de carregamento, mostrar indicador
    if (widget.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.primaryColor,
        ),
      );
    }
    
    // Trackear visualização da tela ao montar os botões (faz sentido aqui pois ocorre uma vez por tela)
    if (widget.screenName != null) {
      AnalyticsService().trackEvent(
        'onboarding_screen_view',
        parameters: {'screen': widget.screenName!},
      );
    }
    
    // Usar o widget NavigationButtons que já tem tracking implementado
    return NavigationButtons(
      onBack: () {
        context.read<OnboardingBloc>().add(PreviousOnboardingStep());
      },
      onNext: widget.onNext,
      canGoBack: widget.showBackButton,
      disableNext: !widget.canProceed,
      nextText: widget.nextButtonText,
      screenName: widget.screenName,
    );
  }
}