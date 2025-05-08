import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Classe utilitária para diagnosticar problemas de conexão com o Supabase
/// Útil para identificar problemas como erro 404 ao acessar tabelas
class SupabaseDiagnostic {
  
  /// Executa o diagnóstico completo e retorna um relatório detalhado
  static Future<String> diagnoseConnection({String? tableName}) async {
    final table = tableName ?? 'smoking_logs';
    final StringBuffer report = StringBuffer();
    
    report.writeln('🔍 RELATÓRIO DE DIAGNÓSTICO SUPABASE');
    report.writeln('📅 Data/hora: ${DateTime.now()}');
    report.writeln('-------------------------------------------');
    
    // Verifica inicialização do cliente
    report.writeln('\n1️⃣ CLIENTE SUPABASE');
    try {
      // Verifica se o cliente está inicializado
      final client = SupabaseConfig.client;
      report.writeln('✅ Cliente inicializado');
      
      // Tenta acessar a URL da API (sem mostrar a chave)
      report.writeln('🌐 Rest URL: ${client.rest.url}');
      report.writeln('🔢 API Version: ${client.rest.url.contains('/rest/v1') ? 'v1' : 'unknown'}');
    } catch (e) {
      report.writeln('❌ Falha na inicialização do cliente: $e');
    }
    
    // Verifica status de autenticação
    report.writeln('\n2️⃣ STATUS DE AUTENTICAÇÃO');
    try {
      final auth = SupabaseConfig.auth;
      final session = auth.currentSession;
      
      if (session != null) {
        report.writeln('✅ Usuário autenticado');
        report.writeln('👤 User ID: ${session.user.id}');
        report.writeln('⏱️ Expira em: ${session.expiresAt != null ? 
          DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000) : 'N/A'}');
        report.writeln('🔄 Token atual válido: ${!auth.currentSession!.isExpired}');
      } else {
        report.writeln('❌ Usuário NÃO autenticado - isso pode causar erros 404 devido à RLS');
      }
    } catch (e) {
      report.writeln('❌ Erro ao verificar autenticação: $e');
    }
    
    // Verifica acesso à tabela específica
    report.writeln('\n3️⃣ VERIFICAÇÃO DA TABELA: $table');
    
    // Tenta listar tabelas para ver se a tabela existe
    try {
      report.writeln('🔍 Tentando listar tabelas disponíveis...');
      
      // Tenta usar RPC para listar tabelas (se disponível)
      try {
        final response = await SupabaseConfig.client.rpc(
          'get_tables',
        ).select('name');
        
        final tables = (response as List<dynamic>)
            .map((item) => item['name'] as String)
            .toList();
            
        report.writeln('📋 Tabelas encontradas (${tables.length}): ${tables.join(', ')}');
        
        if (tables.contains(table)) {
          report.writeln('✅ Tabela $table encontrada na lista');
        } else {
          report.writeln('❌ Tabela $table NÃO encontrada na lista - isso explicaria o erro 404');
        }
      } catch (e) {
        report.writeln('⚠️ Não foi possível listar tabelas com RPC: $e');
        report.writeln('⚠️ Isso é normal se a função RPC "get_tables" não estiver definida');
      }
      
      // Tenta acessar diretamente a tabela
      try {
        report.writeln('\n🔍 Tentando acessar diretamente a tabela $table...');
        final response = await SupabaseConfig.client
            .from(table)
            .select('count(*)')
            .limit(1)
            .maybeSingle();
        
        report.writeln('✅ Conseguiu acessar a tabela $table: $response');
      } catch (e) {
        report.writeln('❌ Erro ao acessar tabela $table: $e');
        
        if (e.toString().contains('404')) {
          report.writeln('\n❗ POSSÍVEIS CAUSAS DO ERRO 404:');
          report.writeln('1. A tabela "$table" não existe no banco de dados');
          report.writeln('2. O URL do Supabase no .env está incorreto');
          report.writeln('3. As migrações não foram aplicadas corretamente');
          report.writeln('4. Políticas RLS estão bloqueando o acesso (você está autenticado?)');
          report.writeln('5. O nome da tabela tem um erro de digitação ou maiúsculas/minúsculas');
        }
      }
    } catch (e) {
      report.writeln('❌ Erro geral ao verificar tabela: $e');
    }
    
    // Verifica status da rede
    report.writeln('\n4️⃣ VERIFICAÇÃO DE REDE');
    try {
      // Tenta uma operação simples para verificar conexão
      final response = await SupabaseConfig.client.functions.invoke('ping');
      if (response.status == 200) {
        report.writeln('✅ Conexão com Supabase Functions funcionando');
      } else {
        report.writeln('⚠️ Código de status inesperado: ${response.status}');
      }
    } catch (e) {
      report.writeln('⚠️ Não conseguiu conectar às Functions, isso é normal se não houver uma function "ping": $e');
    }
    
    report.writeln('\n-------------------------------------------');
    report.writeln('🏁 FIM DO RELATÓRIO DE DIAGNÓSTICO');
    
    return report.toString();
  }
  
  /// Realiza o diagnóstico e mostra o relatório no console 
  static Future<void> logDiagnosticReport({String? tableName}) async {
    try {
      final report = await diagnoseConnection(tableName: tableName);
      
      // Divide o relatório em linhas para facilitar a leitura no console
      final lines = report.split('\n');
      for (final line in lines) {
        if (kDebugMode) {
          print(line);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao executar diagnóstico: $e');
      }
    }
  }
  
  /// Verifica especificamente se a tabela existe e é acessível
  static Future<bool> isTableAccessible(String tableName) async {
    try {
      // Usando select('*') em vez de count(*) para evitar erros de sintaxe
      await SupabaseConfig.client
          .from(tableName)
          .select('*')
          .limit(1);
      return true;
    } catch (e) {
      print('❌ Erro ao verificar acesso à tabela $tableName: $e');
      return false;
    }
  }
}