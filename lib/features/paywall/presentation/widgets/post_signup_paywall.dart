import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/core/services/paywall_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:async';

class PostSignupPaywall extends StatefulWidget {
  final VoidCallback? onPurchaseComplete;
  final VoidCallback? onClose;

  const PostSignupPaywall({
    super.key,
    this.onPurchaseComplete,
    this.onClose,
  });

  @override
  State<PostSignupPaywall> createState() => _PostSignupPaywallState();
}

class _PostSignupPaywallState extends State<PostSignupPaywall> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _canClose = false;
  bool _isPurchasing = false;
  Offerings? _offerings;
  Package? _selectedPackage;
  Timer? _closeTimer;
  int _secondsRemaining = 15; // 15 segundos de delay
  
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadOfferings();
    _startCloseTimer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  void _startCloseTimer() {
    _closeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canClose = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await PaywallService.instance.getOfferings();
      if (mounted) {
        setState(() {
          _offerings = offerings;
          _selectedPackage = offerings?.current?.monthly ?? offerings?.current?.availablePackages.first;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null || _isPurchasing) return;

    setState(() {
      _isPurchasing = true;
    });

    try {
      await PaywallService.instance.purchasePackage(_selectedPackage!);
      
      if (mounted) {
        widget.onPurchaseComplete?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).purchaseError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleClose() {
    if (_canClose) {
      widget.onClose?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.primaryColor.withOpacity(0.9),
                Colors.black87,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header com botão de fechar (condicional)
                _buildHeader(context, localizations),
                
                // Conteúdo principal
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _buildContent(context, localizations),
                ),
                
                // Botão de compra
                if (!_isLoading) _buildPurchaseButton(context, localizations),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicador de urgência
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'OFERTA LIMITADA',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Botão de fechar condicional
          if (_canClose)
            GestureDetector(
              onTap: _handleClose,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_secondsRemaining}s',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations localizations) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Título principal com animação
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Text(
                  '🚭 Sua Jornada Para a Liberdade Começa AGORA!',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Subtítulo de urgência
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              '⚡ Você acabou de dar o primeiro passo mais importante. Não deixe essa motivação escapar!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quebra de objeções
          _buildObjectionBreakers(context, localizations),
          
          const SizedBox(height: 24),
          
          // Elementos de prova social e urgência
          _buildSocialProofAndUrgency(context, localizations),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildObjectionBreakers(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        // Objeção: "É só mais um app"
        _buildObjectionItem(
          icon: '🧠',
          objection: '"É só mais um app..."',
          response: 'Baseado em CIÊNCIA COMPORTAMENTAL e usado por +100.000 pessoas que conseguiram parar de fumar',
          color: Colors.blue,
        ),
        
        const SizedBox(height: 16),
        
        // Objeção: "É muito caro"
        _buildObjectionItem(
          icon: '💰',
          objection: '"É muito caro..."',
          response: 'Menos que 1 maço por semana. Você já gasta 10x mais com cigarro por mês!',
          color: Colors.green,
        ),
        
        const SizedBox(height: 16),
        
        // Objeção: "Não vai funcionar comigo"
        _buildObjectionItem(
          icon: '🎯',
          objection: '"Não vai funcionar comigo..."',
          response: 'Plano PERSONALIZADO baseado no SEU perfil. Taxa de sucesso 89% maior que tentar sozinho',
          color: Colors.orange,
        ),
        
        const SizedBox(height: 16),
        
        // Objeção: "Posso fazer sozinho"
        _buildObjectionItem(
          icon: '⚡',
          objection: '"Posso fazer sozinho..."',
          response: 'Apenas 3% conseguem parar sozinhos. COM AJUDA PROFISSIONAL: 67% de sucesso!',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildObjectionItem({
    required String icon,
    required String objection,
    required String response,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  objection,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            response,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialProofAndUrgency(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        // Prova social
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow.withOpacity(0.2), Colors.orange.withOpacity(0.2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => 
                  const Icon(Icons.star, color: Colors.yellow, size: 20)
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '4.8★ • +100.000 usuários já pararam de fumar',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '"Funcionou quando nada mais funcionava" - Maria, 34 anos',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Urgência e escassez
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Text(
                '⏰ ÚLTIMA CHANCE',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta oferta especial expira quando você sair desta tela',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Apenas para novos usuários • Não reaparecerá',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseButton(BuildContext context, AppLocalizations localizations) {
    if (_offerings?.current?.availablePackages.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    final package = _selectedPackage!;
    final price = package.storeProduct.priceString;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Benefício principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '🎯 Acesso COMPLETO • Plano Personalizado • Suporte 24/7',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Botão de compra principal
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isPurchasing ? 1.0 : _pulseAnimation.value,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.green.shade700],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isPurchasing ? null : _handlePurchase,
                      borderRadius: BorderRadius.circular(30),
                      child: Center(
                        child: _isPurchasing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '🚀 COMEÇAR MINHA JORNADA',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    price,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
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
          ),
          
          const SizedBox(height: 8),
          
          // Garantia
          Text(
            '✅ Garantia de 7 dias • Cancele quando quiser',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}