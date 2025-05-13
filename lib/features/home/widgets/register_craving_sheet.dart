import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart' as bloc_auth;
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/tracking/repositories/tracking_repository.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/stats_calculator.dart';

class RegisterCravingSheet extends StatefulWidget {
  const RegisterCravingSheet({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => const RegisterCravingSheet(),
    );
    return result;
  }

  @override
  State<RegisterCravingSheet> createState() => _RegisterCravingSheetState();
}

class _RegisterCravingSheetState extends State<RegisterCravingSheet> {
  final TextEditingController _notesController = TextEditingController();
  String? _selectedReason;
  String? _selectedIntensity;
  String? _selectedLocation;
  bool _didResist = true;

  // Controls for collapsible sections
  bool _isReasonSectionExpanded = true;
  bool _isIntensitySectionExpanded = false;
  bool _isLocationSectionExpanded = false;
  bool _isResistSectionExpanded = false;
  bool _isNotesSectionExpanded = false;

  @override
  void initState() {
    super.initState();
    _notesController.addListener(() {
      setState(() {
        // Update UI when notes change
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
      // When the user selects a reason, collapse that section and expand the next one
      if (_selectedReason != null && _isReasonSectionExpanded) {
        _isReasonSectionExpanded = false;
        _isIntensitySectionExpanded = true;
      }

      // When the user selects an intensity, collapse that section and expand location
      if (_selectedIntensity != null && _isIntensitySectionExpanded) {
        _isIntensitySectionExpanded = false;
        _isLocationSectionExpanded = true;
      }

      // When the user selects a location, collapse that section and expand resist section
      if (_selectedLocation != null && _isLocationSectionExpanded) {
        _isLocationSectionExpanded = false;
        _isResistSectionExpanded = true;
      }

      // When the user has selected resist option, collapse that section and expand notes
      if (_isResistSectionExpanded && (_didResist != null)) {
        _isResistSectionExpanded = false;
        _isNotesSectionExpanded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<TrackingBloc, TrackingState>(
      listenWhen: (previous, current) {
        // Listen for changes in the status or error message
        return previous.status != current.status || 
               previous.errorMessage != current.errorMessage || 
               // Listen for changes in the unified cravings collection
               previous.unifiedCravings.length != current.unifiedCravings.length;
      },
      listener: (context, state) {
        final l10n = AppLocalizations.of(context);

        // Log state changes for debugging purposes only when in debug mode
        if (kDebugMode) {
          switch (state.status) {
            case TrackingStatus.saving:
              print('💾 [TrackingBloc] Saving craving record...');
              break;
            case TrackingStatus.loaded:
              print('✅ [TrackingBloc] Craving record saved successfully!');
              break;
            case TrackingStatus.error:
              print('❌ [TrackingBloc] Error saving craving record: ${state.errorMessage}');
              break;
            default:
              // Do nothing for other states
              break;
          }
        }

        // Only show UI feedback when necessary and if the sheet is still open
        if (Navigator.canPop(context)) {
          if (state.status == TrackingStatus.loaded) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.cravingRecorded ?? "Craving saved successfully"),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state.status == TrackingStatus.error) {
            // Show error message with proper localization
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.errorMessage ?? "Unknown error"}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.85, // 85% of screen height initially
        minChildSize: 0.5,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.65, 0.8, 0.95],
        builder: (context, scrollController) {
          return Container(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: context.isDarkMode ? const Color(0xFF1C1C1E) : context.backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: <Widget>[
                  // Scrollable content with optimized layout
                  Expanded(
                    child: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 16),
                        children: <Widget>[
                          _buildHandle(context),

                          // Optimized main title without background
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  l10n.registerCraving,
                                  style: context.titleStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  l10n.registerCravingSubtitle,
                                  style: TextStyle(fontSize: 14, color: context.isDarkMode ? Colors.white70 : Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Reason Section - Collapsible
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              color: context.isDarkMode ? Colors.grey[850] : Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      _selectedReason != null
                                          ? Colors.red
                                          : context.isDarkMode
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                  width: _selectedReason != null ? 1.5 : 0.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Clickable header for expand/collapse
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isReasonSectionExpanded = !_isReasonSectionExpanded;
                                      });
                                    },
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(Icons.help_outline, size: 20, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              l10n.whatTriggeredCraving,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                            ),
                                          ),
                                          if (_selectedReason != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                                              ),
                                              child: Text(
                                                _getReasonLabel(_selectedReason!),
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                                              ),
                                            ),
                                          const SizedBox(width: 4),
                                          Icon(_isReasonSectionExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Expandable content
                                  if (_isReasonSectionExpanded)
                                    Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 16), child: _buildReasonGrid(context, l10n)),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Intensity Section - Collapsible
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              color: context.isDarkMode ? Colors.grey[850] : Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      _selectedIntensity != null
                                          ? Colors.red
                                          : context.isDarkMode
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                  width: _selectedIntensity != null ? 1.5 : 0.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Clickable header for expand/collapse
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isIntensitySectionExpanded = !_isIntensitySectionExpanded;
                                      });
                                    },
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(Icons.trending_up, size: 20, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              l10n.intensityLevel,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                            ),
                                          ),
                                          if (_selectedIntensity != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                                              ),
                                              child: Text(
                                                _getIntensityLabel(_selectedIntensity!),
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                                              ),
                                            ),
                                          const SizedBox(width: 4),
                                          Icon(_isIntensitySectionExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Expandable content
                                  if (_isIntensitySectionExpanded)
                                    Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 16), child: _buildIntensityOptions(context, l10n)),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Location Section - Collapsible
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              color: context.isDarkMode ? Colors.grey[850] : Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      _selectedLocation != null
                                          ? Colors.red
                                          : context.isDarkMode
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                  width: _selectedLocation != null ? 1.5 : 0.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Clickable header for expand/collapse
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isLocationSectionExpanded = !_isLocationSectionExpanded;
                                      });
                                    },
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(Icons.place_outlined, size: 20, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              l10n.whereAreYou,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                            ),
                                          ),
                                          if (_selectedLocation != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                                              ),
                                              child: Text(
                                                _getLocationLabel(_selectedLocation!),
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                                              ),
                                            ),
                                          const SizedBox(width: 4),
                                          Icon(_isLocationSectionExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Expandable content
                                  if (_isLocationSectionExpanded)
                                    Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 16), child: _buildLocationGrid(context, l10n)),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Resist Section - Collapsible
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              color: context.isDarkMode ? Colors.grey[850] : Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      (_didResist != null)
                                          ? Colors.red
                                          : context.isDarkMode
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                  width: (_didResist != null) ? 1.5 : 0.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Clickable header for expand/collapse
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isResistSectionExpanded = !_isResistSectionExpanded;
                                      });
                                    },
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(Icons.block, size: 20, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              l10n.didYouResist,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                            ),
                                          ),
                                          if (_didResist != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                                              ),
                                              child: Text(
                                                _didResist ? l10n.yes : l10n.no,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                                              ),
                                            ),
                                          const SizedBox(width: 4),
                                          Icon(_isResistSectionExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Expandable content
                                  if (_isResistSectionExpanded)
                                    Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 16), child: _buildResistOptions(context, l10n)),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Notes Section - Collapsible
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              color: context.isDarkMode ? Colors.grey[850] : Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      _notesController.text.isNotEmpty
                                          ? Colors.red
                                          : context.isDarkMode
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                  width: _notesController.text.isNotEmpty ? 1.5 : 0.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Clickable header for expand/collapse
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isNotesSectionExpanded = !_isNotesSectionExpanded;
                                      });
                                    },
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(Icons.note_outlined, size: 20, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              l10n.notes,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                            ),
                                          ),
                                          if (_notesController.text.isNotEmpty)
                                            Container(
                                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                                              ),
                                              child: Text(
                                                _notesController.text.length > 15
                                                    ? "${_notesController.text.substring(0, 15)}..."
                                                    : _notesController.text,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          const SizedBox(width: 4),
                                          Icon(_isNotesSectionExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Expandable content
                                  if (_isNotesSectionExpanded)
                                    Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 16), child: _buildNotesField(context, l10n)),
                                ],
                              ),
                            ),
                          ),

                          // Extra space at bottom
                          const SizedBox(height: 70),
                        ],
                      ),
                    ),
                  ),

                  // Register button with BlocBuilder
                  BlocBuilder<TrackingBloc, TrackingState>(
                    builder: (context, state) {
                      final isLoading = state.status == TrackingStatus.saving;

                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(left: 20, right: 20, bottom: 16 + MediaQuery.of(context).padding.bottom, top: 12),
                            decoration: BoxDecoration(
                              color: context.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.1), offset: const Offset(0, -3), blurRadius: 10, spreadRadius: 1),
                              ],
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  context.isDarkMode ? const Color.fromRGBO(255, 255, 255, 0.03) : const Color.fromRGBO(255, 255, 255, 0.7),
                                  context.isDarkMode ? const Color.fromRGBO(0, 0, 0, 0.3) : const Color.fromRGBO(255, 255, 255, 0.5),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
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
                                            color: const Color.fromRGBO(255, 0, 0, 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color.fromRGBO(255, 0, 0, 0.3), width: 1),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              const Icon(Icons.error_outline, color: Colors.red, size: 16),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _getValidationMessage(l10n),
                                                  style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Register button with elevation and gradient
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: isLoading || !_isFormValid() ? null : _saveCraving,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      disabledBackgroundColor: Colors.grey[300],
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      elevation: 4,
                                      shadowColor: Colors.red.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.red, Colors.red.shade700],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        height: 52,
                                        alignment: Alignment.center,
                                        child:
                                            isLoading
                                                ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                )
                                                : Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    const Icon(Icons.save_alt, size: 20),
                                                    const SizedBox(width: 8),
                                                    Text(l10n.register, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isFormValid() {
    return _selectedReason != null && _selectedIntensity != null && _selectedLocation != null;
  }

  String _getValidationMessage(AppLocalizations l10n) {
    if (_selectedReason == null) {
      return l10n.pleaseSelectReason;
    } else if (_selectedIntensity == null) {
      return l10n.pleaseSelectIntensity;
    } else if (_selectedLocation == null) {
      return l10n.pleaseSelectLocation;
    }
    return "";
  }

  Widget _buildLocationGrid(BuildContext context, AppLocalizations l10n) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final locations = [
      _LocationOption(icon: Icons.home_outlined, label: l10n.home, value: 'home'),
      _LocationOption(icon: Icons.work_outline, label: l10n.work, value: 'work'),
      _LocationOption(icon: Icons.directions_car_outlined, label: l10n.car, value: 'car'),
      _LocationOption(icon: Icons.restaurant_outlined, label: l10n.restaurant, value: 'restaurant'),
      _LocationOption(icon: Icons.local_bar_outlined, label: l10n.bar, value: 'bar'),
      _LocationOption(icon: Icons.directions_walk_outlined, label: l10n.street, value: 'street'),
      _LocationOption(icon: Icons.park_outlined, label: l10n.park, value: 'park'),
      _LocationOption(icon: Icons.more_horiz, label: l10n.others, value: 'other'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: isSmallScreen ? 2.5 : 2.2,
        crossAxisSpacing: isSmallScreen ? 10 : 12,
        mainAxisSpacing: isSmallScreen ? 10 : 12,
      ),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return _buildLocationOption(context, location.icon, location.label, location.value);
      },
    );
  }

  Widget _buildLocationOption(BuildContext context, IconData icon, String label, String value) {
    final isSelected = _selectedLocation == value;
    final color = Colors.red;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLocation = value;
          _updateSectionStates();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12, horizontal: isSmallScreen ? 10 : 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withOpacity(0.1)
                  : context.isDarkMode
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              color:
                  isSelected
                      ? color
                      : context.isDarkMode
                      ? Colors.white
                      : Colors.grey[800],
              size: isSmallScreen ? 20 : 24,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
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

  Widget _buildResistOptions(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _didResist = true;
              _updateSectionStates();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color:
                  _didResist == true
                      ? Colors.green.withOpacity(0.2)
                      : context.isDarkMode
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _didResist == true ? Colors.green : Colors.transparent, width: 1.5),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _didResist == true ? Colors.green : Colors.transparent,
                    border: Border.all(color: _didResist == true ? Colors.green : Colors.grey.withOpacity(0.5), width: 1.5),
                  ),
                  child: _didResist == true ? const Center(child: Icon(Icons.check, size: 14, color: Colors.white)) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.yes,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _didResist == true ? FontWeight.bold : FontWeight.normal,
                      color: _didResist == true ? Colors.green : context.contentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            setState(() {
              _didResist = false;
              _updateSectionStates();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color:
                  _didResist == false
                      ? Colors.red.withOpacity(0.2)
                      : context.isDarkMode
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _didResist == false ? Colors.red : Colors.transparent, width: 1.5),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _didResist == false ? Colors.red : Colors.transparent,
                    border: Border.all(color: _didResist == false ? Colors.red : Colors.grey.withOpacity(0.5), width: 1.5),
                  ),
                  child: _didResist == false ? const Center(child: Icon(Icons.check, size: 14, color: Colors.white)) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.no,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _didResist == false ? FontWeight.bold : FontWeight.normal,
                      color: _didResist == false ? Colors.red : context.contentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHandle(BuildContext context) {
    return SizedBox(
      height: 24,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.withAlpha(77), borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Close button in the top right corner
          Positioned(
            top: 0,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.close, size: 18, color: Colors.grey[600]),
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

  Widget _buildReasonGrid(BuildContext context, AppLocalizations l10n) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final reasons = [
      _ReasonOption(icon: Icons.psychology, label: l10n.stress, value: 'stress'),
      _ReasonOption(icon: Icons.coffee, label: l10n.coffee, value: 'coffee'),
      _ReasonOption(icon: Icons.sentiment_very_dissatisfied, label: l10n.anxiety, value: 'anxiety'),
      _ReasonOption(icon: Icons.wine_bar, label: l10n.alcohol, value: 'alcohol'),
      _ReasonOption(icon: Icons.people_alt_outlined, label: l10n.socialSituation, value: 'social'),
      _ReasonOption(icon: Icons.fastfood_outlined, label: l10n.afterMeal, value: 'after_meal'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: isSmallScreen ? 2.5 : 2.2,
        crossAxisSpacing: isSmallScreen ? 10 : 12,
        mainAxisSpacing: isSmallScreen ? 10 : 12,
      ),
      itemCount: reasons.length,
      itemBuilder: (context, index) {
        final reason = reasons[index];
        return _buildReasonOption(context, reason.icon, reason.label, reason.value);
      },
    );
  }

  Widget _buildReasonOption(BuildContext context, IconData icon, String label, String value) {
    final isSelected = _selectedReason == value;
    final color = Colors.red;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedReason = value;
          _updateSectionStates();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12, horizontal: isSmallScreen ? 10 : 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withOpacity(0.1)
                  : context.isDarkMode
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              color:
                  isSelected
                      ? color
                      : context.isDarkMode
                      ? Colors.white
                      : Colors.grey[800],
              size: isSmallScreen ? 20 : 24,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
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

  Widget _buildIntensityOptions(BuildContext context, AppLocalizations l10n) {
    final intensities = [
      _IntensityOption(label: l10n.mild, value: 'mild'),
      _IntensityOption(label: l10n.moderate, value: 'moderate'),
      _IntensityOption(label: l10n.intense, value: 'high'),
      _IntensityOption(label: l10n.veryIntense, value: 'very_high'),
    ];

    return Column(
      children:
          intensities
              .map(
                (intensity) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildIntensityOption(context, intensity.label, intensity.value, _selectedIntensity == intensity.value, (value) {
                    setState(() {
                      _selectedIntensity = value ? intensity.value : null;
                      _updateSectionStates();
                    });
                  }),
                ),
              )
              .toList(),
    );
  }

  Widget _buildIntensityOption(BuildContext context, String label, String value, bool isSelected, Function(bool) onSelected) {
    final color = Colors.red;

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
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: <Widget>[
            // Selection indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.5), width: 1.5),
              ),
              child: isSelected ? const Center(child: Icon(Icons.check, size: 14, color: Colors.white)) : null,
            ),
            const SizedBox(width: 12),
            // Option text
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

  Widget _buildNotesField(BuildContext context, AppLocalizations l10n) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.isDarkMode ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2)),
        ),
        child: TextField(
          controller: _notesController,
          maxLines: isSmallScreen ? 2 : 3,
          minLines: 1,
          decoration: InputDecoration(
            hintText: l10n.howDoYouFeel,
            hintStyle: TextStyle(color: context.subtitleColor, fontSize: isSmallScreen ? 12 : 13),
            contentPadding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.check_circle_outline, color: Colors.red.withOpacity(0.7), size: 20),
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }

  // Method to get readable label for a selected reason
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
      case 'social':
        return l10n.socialSituation;
      case 'after_meal':
        return l10n.afterMeal;
      default:
        return value;
    }
  }

  // Method to get readable label for a selected intensity
  String _getIntensityLabel(String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'mild':
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

  // Method to get readable label for a selected location
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
      case 'other':
        return l10n.others;
      default:
        return value;
    }
  }

  void _saveCraving() {
    if (!_isFormValid()) return;

    final authBloc = BlocProvider.of<AuthBloc>(context);
    final trackingBloc = BlocProvider.of<TrackingBloc>(context);
    final l10n = AppLocalizations.of(context);

    // Ensure user is authenticated
    if (authBloc.state.status != bloc_auth.AuthStatus.authenticated) {
      if (kDebugMode) {
        print('❌ Cannot save craving: User not authenticated');
      }
      // Show error message with proper localization
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Not authenticated"), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
      return;
    }

    final userId = authBloc.state.user!.id;

    // Create the craving record
    final craving = CravingModel(
      trigger: _selectedReason!,
      intensity: _selectedIntensity!,
      location: _selectedLocation!,
      resisted: _didResist,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      timestamp: DateTime.now(),
      userId: userId,
    );

    if (kDebugMode) {
      print('📊 [RegisterCravingSheet] Saving craving: resisted=${_didResist}');
    }

    // Exibir indicador de carregamento
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
            const SizedBox(width: 16),
            Text(_didResist ? "Registrando craving resistido..." : "Registrando craving..."),
          ],
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    // Dispatch the save event directly to the TrackingBloc
    trackingBloc.add(SaveCraving(craving: craving));
    
    // Forçar atualização completa para garantir contagem correta
    trackingBloc.add(ForceUpdateStats());
    
    // Health recovery checks are now handled automatically in the TrackingBloc
    // when SaveCraving is processed, so we don't need to do it manually here.
    if (kDebugMode) {
      print('🔄 [RegisterCravingSheet] Requested craving save and stats update');
    }

    // Close the sheet with the result
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop({'registered': true});

      if (kDebugMode) {
        print('👋 [RegisterCravingSheet] Sheet closed, database update in progress');
      }
    }
  }
}

class _ReasonOption {
  final IconData icon;
  final String label;
  final String value;

  const _ReasonOption({required this.icon, required this.label, required this.value});
}

class _IntensityOption {
  final String label;
  final String value;

  const _IntensityOption({required this.label, required this.value});
}

class _LocationOption {
  final IconData icon;
  final String label;
  final String value;

  const _LocationOption({required this.icon, required this.label, required this.value});
}
