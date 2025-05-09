import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/providers/craving_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:nicotinaai_flutter/features/achievements/providers/achievement_provider.dart';
import 'package:nicotinaai_flutter/features/achievements/helpers/achievement_helper.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class RegisterCravingSheet extends StatefulWidget {
  const RegisterCravingSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RegisterCravingSheet(),
    );
    // Retorna true se um craving foi registrado com sucesso
    return result ?? false;
  }

  @override
  State<RegisterCravingSheet> createState() => _RegisterCravingSheetState();
}

class _RegisterCravingSheetState extends State<RegisterCravingSheet> {
  final TextEditingController _notesController = TextEditingController();
  String? _selectedLocation;
  String? _selectedTrigger;
  String? _selectedIntensity;
  bool? _didResist;
  
  // Controles para as seções minimizáveis
  bool _isLocationSectionExpanded = true;
  bool _isTriggerSectionExpanded = true;
  bool _isIntensitySectionExpanded = true;
  bool _isResistSectionExpanded = true;
  bool _isNotesSectionExpanded = true;
  
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
      // Quando o usuário seleciona uma localização, minimiza essa seção e expande a próxima
      if (_selectedLocation != null && _isLocationSectionExpanded) {
        _isLocationSectionExpanded = false;
        _isTriggerSectionExpanded = true;
      }
      
      // Quando o usuário seleciona um gatilho, minimiza essa seção e expande a próxima
      if (_selectedTrigger != null && _isTriggerSectionExpanded) {
        _isTriggerSectionExpanded = false;
        _isIntensitySectionExpanded = true;
      }
      
      // Quando o usuário seleciona uma intensidade, minimiza essa seção e expande a próxima
      if (_selectedIntensity != null && _isIntensitySectionExpanded) {
        _isIntensitySectionExpanded = false;
        _isResistSectionExpanded = true;
      }
      
      // Quando o usuário indica se resistiu, minimiza essa seção e expande a de notas
      if (_didResist != null && _isResistSectionExpanded) {
        _isResistSectionExpanded = false;
        _isNotesSectionExpanded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    // Tamanho ideal para mobile, equilibrando visibilidade e contexto da tela
    const initialSize = 0.80; // Valor ideal para visualizar conteúdo mantendo contexto da tela
    
    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false, // Permite que o conteúdo determine o tamanho natural
      snap: true, // Facilita o ajuste para posições específicas
      snapSizes: const [0.7, 0.85, 0.95], // Manter as opções de snap para dar flexibilidade ao usuário
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
                        color: context.isDarkMode 
                            ? context.primaryColor.withOpacity(0.15) 
                            : context.primaryColor.withOpacity(0.08),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.registerCraving,
                            style: context.titleStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            l10n.registerCravingSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.isDarkMode 
                                  ? Colors.white70 
                                  : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Seções reorganizadas para layout otimizado para mobile
                    // Seção 1: Localização - Minimizável
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      decoration: BoxDecoration(
                        color: context.isDarkMode 
                            ? Colors.grey[850]!.withOpacity(0.8) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: _selectedLocation != null ? Border.all(
                          color: context.primaryColor.withOpacity(0.3),
                          width: 1.5,
                        ) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho clicável para expandir/colapsar
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isLocationSectionExpanded = !_isLocationSectionExpanded;
                              });
                            },
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.08),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.place_outlined, 
                                    size: 18, 
                                    color: context.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l10n.whereAreYou,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: context.primaryColor,
                                      ),
                                    ),
                                  ),
                                  if (_selectedLocation != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: context.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: context.primaryColor.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getLocationIcon(_selectedLocation!),
                                            size: 14,
                                            color: context.primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _getLocationLabel(_selectedLocation!),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: context.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _isLocationSectionExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Conteúdo expansível
                          if (_isLocationSectionExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildLocationGrid(context, l10n),
                            ),
                        ],
                      ),
                    ),
                    
                    // Seção 2: Triggers - Minimizável
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      decoration: BoxDecoration(
                        color: context.isDarkMode 
                            ? Colors.grey[850]!.withOpacity(0.8) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: _selectedTrigger != null ? Border.all(
                          color: context.primaryColor.withOpacity(0.3),
                          width: 1.5,
                        ) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho clicável para expandir/colapsar
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isTriggerSectionExpanded = !_isTriggerSectionExpanded;
                              });
                            },
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.08),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.psychology_outlined, 
                                    size: 18, 
                                    color: context.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l10n.whatTriggeredCraving,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: context.primaryColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_selectedTrigger != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: context.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: context.primaryColor.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        _getTriggerLabel(_selectedTrigger!),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: context.primaryColor,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _isTriggerSectionExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Conteúdo expansível
                          if (_isTriggerSectionExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildTriggerOptions(context, l10n),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Seção 3: Intensidade - Minimizável
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      decoration: BoxDecoration(
                        color: context.isDarkMode 
                            ? Colors.grey[850]!.withOpacity(0.8) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: _selectedIntensity != null ? Border.all(
                          color: _getIntensityColor(_selectedIntensity!).withOpacity(0.3),
                          width: 1.5,
                        ) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho clicável para expandir/colapsar
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isIntensitySectionExpanded = !_isIntensitySectionExpanded;
                              });
                            },
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.08),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.speed_outlined, 
                                    size: 18, 
                                    color: context.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l10n.intensityLevel,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: context.primaryColor,
                                      ),
                                    ),
                                  ),
                                  if (_selectedIntensity != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getIntensityColor(_selectedIntensity!).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _getIntensityColor(_selectedIntensity!).withOpacity(0.3)
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getIntensityIcon(_selectedIntensity!),
                                            size: 14,
                                            color: _getIntensityColor(_selectedIntensity!),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _getIntensityLabel(_selectedIntensity!),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _getIntensityColor(_selectedIntensity!),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _isIntensitySectionExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Conteúdo expansível
                          if (_isIntensitySectionExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildIntensityOptions(context, l10n),
                            ),
                        ],
                      ),
                    ),
                    
                    // Seção 4: Resistência - Minimizável
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      decoration: BoxDecoration(
                        color: context.isDarkMode 
                            ? Colors.grey[850]!.withOpacity(0.8) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: _didResist != null ? Border.all(
                          color: _didResist! ? Colors.green.withOpacity(0.3) : Colors.redAccent.withOpacity(0.3),
                          width: 1.5,
                        ) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho clicável para expandir/colapsar
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isResistSectionExpanded = !_isResistSectionExpanded;
                              });
                            },
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.08),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.fitness_center_outlined, 
                                    size: 18, 
                                    color: context.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l10n.didYouResist,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: context.primaryColor,
                                      ),
                                    ),
                                  ),
                                  if (_didResist != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _didResist! 
                                            ? Colors.green.withOpacity(0.1) 
                                            : Colors.redAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _didResist! 
                                              ? Colors.green.withOpacity(0.3) 
                                              : Colors.redAccent.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _didResist! 
                                                ? Icons.check_circle_outline 
                                                : Icons.cancel_outlined,
                                            size: 14,
                                            color: _didResist! ? Colors.green : Colors.redAccent,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _getResistLabel(_didResist!),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _didResist! ? Colors.green : Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _isResistSectionExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Conteúdo expansível
                          if (_isResistSectionExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildResistOptions(context, l10n),
                            ),
                        ],
                      ),
                    ),
                    
                    // Seção 5: Notas - Minimizável
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      decoration: BoxDecoration(
                        color: context.isDarkMode 
                            ? Colors.grey[850]!.withOpacity(0.8) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: _notesController.text.isNotEmpty ? Border.all(
                          color: context.primaryColor.withOpacity(0.3),
                          width: 1.5,
                        ) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho clicável para expandir/colapsar
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isNotesSectionExpanded = !_isNotesSectionExpanded;
                              });
                            },
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.08),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.note_outlined, 
                                    size: 18, 
                                    color: context.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l10n.notes,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: context.primaryColor,
                                      ),
                                    ),
                                  ),
                                  if (_notesController.text.isNotEmpty)
                                    Container(
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: context.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: context.primaryColor.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        _notesController.text.length > 15 
                                            ? "${_notesController.text.substring(0, 15)}..." 
                                            : _notesController.text,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: context.primaryColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _isNotesSectionExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Conteúdo expansível
                          if (_isNotesSectionExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildNotesField(context, l10n),
                            ),
                        ],
                      ),
                    ),
                    
                    // Extra space at the bottom
                    const SizedBox(height: 70),
                  ],
                ),
              ),
              
              // Botão de salvar otimizado
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
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                    
                    // Botão de salvar com elevation
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isFormValid() ? _saveCraving : () {
                          // Mensagem de erro em caso de formulário inválido
                          final message = _getValidationMessage(l10n);
                          
                          // Verificar campos específicos
                          String tipMessage = "";
                          if (_selectedLocation == null) {
                            tipMessage = "Por favor, selecione uma localização";
                          } else if (_selectedTrigger == null) {
                            tipMessage = "Por favor, selecione o que desencadeou o desejo";
                          } else if (_selectedIntensity == null) {
                            tipMessage = "Por favor, indique a intensidade do desejo";
                          } else if (_didResist == null) {
                            tipMessage = "Por favor, informe se resistiu ao desejo";
                          }
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (tipMessage.isNotEmpty)
                                    Text(tipMessage, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          disabledBackgroundColor: Colors.grey[300],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: 4,
                          shadowColor: context.primaryColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.primaryColor,
                                context.primaryColor.withRed((context.primaryColor.red + 25).clamp(0, 255)),
                              ],
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
                                const Icon(Icons.save_outlined, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.save,
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
    return _selectedLocation != null && 
           _selectedTrigger != null && 
           _selectedIntensity != null &&
           _didResist != null;
  }
  
  // Método para obter o rótulo legível para um valor de localização selecionado
  String _getLocationLabel(String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'home':
        return l10n.home;
      case 'work':
        return l10n.work;
      case 'car':
        return l10n.car;
      case 'restaurant':
        return l10n.restaurant;
      case 'bar':
        return l10n.bar;
      case 'street':
        return l10n.street;
      case 'park':
        return l10n.park;
      case 'others':
        return l10n.others;
      default:
        return value;
    }
  }
  
  // Método para obter o ícone correspondente à localização
  IconData _getLocationIcon(String value) {
    switch (value) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'car':
        return Icons.directions_car;
      case 'restaurant':
        return Icons.restaurant;
      case 'bar':
        return Icons.local_bar;
      case 'street':
        return Icons.map;
      case 'park':
        return Icons.park;
      case 'others':
        return Icons.more_horiz;
      default:
        return Icons.place;
    }
  }
  
  // Método para obter o rótulo legível para um valor de gatilho selecionado
  String _getTriggerLabel(String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'stress':
        return l10n.stress;
      case 'boredom':
        return l10n.boredom;
      case 'social_situation':
        return l10n.socialSituation;
      case 'after_meal':
        return l10n.afterMeal;
      case 'coffee':
        return l10n.coffee;
      case 'alcohol':
        return l10n.alcohol;
      case 'craving':
        return l10n.craving;
      case 'other':
        return l10n.other;
      default:
        return value;
    }
  }
  
  // Método para obter o rótulo legível para um valor de intensidade
  String _getIntensityLabel(String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'low':
        return l10n.mild;
      case 'moderate':
        return l10n.moderate;
      case 'high':
        return l10n.intense;
      case 'very_high':
        return l10n.veryIntense;
      default:
        return value;
    }
  }
  
  // Método para obter a cor correspondente à intensidade
  Color _getIntensityColor(String value) {
    switch (value) {
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.deepOrange;
      case 'very_high':
        return Colors.red;
      default:
        return context.primaryColor;
    }
  }
  
  // Método para obter o ícone correspondente à intensidade
  IconData _getIntensityIcon(String value) {
    switch (value) {
      case 'low':
        return Icons.sentiment_satisfied_outlined;
      case 'moderate':
        return Icons.sentiment_neutral_outlined;
      case 'high':
        return Icons.sentiment_dissatisfied_outlined;
      case 'very_high':
        return Icons.sentiment_very_dissatisfied_outlined;
      default:
        return Icons.circle;
    }
  }
  
  // Método para obter o rótulo legível para resistência
  String _getResistLabel(bool value) {
    final l10n = AppLocalizations.of(context);
    return value ? l10n.yes : l10n.no;
  }
  
  String _getValidationMessage(AppLocalizations l10n) {
    if (_selectedLocation == null) {
      return l10n.pleaseSelectLocation;
    } else if (_selectedTrigger == null) {
      return l10n.pleaseSelectTrigger;
    } else if (_selectedIntensity == null) {
      return l10n.pleaseSelectIntensity;
    } else if (_didResist == null) {
      return l10n.didYouResist;
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
              icon: Icon(
                Icons.close,
                size: 18,
                color: Colors.grey[600],
              ),
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

  Widget _buildLocationGrid(BuildContext context, AppLocalizations l10n) {
    final locations = [
      _LocationOption(
        icon: Icons.home,
        label: l10n.home,
        value: 'home',
      ),
      _LocationOption(
        icon: Icons.work,
        label: l10n.work,
        value: 'work',
      ),
      _LocationOption(
        icon: Icons.directions_car,
        label: l10n.car,
        value: 'car',
      ),
      _LocationOption(
        icon: Icons.restaurant,
        label: l10n.restaurant,
        value: 'restaurant',
      ),
      _LocationOption(
        icon: Icons.local_bar,
        label: l10n.bar,
        value: 'bar',
      ),
      _LocationOption(
        icon: Icons.map,
        label: l10n.street,
        value: 'street',
      ),
      _LocationOption(
        icon: Icons.park,
        label: l10n.park,
        value: 'park',
      ),
      _LocationOption(
        icon: Icons.more_horiz,
        label: l10n.others,
        value: 'others',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: MediaQuery.of(context).size.height < 700 ? 0.85 : 0.8, // Ajustado para telas menores
        crossAxisSpacing: 6,
        mainAxisSpacing: 8,
      ),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return _buildLocationOption(
          context,
          location.icon,
          location.label,
          location.value,
        );
      },
    );
  }
  
  Widget _buildTriggerOptions(BuildContext context, AppLocalizations l10n) {
    final triggers = [
      _TriggerOption(label: l10n.stress, value: 'stress'),
      _TriggerOption(label: l10n.boredom, value: 'boredom'),
      _TriggerOption(label: l10n.socialSituation, value: 'social_situation'),
      _TriggerOption(label: l10n.afterMeal, value: 'after_meal'),
      _TriggerOption(label: l10n.coffee, value: 'coffee'),
      _TriggerOption(label: l10n.alcohol, value: 'alcohol'),
      _TriggerOption(label: l10n.craving, value: 'craving'),
      _TriggerOption(label: l10n.other, value: 'other'),
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: triggers.map((trigger) => _buildSelectionChip(
        context, 
        trigger.label, 
        trigger.value,
        isSelected: _selectedTrigger == trigger.value,
        onSelected: (selected) {
          setState(() {
            _selectedTrigger = selected ? trigger.value : null;
          });
        },
      )).toList(),
    );
  }
  
  Widget _buildIntensityOptions(BuildContext context, AppLocalizations l10n) {
    // Mapeando para os valores do enum do banco de dados: ["LOW", "MODERATE", "HIGH", "VERY_HIGH"]
    final intensities = [
      _IntensityOption(label: l10n.mild, value: 'low'), // "LOW" no banco de dados
      _IntensityOption(label: l10n.moderate, value: 'moderate'), // "MODERATE" no banco de dados
      _IntensityOption(label: l10n.intense, value: 'high'), // "HIGH" no banco de dados
      _IntensityOption(label: l10n.veryIntense, value: 'very_high'), // "VERY_HIGH" no banco de dados
    ];
    
    // Layout otimizado para mobile que adapta melhor para telas diferentes
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 0,
      ),
      itemCount: intensities.length,
      itemBuilder: (context, index) {
        final intensity = intensities[index];
        return _buildIntensityOption(
          context,
          intensity.label,
          intensity.value,
        );
      },
    );
  }
  
  Widget _buildLocationOption(
    BuildContext context, 
    IconData icon, 
    String label, 
    String value,
  ) {
    final isSelected = _selectedLocation == value;
    final color = context.primaryColor;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Ajustes adaptativos baseados na altura da tela
    final bool isSmallScreen = screenHeight < 700;
    final double iconSize = isSmallScreen ? 22 : 24;
    final double fontSize = isSmallScreen ? 10 : 11;
    final double padding = isSmallScreen ? 6 : 8;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLocation = value;
          // Atualiza o estado das seções quando o usuário seleciona uma localização
          _updateSectionStates();
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: isSelected 
                ? color.withAlpha(51) 
                : context.isDarkMode 
                  ? Colors.grey.withAlpha(26) 
                  : Colors.grey.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                  ? color 
                  : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected 
                ? color 
                : context.isDarkMode 
                  ? Colors.white 
                  : Colors.grey[800],
              size: iconSize,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected 
                ? color 
                : context.contentColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSelectionChip(
    BuildContext context,
    String label,
    String value, {
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        onSelected(selected);
        // Atualiza o estado das seções quando o usuário seleciona um gatilho
        _updateSectionStates();
      },
      backgroundColor: context.isDarkMode 
        ? Colors.grey.withAlpha(26) 
        : Colors.grey.withAlpha(13),
      selectedColor: context.primaryColor.withAlpha(51),
      checkmarkColor: context.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected 
            ? context.primaryColor 
            : Colors.transparent,
        ),
      ),
      labelStyle: TextStyle(
        color: isSelected 
          ? context.primaryColor 
          : context.contentColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  
  Widget _buildIntensityOption(
    BuildContext context,
    String label,
    String value,
  ) {
    final isSelected = _selectedIntensity == value;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    // Colors para cada nível de intensidade
    Color getColor() {
      switch (value) {
        case 'low':
          return Colors.green;
        case 'moderate':
          return Colors.orange;
        case 'high':
          return Colors.deepOrange;
        case 'very_high':
          return Colors.red;
        default:
          return context.primaryColor;
      }
    }
    
    final itemColor = getColor();
    
    // Ícones para cada nível de intensidade
    IconData getIcon() {
      switch (value) {
        case 'low':
          return Icons.sentiment_satisfied_outlined;
        case 'moderate':
          return Icons.sentiment_neutral_outlined;
        case 'high':
          return Icons.sentiment_dissatisfied_outlined;
        case 'very_high':
          return Icons.sentiment_very_dissatisfied_outlined;
        default:
          return Icons.circle;
      }
    }
    
    final iconData = getIcon();
    final double iconSize = 24;
    final double fontSize = 12;
    
    // Design moderno para seleção de intensidade
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIntensity = value;
          // Atualiza o estado das seções quando o usuário seleciona uma intensidade
          _updateSectionStates();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
            ? itemColor.withOpacity(0.1) 
            : context.isDarkMode 
              ? Colors.grey.withOpacity(0.05) 
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? itemColor 
              : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone com fundo circular
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? itemColor.withOpacity(0.2) : Colors.transparent,
              ),
              child: Icon(
                iconData,
                color: isSelected ? itemColor : Colors.grey,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 4),
            // Texto descritivo
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? itemColor : context.contentColor,
                  ),
                  textAlign: TextAlign.center,
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
        color: context.isDarkMode 
            ? Colors.grey.withOpacity(0.1) 
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode 
              ? Colors.grey.withOpacity(0.2) 
              : Colors.grey.withOpacity(0.15),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: isSmallScreen ? 2 : 3,
        minLines: isSmallScreen ? 1 : 2,
        style: TextStyle(
          fontSize: 15,
          color: context.contentColor,
        ),
        onChanged: (text) {
          // Não precisa fazer nada aqui já que o listener
          // no initState vai cuidar de atualizar o estado
        },
        decoration: InputDecoration(
          hintText: l10n.howAreYouFeeling,
          hintStyle: TextStyle(
            color: context.subtitleColor,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(
              Icons.edit_note_outlined,
              color: context.primaryColor.withOpacity(0.5),
              size: 20,
            ),
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: context.primaryColor.withOpacity(0.5),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildResistOptions(BuildContext context, AppLocalizations l10n) {
    // Botões maiores e mais espaçados para melhor experiência tátil
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.38, // 38% da largura da tela
          height: 60, // Altura fixa para melhor toque
          child: _buildResistOption(
            context, 
            l10n.yes, 
            true, 
            Colors.green,
          ),
        ),
        const SizedBox(width: 16), // Espaçamento entre os botões
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.38, // 38% da largura da tela
          height: 60, // Altura fixa para melhor toque
          child: _buildResistOption(
            context, 
            l10n.no, 
            false,
            Colors.redAccent,
          ),
        ),
      ],
    );
  }
  
  Widget _buildResistOption(
    BuildContext context,
    String label,
    bool value,
    Color color,
  ) {
    final isSelected = _didResist == value;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    // Ícone baseado na opção (sim/não)
    IconData getIcon() {
      return value ? Icons.check_circle_outline : Icons.cancel_outlined;
    }
    
    final double fontSize = 16;
    final double iconSize = 22;
    
    // Design moderno para botões de resistência
    return InkWell(
      onTap: () {
        setState(() {
          _didResist = value;
          // Atualiza o estado das seções quando o usuário seleciona se resistiu
          _updateSectionStates();
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isSelected 
            ? null // Usamos gradiente quando selecionado
            : context.isDarkMode 
              ? Colors.grey.withOpacity(0.1) 
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              getIcon(),
              color: isSelected ? Colors.white : color.withOpacity(0.7),
              size: iconSize,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : context.contentColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveCraving() async {
    if (!_isFormValid()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cravingProvider = Provider.of<CravingProvider>(context, listen: false);
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    
    final userId = authProvider.currentUser?.id ?? '';
    if (userId.isEmpty) {
      // Cannot save if not authenticated
      Navigator.of(context).pop();
      return;
    }
    
    // Verificar se todos os campos estão preenchidos corretamente
    assert(_selectedLocation != null, "Location is not selected");
    assert(_selectedTrigger != null, "Trigger is not selected");
    assert(_selectedIntensity != null, "Intensity is not selected");
    assert(_didResist != null, "Resist option is not selected");
    
    // Logs para debug (serão removidos na produção)
    debugPrint('Saving craving with:');
    debugPrint('- Location: $_selectedLocation');
    debugPrint('- Trigger: $_selectedTrigger');
    debugPrint('- Intensity: $_selectedIntensity');
    debugPrint('- Resisted: $_didResist');
    debugPrint('- Notes: ${_notesController.text}');
    
    final craving = CravingModel(
      location: _selectedLocation!,
      trigger: _selectedTrigger!,
      intensity: _selectedIntensity!,
      resisted: _didResist!,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      timestamp: DateTime.now(),
      userId: userId,
    );
    
    // Prepare snackbar messages before dismissing the sheet
    final bool didResist = _didResist!;
    final successMessage = didResist ? l10n.cravingResistedRecorded : l10n.cravingRecorded;
    final backgroundColor = didResist ? Colors.green : Colors.blue;
    final retryLabel = l10n.retry;
    
    // Store current context's scaffold messenger and achievement provider
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
    
    // Check for achievements now while context is still valid
    if (_didResist != null) {
      try {
        // This is safe because the context is still mounted
        AchievementHelper.checkAfterCravingRecordedWithNotifications(context, _didResist!);
      } catch (e) {
        debugPrint('Error checking for achievements in UI: $e');
      }
    }
    
    // Close the sheet immediately for better UX with success result
    Navigator.of(context).pop(true);
    
    try {
      // Optimistically update the UI and save in the background
      await cravingProvider.saveCraving(craving);
      
      // Força a atualização das estatísticas no TrackingProvider
      await trackingProvider.forceUpdateStats();
      
      // Se resistiu ao craving, vamos exibir uma notificação motivacional
      // Envio de notificação é feito no TrackingProvider
      
      // Show a success snackbar
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
          action: cravingProvider.error != null ? SnackBarAction(
            label: retryLabel,
            onPressed: () {
              // Find the failed craving and retry
              final failedCravings = cravingProvider.failedCravings;
              if (failedCravings.isNotEmpty) {
                final failedCraving = failedCravings.first;
                if (failedCraving.id != null) {
                  cravingProvider.retrySyncCraving(failedCraving.id!);
                }
              }
            },
          ) : null,
        ),
      );
    } catch (e) {
      // Em caso de erro, mostrar mensagem de erro
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${l10n.errorSavingCraving}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: retryLabel,
            onPressed: () {
              // Find the failed craving and retry
              final failedCravings = cravingProvider.failedCravings;
              if (failedCravings.isNotEmpty) {
                final failedCraving = failedCravings.first;
                if (failedCraving.id != null) {
                  cravingProvider.retrySyncCraving(failedCraving.id!);
                }
              }
            },
          ),
        ),
      );
    }
  }
}

class _LocationOption {
  final IconData icon;
  final String label;
  final String value;
  
  const _LocationOption({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _TriggerOption {
  final String label;
  final String value;
  
  const _TriggerOption({
    required this.label,
    required this.value,
  });
}

class _IntensityOption {
  final String label;
  final String value;
  
  const _IntensityOption({
    required this.label,
    required this.value,
  });
}