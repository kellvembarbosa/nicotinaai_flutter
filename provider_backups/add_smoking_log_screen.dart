import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';
import 'package:nicotinaai_flutter/features/tracking/models/smoking_log.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddSmokingLogScreen extends StatefulWidget {
  const AddSmokingLogScreen({Key? key}) : super(key: key);

  @override
  State<AddSmokingLogScreen> createState() => _AddSmokingLogScreenState();
}

class _AddSmokingLogScreenState extends State<AddSmokingLogScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedTime = DateTime.now();
  ProductType _selectedProductType = ProductType.cigaretteOnly;
  int _quantity = 1;
  String? _location;
  String? _mood;
  String? _trigger;
  String? _notes;

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Smoking Event')),
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

              // Product Type Selection
              _buildProductTypeSelector(),

              const SizedBox(height: 20),

              // Quantity Selector
              _buildQuantitySelector(),

              const SizedBox(height: 20),

              // Location Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location', hintText: 'Where were you when smoking?', border: OutlineInputBorder()),
                onChanged: (value) => _location = value,
              ),

              const SizedBox(height: 20),

              // Mood Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mood', hintText: 'How were you feeling?', border: OutlineInputBorder()),
                onChanged: (value) => _mood = value,
              ),

              const SizedBox(height: 20),

              // Trigger Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Trigger', hintText: 'What triggered you to smoke?', border: OutlineInputBorder()),
                onChanged: (value) => _trigger = value,
              ),

              const SizedBox(height: 20),

              // Notes Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes', hintText: 'Any additional details', border: OutlineInputBorder()),
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
                  child: _isSubmitting ? const CircularProgressIndicator() : const Text('Log Smoking Event'),
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
        const Text('When did you smoke?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(dateFormat.format(_selectedTime)), const Icon(Icons.calendar_today)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What did you smoke?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        SegmentedButton<ProductType>(
          segments: const [
            ButtonSegment<ProductType>(value: ProductType.cigaretteOnly, label: Text('Cigarette'), icon: Icon(Icons.smoke_free)),
            ButtonSegment<ProductType>(value: ProductType.vapeOnly, label: Text('Vape'), icon: Icon(Icons.air)),
            ButtonSegment<ProductType>(value: ProductType.both, label: Text('Both'), icon: Icon(Icons.category)),
          ],
          selected: {_selectedProductType},
          onSelectionChanged: (Set<ProductType> newSelection) {
            setState(() {
              _selectedProductType = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How many?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove_circle_outline)),
            Expanded(child: Text(_quantity.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 20))),
            IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add_circle_outline)),
          ],
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
      final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selectedTime));

      if (pickedTime != null) {
        setState(() {
          _selectedTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
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
        final userId = context.read<TrackingProvider>().state.userStats?.userId ?? 'unknown';

        final log = SmokingLog(
          userId: userId,
          timestamp: _selectedTime,
          productType: _selectedProductType,
          quantity: _quantity,
          location: _location,
          mood: _mood,
          trigger: _trigger,
          notes: _notes,
        );

        await context.read<TrackingProvider>().addSmokingLog(log);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Smoking event logged successfully')));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error logging smoking event: $e')));
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
