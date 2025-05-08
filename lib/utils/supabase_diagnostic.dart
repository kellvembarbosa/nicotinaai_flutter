import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A utility class that provides diagnostic functions for Supabase connection issues
class SupabaseDiagnostic {
  
  /// Tests the Supabase connection and table availability to diagnose 404 errors
  /// 
  /// This function performs a series of checks to diagnose Supabase connection issues:
  /// 1. Validates that we can access the Supabase API
  /// 2. Checks that we have an authenticated user (if required)
  /// 3. Verifies the 'smoking_records' table exists
  /// 4. Attempts to query the table
  /// 
  /// Returns a detailed diagnostic report as a string.
  static Future<String> diagnoseConnection({
    String tableName = 'smoking_records',
    bool requireAuth = true,
  }) async {
    StringBuffer report = StringBuffer();
    report.writeln('🔍 SUPABASE DIAGNOSTIC REPORT');
    report.writeln('📅 ${DateTime.now()}');
    report.writeln('-------------------------------------------');
    
    try {
      // 1. Check basic client connection
      report.writeln('\n1️⃣ CHECKING CLIENT CONNECTION');
      try {
        // Get Supabase client info
        final String url = Supabase.instance.client.supabaseUrl;
        report.writeln('✓ Client initialized with URL: $url');
      } catch (e) {
        report.writeln('❌ Client not properly initialized: $e');
        report.writeln('⚠️ Make sure Supabase.initialize() was called before accessing the client');
        return report.toString();
      }

      // 2. Check authentication status (if required)
      report.writeln('\n2️⃣ CHECKING AUTHENTICATION STATUS');
      final currentSession = SupabaseConfig.auth.currentSession;
      final isAuthenticated = currentSession != null;
      
      if (isAuthenticated) {
        report.writeln('✓ User is authenticated');
        report.writeln('  User ID: ${currentSession.user.id}');
        report.writeln('  Session expires: ${currentSession.expiresAt}');
      } else {
        report.writeln('❌ No authenticated user session found');
        if (requireAuth) {
          report.writeln('⚠️ Authentication is required for this operation');
          report.writeln('⚠️ Most Supabase operations require authentication - please login first');
        } else {
          report.writeln('ℹ️ Authentication not required for this test');
        }
      }

      // 3. Check database/schema/table access
      report.writeln('\n3️⃣ CHECKING DATABASE SCHEMA ACCESS');
      try {
        // Try to get a list of tables from the database
        final tablesResponse = await SupabaseConfig.client.rpc(
          'get_tables',
        ).select('name');
        
        final tables = (tablesResponse as List<dynamic>)
            .map((item) => item['name'] as String)
            .toList();
            
        report.writeln('✓ Successfully accessed database schema');
        report.writeln('  Available tables: ${tables.join(', ')}');
        
        // Check if our target table exists
        if (tables.contains(tableName)) {
          report.writeln('✓ Target table \'$tableName\' exists in the database');
        } else {
          report.writeln('❌ Table \'$tableName\' NOT FOUND in the database schema');
          report.writeln('⚠️ Check database migrations to ensure this table was created properly');
        }
      } catch (e) {
        report.writeln('❌ Failed to access database schema: $e');
        report.writeln('⚠️ This may indicate permission issues or missing RPC function');
        
        // Try alternative approach with system tables if available
        try {
          report.writeln('\n  Attempting to check tables via pg_tables...');
          final pgTablesResult = await SupabaseConfig.client
              .from('pg_tables')
              .select('tablename')
              .eq('schemaname', 'public');
          
          final pgTables = (pgTablesResult as List<dynamic>)
              .map((item) => item['tablename'] as String)
              .toList();
              
          report.writeln('  Tables via pg_tables: ${pgTables.join(', ')}');
          
          if (pgTables.contains(tableName)) {
            report.writeln('✓ Target table \'$tableName\' found via pg_tables');
          } else {
            report.writeln('❌ Table \'$tableName\' NOT FOUND in pg_tables');
          }
        } catch (pgError) {
          report.writeln('  ❌ Failed to check tables via pg_tables: $pgError');
        }
      }
      
      // 4. Test table access directly
      report.writeln('\n4️⃣ TESTING TABLE ACCESS');
      try {
        // Try a simple count query on the table
        final countResult = await SupabaseConfig.client
            .from(tableName)
            .select('count(*)', const FetchOptions(count: CountOption.exact))
            .limit(1);
        
        final int count = countResult.count ?? 0;
        report.writeln('✓ Successfully accessed \'$tableName\' table');
        report.writeln('  Table contains $count records');
      } catch (e) {
        report.writeln('❌ Failed to query table \'$tableName\': $e');
        
        // Try a more detailed error analysis
        if (e is PostgrestException) {
          report.writeln('  Error code: ${e.code}');
          report.writeln('  Error details: ${e.details}');
          report.writeln('  Error hint: ${e.hint}');
          
          if (e.code == '404') {
            report.writeln('⚠️ 404 error indicates the table does not exist or the API path is incorrect');
            report.writeln('  Possible causes:');
            report.writeln('  - Table migration was not applied correctly');
            report.writeln('  - Table name has a typo or case mismatch');
            report.writeln('  - RLS (Row Level Security) policy is blocking all access');
            report.writeln('  - API endpoint is misconfigured');
          } else if (e.code == '401' || e.code == '403') {
            report.writeln('⚠️ Authentication/permission error');
            report.writeln('  - Check if user session is valid');
            report.writeln('  - Verify RLS policies allow this operation');
          }
        }
      }
      
      // 5. Network connectivity test (basic)
      report.writeln('\n5️⃣ NETWORK CONNECTIVITY CHECK');
      try {
        final response = await SupabaseConfig.client.functions.invoke('version');
        if (response.status == 200) {
          report.writeln('✓ Successfully connected to Supabase API');
        } else {
          report.writeln('⚠️ Unexpected status when connecting to API: ${response.status}');
        }
      } catch (e) {
        report.writeln('❌ Failed to connect to Supabase API: $e');
        report.writeln('⚠️ Check internet connection and Supabase service status');
      }
      
      report.writeln('\n-------------------------------------------');
      report.writeln('🏁 DIAGNOSTIC COMPLETE');
      
    } catch (e) {
      report.writeln('\n❌ UNEXPECTED ERROR DURING DIAGNOSTIC');
      report.writeln('Error: $e');
    }
    
    return report.toString();
  }
  
  /// Simple helper method to log the diagnostic report to the console
  static Future<void> logDiagnosticReport({
    String tableName = 'smoking_records',
    bool requireAuth = true,
  }) async {
    final report = await diagnoseConnection(
      tableName: tableName,
      requireAuth: requireAuth,
    );
    
    // Split the report into lines for better console readability
    final lines = report.split('\n');
    for (final line in lines) {
      debugPrint(line);
    }
  }
}