import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart' as bloc_auth;
import 'package:nicotinaai_flutter/blocs/craving/craving_bloc.dart';
import 'package:nicotinaai_flutter/blocs/craving/craving_event.dart';
import 'package:nicotinaai_flutter/blocs/craving/craving_state.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/achievements/helpers/achievement_helper.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/stats_calculator.dart';

class RegisterCravingSheetBloc extends StatefulWidget {
  const RegisterCravingSheetBloc({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => const RegisterCravingSheetBloc(),
    );
    // Return result data if a craving was successfully registered
    return result;
  }

  @override
  State<RegisterCravingSheetBloc> createState() => _RegisterCravingSheetBlocState();
}

class _RegisterCravingSheetBlocState extends State<RegisterCravingSheetBloc> {
  final TextEditingController _notesController = TextEditingController();
  String? _selectedLocation;
  String? _selectedTrigger;
  String? _selectedIntensity;
  bool? _didResist;
  
  // Controls for collapsible sections
  bool _isLocationSectionExpanded = true;
  bool _isTriggerSectionExpanded = true;
  bool _isIntensitySectionExpanded = true;
  bool _isResistSectionExpanded = true;
  bool _isNotesSectionExpanded = true;
  
  @override
  void initState() {
    super.initState();
    // Add listener for notes controller
    _notesController.addListener(() {
      setState(() {
        // Force rebuild when text changes to update summary
      });
    });
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  // Method to update the expansion state of sections
  void _updateSectionStates() {
    setState(() {
      // When user selects a location, collapse that section and expand the next
      if (_selectedLocation != null && _isLocationSectionExpanded) {
        _isLocationSectionExpanded = false;
        _isTriggerSectionExpanded = true;
      }
      
      // When user selects a trigger, collapse that section and expand the next
      if (_selectedTrigger != null && _isTriggerSectionExpanded) {
        _isTriggerSectionExpanded = false;
        _isIntensitySectionExpanded = true;
      }
      
      // When user selects an intensity, collapse that section and expand the next
      if (_selectedIntensity != null && _isIntensitySectionExpanded) {
        _isIntensitySectionExpanded = false;
        _isResistSectionExpanded = true;
      }
      
      // When user indicates if they resisted, collapse that section and expand the notes section
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
    
    // Ideal size for mobile, balancing visibility and screen context
    const initialSize = 0.80;
    
    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      snapSizes: const [0.7, 0.85, 0.95],
      builder: (context, scrollController) {
        return Container(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: context.isDarkMode 
                ? Color(0xFF1C1C1E) 
                : context.backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Scrollable content with optimized layout
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      _buildHandle(context),
                      
                      // Optimized main title without background
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
                      
                      // Sections reorganized for optimized layout for mobile
                      // Section 1: Location - Collapsible
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        decoration: BoxDecoration(
                          color: context.isDarkMode 
                              ? Color(0xFF2C2C2E) 
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
                            // Clickable header to expand/collapse
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
                            
                            // Expandable content
                            if (_isLocationSectionExpanded)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: _buildLocationGrid(context, l10n),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Section 2: Triggers - Collapsible
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        decoration: BoxDecoration(
                          color: context.isDarkMode 
                              ? Color(0xFF2C2C2E) 
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
                            // Clickable header to expand/collapse
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
                            
                            // Expandable content
                            if (_isTriggerSectionExpanded)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: _buildTriggerOptions(context, l10n),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Section 3: Intensity - Collapsible
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        decoration: BoxDecoration(
                          color: context.isDarkMode 
                              ? Color(0xFF2C2C2E) 
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
                            // Clickable header to expand/collapse
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
                            
                            // Expandable content
                            if (_isIntensitySectionExpanded)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: _buildIntensityOptions(context, l10n),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Section 4: Resistance - Collapsible
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        decoration: BoxDecoration(
                          color: context.isDarkMode 
                              ? Color(0xFF2C2C2E) 
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
                            // Clickable header to expand/collapse
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
                            
                            // Expandable content
                            if (_isResistSectionExpanded)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: _buildResistOptions(context, l10n),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Section 5: Notes - Collapsible
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        decoration: BoxDecoration(
                          color: context.isDarkMode 
                              ? Color(0xFF2C2C2E) 
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
                            // Clickable header to expand/collapse
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
                            
                            // Expandable content
                            if (_isNotesSectionExpanded)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: _buildNotesField(context, l10n),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Extra space at the bottom
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
                
                // Optimized save button with frosted glass effect
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 16 + MediaQuery.of(context).padding.bottom,
                        top: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.isDarkMode 
                            ? Colors.black.withOpacity(0.2)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            offset: const Offset(0, -3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                        // Add backdrop filter for glass effect
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            context.isDarkMode 
                                ? Color.fromRGBO(255, 255, 255, 0.03) 
                                : Color.fromRGBO(255, 255, 255, 0.7),
                            context.isDarkMode 
                                ? Color.fromRGBO(0, 0, 0, 0.3) 
                                : Color.fromRGBO(255, 255, 255, 0.5),
                          ],
                        ),
                      ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Compact error message
                      if (!_isFormValid())
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 0, 0, 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color.fromRGBO(255, 0, 0, 0.3),
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
                          ),
                        ),
                      
                      // Save button with elevation
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isFormValid() ? _saveCraving : () {
                            // Error message when form is invalid
                            final message = _getValidationMessage(l10n);
                            
                            // Check specific fields
                            String tipMessage = "";
                            if (_selectedLocation == null) {
                              tipMessage = "Please select a location";
                            } else if (_selectedTrigger == null) {
                              tipMessage = "Please select what triggered the craving";
                            } else if (_selectedIntensity == null) {
                              tipMessage = "Please indicate the intensity of the craving";
                            } else if (_didResist == null) {
                              tipMessage = "Please indicate if you resisted the craving";
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
              ),
            ),
              ],
            ),
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
  
  // Method to get readable label for selected location value
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
  
  // Method to get icon for location
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
  
  // Method to get readable label for selected trigger value
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
  
  // Method to get readable label for intensity value
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
  
  // Method to get color for intensity
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
  
  // Method to get icon for intensity
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
  
  // Method to get readable label for resistance
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
    return SizedBox(
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
          
          // Close button in the right corner
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
              constraints: const BoxConstraints(),
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
        childAspectRatio: MediaQuery.of(context).size.height < 700 ? 0.85 : 0.8, // Adjusted for smaller screens
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
          // Updates the sections state when user selects a trigger
          _updateSectionStates();
        },
      )).toList(),
    );
  }
  
  Widget _buildIntensityOptions(BuildContext context, AppLocalizations l10n) {
    // Mapping to database enum values: ["LOW", "MODERATE", "HIGH", "VERY_HIGH"]
    final intensities = [
      _IntensityOption(label: l10n.mild, value: 'low'), // "LOW" in database
      _IntensityOption(label: l10n.moderate, value: 'moderate'), // "MODERATE" in database
      _IntensityOption(label: l10n.intense, value: 'high'), // "HIGH" in database
      _IntensityOption(label: l10n.veryIntense, value: 'very_high'), // "VERY_HIGH" in database
    ];
    
    // Optimized layout for mobile that adapts better to different screens
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    
    // Adaptive adjustments based on screen height
    final bool isSmallScreen = screenHeight < 700;
    final double iconSize = isSmallScreen ? 22 : 24;
    final double fontSize = isSmallScreen ? 10 : 11;
    final double padding = isSmallScreen ? 6 : 8;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLocation = value;
          // Updates the sections state when user selects a location
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
              shape: BoxShape.circle,
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
      onSelected: onSelected,
      backgroundColor: context.isDarkMode 
        ? Color(0xFF383838) 
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
    
    // Colors for each intensity level
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
    
    // Icons for each intensity level
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
    
    // Modern design for intensity selection
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIntensity = value;
          // Updates the sections state when user selects an intensity
          _updateSectionStates();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
            ? itemColor.withOpacity(0.1) 
            : context.isDarkMode 
                ? Color(0xFF383838) 
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
            // Icon with circular background
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
            // Descriptive text
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
          // No need to do anything here since the listener in initState will handle updating the state
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
    // Larger and more spaced buttons for better touch experience
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.38, // 38% of screen width
          height: 60, // Fixed height for better touch
          child: _buildResistOption(
            context, 
            l10n.yes, 
            true, 
            Colors.green,
          ),
        ),
        const SizedBox(width: 16), // Spacing between buttons
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.38, // 38% of screen width
          height: 60, // Fixed height for better touch
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
    
    // Icon based on option (yes/no)
    IconData getIcon() {
      return value ? Icons.check_circle_outline : Icons.cancel_outlined;
    }
    
    final double fontSize = 16;
    final double iconSize = 22;
    
    // Modern design for resist buttons
    return InkWell(
      onTap: () {
        setState(() {
          _didResist = value;
          // Updates the sections state when user selects if they resisted
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
            ? null // Use gradient when selected
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
    
    final authState = context.read<AuthBloc>().state;
    if (authState.status != bloc_auth.AuthStatus.authenticated || authState.user == null) {
      // Cannot save if not authenticated
      Navigator.of(context).pop();
      return;
    }
    
    final userId = authState.user!.id;
    final l10n = AppLocalizations.of(context);
    
    // Check if all fields are correctly filled
    assert(_selectedLocation != null, "Location is not selected");
    assert(_selectedTrigger != null, "Trigger is not selected");
    assert(_selectedIntensity != null, "Intensity is not selected");
    assert(_didResist != null, "Resist option is not selected");
    
    // Debug logs
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
    
    // Store current context's scaffold messenger
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Check for achievements while context is still valid
    if (_didResist != null) {
      try {
        AchievementHelper.checkAfterCravingRecordedWithNotifications(context, _didResist!);
      } catch (e) {
        debugPrint('Error checking for achievements in UI: $e');
      }
    }
    
    try {
      // Obter os BLOCs antes de qualquer operação
      final cravingBloc = context.read<CravingBloc>();
      final trackingBloc = context.read<TrackingBloc>();
      
      // Obter estatísticas atuais do usuário (pode ser null para o primeiro craving)
      final currentStats = trackingBloc.state.userStats;
      
      // Valores iniciais para atualização otimista
      int newCravingsResisted = 1; // Assume pelo menos 1 para o primeiro craving
      int newCigarettesAvoided = 1; // Assume pelo menos 1 para o primeiro craving
      int newMoneySaved = 0;
      
      // Use CravingBloc to save the craving
      cravingBloc.add(SaveCravingRequested(craving: craving));
      
      // Disparar eventos para atualizações imediatas e em segundo plano
      trackingBloc.add(CravingAdded());
      trackingBloc.add(ForceUpdateStats());
      
      if (kDebugMode) {
        print('💡 [RegisterCravingSheetBloc] Disparou eventos de atualização otimista e forçada');
      }
      
      // Cálculo para atualização otimista
      if (currentStats != null) {
        // Se temos estatísticas existentes, usar o StatsCalculator
        final updatedStats = StatsCalculator.calculateAddCraving(currentStats);
        newCravingsResisted = updatedStats.cravingsResisted ?? 1;
        newCigarettesAvoided = updatedStats.cigarettesAvoided;
        newMoneySaved = updatedStats.moneySaved;
        
        if (kDebugMode) {
          print('💡 [RegisterCravingSheetBloc] Valores calculados pelo StatsCalculator:');
          print('  - Cravings resistidos: ${currentStats.cravingsResisted ?? 0} -> $newCravingsResisted');
          print('  - Cigarros evitados: ${currentStats.cigarettesAvoided} -> $newCigarettesAvoided');
          print('  - Economia: ${currentStats.moneySaved} -> $newMoneySaved centavos');
        }
      } else if (kDebugMode) {
        // Se não temos estatísticas atuais, mantemos os valores default
        print('⚠️ [RegisterCravingSheetBloc] Nenhuma estatística disponível, usando valores padrão para atualização otimista');
        print('  - Cravings resistidos: default -> $newCravingsResisted');
        print('  - Cigarros evitados: default -> $newCigarettesAvoided');
        print('  - Economia: default -> $newMoneySaved centavos');
      }
      
      // IMPORTANTE: Sempre retornar um Map com valores padrão mesmo para o primeiro craving
      // Isso garante que mesmo sem estatísticas iniciais, a UI seja atualizada
      Navigator.of(context).pop({
        'registered': true,
        'stats': {
          'cravingsResisted': newCravingsResisted,
          'cigarettesAvoided': newCigarettesAvoided,
          'moneySaved': newMoneySaved,
        }
      });
      
      // Show a success snackbar
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // In case of error, show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${l10n.errorSavingCraving}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: retryLabel,
            onPressed: () {
              // Find the failed craving and retry
              final failedCravings = context.read<CravingBloc>().state.failedCravings;
              if (failedCravings.isNotEmpty) {
                final failedCraving = failedCravings.first;
                if (failedCraving.id != null) {
                  context.read<CravingBloc>().add(
                    RetrySyncCravingRequested(id: failedCraving.id!),
                  );
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