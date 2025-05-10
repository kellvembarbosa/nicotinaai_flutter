import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/supported_currencies.dart';
import 'package:flutter/services.dart';

class CurrencySelectionScreen extends StatefulWidget {
  const CurrencySelectionScreen({super.key});

  @override
  State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  String? _selectedCurrency;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final currentOnboarding = provider.state.onboarding;
    
    // Inicializa com a moeda já salva ou usa a moeda padrão
    _selectedCurrency = currentOnboarding?.packPriceCurrency ?? SupportedCurrencies.defaultCurrency.code;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      } else {
        // Dar foco ao campo de busca quando ativar
        // Usando um FocusNode em vez de acessar context em um Future
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(FocusNode());
        });
      }
    });
  }
  
  List<CurrencyInfo> _getFilteredCurrencies() {
    if (_searchQuery.isEmpty) {
      return SupportedCurrencies.all;
    }
    
    return SupportedCurrencies.all.where((currency) {
      return currency.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             currency.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             currency.symbol.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final currentOnboarding = provider.state.onboarding;
    final localizations = AppLocalizations.of(context);
    
    if (currentOnboarding == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final filteredCurrencies = _getFilteredCurrencies();
    
    return OnboardingContainer(
      title: localizations.selectCurrency,
      subtitle: localizations.selectCurrencySubtitle,
      contentType: OnboardingContentType.list,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Opção para pesquisar
          if (!_isSearching)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _toggleSearch,
                tooltip: localizations.search,
              ),
            ),
          
          // Barra de busca
          if (_isSearching)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: localizations.search,
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleSearch,
                  ),
                ),
                autofocus: true,
              ),
            ),
            
          // Texto informativo com padding reduzido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              localizations.preselectedCurrency,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Área de lista - preenche o espaço disponível restante
          Expanded(
            child: filteredCurrencies.isEmpty
                ? Center(
                    child: Text(
                      localizations.noResults,
                      style: context.textTheme.titleMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    itemCount: filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = filteredCurrencies[index];
                      final isSelected = currency.code == _selectedCurrency;
                      
                      return Card(
                        elevation: isSelected ? 2 : 0,
                        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected 
                                ? context.primaryColor 
                                : Colors.grey.withAlpha(77), // 0.3 alpha ~= 77/255
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCurrency = currency.code;
                              // Dar feedback tátil ao selecionar
                              HapticFeedback.selectionClick();
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            child: Row(
                              children: [
                                // Símbolo da moeda em destaque
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: context.primaryColor.withAlpha(26), // 0.1 alpha ~= 26/255
                                    borderRadius: BorderRadius.circular(12),
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
                                
                                const SizedBox(width: 12),
                                
                                // Informações da moeda
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currency.name,
                                        style: context.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        currency.code,
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Ícone de selecionado
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: context.primaryColor,
                                    size: 24,
                                  )
                                else
                                  const SizedBox(width: 24),
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
      onNext: () async {
        if (_selectedCurrency != null) {
          final currencyInfo = SupportedCurrencies.getByCurrencyCode(_selectedCurrency!);
          if (currencyInfo != null) {
            final updated = currentOnboarding.copyWith(
              packPriceCurrency: currencyInfo.code,
              additionalData: {
                ...currentOnboarding.additionalData,
                'currency_symbol': currencyInfo.symbol,
                'currency_locale': currencyInfo.locale,
              },
            );
            
            await provider.updateOnboarding(updated);
            provider.nextStep();
          }
        }
      },
      canProceed: _selectedCurrency != null,
    );
  }
}