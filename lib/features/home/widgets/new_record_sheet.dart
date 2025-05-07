import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';
import 'package:nicotinaai_flutter/features/home/models/smoking_record_model.dart';
import 'package:nicotinaai_flutter/features/home/providers/smoking_record_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

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

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
                    
                    // "What's the reason?" section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Text(
                        l10n.whatsTheReason,
                        style: context.titleStyle.copyWith(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Reason options in grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildReasonGrid(context, l10n),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // How much did you smoke section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Text(
                        l10n.howMuchDidYouSmoke,
                        style: context.titleStyle.copyWith(fontSize: 20),
                      ),
                    ),
                    
                    // Amount options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildAmountOptions(context, l10n),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // How long did it last section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Text(
                        l10n.howLongDidItLast,
                        style: context.titleStyle.copyWith(fontSize: 20),
                      ),
                    ),
                    
                    // Duration options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildDurationOptions(context, l10n),
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
              
              // Fixed register button at the bottom
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
                    // Full-width register button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isFormValid() ? _saveRecord : () {
                          // Show message when button is pressed but form is invalid
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
                          l10n.register,
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
    return _selectedReason != null && 
           _selectedAmount != null && 
           _selectedDuration != null;
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

  Widget _buildReasonGrid(BuildContext context, AppLocalizations l10n) {
    final reasons = [
      _ReasonOption(
        icon: Icons.psychology,
        label: l10n.stress,
        value: 'stress',
      ),
      _ReasonOption(
        icon: Icons.coffee,
        label: l10n.coffee,
        value: 'coffee',
      ),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
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
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedReason = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
            ? color.withOpacity(0.1) 
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected 
                ? color 
                : context.isDarkMode 
                  ? Colors.white 
                  : Colors.grey[800],
              size: 24,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                    ? color 
                    : context.contentColor,
                ),
              ),
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
        maxLines: 5,
        decoration: InputDecoration(
          hintText: l10n.howDoYouFeel,
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
  
  Widget _buildAmountOptions(BuildContext context, AppLocalizations l10n) {
    final amounts = [
      _AmountOption(label: l10n.oneOrLess, value: 'one_or_less'),
      _AmountOption(label: l10n.twoToFive, value: 'two_to_five'),
      _AmountOption(label: l10n.moreThanFive, value: 'more_than_five'),
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: amounts.map((amount) => Expanded(
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
      )).toList(),
    );
  }
  
  Widget _buildDurationOptions(BuildContext context, AppLocalizations l10n) {
    final durations = [
      _DurationOption(label: l10n.lessThan5min, value: 'less_than_5min'),
      _DurationOption(label: l10n.fiveToFifteenMin, value: '5_to_15min'),
      _DurationOption(label: l10n.moreThan15min, value: 'more_than_15min'),
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: durations.map((duration) => Expanded(
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
      )).toList(),
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
    
    return InkWell(
      onTap: () => onSelected(!isSelected),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : context.contentColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  void _saveRecord() async {
    if (!_isFormValid()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recordProvider = Provider.of<SmokingRecordProvider>(context, listen: false);
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    
    final userId = authProvider.currentUser?.id ?? '';
    if (userId.isEmpty) {
      // Cannot save if not authenticated
      Navigator.of(context).pop();
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
    
    // Close the sheet immediately for better UX with success result
    Navigator.of(context).pop(true);
    
    try {
      // Optimistically update the UI and save in the background
      await recordProvider.saveRecord(record);
      
      // Força a atualização das estatísticas no TrackingProvider
      await trackingProvider.forceUpdateStats();
      
      // Show a success snackbar using the stored scaffold messenger
      // This avoids the mounted check which can cause issues
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
          action: recordProvider.error != null ? SnackBarAction(
            label: retryLabel,
            onPressed: () {
              // Find the failed record and retry
              final failedRecord = recordProvider.failedRecords.firstOrNull;
              if (failedRecord != null) {
                recordProvider.retrySyncRecord(failedRecord.id!);
              }
            },
          ) : null,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving record: $e');
      }
      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
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
  
  const _AmountOption({
    required this.label,
    required this.value,
  });
}

class _DurationOption {
  final String label;
  final String value;
  
  const _DurationOption({
    required this.label,
    required this.value,
  });
}