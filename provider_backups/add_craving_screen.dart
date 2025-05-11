import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/features/tracking/models/craving.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddCravingScreen extends StatefulWidget {
  const AddCravingScreen({Key? key}) : super(key: key);

  @override
  State<AddCravingScreen> createState() => _AddCravingScreenState();
}

class _AddCravingScreenState extends State<AddCravingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  DateTime _selectedTime = DateTime.now();
  CravingIntensity _selectedIntensity = CravingIntensity.moderate;
  String? _trigger;
  String? _location;
  int? _durationMinutes = 5;
  CravingOutcome _selectedOutcome = CravingOutcome.resisted;
  String? _copingStrategy;
  String? _notes;
  
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Craving'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Time Picker
              _buildDateTimePicker(),
              
              const SizedBox(height: 20),
              
              // Intensity Selection
              _buildIntensitySelector(),
              
              const SizedBox(height: 20),
              
              // Duration Selector
              _buildDurationSelector(),
              
              const SizedBox(height: 20),
              
              // Outcome Selection
              _buildOutcomeSelector(),
              
              const SizedBox(height: 20),
              
              // Trigger Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Trigger',
                  hintText: 'What triggered your craving?',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _trigger = value,
              ),
              
              const SizedBox(height: 20),
              
              // Location Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Where were you when the craving hit?',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _location = value,
              ),
              
              const SizedBox(height: 20),
              
              // Coping Strategy Field (only if resisted or alternative)
              if (_selectedOutcome != CravingOutcome.smoked)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Coping Strategy',
                    hintText: 'How did you manage the craving?',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _copingStrategy = value,
                ),
              
              if (_selectedOutcome != CravingOutcome.smoked)
                const SizedBox(height: 20),
              
              // Notes Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any additional details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => _notes = value,
              ),
              
              const SizedBox(height: 30),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting 
                    ? const CircularProgressIndicator()
                    : const Text('Log Craving'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    final dateFormat = DateFormat('yyyy-MM-dd – HH:mm');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'When did you feel the craving?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateFormat.format(_selectedTime)),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How strong was the craving?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SegmentedButton<CravingIntensity>(
          segments: const [
            ButtonSegment<CravingIntensity>(
              value: CravingIntensity.low,
              label: Text('Low'),
            ),
            ButtonSegment<CravingIntensity>(
              value: CravingIntensity.moderate,
              label: Text('Moderate'),
            ),
            ButtonSegment<CravingIntensity>(
              value: CravingIntensity.high,
              label: Text('High'),
            ),
            ButtonSegment<CravingIntensity>(
              value: CravingIntensity.veryHigh,
              label: Text('Very High'),
            ),
          ],
          selected: {_selectedIntensity},
          onSelectionChanged: (Set<CravingIntensity> newSelection) {
            setState(() {
              _selectedIntensity = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How long did it last? (minutes)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: _durationMinutes! > 1 
                ? () => setState(() => _durationMinutes = _durationMinutes! - 1) 
                : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Expanded(
              child: Text(
                _durationMinutes.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _durationMinutes = _durationMinutes! + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutcomeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What was the outcome?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SegmentedButton<CravingOutcome>(
          segments: const [
            ButtonSegment<CravingOutcome>(
              value: CravingOutcome.resisted,
              label: Text('Resisted'),
              icon: Icon(Icons.check_circle_outline),
            ),
            ButtonSegment<CravingOutcome>(
              value: CravingOutcome.smoked,
              label: Text('Smoked'),
              icon: Icon(Icons.smoking_rooms),
            ),
            ButtonSegment<CravingOutcome>(
              value: CravingOutcome.alternative,
              label: Text('Alternative'),
              icon: Icon(Icons.swap_horiz),
            ),
          ],
          selected: {_selectedOutcome},
          onSelectionChanged: (Set<CravingOutcome> newSelection) {
            setState(() {
              _selectedOutcome = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedTime),
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        final userId = context.read<TrackingProvider>().state.userStats?.userId ??
            'unknown';
            
        final craving = Craving(
          userId: userId,
          timestamp: _selectedTime,
          intensity: _selectedIntensity,
          trigger: _trigger,
          location: _location,
          durationMinutes: _durationMinutes,
          outcome: _selectedOutcome,
          copingStrategy: _copingStrategy,
          notes: _notes,
        );
        
        await context.read<TrackingProvider>().addCraving(craving);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Craving logged successfully')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error logging craving: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}