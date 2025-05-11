import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_event.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/settings/repositories/settings_repository.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// Tela para edição da quantidade de cigarros por dia antes de parar
class CigarettesPerDayScreen extends StatefulWidget {
  static const String routeName = '/settings/cigarettes-per-day';

  const CigarettesPerDayScreen({super.key});

  @override
  State<CigarettesPerDayScreen> createState() => _CigarettesPerDayScreenState();
}

class _CigarettesPerDayScreenState extends State<CigarettesPerDayScreen> {
  /// Controlador do campo de texto
  final TextEditingController _cigarettesController = TextEditingController();
  
  /// Foco do campo de texto
  final FocusNode _cigarettesFocusNode = FocusNode();
  
  /// Valor selecionado
  int _selectedValue = 0;
  
  /// Valores pré-definidos
  final List<int> _presetValues = [5, 10, 15, 20, 25, 30];
  
  /// Valor original carregado do banco de dados
  int _originalValue = 0;
  
  /// Controle de alteração de valor
  bool _valueChanged = false;
  
  @override
  void initState() {
    super.initState();
    
    // Carrega configurações ao iniciar
    context.read<SettingsBloc>().add(const LoadSettings());
    
    // Adiciona listener para mudanças no campo de texto
    _cigarettesController.addListener(_onCigarettesChanged);
  }
  
  @override
  void dispose() {
    _cigarettesController.removeListener(_onCigarettesChanged);
    _cigarettesController.dispose();
    _cigarettesFocusNode.dispose();
    super.dispose();
  }
  
  /// Reage a mudanças no campo de texto
  void _onCigarettesChanged() {
    if (_cigarettesController.text.isEmpty) {
      return;
    }
    
    try {
      final int value = int.parse(_cigarettesController.text);
      
      if (value != _originalValue && value > 0) {
        _selectedValue = value;
        _valueChanged = true;
        
        // Salva automaticamente após um curto delay para evitar chamadas excessivas
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (_valueChanged) {
            _saveCigarettesPerDay();
            _valueChanged = false;
            _originalValue = value;
          }
        });
      }
    } catch (e) {
      // Ignora erros de parsing
    }
  }
  
  /// Salva a quantidade de cigarros por dia
  void _saveCigarettesPerDay() {
    int cigarettesPerDay = _selectedValue;
    
    if (_cigarettesController.text.isNotEmpty) {
      try {
        cigarettesPerDay = int.parse(_cigarettesController.text);
      } catch (e) {
        // Usa o valor selecionado se houver erro no parsing
      }
    }
    
    if (cigarettesPerDay <= 0) {
      // Mostra erro se o valor for inválido
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).selectConsumptionLevelError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    context.read<SettingsBloc>().add(UpdateCigarettesPerDay(cigarettesPerDay: cigarettesPerDay));
  }
  
  /// Seleciona um valor pré-definido
  void _selectPresetValue(int value) {
    setState(() {
      _selectedValue = value;
      _cigarettesController.text = value.toString();
    });
    
    // Dispara o salvamento automático ao selecionar um valor predefinido
    if (value != _originalValue) {
      _valueChanged = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_valueChanged) {
          _saveCigarettesPerDay();
          _valueChanged = false;
          _originalValue = value;
        }
      });
    }
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
            if (_cigarettesController.text.isEmpty) {
              final cigarettesPerDay = state.settings.cigarettesPerDay;
              if (cigarettesPerDay > 0) {
                _cigarettesController.text = cigarettesPerDay.toString();
                setState(() {
                  _selectedValue = cigarettesPerDay;
                  _originalValue = cigarettesPerDay;
                });
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
                localizations.cigarettesPerDay,
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
                      localizations.cigarettesPerDayQuestion,
                      style: context.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Descrição
                    Text(
                      localizations.cigarettesPerDaySubtitle,
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: context.subtitleColor,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Campo de quantidade
                    TextField(
                      controller: _cigarettesController,
                      focusNode: _cigarettesFocusNode,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2), // Limita a 2 dígitos (até 99)
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _selectedValue = int.parse(value);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: '0',
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
                    
                    const SizedBox(height: 32),
                    
                    // Consumo por nível
                    Text(
                      localizations.selectConsumptionLevel,
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Níveis pré-definidos
                    Wrap(
                      spacing: 8,
                      runSpacing: 16,
                      children: [
                        // Baixo (até 5 cigarros por dia)
                        _buildConsumptionLevel(
                          title: localizations.low,
                          description: localizations.upTo5,
                          value: 5,
                        ),
                        
                        // Moderado (6 a 15 cigarros por dia)
                        _buildConsumptionLevel(
                          title: localizations.moderate,
                          description: localizations.sixTo15,
                          value: 10,
                        ),
                        
                        // Alto (16 a 25 cigarros por dia)
                        _buildConsumptionLevel(
                          title: localizations.high,
                          description: localizations.sixteenTo25,
                          value: 20,
                        ),
                        
                        // Muito alto (mais de 25 cigarros por dia)
                        _buildConsumptionLevel(
                          title: localizations.veryHigh,
                          description: localizations.moreThan25,
                          value: 30,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Valores pré-definidos específicos
                    Text(
                      localizations.exactNumber,
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botões de valores pré-definidos
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetValues.map((value) {
                        return _buildPresetValueButton(value);
                      }).toList(),
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
  
  /// Constrói um card para nível de consumo
  Widget _buildConsumptionLevel({
    required String title,
    required String description,
    required int value,
  }) {
    final isSelected = _selectedValue == value;
    
    return GestureDetector(
      onTap: () => _selectPresetValue(value),
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 24, // 2 colunas com margem
        decoration: BoxDecoration(
          color: isSelected 
              ? context.primaryColor.withOpacity(0.1) 
              : context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? context.primaryColor 
                : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.contentColor,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: context.primaryColor,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: context.textTheme.bodySmall!.copyWith(
                color: context.subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói um botão para valor pré-definido
  Widget _buildPresetValueButton(int value) {
    final isSelected = _selectedValue == value;
    
    return InkWell(
      onTap: () => _selectPresetValue(value),
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
          value.toString(),
          style: context.textTheme.bodyLarge!.copyWith(
            color: context.contentColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}