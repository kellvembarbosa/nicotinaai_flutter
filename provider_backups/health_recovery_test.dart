import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/auth/providers/auth_provider.dart';

/// A test widget to verify the health recovery edge function
class HealthRecoveryTest extends StatefulWidget {
  const HealthRecoveryTest({Key? key}) : super(key: key);

  @override
  State<HealthRecoveryTest> createState() => _HealthRecoveryTestState();
}

class _HealthRecoveryTestState extends State<HealthRecoveryTest> {
  bool _isLoading = false;
  String _result = '';
  String _error = '';

  Future<void> _testHealthRecoveryFunction() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    
    if (userId == null) {
      setState(() {
        _error = 'User is not authenticated';
        _isLoading = false;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _result = '';
      _error = '';
    });
    
    try {
      final client = SupabaseConfig.client;
      
      // Call the edge function
      final response = await client.functions.invoke(
        'checkHealthRecoveries',
        body: {'userId': userId},
      );
      
      if (response.status != 200) {
        setState(() {
          _error = 'Error: Status ${response.status} - Unknown error';
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _result = 'Success!\n\n${response.data != null ? _prettyPrintJson(response.data) : 'No data returned'}';
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _error = 'Exception: $e';
        _isLoading = false;
      });
    }
  }
  
  String _prettyPrintJson(dynamic json) {
    if (json is Map) {
      return json.entries.map((e) => '${e.key}: ${e.value is Map || e.value is List ? "\n  " + _prettyPrintJson(e.value).replaceAll("\n", "\n  ") : e.value}').join('\n');
    } else if (json is List) {
      return json.asMap().entries.map((e) => '${e.key}: ${e.value is Map || e.value is List ? "\n  " + _prettyPrintJson(e.value).replaceAll("\n", "\n  ") : e.value}').join('\n');
    }
    return json.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Recovery Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testHealthRecoveryFunction,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test Health Recovery Function'),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty) ...[
              const Text('Result:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(26), // Equivalent to opacity 0.1 (255 * 0.1 = 25.5 ≈ 26)
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(_result),
                  ),
                ),
              ),
            ],
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26), // Equivalent to opacity 0.1 (255 * 0.1 = 25.5 ≈ 26)
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(_error, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}