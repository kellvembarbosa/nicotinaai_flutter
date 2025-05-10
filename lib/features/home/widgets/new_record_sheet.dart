import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart' as bloc_auth;
import 'package:nicotinaai_flutter/blocs/smoking_record/smoking_record_bloc.dart';
import 'package:nicotinaai_flutter/blocs/smoking_record/smoking_record_event.dart';
import 'package:nicotinaai_flutter/blocs/smoking_record/smoking_record_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class NewRecordSheet extends StatefulWidget {
  const NewRecordSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => const NewRecordSheet(),
    );
    // Returns true if a record was successfully registered
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

  // Controls for collapsible sections
  bool _isReasonSectionExpanded = true;
  bool _isAmountDurationSectionExpanded = true;
  bool _isNotesSectionExpanded = true;

  // Controls for subsections within the amount/duration section
  bool _isAmountSubSectionVisible = true;
  bool _isDurationSubSectionVisible = false;

  @override
  void initState() {
    super.initState();
    // Add listener for notes controller
    _notesController.addListener(() {
      setState(() {
        // Force rebuild when text changes to update the summary
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
        _isAmountDurationSectionExpanded = true;
      }

      // When the user completes amount and duration, collapse that section and expand notes
      if (_selectedAmount != null &&
          _selectedDuration != null &&
          _isAmountDurationSectionExpanded) {
        _isAmountDurationSectionExpanded = false;
        _isNotesSectionExpanded = true;
      }
    });
  }

  // Update subsections within the amount/duration section
  void _updateAmountDurationSubSections() {
    setState(() {
      if (_selectedAmount != null && _selectedDuration == null) {
        // If an amount is selected but not a duration,
        // collapse the amount section and show the duration section
        _isAmountSubSectionVisible = false;
        _isDurationSubSectionVisible = true;
      } else if (_selectedAmount != null && _selectedDuration != null) {
        // If both are selected, collapse both subsections
        _isAmountSubSectionVisible = false;
        _isDurationSubSectionVisible = false;
      } else {
        // Initial state or reset
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

    // Specific size for this sheet 
    const initialSize = 0.80; // 80% of screen height

    return BlocListener<SmokingRecordBloc, SmokingRecordState>(
      listener: (context, state) {
        // Listen for changes in the smoking record state
        if (state.status == SmokingRecordStatus.saving) {
          // Show loading indicator
          if (kDebugMode) {
            print('💾 Saving smoking record...');
          }
        } else if (state.status == SmokingRecordStatus.loaded) {
          // The record was saved successfully
          if (kDebugMode) {
            print('✅ Smoking record saved successfully!');
          }
          
          // Close the sheet with success result
          Navigator.of(context).pop(true);
        } else if (state.status == SmokingRecordStatus.error) {
          // The save operation failed
          if (kDebugMode) {
            print('❌ Error saving smoking record: ${state.errorMessage}');
          }
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.errorMessage}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          
          // Don't close the sheet on error
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: initialSize,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false, // Let content determine natural size
        snap: true, // Make adjustment to specific positions easier
        snapSizes: const [
          0.65,
          0.8,
          0.95,
        ], // Keep snap options for user flexibility
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

                        // Main title, optimized without background
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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

                        // Reason Section - Collapsible
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
                                // Clickable header for expand/collapse
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
                                        const Icon(
                                          Icons.help_outline,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            l10n.whatsTheReason,
                                            style: const TextStyle(
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

                                // Expandable content
                                if (_isReasonSectionExpanded)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      0,
                                      12,
                                      12,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                        child: _buildReasonGrid(context, l10n),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Amount and Duration Section - Collapsible
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
                                // Clickable header for expand/collapse
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
                                        const Icon(
                                          Icons.smoking_rooms_outlined,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "${l10n.howMuchDidYouSmoke} & ${l10n.howLongDidItLast}",
                                            style: const TextStyle(
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

                                // Expandable content
                                if (_isAmountDurationSectionExpanded)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      0,
                                      12,
                                      12,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Amount - Normal or minimized version
                                            if (_isAmountSubSectionVisible)
                                              // Full version of amount subsection
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                  bottom: 16,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Label for amount
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.smoking_rooms_outlined,
                                                          size: 18,
                                                          color: Colors.blue,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            l10n.howMuchDidYouSmoke,
                                                            style: const TextStyle(
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
                                              // Minimized version of amount subsection
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
                                                        const Icon(
                                                          Icons.smoking_rooms_outlined,
                                                          size: 16,
                                                          color: Colors.blue,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          "${l10n.howMuchDidYouSmoke}: ${_getAmountLabel(_selectedAmount!)}",
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        const Icon(
                                                          Icons.edit,
                                                          size: 14,
                                                          color: Colors.blue,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            // Duration - Normal or minimized version
                                            if (_isDurationSubSectionVisible)
                                              // Full version of duration subsection
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Label for duration
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.timer_outlined,
                                                        size: 18,
                                                        color: Colors.blue,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          l10n.howLongDidItLast,
                                                          style: const TextStyle(
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
                                              // Minimized version of duration subsection
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
                                                        const Icon(
                                                          Icons.timer_outlined,
                                                          size: 16,
                                                          color: Colors.blue,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          "${l10n.howLongDidItLast}: ${_getDurationLabel(_selectedDuration!)}",
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        const Icon(
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
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Notes Section - Collapsible
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
                                // Clickable header for expand/collapse
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
                                        const Icon(
                                          Icons.note_outlined,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            l10n.notes,
                                            style: const TextStyle(
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

                                // Expandable content
                                if (_isNotesSectionExpanded)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      0,
                                      12,
                                      12,
                                    ),
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
                        ),

                        // Extra space at bottom
                        const SizedBox(height: 70), // Reduced from 90 to 70
                      ],
                    ),
                  ),

                  // Register button with BlocBuilder
                  BlocBuilder<SmokingRecordBloc, SmokingRecordState>(
                    builder: (context, state) {
                      final isLoading = state.status == SmokingRecordStatus.saving;
                      
                      return ClipRRect(
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
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 12,
                                          ),
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
                                              const Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _getValidationMessage(l10n),
                                                  style: const TextStyle(
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

                                // Register button with elevation and gradient
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: isLoading || !_isFormValid()
                                        ? null
                                        : _saveRecord,
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
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Row(
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
    return _selectedReason != null &&
        _selectedAmount != null &&
        _selectedDuration != null;
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
      default:
        return value;
    }
  }

  // Method to get readable label for a selected amount
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

  // Method to get readable label for a selected duration
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
            isSmallScreen ? 2.5 : 2.2, // More compact for small screens
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

    // Adaptive adjustments based on screen height
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
          // Update section states when user selects a reason
          _updateSectionStates();
        });
      },
      borderRadius: BorderRadius.circular(12), // Reduced from 16 to 12
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
          borderRadius: BorderRadius.circular(12), // Reduced from 16 to 12
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
        maxLines: isSmallScreen ? 2 : 3, // Adjusted for small screens
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

  // Vertical layout for amount options
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
                        // Update sections and subsections when user makes a selection
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

  // Vertical layout for duration options
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
                        // Update sections when user makes a selection
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

  // Full-width vertical option button
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
            // Selection indicator
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

  void _saveRecord() {
    if (!_isFormValid()) return;

    final authBloc = BlocProvider.of<AuthBloc>(context);
    final recordBloc = BlocProvider.of<SmokingRecordBloc>(context);
    final l10n = AppLocalizations.of(context);

    // Ensure user is authenticated
    if (authBloc.state.status != bloc_auth.AuthStatus.authenticated) {
      if (kDebugMode) {
        print('❌ Cannot save record: User not authenticated');
      }
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: User not authenticated'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final userId = authBloc.state.user!.id;
    
    // Create the record
    final record = SmokingRecordModel(
      reason: _selectedReason!,
      amount: _selectedAmount!,
      duration: _selectedDuration!,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      timestamp: DateTime.now(),
      userId: userId,
      context: context, // Used for achievement checks
    );

    // Dispatch the event to save the record
    recordBloc.add(SaveSmokingRecordRequested(record: record));
    
    if (kDebugMode) {
      print('💾 Dispatched SaveSmokingRecordRequested event to BLoC');
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