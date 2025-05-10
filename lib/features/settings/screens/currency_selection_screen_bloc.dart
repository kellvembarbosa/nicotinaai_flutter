import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_bloc.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_event.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/supported_currencies.dart';

/// Tela para seleção de moeda usando BLoC
class CurrencySelectionScreenBloc extends StatefulWidget {
  static const String routeName = '/settings/currency_bloc';

  const CurrencySelectionScreenBloc({super.key});

  @override
  State<CurrencySelectionScreenBloc> createState() => _CurrencySelectionScreenBlocState();
}

class _CurrencySelectionScreenBlocState extends State<CurrencySelectionScreenBloc> {
  /// Controle do campo de pesquisa
  final TextEditingController _searchController = TextEditingController();
  
  /// Lista filtrada de moedas
  List<CurrencyInfo> _filteredCurrencies = [];
  
  @override
  void initState() {
    super.initState();
    
    // Inicializa a lista de moedas filtradas
    _filteredCurrencies = SupportedCurrencies.all;
    
    // Adiciona listener para atualizar a lista filtrada
    _searchController.addListener(_filterCurrencies);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  /// Filtra a lista de moedas com base no texto de pesquisa
  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = SupportedCurrencies.all;
      } else {
        _filteredCurrencies = SupportedCurrencies.all.where((currency) {
          return currency.name.toLowerCase().contains(query) ||
                 currency.code.toLowerCase().contains(query) ||
                 currency.symbol.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return BlocConsumer<CurrencyBloc, CurrencyState>(
      listener: (context, state) {
        // Mostrar mensagem de erro se ocorrer algum erro
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
              localizations.currency,
              style: context.titleStyle,
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Campo de pesquisa
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: localizations.search,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      filled: true,
                      fillColor: context.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    style: context.textTheme.bodyMedium,
                  ),
                ),
                
                // Lista de moedas
                Expanded(
                  child: _filteredCurrencies.isEmpty
                      ? Center(
                          child: Text(
                            localizations.noResults,
                            style: context.textTheme.bodyLarge,
                          ),
                        )
                      : state.status == CurrencyStatus.loading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              itemCount: _filteredCurrencies.length,
                              itemBuilder: (context, index) {
                                final currency = _filteredCurrencies[index];
                                final isSelected = state.currencyCode == currency.code;
                                
                                return Card(
                                  elevation: 0,
                                  color: isSelected
                                      ? context.primaryColor.withOpacity(0.1)
                                      : context.cardColor,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 4.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected
                                          ? context.primaryColor
                                          : context.borderColor,
                                      width: isSelected ? 2.0 : 1.0,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      // Chama o evento para mudar a moeda
                                      context.read<CurrencyBloc>().add(
                                        ChangeCurrency(currency: currency),
                                      );
                                      
                                      // Volta para a tela anterior
                                      Navigator.of(context).pop();
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          // Símbolo da moeda
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: context.primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                currency.symbol,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: context.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          
                                          const SizedBox(width: 16.0),
                                          
                                          // Nome e código da moeda
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  currency.name,
                                                  style: context.textTheme.titleMedium!.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: context.contentColor,
                                                  ),
                                                ),
                                                Text(
                                                  currency.code,
                                                  style: context.textTheme.bodySmall!.copyWith(
                                                    color: context.subtitleColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // Indicador de seleção
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: context.primaryColor,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}