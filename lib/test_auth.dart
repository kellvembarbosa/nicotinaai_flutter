import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with your credentials
  await Supabase.initialize(
    url: 'https://rohfurmgebouerahgvxb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvaGZ1cm1nZWJvdWVyYWhndnhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYzNzU0NzIsImV4cCI6MjA2MTk1MTQ3Mn0.8HyxFynBA2UHidiJyWSHhInxopBwBgYyGjSC1fVmOCg',
    debug: true, // Enable debug mode
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Supabase Auth Test'),
        ),
        body: const AuthTestScreen(),
      ),
    );
  }
}

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({Key? key}) : super(key: key);

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  String _results = 'No tests run yet';
  bool _isLoading = false;

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _results = 'Testing login...';
    });

    try {
      developer.log('Testing login with test credentials');
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: 'kellvem222@gmail.com',
        password: '123123123',
      );
      
      developer.log('Login response: ${response.user?.email}');
      setState(() {
        _results = 'Login successful!\nUser: ${response.user?.email}\nID: ${response.user?.id}';
      });
    } catch (e) {
      developer.log('Login error: $e', error: e);
      setState(() {
        _results = 'Login failed!\nError: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testTableAccess() async {
    setState(() {
      _isLoading = true;
      _results = 'Testing table access...';
    });

    try {
      developer.log('Testing health_recoveries table access');
      final data = await Supabase.instance.client
          .from('health_recoveries')
          .select()
          .limit(1);
      
      developer.log('Table access result: $data');
      setState(() {
        _results = 'Table access successful!\nData: $data';
      });
    } catch (e) {
      developer.log('Table access error: $e', error: e);
      setState(() {
        _results = 'Table access failed!\nError: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _isLoading ? null : _testLogin,
            child: const Text('Test Login'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _testTableAccess,
            child: const Text('Test Table Access'),
          ),
          const SizedBox(height: 32),
          const Text('Results:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(_results),
              ),
            ),
          ),
        ],
      ),
    );
  }
}