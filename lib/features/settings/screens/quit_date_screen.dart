import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_event.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/settings/repositories/settings_repository.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// Tela para edição da data em que o usuário parou de fumar
class QuitDateScreen extends StatefulWidget {
  static const String routeName = '/settings/quit-date';

  const QuitDateScreen({super.key});

  @override
  State<QuitDateScreen> createState() => _QuitDateScreenState();
}

class _QuitDateScreenState extends State<QuitDateScreen> {
  /// Data selecionada
  DateTime? _selectedDate;
  
  /// Data original do banco de dados
  DateTime? _originalDate;
  
  /// Formatador de data
  final DateFormat _dateFormat = DateFormat.yMMMd();
  
  @override
  void initState() {
    super.initState();
    
    // Carrega configurações ao iniciar
    context.read<SettingsBloc>().add(const LoadSettings());
  }
  
  /// Mostra seletor de data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.primaryColor,
              onPrimary: Colors.white,
              onSurface: context.contentColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: context.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      // Salva automaticamente ao selecionar uma data
      if (_areDatesDifferent(_selectedDate, _originalDate)) {
        _saveQuitDate();
      }
    }
  }
  
  /// Verifica se as datas são diferentes
  bool _areDatesDifferent(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return false;
    if (date1 == null || date2 == null) return true;
    
    return date1.year != date2.year || 
           date1.month != date2.month || 
           date1.day != date2.day;
  }
  
  /// Salva a data em que o usuário parou de fumar
  void _saveQuitDate() {
    context.read<SettingsBloc>().add(UpdateQuitDate(quitDate: _selectedDate));
    _originalDate = _selectedDate;
  }
  
  /// Limpa a data selecionada
  void _clearDate() {
    if (_selectedDate != null) {
      setState(() {
        _selectedDate = null;
      });
      
      // Salva como nulo para limpar no banco de dados
      context.read<SettingsBloc>().add(const UpdateQuitDate(quitDate: null));
      _originalDate = null;
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
            // Atualiza a data selecionada quando o estado é carregado
            if (_selectedDate == null) {
              final quitDate = state.settings.quitDate;
              if (quitDate != null) {
                setState(() {
                  _selectedDate = quitDate;
                  _originalDate = quitDate;
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
                localizations.startDate,
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
                      localizations.whenYouQuitSmoking,
                      style: context.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Descrição
                    Text(
                      localizations.establishDeadline,
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: context.subtitleColor,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Exibição da data selecionada
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Column(
                        children: [
                          // Ícone de calendário
                          Icon(
                            Icons.calendar_today,
                            size: 48,
                            color: context.primaryColor,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Data selecionada ou texto padrão
                          Text(
                            _selectedDate != null
                                ? _dateFormat.format(_selectedDate!)
                                : localizations.selectApplicable,
                            style: context.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Dias sem fumar (se houver data selecionada)
                          if (_selectedDate != null)
                            Text(
                              localizations.daysSmokeFree(
                                DateTime.now().difference(_selectedDate!).inDays,
                              ),
                              style: context.textTheme.titleMedium!.copyWith(
                                color: context.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // Botão para selecionar data
                          ElevatedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.edit_calendar),
                            label: Text(
                              _selectedDate != null
                                  ? localizations.changeDate
                                  : localizations.selectDate,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          
                          // Botão para limpar data (se houver data selecionada)
                          if (_selectedDate != null)
                            TextButton.icon(
                              onPressed: _clearDate,
                              icon: const Icon(Icons.clear),
                              label: Text(localizations.clearDate),
                              style: TextButton.styleFrom(
                                foregroundColor: context.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Datas sugeridas
                    Text(
                      localizations.suggestedDates,
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Lista de datas sugeridas
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Hoje
                        _buildDateSuggestionChip(
                          date: DateTime.now(),
                          label: localizations.today,
                        ),
                        
                        // Ontem
                        _buildDateSuggestionChip(
                          date: DateTime.now().subtract(const Duration(days: 1)),
                          label: localizations.yesterday,
                        ),
                        
                        // Uma semana atrás
                        _buildDateSuggestionChip(
                          date: DateTime.now().subtract(const Duration(days: 7)),
                          label: localizations.oneWeekAgo,
                        ),
                        
                        // Duas semanas atrás
                        _buildDateSuggestionChip(
                          date: DateTime.now().subtract(const Duration(days: 14)),
                          label: localizations.twoWeeksAgo,
                        ),
                        
                        // Um mês atrás
                        _buildDateSuggestionChip(
                          date: DateTime.now().subtract(const Duration(days: 30)),
                          label: localizations.oneMonthAgo,
                        ),
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
  
  /// Constrói um chip para data sugerida
  Widget _buildDateSuggestionChip({
    required DateTime date,
    required String label,
  }) {
    final bool isSelected = _selectedDate != null && 
        _selectedDate!.year == date.year && 
        _selectedDate!.month == date.month && 
        _selectedDate!.day == date.day;
    
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      avatar: Icon(
        Icons.calendar_today_outlined,
        size: 16,
        color: isSelected ? Colors.white : context.subtitleColor,
      ),
      onSelected: (selected) {
        if (selected) {
          final newDate = DateTime(date.year, date.month, date.day);
          setState(() {
            _selectedDate = newDate;
          });
          
          // Salva automaticamente a data selecionada
          if (_areDatesDifferent(newDate, _originalDate)) {
            _saveQuitDate();
          }
        }
      },
      backgroundColor: context.cardColor,
      selectedColor: context.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : context.contentColor,
      ),
      side: BorderSide(
        color: isSelected ? context.primaryColor : context.borderColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

// Extensão para adicionar strings que não estão no AppLocalizations
extension _QuitDateLocalizations on AppLocalizations {
  String get changeDate => 'Change date';
  String get selectDate => 'Select date';
  String get clearDate => 'Clear date';
  String get suggestedDates => 'Suggested dates';
  String get today => 'Today';
  String get yesterday => 'Yesterday';
  String get oneWeekAgo => 'One week ago';
  String get twoWeeksAgo => 'Two weeks ago';
  String get oneMonthAgo => 'One month ago';
}