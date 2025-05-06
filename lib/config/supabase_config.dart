import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuração e inicialização do Supabase
class SupabaseConfig {
  static Future<void> initialize() async {
    await dotenv.load();
    
    final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Supabase credentials not found. Please check your .env file.');
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false, // Defina como true para depuração
    );
  }
  
  /// Instância do cliente Supabase
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Instância do GoTrueClient para autenticação
  static GoTrueClient get auth => Supabase.instance.client.auth;
}