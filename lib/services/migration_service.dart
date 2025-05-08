import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';

/// Serviço para ajudar a aplicar as migrações SQL do Supabase
/// 
/// Este serviço é útil para garantir que as tabelas necessárias 
/// sejam criadas quando o aplicativo é iniciado pela primeira vez
class MigrationService {
  
  /// Lista de scripts SQL para aplicar como migrações
  static const List<String> _migrationScripts = [
    // No longer needed as we're using the existing smoking_logs table
    // Kept as an empty list to maintain code structure
  ];
  
  /// Executa SQL no Supabase para criar ou atualizar tabela
  static Future<bool> applyMigrations() async {
    try {
      if (kDebugMode) {
        print('🔄 Tentando aplicar migrações...');
      }
      
      // Verifica se o usuário está autenticado
      final session = SupabaseConfig.auth.currentSession;
      if (session == null) {
        if (kDebugMode) {
          print('❌ Usuário não autenticado, não é possível aplicar migrações');
        }
        return false;
      }
      
      // Tenta aplicar cada script SQL
      for (int i = 0; i < _migrationScripts.length; i++) {
        final script = _migrationScripts[i];
        
        try {
          if (kDebugMode) {
            print('🔄 Aplicando migração ${i + 1}/${_migrationScripts.length}...');
          }
          
          // Execute o SQL diretamente
          final result = await SupabaseConfig.client.rpc(
            'apply_migration', 
            params: {
              'sql_query': script,
            },
          );
          
          if (kDebugMode) {
            print('✅ Migração ${i + 1} aplicada com sucesso: $result');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Erro ao aplicar migração ${i + 1}: $e');
          }
          // Continua mesmo se uma migração falhar
          // Isso permite que as migrações subsequentes sejam aplicadas
        }
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro geral ao aplicar migrações: $e');
      }
      return false;
    }
  }
  
  /// Verifica se tabela específica existe e tenta criá-la se não existir
  static Future<bool> ensureTableExists(String tableName) async {
    try {
      // Primeiro verificamos se a tabela já existe
      try {
        await SupabaseConfig.client
            .from(tableName)
            .select('*')
            .limit(1);
            
        // Se chegou aqui, a tabela existe
        if (kDebugMode) {
          print('✅ Tabela $tableName já existe');
        }
        return true;
      } catch (e) {
        // Se for erro 404, a tabela não existe
        if (e.toString().contains('404')) {
          if (kDebugMode) {
            print('⚠️ Tabela $tableName não existe, tentando criar...');
          }
          
          // Aqui inserimos o SQL específico para criar esta tabela
          String sqlScript = '';
          
          if (tableName == 'smoking_logs') {
            sqlScript = '''
            CREATE TABLE IF NOT EXISTS public.smoking_logs (
              id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
              user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
              timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
              product_type VARCHAR(20) NOT NULL DEFAULT 'CIGARETTE_ONLY',
              quantity INT NOT NULL DEFAULT 1,
              location TEXT,
              mood TEXT,
              trigger TEXT,
              notes TEXT,
              created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
              updated_at TIMESTAMPTZ
            );
            
            ALTER TABLE public.smoking_logs ENABLE ROW LEVEL SECURITY;
            
            CREATE POLICY "Users can read their own smoking logs" 
                ON public.smoking_logs
                FOR SELECT 
                USING (auth.uid() = user_id);
            
            CREATE POLICY "Users can create their own smoking logs" 
                ON public.smoking_logs
                FOR INSERT 
                WITH CHECK (auth.uid() = user_id);
            
            CREATE POLICY "Users can update their own smoking logs" 
                ON public.smoking_logs
                FOR UPDATE 
                USING (auth.uid() = user_id);
            
            CREATE POLICY "Users can delete their own smoking logs" 
                ON public.smoking_logs
                FOR DELETE 
                USING (auth.uid() = user_id);
            ''';
          }
          
          if (sqlScript.isNotEmpty) {
            try {
              // Tentativa de criar a tabela
              await SupabaseConfig.client.rpc(
                'apply_migration', 
                params: {
                  'sql_query': sqlScript,
                },
              );
              
              if (kDebugMode) {
                print('✅ Tabela $tableName criada com sucesso');
              }
              return true;
            } catch (e) {
              if (kDebugMode) {
                print('❌ Erro ao criar tabela $tableName: $e');
              }
              return false;
            }
          } else {
            if (kDebugMode) {
              print('⚠️ Nenhum script SQL disponível para criar a tabela $tableName');
            }
            return false;
          }
        } else {
          // Outro tipo de erro
          if (kDebugMode) {
            print('❌ Erro ao verificar tabela $tableName: $e');
          }
          return false;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro geral ao verificar/criar tabela $tableName: $e');
      }
      return false;
    }
  }
}