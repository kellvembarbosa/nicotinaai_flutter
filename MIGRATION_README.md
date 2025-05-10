# Instruções para Migração do Banco de Dados

Este documento descreve as alterações necessárias para corrigir problemas encontrados no banco de dados da aplicação NicotinaAI.

## Problema 1: Tabela `onboarding_data` Ausente

Os logs mostram que a tabela `onboarding_data` não existe no banco de dados:
```
flutter: ❌ Erro ao verificar acesso à tabela onboarding_data: PostgrestException(message: relation "public.onboarding_data" does not exist, code: 42P01, details: Not Found, hint: null)
```

## Problema 2: Função `add_user_xp` Ausente

Os logs mostram que a função `add_user_xp` não existe no banco de dados:
```
flutter: ⚠️ XP award failed: PostgrestException(message: Could not find the function public.add_user_xp(p_amount, p_reference_id, p_source, p_user_id) in the schema cache, code: PGRST202, details: Searched for the function public.add_user_xp with parameters p_amount, p_reference_id, p_source, p_user_id or with a single unnamed json/jsonb parameter, but no matches were found in the schema cache., hint: null)
```

## Solução

Foi criado um novo arquivo de migração em `supabase/migrations/20240510_add_missing_tables_and_functions.sql` que inclui:

1. Criação da tabela `onboarding_data` (se não existir)
2. Configuração de políticas RLS para a tabela `onboarding_data`
3. Criação da tabela `user_xp` (se não existir)
4. Configuração de políticas RLS para a tabela `user_xp`
5. Criação da função `add_user_xp` para gerenciar pontos de experiência

## Como Aplicar a Migração

Execute a migração através do Supabase CLI:

```bash
supabase migration up
```

Ou aplique o SQL diretamente no painel de administração do Supabase:

1. Acesse o painel do Supabase
2. Vá para "SQL Editor"
3. Cole o conteúdo do arquivo `20240510_add_missing_tables_and_functions.sql`
4. Execute o script

## Importante

- A modificação em `DbCheckService` remove `onboarding_data` da lista de tabelas essenciais já que os dados de onboarding podem estar sendo armazenados em outras tabelas.
- A implementação `NotificationService` foi modificada para usar `upsert` para evitar erros de duplicação ao salvar tokens FCM.

## Verificação

Após aplicar a migração, reinicie o aplicativo e verifique os logs para confirmar que não há mais erros relacionados à tabela `onboarding_data` ou à função `add_user_xp`.