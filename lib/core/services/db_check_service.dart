import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/services/supabase_diagnostic.dart';

/// Service responsible for checking the availability of essential database tables
/// Used during app initialization to ensure all required tables are accessible
class DbCheckService {
  /// List of essential tables that must be available for the app to function properly
  final List<String> _essentialTables = [
    'smoking_logs',
    'cravings',
    'onboarding_data',
    'profiles',
  ];

  /// Checks if all essential tables are available
  /// Returns true if all tables are accessible, false otherwise
  Future<bool> checkAllEssentialTables() async {
    try {
      if (kDebugMode) {
        print('🔍 Checking availability of essential database tables...');
      }

      bool allTablesAvailable = true;
      
      for (final tableName in _essentialTables) {
        final isAvailable = await SupabaseDiagnostic.isTableAccessible(tableName);
        
        if (kDebugMode) {
          if (isAvailable) {
            print('✅ Table $tableName is accessible');
          } else {
            print('❌ Table $tableName is NOT accessible');
            allTablesAvailable = false;
          }
        }
      }
      
      return allTablesAvailable;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking essential tables: $e');
      }
      return false;
    }
  }

  /// Gets a detailed diagnostic report for troubleshooting
  Future<String> getDiagnosticReport() async {
    try {
      final StringBuffer report = StringBuffer();
      
      report.writeln('🔍 DATABASE TABLES DIAGNOSTIC REPORT');
      report.writeln('📅 Date/time: ${DateTime.now()}');
      report.writeln('-------------------------------------------');
      
      for (final tableName in _essentialTables) {
        final isAvailable = await SupabaseDiagnostic.isTableAccessible(tableName);
        report.writeln('${isAvailable ? "✅" : "❌"} Table $tableName: ${isAvailable ? "Accessible" : "NOT accessible"}');
      }
      
      report.writeln('-------------------------------------------');
      report.writeln('🏁 END OF TABLE DIAGNOSTIC REPORT');
      
      return report.toString();
    } catch (e) {
      return '❌ Error generating diagnostic report: $e';
    }
  }
}