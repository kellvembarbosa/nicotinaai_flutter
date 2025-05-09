import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';
import 'package:nicotinaai_flutter/features/home/providers/smoking_record_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/supabase_diagnostic.dart';
import 'package:nicotinaai_flutter/services/migration_service.dart';

class NewRecordSheet extends StatefulWidget {
  const NewRecordSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewRecordSheet(),
    );
    // Retorna true se um record foi registrado com sucesso
    return result ?? false;
  }

  @override
  State<NewRecordSheet> createState() => _NewRecordSheetState();
}

class _NewRecordSheetState extends State<NewRecordSheet> {
  final TextEditingController _notesController = TextEditingController();
  String? _selectedReason;
  String? _selectedAmount;
  String? _selectedDuration;

  // Controles para as seções minimizáveis
  bool _isReasonSectionExpanded = true;
  bool _isAmountDurationSectionExpanded = true;
  bool _isNotesSectionExpanded = true;

  // Controles para as subseções dentro da seção de quantidade/duração
  bool _isAmountSubSectionVisible = true;
  bool _isDurationSubSectionVisible = false;

  @override
  void initState() {
    super.initState();
    // Adiciona listener para o controller de notas
    _notesController.addListener(() {
      setState(() {
        // Força reconstrução quando o texto muda para atualizar o resumo
      });
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Método para atualizar o estado de expansão das seções
  void _updateSectionStates() {
    setState(() {
      // Quando o usuário seleciona um motivo, minimiza essa seção e expande a próxima
      if (_selectedReason != null && _isReasonSectionExpanded) {
        _isReasonSectionExpanded = false;
        _isAmountDurationSectionExpanded = true;
      }

      // Quando o usuário completa quantidade e duração, minimiza essa seção e expande a de notas
      if (_selectedAmount != null &&
          _selectedDuration != null &&
          _isAmountDurationSectionExpanded) {
        _isAmountDurationSectionExpanded = false;
        _isNotesSectionExpanded = true;
      }
    });
  }

  // Separar a atualização de subseções dentro da seção de quantidade/duração
  void _updateAmountDurationSubSections() {
    setState(() {
      if (_selectedAmount != null && _selectedDuration == null) {
        // Se houver uma quantidade selecionada mas não uma duração,
        // minimiza a seção de quantidade e exibe a seção de duração
        _isAmountSubSectionVisible = false;
        _isDurationSubSectionVisible = true;
      } else if (_selectedAmount != null && _selectedDuration != null) {
        // Se ambos estiverem selecionados, minimiza ambas as subseções
        _isAmountSubSectionVisible = false;
        _isDurationSubSectionVisible = false;
      } else {
        // Estado inicial ou reset
        _isAmountSubSectionVisible = true;
        _isDurationSubSectionVisible = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Tamanho específico para esta sheet 
    const initialSize = 0.80; // 80% da altura da tela

    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false, // Permite que o conteúdo determine o tamanho natural
      snap: true, // Facilita o ajuste para posições específicas
      snapSizes: const [
        0.65,
        0.8,
        0.95,
      ], // Manter as opções de snap para dar flexibilidade ao usuário
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Scrollable content com layout otimizado
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    _buildHandle(context),

                    // Título principal otimizado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      decoration: BoxDecoration(
                        color:
                            context.isDarkMode
                                ? Colors.blue.withOpacity(0.15)
                                : Colors.blue.withOpacity(0.08),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.newRecord,
                            style: context.titleStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            l10n.newRecordSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  context.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Seção de Razão - Minimizável
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color:
                            context.isDarkMode
                                ? Colors.grey[850]
                                : Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                _selectedReason != null
                                    ? Colors.blue
                                    : context.isDarkMode
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!,
                            width: _selectedReason != null ? 1.5 : 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabeçalho clicável para expandir/colapsar
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isReasonSectionExpanded =
                                      !_isReasonSectionExpanded;
                                });
                              },
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.help_outline,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        l10n.whatsTheReason,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    if (_selectedReason != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          _getReasonLabel(_selectedReason!),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _isReasonSectionExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Conteúdo expansível
                            if (_isReasonSectionExpanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  12,
                                ),
                                child: _buildReasonGrid(context, l10n),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Seção de Quantidade e Duração - Minimizável
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color:
                            context.isDarkMode
                                ? Colors.grey[850]
                                : Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                (_selectedAmount != null &&
                                        _selectedDuration != null)
                                    ? Colors.blue
                                    : context.isDarkMode
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!,
                            width:
                                (_selectedAmount != null &&
                                        _selectedDuration != null)
                                    ? 1.5
                                    : 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabeçalho clicável para expandir/colapsar
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isAmountDurationSectionExpanded =
                                      !_isAmountDurationSectionExpanded;
                                });
                              },
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.smoking_rooms_outlined,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "${l10n.howMuchDidYouSmoke} & ${l10n.howLongDidItLast}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    if (_selectedAmount != null &&
                                        _selectedDuration != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              "${_getAmountLabel(_selectedAmount!)} • ${_getDurationLabel(_selectedDuration!)}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _isAmountDurationSectionExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Conteúdo expansível
                            if (_isAmountDurationSectionExpanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Quantidade - Versão normal ou minimizada
                                    if (_isAmountSubSectionVisible)
                                      // Versão completa da subseção de quantidade
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Label para quantidade
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.smoking_rooms_outlined,
                                                  size: 18,
                                                  color: Colors.blue,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    l10n.howMuchDidYouSmoke,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            _buildAmountOptionsVertical(
                                              context,
                                              l10n,
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (_selectedAmount != null)
                                      // Versão minimizada da subseção de quantidade
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isAmountSubSectionVisible = true;
                                            _isDurationSubSectionVisible =
                                                false;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.blue.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.smoking_rooms_outlined,
                                                  size: 16,
                                                  color: Colors.blue,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "${l10n.howMuchDidYouSmoke}: ${_getAmountLabel(_selectedAmount!)}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.edit,
                                                  size: 14,
                                                  color: Colors.blue,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Duração - Versão normal ou minimizada
                                    if (_isDurationSubSectionVisible)
                                      // Versão completa da subseção de duração
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Label para duração
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.timer_outlined,
                                                size: 18,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  l10n.howLongDidItLast,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _buildDurationOptionsVertical(
                                            context,
                                            l10n,
                                          ),
                                        ],
                                      )
                                    else if (_selectedDuration != null)
                                      // Versão minimizada da subseção de duração
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isDurationSubSectionVisible = true;
                                            _isAmountSubSectionVisible = false;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.blue.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.timer_outlined,
                                                  size: 16,
                                                  color: Colors.blue,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "${l10n.howLongDidItLast}: ${_getDurationLabel(_selectedDuration!)}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.edit,
                                                  size: 14,
                                                  color: Colors.blue,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Seção de Notas - Minimizável
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color:
                            context.isDarkMode
                                ? Colors.grey[850]
                                : Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                _notesController.text.isNotEmpty
                                    ? Colors.blue
                                    : context.isDarkMode
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!,
                            width: _notesController.text.isNotEmpty ? 1.5 : 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabeçalho clicável para expandir/colapsar
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isNotesSectionExpanded =
                                      !_isNotesSectionExpanded;
                                });
                              },
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.note_outlined,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        l10n.notes,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    if (_notesController.text.isNotEmpty)
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.3,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          _notesController.text.length > 15
                                              ? "${_notesController.text.substring(0, 15)}..."
                                              : _notesController.text,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _isNotesSectionExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Conteúdo expansível
                            if (_isNotesSectionExpanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  12,
                                ),
                                child: _buildNotesField(context, l10n),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Extra space at the bottom
                    const SizedBox(height: 70), // Reduzido de 90 para 70
                  ],
                ),
              ),

              // Botão de registro otimizado
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 16 + MediaQuery.of(context).padding.bottom,
                  top: 8,
                ),
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      offset: const Offset(0, -3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mensagem de erro compacta
                    if (!_isFormValid())
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getValidationMessage(l10n),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Botão de registro com elevation e gradiente
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            _isFormValid()
                                ? _saveRecord
                                : () {
                                  // Mensagem de erro em caso de formulário inválido
                                  final message = _getValidationMessage(l10n);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          disabledBackgroundColor: Colors.grey[300],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: 4,
                          shadowColor: Colors.blue.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.blue.shade800],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.smoking_rooms_outlined,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.register,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isFormValid() {
    return _selectedReason != null &&
        _selectedAmount != null &&
        _selectedDuration != null;
  }

  // Método para obter o rótulo legível para um valor de razão selecionado
  String _getReasonLabel(String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'stress':
        return l10n.stress;
      case 'anxiety':
        return l10n.anxiety;
      case 'coffee':
        return l10n.coffee;
      case 'alcohol':
        return l10n.alcohol;
      default:
        return value;
    }
  }

  // Método para obter o rótulo legível para um valor de quantidade
  String _getAmountLabel(String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'one_or_less':
        return l10n.oneOrLess;
      case 'two_to_five':
        return l10n.twoToFive;
      case 'more_than_five':
        return l10n.moreThanFive;
      default:
        return value;
    }
  }

  // Método para obter o rótulo legível para um valor de duração
  String _getDurationLabel(String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'less_than_5min':
        return l10n.lessThan5min;
      case '5_to_15min':
        return l10n.fiveToFifteenMin;
      case 'more_than_15min':
        return l10n.moreThan15min;
      default:
        return value;
    }
  }

  String _getValidationMessage(AppLocalizations l10n) {
    if (_selectedReason == null) {
      return l10n.pleaseSelectReason;
    } else if (_selectedAmount == null) {
      return l10n.pleaseSelectAmount;
    } else if (_selectedDuration == null) {
      return l10n.pleaseSelectDuration;
    }
    return "";
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      height: 24,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(77),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Botão de fechar no canto direito
          Positioned(
            top: 0,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.close, size: 18, color: Colors.grey[600]),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              splashRadius: 20,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonGrid(BuildContext context, AppLocalizations l10n) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final reasons = [
      _ReasonOption(
        icon: Icons.psychology,
        label: l10n.stress,
        value: 'stress',
      ),
      _ReasonOption(icon: Icons.coffee, label: l10n.coffee, value: 'coffee'),
      _ReasonOption(
        icon: Icons.sentiment_very_dissatisfied,
        label: l10n.anxiety,
        value: 'anxiety',
      ),
      _ReasonOption(
        icon: Icons.wine_bar,
        label: l10n.alcohol,
        value: 'alcohol',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
            isSmallScreen ? 2.5 : 2.2, // Mais compacto para telas pequenas
        crossAxisSpacing: isSmallScreen ? 10 : 12,
        mainAxisSpacing: isSmallScreen ? 10 : 12,
      ),
      itemCount: reasons.length,
      itemBuilder: (context, index) {
        final reason = reasons[index];
        return _buildReasonOption(
          context,
          reason.icon,
          reason.label,
          reason.value,
        );
      },
    );
  }

  Widget _buildReasonOption(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final isSelected = _selectedReason == value;
    final color = context.primaryColor;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ajustes adaptativos baseados na altura da tela
    final bool isSmallScreen = screenHeight < 700;
    final double iconSize = isSmallScreen ? 20 : 24;
    final double fontSize = isSmallScreen ? 14 : 16;
    final double vertPadding = isSmallScreen ? 8 : 12;
    final double horzPadding = isSmallScreen ? 10 : 12;
    final double spacing = isSmallScreen ? 8 : 12;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedReason = value;
          // Atualiza o estado das seções quando o usuário seleciona um motivo
          _updateSectionStates();
        });
      },
      borderRadius: BorderRadius.circular(12), // Reduzido de 16 para 12
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: vertPadding,
          horizontal: horzPadding,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withOpacity(0.1)
                  : context.isDarkMode
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12), // Reduzido de 16 para 12
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? color
                      : context.isDarkMode
                      ? Colors.white
                      : Colors.grey[800],
              size: iconSize,
            ),
            SizedBox(width: spacing),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : context.contentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField(BuildContext context, AppLocalizations l10n) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Container(
      decoration: BoxDecoration(
        color:
            context.isDarkMode
                ? Colors.grey.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              context.isDarkMode
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: isSmallScreen ? 2 : 3, // Ajustado para telas pequenas
        minLines: 1,
        decoration: InputDecoration(
          hintText: l10n.howDoYouFeel,
          hintStyle: TextStyle(
            color: context.subtitleColor,
            fontSize: isSmallScreen ? 12 : 13,
          ),
          contentPadding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Manter o método antigo para backward compatibility
  Widget _buildAmountOptions(BuildContext context, AppLocalizations l10n) {
    final amounts = [
      _AmountOption(label: l10n.oneOrLess, value: 'one_or_less'),
      _AmountOption(label: l10n.twoToFive, value: 'two_to_five'),
      _AmountOption(label: l10n.moreThanFive, value: 'more_than_five'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          amounts
              .map(
                (amount) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildOptionButton(
                      context,
                      amount.label,
                      amount.value,
                      _selectedAmount == amount.value,
                      (value) {
                        setState(() {
                          _selectedAmount = value ? amount.value : null;
                        });
                      },
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  // Novo método para layout vertical
  Widget _buildAmountOptionsVertical(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final amounts = [
      _AmountOption(label: l10n.oneOrLess, value: 'one_or_less'),
      _AmountOption(label: l10n.twoToFive, value: 'two_to_five'),
      _AmountOption(label: l10n.moreThanFive, value: 'more_than_five'),
    ];

    return Column(
      children:
          amounts
              .map(
                (amount) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildOptionButtonVertical(
                    context,
                    amount.label,
                    amount.value,
                    _selectedAmount == amount.value,
                    (value) {
                      setState(() {
                        _selectedAmount = value ? amount.value : null;
                        // Atualiza as seções e subseções quando o usuário faz uma seleção
                        _updateSectionStates();
                        _updateAmountDurationSubSections();
                      });
                    },
                  ),
                ),
              )
              .toList(),
    );
  }

  // Manter o método antigo para backward compatibility
  Widget _buildDurationOptions(BuildContext context, AppLocalizations l10n) {
    final durations = [
      _DurationOption(label: l10n.lessThan5min, value: 'less_than_5min'),
      _DurationOption(label: l10n.fiveToFifteenMin, value: '5_to_15min'),
      _DurationOption(label: l10n.moreThan15min, value: 'more_than_15min'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          durations
              .map(
                (duration) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildOptionButton(
                      context,
                      duration.label,
                      duration.value,
                      _selectedDuration == duration.value,
                      (value) {
                        setState(() {
                          _selectedDuration = value ? duration.value : null;
                        });
                      },
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  // Novo método para layout vertical
  Widget _buildDurationOptionsVertical(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final durations = [
      _DurationOption(label: l10n.lessThan5min, value: 'less_than_5min'),
      _DurationOption(label: l10n.fiveToFifteenMin, value: '5_to_15min'),
      _DurationOption(label: l10n.moreThan15min, value: 'more_than_15min'),
    ];

    return Column(
      children:
          durations
              .map(
                (duration) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildOptionButtonVertical(
                    context,
                    duration.label,
                    duration.value,
                    _selectedDuration == duration.value,
                    (value) {
                      setState(() {
                        _selectedDuration = value ? duration.value : null;
                        // Atualiza as seções quando o usuário faz uma seleção
                        _updateSectionStates();
                        _updateAmountDurationSubSections();
                      });
                    },
                  ),
                ),
              )
              .toList(),
    );
  }

  // Botão de opção vertical de largura total
  Widget _buildOptionButtonVertical(
    BuildContext context,
    String label,
    String value,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    final color = context.primaryColor;

    return InkWell(
      onTap: () {
        onSelected(!isSelected);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withOpacity(0.2)
                  : context.isDarkMode
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Indicador de seleção
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child:
                  isSelected
                      ? const Center(
                        child: Icon(Icons.check, size: 14, color: Colors.white),
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            // Texto da opção
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : context.contentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String label,
    String value,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    final color = context.primaryColor;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    // Ajustes para telas pequenas
    final double fontSize =
        isSmallScreen
            ? 13
            : 16; // Aumentamos o tamanho da fonte para melhor legibilidade
    final double vertPadding =
        isSmallScreen ? 10 : 14; // Aumentamos o padding para toques mais fáceis
    final double horzPadding =
        isSmallScreen ? 8 : 10; // Aumentamos o padding horizontal

    return InkWell(
      onTap: () {
        onSelected(!isSelected);
        // Atualiza as seções quando o usuário faz uma seleção
        _updateSectionStates();
      },
      borderRadius: BorderRadius.circular(12), // Reduzido para 12
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: vertPadding,
          horizontal: horzPadding,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withOpacity(0.2)
                  : context.isDarkMode
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12), // Reduzido para 12
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : context.contentColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _saveRecord() async {
    if (!_isFormValid()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recordProvider = Provider.of<SmokingRecordProvider>(
      context,
      listen: false,
    );
    final trackingProvider = Provider.of<TrackingProvider>(
      context,
      listen: false,
    );
    final l10n = AppLocalizations.of(context);

    final userId = authProvider.currentUser?.id ?? '';
    if (userId.isEmpty) {
      // Cannot save if not authenticated
      Navigator.of(context).pop();
      return;
    }

    // Verificar se a tabela existe antes de tentar salvar
    final isTableAccessible = await SupabaseDiagnostic.isTableAccessible(
      'smoking_logs',
    );
    if (!isTableAccessible) {
      // Execute o diagnóstico completo em caso de problemas
      if (kDebugMode) {
        print('🔍 Tabela não acessível. Executando diagnóstico completo...');
        await SupabaseDiagnostic.logDiagnosticReport();
      }

      // Mostre mensagem e não continue se a tabela não for acessível
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro: Tabela smoking_logs não encontrada. Verifique as migrações.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    final record = SmokingRecordModel(
      reason: _selectedReason!,
      amount: _selectedAmount!,
      duration: _selectedDuration!,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      timestamp: DateTime.now(),
      userId: userId,
    );

    // Prepare snackbar content before dismissing the sheet
    final successMessage = l10n.recordSaved;
    final retryLabel = l10n.retry;

    // Store current context's scaffold messenger
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Tenta verificar se a tabela existe e criá-la em caso de necessidade
    if (!isTableAccessible) {
      final tableFixed = await MigrationService.ensureTableExists(
        'smoking_logs',
      );
      if (tableFixed) {
        if (kDebugMode) {
          print('✅ Tabela smoking_logs criada e agora está acessível');
        }
      } else {
        if (kDebugMode) {
          print('❌ Não foi possível criar a tabela smoking_logs');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro: Não foi possível criar a tabela necessária. Entre em contato com o suporte.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }
    }

    // Configurar a referência ao TrackingProvider no SmokingRecordProvider
    // para permitir a atualização da última data de fumo
    recordProvider.trackingProvider = trackingProvider;

    // Close the sheet immediately for better UX with success result
    Navigator.of(context).pop(true);

    try {
      if (kDebugMode) {
        print('🔍 Tentando salvar registro...');
      }

      // Optimistically update the UI and save in the background
      // O recordProvider agora irá atualizar a última data de fumo internamente
      await recordProvider.saveRecord(record);

      // Explicitamente forçar a atualização das estatísticas no TrackingProvider após salvar
      // para garantir que a data do último cigarro seja atualizada imediatamente
      if (kDebugMode) {
        print(
          '🔄 Forçando atualização das estatísticas após salvar registro...',
        );
      }
      await trackingProvider.forceUpdateStats();

      // Show a success snackbar using the stored scaffold messenger
      // This avoids the mounted check which can cause issues
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
          action:
              recordProvider.error != null
                  ? SnackBarAction(
                    label: retryLabel,
                    onPressed: () {
                      // Find the failed record and retry
                      final failedRecord =
                          recordProvider.failedRecords.firstOrNull;
                      if (failedRecord != null) {
                        recordProvider.retrySyncRecord(failedRecord.id!);
                      }
                    },
                  )
                  : null,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving record: $e');
      }

      // Tenta identificar o tipo de erro
      String errorMsg = 'Error: ${e.toString()}';

      // Caso especial para erro 404
      if (e.toString().contains('404') && e.toString().contains('Not Found')) {
        errorMsg =
            'Erro 404: Tabela não encontrada. Verifique se o banco de dados está configurado corretamente.';
        print('👀 Detalhes completos do erro: $e');

        // Executar diagnóstico para ajudar a identificar o problema
        if (kDebugMode) {
          print('🔍 Executando diagnóstico após erro 404...');
          SupabaseDiagnostic.logDiagnosticReport();
        }
      }

      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

class _ReasonOption {
  final IconData icon;
  final String label;
  final String value;

  const _ReasonOption({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _AmountOption {
  final String label;
  final String value;

  const _AmountOption({required this.label, required this.value});
}

class _DurationOption {
  final String label;
  final String value;

  const _DurationOption({required this.label, required this.value});
}
