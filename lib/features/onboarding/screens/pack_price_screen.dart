import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/supported_currencies.dart';
import 'package:intl/intl.dart';

class PackPriceScreen extends StatefulWidget {
  const PackPriceScreen({Key? key}) : super(key: key);

  @override
  State<PackPriceScreen> createState() => _PackPriceScreenState();
}

class _PackPriceScreenState extends State<PackPriceScreen> {
  late TextEditingController _priceController;
  bool _isValid = false;
  late String _currencyCode;
  String _currencySymbol = '';
  String _currencyLocale = '';
  double _currentValue = 0.0;
  
  // Valores comuns de preços (em unidades inteiras para simplificar)
  final List<int> _commonPrices = [10, 15, 20, 25, 30];
  
  @override
  void initState() {
    super.initState();
    final bloc = context.read<OnboardingBloc>();
    final currentOnboarding = bloc.state.onboarding;
    
    // Obtém a moeda selecionada
    _currencyCode = currentOnboarding?.packPriceCurrency ?? 'BRL';
    
    // Obtém o símbolo e locale com base no código da moeda
    final currency = SupportedCurrencies.getByCurrencyCode(_currencyCode);
    if (currency != null) {
      _currencySymbol = currency.symbol;
      _currencyLocale = currency.locale;
    } else {
      // Valores padrão
      _currencySymbol = 'R\$';
      _currencyLocale = 'pt_BR';
    }
    
    // Inicializa o controller com o valor já salvo se existir
    // Converte centavos para a moeda (ex: 1200 centavos = 12,00)
    final savedPrice = currentOnboarding?.packPrice;
    if (savedPrice != null) {
      _currentValue = savedPrice / 100.0;
    }
    
    final initialPrice = _currentValue > 0 ? _currentValue.toStringAsFixed(2) : '';
    
    _priceController = TextEditingController(text: initialPrice);
    _validateInput(initialPrice);
  }
  
  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    // Verifica se o input é um número válido maior que zero
    if (value.isEmpty) {
      setState(() => _isValid = false);
      return;
    }
    
    try {
      final price = double.parse(value.replaceAll(',', '.'));
      setState(() {
        _isValid = price > 0;
        if (_isValid) {
          _currentValue = price;
        }
      });
    } catch (_) {
      setState(() => _isValid = false);
    }
  }
  
  void _incrementValue(double amount) {
    // Incrementa o valor atual pelo valor informado
    setState(() {
      _currentValue = _currentValue + amount;
      _priceController.text = _currentValue.toStringAsFixed(2);
      _isValid = _currentValue > 0;
    });
    
    // Feedback tátil
    HapticFeedback.lightImpact();
  }
  
  void _decrementValue(double amount) {
    // Decrementa o valor atual, mas não permite valores negativos
    if (_currentValue > amount) {
      setState(() {
        _currentValue = _currentValue - amount;
        _priceController.text = _currentValue.toStringAsFixed(2);
        _isValid = _currentValue > 0;
      });
    } else {
      setState(() {
        _currentValue = 0;
        _priceController.text = "";
        _isValid = false;
      });
    }
    
    // Feedback tátil
    HapticFeedback.lightImpact();
  }
  
  void _setPrice(double price) {
    // Define o preço diretamente
    setState(() {
      _currentValue = price;
      _priceController.text = _currentValue.toStringAsFixed(2);
      _isValid = true;
    });
    
    // Feedback tátil
    HapticFeedback.selectionClick();
  }
  
  // Formata o valor para exibição de acordo com a moeda
  String _formatCurrency(int valueInCents) {
    final double valueInCurrency = valueInCents / 100.0;
    
    // Usar NumberFormat da biblioteca intl para formatação de números
    final formatter = NumberFormat.currency(
      symbol: _currencySymbol,
      decimalDigits: 2,
      locale: _currencyLocale,
    );
    
    // Formatar o valor
    return formatter.format(valueInCurrency);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final currentOnboarding = state.onboarding;
        
        if (currentOnboarding == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return OnboardingContainer(
          title: localizations.packPriceQuestion,
          subtitle: localizations.helpCalculateFinancial,
          contentType: OnboardingContentType.scrollable,
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    localizations.enterAveragePrice,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Widget principal de entrada de preço
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    color: context.isDarkMode ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isValid ? context.primaryColor : Colors.grey.withOpacity(0.3),
                      width: _isValid ? 2 : 1,
                    ),
                    boxShadow: [
                      if (!context.isDarkMode)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Área de exibição do valor
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Símbolo da moeda
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _currencySymbol,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: context.primaryColor,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Campo de entrada do valor
                            Expanded(
                              child: TextField(
                                controller: _priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                onChanged: _validateInput,
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: context.isDarkMode ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0,00',
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey.withOpacity(0.5),
                                    fontSize: 32,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                    // Permitir apenas um ponto decimal ou uma vírgula
                                    if (newValue.text.isEmpty) return newValue;
                                    
                                    String text = newValue.text;
                                    // Substitui vírgula por ponto
                                    if (text.contains(',')) {
                                      text = text.replaceAll('.', '');
                                      if (text.indexOf(',') != text.lastIndexOf(',')) {
                                        text = text.substring(0, text.lastIndexOf(',')) + 
                                              text.substring(text.lastIndexOf(',') + 1);
                                      }
                                      text = text.replaceFirst(',', '.');
                                    } else if (text.split('.').length > 2) {
                                      text = text.substring(0, text.lastIndexOf('.')) + 
                                            text.substring(text.lastIndexOf('.') + 1);
                                    }
                                    
                                    // Limita a 2 casas decimais
                                    final parts = text.split('.');
                                    if (parts.length > 1 && parts[1].length > 2) {
                                      text = '${parts[0]}.${parts[1].substring(0, 2)}';
                                    }
                                    
                                    return TextEditingValue(
                                      text: text,
                                      selection: TextSelection.collapsed(offset: text.length),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Controles de incremento/decremento
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIncrementButton(-1.0, Icons.remove),
                            const SizedBox(width: 8),
                            _buildIncrementButton(-0.1, Icons.remove, small: true),
                            const SizedBox(width: 8),
                            _buildIncrementButton(0.1, Icons.add, small: true),
                            const SizedBox(width: 8),
                            _buildIncrementButton(1.0, Icons.add),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Preços comuns
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    localizations.commonPrices,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Chips com preços comuns
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: _commonPrices.map((price) {
                    final formattedPrice = _formatCurrency(price * 100);
                    
                    final isSelected = (_currentValue - price).abs() < 0.01;
                    
                    return ActionChip(
                      elevation: isSelected ? 4 : 0,
                      backgroundColor: isSelected
                          ? context.primaryColor
                          : (context.isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                      side: BorderSide(
                        color: isSelected
                            ? context.primaryColor
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (context.isDarkMode ? Colors.white : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      label: Text(formattedPrice),
                      onPressed: () => _setPrice(price.toDouble()),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 20),
                
                // Preços personalizados + comuns
                if (_currentValue > 0 && !_commonPrices.contains(_currentValue.toInt()))
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ActionChip(
                        elevation: 4,
                        backgroundColor: context.primaryColor,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        label: Text(_formatCurrency((_currentValue * 100).round())),
                        onPressed: () => _setPrice(_currentValue),
                      ),
                    ],
                  ),

                const SizedBox(height: 32),
                
                // Texto informativo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    localizations.priceHelp,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Espaço adicional no final para evitar que o conteúdo fique coberto pelos botões
                const SizedBox(height: 20),
              ],
            ),
          ),
          onNext: () {
            if (_isValid) {
              // Converte o valor para centavos para armazenar no modelo
              final priceInCents = (_currentValue * 100).round();
              
              final updated = currentOnboarding.copyWith(
                packPrice: priceInCents,
              );
              
              // Enviar evento de atualização do onboarding
              context.read<OnboardingBloc>().add(UpdateOnboarding(updated));
              
              // Avançar para o próximo passo
              context.read<OnboardingBloc>().add(NextOnboardingStep());
            }
          },
          canProceed: _isValid,
        );
      },
    );
  }
  
  Widget _buildIncrementButton(double amount, IconData icon, {bool small = false}) {
    final bool isDecrease = amount < 0;
    final double absAmount = amount.abs();
    
    Color backgroundColor = isDecrease
        ? Colors.red.withOpacity(0.1)
        : context.primaryColor.withOpacity(0.1);
        
    Color iconColor = isDecrease
        ? Colors.red
        : context.primaryColor;
    
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(small ? 8 : 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(small ? 8 : 12),
        onTap: () => isDecrease
            ? _decrementValue(absAmount)
            : _incrementValue(absAmount),
        child: Container(
          padding: EdgeInsets.all(small ? 8 : 12),
          child: Icon(
            icon,
            size: small ? 16 : 24,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}