import 'package:flutter/material.dart';
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
import 'package:nicotinaai_flutter/utils/improved_optimistic_utils.dart';

/// A modal bottom sheet for registering cravings with improved optimistic updates
class RegisterCravingSheetImproved extends StatefulWidget {
  const RegisterCravingSheetImproved({super.key});

  /// Shows the register craving sheet and returns true if a craving was registered
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RegisterCravingSheetImproved(),
    );
    // Return true if a craving was successfully registered
    return result ?? false;
  }

  @override
  State<RegisterCravingSheetImproved> createState() => _RegisterCravingSheetImprovedState();
}

class _RegisterCravingSheetImprovedState extends State<RegisterCravingSheetImproved> {
  // Form fields
  final TextEditingController _notesController = TextEditingController();
  String? _selectedLocation;
  String? _selectedTrigger;
  String? _selectedIntensity;
  bool? _didResist;
  
  // State for expandable sections
  bool _isLocationSectionExpanded = true;
  bool _isTriggerSectionExpanded = true;
  bool _isIntensitySectionExpanded = true;
  bool _isResistSectionExpanded = true;
  bool _isNotesSectionExpanded = true;

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

  // Check if all required fields are filled
  bool _isFormValid() {
    // Location, trigger, and intensity are required
    // Whether they resisted is also required
    return _selectedLocation != null && 
           _selectedTrigger != null && 
           _selectedIntensity != null &&
           _didResist != null;
  }
  
  // Returns error message based on missing fields
  String _getValidationMessage(AppLocalizations l10n) {
    if (_selectedLocation == null) {
      return l10n.pleaseSelectLocation;
    } else if (_selectedTrigger == null) {
      return l10n.pleaseSelectTrigger;
    } else if (_selectedIntensity == null) {
      return l10n.pleaseSelectIntensity;
    } else if (_didResist == null) {
      return l10n.pleaseSelectResistOption;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return BlocListener<CravingBloc, CravingState>(
      listener: (context, state) {
        // Handle state changes from the craving bloc
        if (state.status == CravingStatus.saved) {
          // Close the sheet and return true to indicate success
          Navigator.of(context).pop(true);
        } else if (state.status == CravingStatus.error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l10n.errorOccurred),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: context.backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Handle and header
                Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Column(
                    children: <Widget>[
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        l10n.registerCraving,
                        style: const TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      // Subtitle
                      Text(
                        l10n.registerCravingSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.subtitleColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Form sections
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const ClampingScrollPhysics(),
                    children: <Widget>[
                      // Location section
                      _buildExpandableSection(
                        title: l10n.whereAreYou,
                        icon: Icons.place,
                        isExpanded: _isLocationSectionExpanded,
                        onToggle: () => setState(() {
                          _isLocationSectionExpanded = !_isLocationSectionExpanded;
                        }),
                        selectedValue: _selectedLocation,
                        valueLabel: _selectedLocation != null 
                            ? _getLocationLabel(_selectedLocation!) 
                            : null,
                        child: _buildLocationOptions(context),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Trigger section
                      _buildExpandableSection(
                        title: l10n.whatTriggeredCraving,
                        icon: Icons.psychology,
                        isExpanded: _isTriggerSectionExpanded,
                        onToggle: () => setState(() {
                          _isTriggerSectionExpanded = !_isTriggerSectionExpanded;
                        }),
                        selectedValue: _selectedTrigger,
                        valueLabel: _selectedTrigger != null 
                            ? _getTriggerLabel(_selectedTrigger!) 
                            : null,
                        child: _buildTriggerOptions(context),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Intensity section
                      _buildExpandableSection(
                        title: l10n.howIntenseIsYourCraving,
                        icon: Icons.trending_up,
                        isExpanded: _isIntensitySectionExpanded,
                        onToggle: () => setState(() {
                          _isIntensitySectionExpanded = !_isIntensitySectionExpanded;
                        }),
                        selectedValue: _selectedIntensity,
                        valueLabel: _selectedIntensity != null 
                            ? _getIntensityLabel(_selectedIntensity!) 
                            : null,
                        child: _buildIntensityOptions(context),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Resist section
                      _buildExpandableSection(
                        title: l10n.didYouResist,
                        icon: Icons.shield,
                        isExpanded: _isResistSectionExpanded,
                        onToggle: () => setState(() {
                          _isResistSectionExpanded = !_isResistSectionExpanded;
                        }),
                        selectedValue: _didResist != null ? _didResist.toString() : null,
                        valueLabel: _didResist != null 
                            ? (_didResist! ? l10n.yes : l10n.no)
                            : null,
                        child: _buildResistOptions(context),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Notes section
                      _buildExpandableSection(
                        title: l10n.notes,
                        icon: Icons.note,
                        isExpanded: _isNotesSectionExpanded,
                        onToggle: () => setState(() {
                          _isNotesSectionExpanded = !_isNotesSectionExpanded;
                        }),
                        selectedValue: _notesController.text.isNotEmpty 
                            ? _notesController.text 
                            : null,
                        valueLabel: _notesController.text.isNotEmpty 
                            ? _notesController.text.length > 20
                                ? '${_notesController.text.substring(0, 20)}...'
                                : _notesController.text
                            : null,
                        child: _buildNotesField(context),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                
                // Bottom action bar
                Container(
                  padding: EdgeInsets.only(
                    left: 16, 
                    right: 16, 
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                    top: 16,
                  ),
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Validation message if needed
                      if (!_isFormValid())
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _getValidationMessage(l10n),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      // Submit button
                      BlocBuilder<CravingBloc, CravingState>(
                        builder: (context, state) {
                          final isLoading = state.status == CravingStatus.saving;
                          
                          return ElevatedButton(
                            onPressed: isLoading || !_isFormValid()
                                ? null
                                : () => _saveCraving(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    l10n.register,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
                        },
                      ),
                      
                      // Cancel button
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Expandable section widget
  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    String? selectedValue,
    String? valueLabel,
  }) {
    return Card(
      elevation: 0,
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selectedValue != null
              ? Colors.red
              : context.dividerColor,
          width: selectedValue != null ? 1.0 : 0.5,
        ),
      ),
      margin: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Icon(icon, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (valueLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        valueLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }
  
  // Location options
  Widget _buildLocationOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    final locations = [
      _LocationOption(icon: Icons.home, label: l10n.home, value: 'home'),
      _LocationOption(icon: Icons.work, label: l10n.work, value: 'work'),
      _LocationOption(icon: Icons.restaurant, label: l10n.restaurant, value: 'restaurant'),
      _LocationOption(icon: Icons.local_bar, label: l10n.bar, value: 'bar'),
      _LocationOption(icon: Icons.directions_car, label: l10n.inCar, value: 'car'),
      _LocationOption(icon: Icons.public, label: l10n.public, value: 'public'),
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: locations.map((location) {
        final isSelected = _selectedLocation == location.value;
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedLocation = location.value;
              // Automatically collapse this section and expand next when selected
              if (_isLocationSectionExpanded) {
                _isLocationSectionExpanded = false;
                _isTriggerSectionExpanded = true;
              }
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.red.withOpacity(0.1) 
                  : context.chipBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.red : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  location.icon,
                  size: 18,
                  color: isSelected ? Colors.red : context.iconColor,
                ),
                const SizedBox(width: 6),
                Text(
                  location.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.red : context.textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  // Trigger options
  Widget _buildTriggerOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    final triggers = [
      _TriggerOption(icon: Icons.psychology, label: l10n.stress, value: 'stress'),
      _TriggerOption(icon: Icons.sentiment_very_dissatisfied, label: l10n.anxiety, value: 'anxiety'),
      _TriggerOption(icon: Icons.restaurant, label: l10n.afterMeal, value: 'after_meal'),
      _TriggerOption(icon: Icons.coffee, label: l10n.coffee, value: 'coffee'),
      _TriggerOption(icon: Icons.local_bar, label: l10n.alcohol, value: 'alcohol'),
      _TriggerOption(icon: Icons.people, label: l10n.socialSituation, value: 'social'),
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: triggers.map((trigger) {
        final isSelected = _selectedTrigger == trigger.value;
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedTrigger = trigger.value;
              // Automatically collapse this section and expand next when selected
              if (_isTriggerSectionExpanded) {
                _isTriggerSectionExpanded = false;
                _isIntensitySectionExpanded = true;
              }
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.red.withOpacity(0.1) 
                  : context.chipBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.red : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  trigger.icon,
                  size: 18,
                  color: isSelected ? Colors.red : context.iconColor,
                ),
                const SizedBox(width: 6),
                Text(
                  trigger.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.red : context.textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  // Intensity options using slider
  Widget _buildIntensityOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // Determine current intensity level index
    final intensityValue = _selectedIntensity == null
        ? 0.0
        : _getIntensityValue(_selectedIntensity!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Intensity slider
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8,
            activeTrackColor: Colors.red,
            inactiveTrackColor: Colors.red.withOpacity(0.2),
            thumbColor: Colors.red,
            overlayColor: Colors.red.withOpacity(0.2),
            valueIndicatorColor: Colors.red,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(
            value: intensityValue,
            min: 1,
            max: 5,
            divisions: 4,
            label: _getIntensityLabelFromValue(intensityValue.toInt()),
            onChanged: (value) {
              setState(() {
                _selectedIntensity = _getIntensityKeyFromValue(value.toInt());
              });
            },
            onChangeEnd: (value) {
              // Automatically collapse this section and expand next when selected
              if (_isIntensitySectionExpanded) {
                setState(() {
                  _isIntensitySectionExpanded = false;
                  _isResistSectionExpanded = true;
                });
              }
            },
          ),
        ),
        
        // Intensity labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildIntensityLabel(l10n.veryMild, intensityValue == 1),
              _buildIntensityLabel(l10n.mild, intensityValue == 2),
              _buildIntensityLabel(l10n.moderate, intensityValue == 3),
              _buildIntensityLabel(l10n.severe, intensityValue == 4),
              _buildIntensityLabel(l10n.verySevere, intensityValue == 5),
            ],
          ),
        ),
      ],
    );
  }
  
  // Small intensity label widget
  Widget _buildIntensityLabel(String label, bool isSelected) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: isSelected ? Colors.red : context.subtitleColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  
  // Resist options (yes/no)
  Widget _buildResistOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Row(
      children: <Widget>[
        // Yes option
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _didResist = true;
                // Automatically collapse this section and expand notes when selected
                if (_isResistSectionExpanded) {
                  _isResistSectionExpanded = false;
                  _isNotesSectionExpanded = true;
                }
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _didResist == true
                    ? Colors.green.withOpacity(0.2)
                    : context.chipBackgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _didResist == true ? Colors.green : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    color: _didResist == true ? Colors.green : context.iconColor,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.yes,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _didResist == true ? FontWeight.bold : FontWeight.normal,
                      color: _didResist == true ? Colors.green : context.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // No option
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _didResist = false;
                // Automatically collapse this section and expand notes when selected
                if (_isResistSectionExpanded) {
                  _isResistSectionExpanded = false;
                  _isNotesSectionExpanded = true;
                }
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _didResist == false
                    ? Colors.red.withOpacity(0.2)
                    : context.chipBackgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _didResist == false ? Colors.red : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.cancel_outlined,
                    color: _didResist == false ? Colors.red : context.iconColor,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.no,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _didResist == false ? FontWeight.bold : FontWeight.normal,
                      color: _didResist == false ? Colors.red : context.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Notes text field
  Widget _buildNotesField(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: context.inputBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.dividerColor,
        ),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        minLines: 3,
        decoration: InputDecoration(
          hintText: l10n.howDoYouFeel,
          hintStyle: TextStyle(
            color: context.subtitleColor,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.all(12),
          border: InputBorder.none,
        ),
        style: TextStyle(
          color: context.textColor,
          fontSize: 14,
        ),
      ),
    );
  }
  
  // Save the craving with optimistic updates
  void _saveCraving(BuildContext context) {
    // Ensure the form is valid
    if (!_isFormValid()) return;
    
    final l10n = AppLocalizations.of(context);
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final cravingBloc = BlocProvider.of<CravingBloc>(context);
    final trackingBloc = BlocProvider.of<TrackingBloc>(context);
    
    // Check if user is authenticated
    if (authBloc.state.status != bloc_auth.AuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notAuthenticated),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final userId = authBloc.state.user!.id;
    
    // Create the craving model
    final craving = CravingModel(
      location: _selectedLocation!,
      reason: _selectedTrigger!,
      intensity: _selectedIntensity!,
      didResist: _didResist!,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      timestamp: DateTime.now(),
      userId: userId,
    );
    
    // Apply optimistic update using the utility
    ImprovedOptimisticUtils.optimisticCravingAction(
      context: context,
      trackingBloc: trackingBloc,
      craving: craving, 
      didResist: _didResist!,
      onUpdateCompleted: () {
        // Dispatch the actual save event
        cravingBloc.add(SaveCravingRequested(craving: craving));
        
        // Check for achievements on craving resistance
        if (_didResist!) {
          AchievementHelper.checkCravingResistanceAchievements(context);
        }
      }
    );
  }
  
  // Helper methods for location labels
  String _getLocationLabel(String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'home': return l10n.home;
      case 'work': return l10n.work;
      case 'restaurant': return l10n.restaurant;
      case 'bar': return l10n.bar;
      case 'car': return l10n.inCar;
      case 'public': return l10n.public;
      default: return value;
    }
  }
  
  // Helper methods for trigger labels
  String _getTriggerLabel(String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'stress': return l10n.stress;
      case 'anxiety': return l10n.anxiety;
      case 'after_meal': return l10n.afterMeal;
      case 'coffee': return l10n.coffee;
      case 'alcohol': return l10n.alcohol;
      case 'social': return l10n.socialSituation;
      default: return value;
    }
  }
  
  // Helper methods for intensity labels
  String _getIntensityLabel(String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'very_mild': return l10n.veryMild;
      case 'mild': return l10n.mild;
      case 'moderate': return l10n.moderate;
      case 'severe': return l10n.severe;
      case 'very_severe': return l10n.verySevere;
      default: return value;
    }
  }
  
  // Convert intensity key to numeric value
  double _getIntensityValue(String intensityKey) {
    switch (intensityKey) {
      case 'very_mild': return 1.0;
      case 'mild': return 2.0;
      case 'moderate': return 3.0;
      case 'severe': return 4.0;
      case 'very_severe': return 5.0;
      default: return 0.0;
    }
  }
  
  // Convert numeric value to intensity label
  String _getIntensityLabelFromValue(int value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 1: return l10n.veryMild;
      case 2: return l10n.mild;
      case 3: return l10n.moderate;
      case 4: return l10n.severe;
      case 5: return l10n.verySevere;
      default: return '';
    }
  }
  
  // Convert numeric value to intensity key
  String _getIntensityKeyFromValue(int value) {
    switch (value) {
      case 1: return 'very_mild';
      case 2: return 'mild';
      case 3: return 'moderate';
      case 4: return 'severe';
      case 5: return 'very_severe';
      default: return 'moderate';
    }
  }
}

// Helper classes for form options
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
  final IconData icon;
  final String label;
  final String value;
  
  const _TriggerOption({
    required this.icon,
    required this.label,
    required this.value,
  });
}