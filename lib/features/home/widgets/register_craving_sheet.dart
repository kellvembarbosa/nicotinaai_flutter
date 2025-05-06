import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/home/providers/craving_provider.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class RegisterCravingSheet extends StatefulWidget {
  const RegisterCravingSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RegisterCravingSheet(),
    );
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

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _buildHandle(context),
                    
                    // "Where are you?" section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Text(
                        l10n.whereAreYou,
                        style: context.titleStyle.copyWith(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Location grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildLocationGrid(context, l10n),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Trigger section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Text(
                        l10n.whatTriggeredCraving,
                        style: context.titleStyle.copyWith(fontSize: 20),
                      ),
                    ),
                    
                    // Trigger options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildTriggerOptions(context, l10n),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Intensity section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Text(
                        l10n.intensityLevel,
                        style: context.titleStyle.copyWith(fontSize: 20),
                      ),
                    ),
                    
                    // Intensity options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildIntensityOptions(context, l10n),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Did you resist section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Text(
                        l10n.didYouResist,
                        style: context.titleStyle.copyWith(fontSize: 20),
                      ),
                    ),
                    
                    // Yes/No options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildResistOptions(context, l10n),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Notes field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.notes,
                            style: context.titleStyle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          _buildNotesField(context, l10n),
                        ],
                      ),
                    ),
                    
                    // Extra space at the bottom for content to scroll above the fixed button
                    const SizedBox(height: 90),
                  ],
                ),
              ),
              
              // Fixed save button at the bottom
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 24, 
                  right: 24, 
                  bottom: 24 + MediaQuery.of(context).viewInsets.bottom / 2,
                  top: 12,
                ),
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error message for invalid form
                    if (!_isFormValid())
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _getValidationMessage(l10n),
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    // Full-width save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isFormValid() ? _saveCraving : () {
                          // Show bottom message when button is pressed but form is invalid
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_getValidationMessage(l10n)),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          disabledBackgroundColor: null, // Let the button be tappable even if invalid
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          l10n.save,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
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
    final intensities = [
      _IntensityOption(label: l10n.mild, value: 'mild'),
      _IntensityOption(label: l10n.moderate, value: 'moderate'),
      _IntensityOption(label: l10n.intense, value: 'intense'),
      _IntensityOption(label: l10n.veryIntense, value: 'very_intense'),
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: intensities.map((intensity) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _buildIntensityOption(
            context,
            intensity.label,
            intensity.value,
          ),
        ),
      )).toList(),
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
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLocation = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected 
                ? color.withOpacity(0.2) 
                : context.isDarkMode 
                  ? Colors.grey.withOpacity(0.1) 
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
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
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
        ? Colors.grey.withOpacity(0.1) 
        : Colors.grey.withOpacity(0.05),
      selectedColor: context.primaryColor.withOpacity(0.2),
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
    final color = context.primaryColor;
    
    Color getColor() {
      switch (value) {
        case 'mild':
          return Colors.green;
        case 'moderate':
          return Colors.orange;
        case 'intense':
          return Colors.deepOrange;
        case 'very_intense':
          return Colors.red;
        default:
          return color;
      }
    }
    
    final itemColor = getColor();
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIntensity = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? itemColor.withOpacity(0.2) 
            : context.isDarkMode 
              ? Colors.grey.withOpacity(0.1) 
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? itemColor 
              : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              color: isSelected ? itemColor : Colors.grey.withOpacity(0.3),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? itemColor : context.contentColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotesField(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode 
            ? Colors.grey.withOpacity(0.1) 
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode 
              ? Colors.grey.withOpacity(0.3) 
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: l10n.howAreYouFeeling,
          hintStyle: TextStyle(
            color: context.subtitleColor,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }
  
  Widget _buildResistOptions(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildResistOption(
            context, 
            l10n.yes, 
            true, 
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
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
    
    return InkWell(
      onTap: () {
        setState(() {
          _didResist = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
            ? color.withOpacity(0.2) 
            : context.isDarkMode 
              ? Colors.grey.withOpacity(0.1) 
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? color 
              : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : context.contentColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  void _saveCraving() async {
    if (!_isFormValid()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cravingProvider = Provider.of<CravingProvider>(context, listen: false);
    
    final userId = authProvider.currentUser?.id ?? '';
    if (userId.isEmpty) {
      // Cannot save if not authenticated
      Navigator.of(context).pop();
      return;
    }
    
    final craving = CravingModel(
      location: _selectedLocation!,
      trigger: _selectedTrigger!,
      intensity: _selectedIntensity!,
      resisted: _didResist!,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      timestamp: DateTime.now(),
      userId: userId,
    );
    
    final success = await cravingProvider.saveCraving(craving);
    
    // Close the sheet after saving
    if (!context.mounted) return;
    Navigator.of(context).pop();
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