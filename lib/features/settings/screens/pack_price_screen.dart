import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_event.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/settings/repositories/settings_repository.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/currency_utils.dart';

/// Tela para edição do preço do maço de cigarros
class PackPriceScreen extends StatefulWidget {
  static const String routeName = '/settings/pack-price';

  const PackPriceScreen({super.key});

  @override
  State<PackPriceScreen> createState() => _PackPriceScreenState();
}

class _PackPriceScreenState extends State<PackPriceScreen> {
  /// Controlador do campo de texto
  final TextEditingController _priceController = TextEditingController();
  
  /// Foco do campo de texto
  final FocusNode _priceFocusNode = FocusNode();
  
  /// Formatador de moeda
  final CurrencyUtils _currencyUtils = CurrencyUtils();
  
  @override
  void initState() {
    super.initState();
    
    // Carrega configurações ao iniciar
    context.read<SettingsBloc>().add(const LoadSettings());
    
    // Atualiza valor do campo quando o preço muda
    _priceController.addListener(_onPriceChanged);
  }
  
  @override
  void dispose() {
    _priceController.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }
  
  // Variável para controlar se houve alteração de valor
  bool _valueChanged = false;
  
  // Valor original carregado do banco de dados
  int _originalPriceInCents = 0;
  
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
    final int valueInCents = int.parse(cleanValue);
    
    // Verifica se o valor mudou para habilitar o salvamento automático
    if (valueInCents != _originalPriceInCents) {
      _valueChanged = true;
      
      // Salva automaticamente após um curto delay para não fazer muitas chamadas
      // durante digitação rápida
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_valueChanged) {
          _savePackPrice();
          _valueChanged = false;
          _originalPriceInCents = valueInCents;
        }
      });
    }
    
    // Reposiciona o cursor após a formatação
    final int cursorPosition = _priceController.selection.start;
    
    // Formata o valor para exibição
    _priceController.text = _currencyUtils.format(valueInCents);
    
    // Reposiciona o cursor
    if (cursorPosition != -1) {
      _priceController.selection = TextSelection.fromPosition(
        TextPosition(offset: _priceController.text.length),
      );
    }
    
    // Reativa o listener
    _priceController.addListener(_onPriceChanged);
  }
  
  /// Salva o preço do maço
  void _savePackPrice() {
    final String textValue = _priceController.text;
    if (textValue.isEmpty) {
      return;
    }
    
    final int priceInCents = _currencyUtils.parseToCents(textValue);
    context.read<SettingsBloc>().add(UpdatePackPrice(priceInCents: priceInCents));
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
                _priceController.text = _currencyUtils.format(packPrice);
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da seção
                    Text(
                      localizations.packPriceQuestion,
                      style: context.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Descrição
                    Text(
                      localizations.setPriceForCalculations,
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: context.subtitleColor,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Campo de preço
                    TextField(
                      controller: _priceController,
                      focusNode: _priceFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                      decoration: InputDecoration(
                        hintText: '0,00',
                        hintStyle: context.textTheme.headlineMedium!.copyWith(
                          color: context.subtitleColor.withOpacity(0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: context.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 20.0,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Texto de ajuda
                    Text(
                      localizations.priceHelp,
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: context.subtitleColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Preços comuns
                    Text(
                      localizations.commonPrices,
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botões de preços comuns
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCommonPriceButton(1000), // R$ 10,00
                        _buildCommonPriceButton(1200), // R$ 12,00
                        _buildCommonPriceButton(1500), // R$ 15,00
                        _buildCommonPriceButton(1800), // R$ 18,00
                        _buildCommonPriceButton(2000), // R$ 20,00
                        _buildCommonPriceButton(2200), // R$ 22,00
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// Constrói um botão para preço comum
  Widget _buildCommonPriceButton(int priceInCents) {
    final bool isSelected = _originalPriceInCents == priceInCents;
    
    return InkWell(
      onTap: () {
        _priceController.text = _currencyUtils.format(priceInCents);
        
        // Dispara o salvamento automático se o valor for diferente
        if (_originalPriceInCents != priceInCents) {
          // Salva após um curto delay para que o campo seja atualizado
          Future.delayed(const Duration(milliseconds: 300), () {
            _savePackPrice();
            _originalPriceInCents = priceInCents;
          });
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? context.primaryColor.withOpacity(0.1) 
              : context.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? context.primaryColor 
                : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          _currencyUtils.format(priceInCents),
          style: context.textTheme.bodyMedium!.copyWith(
            color: context.contentColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}