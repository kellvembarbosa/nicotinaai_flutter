import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_event.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/settings/repositories/settings_repository.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// Tela para edição do preço do maço de cigarros (layout melhorado, similar ao onboarding)
class PackPriceScreenImproved extends StatefulWidget {
  static const String routeName = '/settings/pack-price';

  const PackPriceScreenImproved({super.key});

  @override
  State<PackPriceScreenImproved> createState() => _PackPriceScreenImprovedState();
}

class _PackPriceScreenImprovedState extends State<PackPriceScreenImproved> {
  /// Controlador do campo de texto
  final TextEditingController _priceController = TextEditingController();
  
  /// Foco do campo de texto
  final FocusNode _priceFocusNode = FocusNode();
  
  // Removido formatador de moeda direta em favor do CurrencyBloc
  
  /// Valor em centavos atual
  int _valueInCents = 0;
  
  /// Valor original carregado do banco de dados
  int _originalPriceInCents = 0;
  
  /// Controle de alteração de valor
  bool _valueChanged = false;
  
  /// Preços comuns pré-definidos (em centavos)
  final List<int> _commonPrices = [1000, 1200, 1500, 1800, 2000, 2500];

  @override
  void initState() {
    super.initState();
    
    // Carrega configurações ao iniciar
    context.read<SettingsBloc>().add(const LoadSettings());
    
    // Adiciona listener para campo de preço
    _priceController.addListener(_onPriceChanged);
  }
  
  @override
  void dispose() {
    _priceController.removeListener(_onPriceChanged);
    _priceController.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  /// Atualiza o valor formatado no campo quando o usuário digita
  void _onPriceChanged() {
    // Evita loop infinito removendo o listener temporariamente
    _priceController.removeListener(_onPriceChanged);
    
    final String textValue = _priceController.text;
    if (textValue.isEmpty) {
      _priceController.addListener(_onPriceChanged);
      return;
    }
    
    // Remove símbolos de moeda e formatação
    final cleanValue = textValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.isEmpty) {
      _priceController.text = '';
      _priceController.addListener(_onPriceChanged);
      return;
    }
    
    // Converte para centavos (considerando que os últimos 2 dígitos são centavos)
    _valueInCents = int.parse(cleanValue);
    
    // Verifica se o valor mudou para habilitar o salvamento automático
    if (_valueInCents != _originalPriceInCents) {
      _valueChanged = true;
      
      // Salva automaticamente após um curto delay para não fazer muitas chamadas
      // durante digitação rápida
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_valueChanged) {
          _savePackPrice();
          _valueChanged = false;
          _originalPriceInCents = _valueInCents;
        }
      });
    }
    
    // Reposiciona o cursor após a formatação
    final int cursorPosition = _priceController.selection.start;
    
    // Formata o valor para exibição usando a moeda preferencial do usuário
    _priceController.text = context.read<CurrencyBloc>().format(_valueInCents);
    
    // Reposiciona o cursor
    if (cursorPosition != -1) {
      _priceController.selection = TextSelection.fromPosition(
        TextPosition(offset: _priceController.text.length),
      );
    }
    
    // Reativa o listener
    _priceController.addListener(_onPriceChanged);
  }
  
  /// Incrementa ou decrementa o valor em centavos
  void _adjustValue(int adjustment) {
    // Calcula o novo valor
    final int newValue = _valueInCents + adjustment;
    
    // Verifica se o valor é válido (maior que zero)
    if (newValue <= 0) {
      return;
    }
    
    // Atualiza o campo usando a moeda preferencial do usuário
    _priceController.text = context.read<CurrencyBloc>().format(newValue);
    
    // Feedback tátil
    HapticFeedback.lightImpact();
  }
  
  /// Salva o preço do maço
  void _savePackPrice() {
    if (_valueInCents <= 0) {
      return;
    }
    
    context.read<SettingsBloc>().add(UpdatePackPrice(priceInCents: _valueInCents));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return BlocProvider(
      create: (context) => SettingsBloc(
        settingsRepository: SettingsRepository(),
      )..add(const LoadSettings()),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.success && !state.isLoading) {
            // Atualiza o campo com o valor atual quando o estado é carregado
            if (_priceController.text.isEmpty) {
              final packPrice = state.settings.packPriceInCents;
              if (packPrice > 0) {
                _priceController.text = context.read<CurrencyBloc>().format(packPrice);
                _valueInCents = packPrice;
                _originalPriceInCents = packPrice;
              }
            }
            
            // Mostra mensagem de sucesso ao salvar sem fechar a tela
            if (state.status == SettingsStatus.success && state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
          
          // Mostra erro se houver
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.backgroundColor,
            appBar: AppBar(
              backgroundColor: context.backgroundColor,
              title: Text(
                localizations.packPrice,
                style: context.titleStyle,
              ),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                // Indicador de carregamento
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Título da seção
                      Text(
                        localizations.packPriceQuestion,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.contentColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Descrição
                      Text(
                        localizations.setPriceForCalculations,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: context.subtitleColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Widget principal de entrada de preço
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _valueInCents > 0 ? context.primaryColor : Colors.grey.withOpacity(0.3),
                            width: _valueInCents > 0 ? 2 : 1,
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
                                      context.read<CurrencyBloc>().state.currencySymbol,
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
                                      focusNode: _priceFocusNode,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
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
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildIncrementButton(-100, Icons.remove),
                                  const SizedBox(width: 8),
                                  _buildIncrementButton(-10, Icons.remove, small: true),
                                  const SizedBox(width: 8),
                                  _buildIncrementButton(10, Icons.add, small: true),
                                  const SizedBox(width: 8),
                                  _buildIncrementButton(100, Icons.add),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Preços comuns
                      Text(
                        localizations.commonPrices,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: context.contentColor,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Chips com preços comuns
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: _commonPrices.map((price) {
                          final isSelected = _valueInCents == price;
                          
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
                            label: Text(context.read<CurrencyBloc>().format(price)),
                            onPressed: () {
                              // Atualiza o preço diretamente
                              _priceController.text = context.read<CurrencyBloc>().format(price);
                              
                              // Dispara o salvamento automático se o valor for diferente
                              if (_originalPriceInCents != price) {
                                _valueChanged = true;
                                _valueInCents = price;
                                
                                // Salva após um curto delay para que o campo seja atualizado
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  if (_valueChanged) {
                                    _savePackPrice();
                                    _valueChanged = false;
                                    _originalPriceInCents = price;
                                  }
                                });
                              }
                              
                              // Feedback tátil
                              HapticFeedback.selectionClick();
                            },
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Texto de ajuda
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          localizations.priceHelp,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// Constrói um botão para incremento/decremento
  Widget _buildIncrementButton(int amount, IconData icon, {bool small = false}) {
    final bool isDecrease = amount < 0;
    
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
        onTap: () => _adjustValue(amount),
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