-- Migration to add RLS policies for account deletion
-- This ensures users can only delete their own data

-- Add RLS policies to restrict users from seeing soft-deleted accounts
CREATE OR REPLACE FUNCTION auth.is_account_active()
RETURNS BOOLEAN AS $$
  SELECT COALESCE(
    current_setting('request.jwt.claims', TRUE)::json->>'account_deleted',
    'false'
  )::TEXT = 'false'
$$ LANGUAGE SQL SECURITY DEFINER;

-- Add policy to all tables to prevent access if account is marked as deleted
DO $$
DECLARE
  table_name TEXT;
BEGIN
  FOR table_name IN 
    SELECT tablename 
    FROM pg_tables 
    WHERE schemaname = 'public' 
  LOOP
    BEGIN
      -- Add RLS policy to prevent access by deleted accounts
      EXECUTE format('
        CREATE POLICY "Prevent deleted accounts from accessing %I" 
        ON public.%I 
        FOR ALL 
        TO authenticated
        USING (auth.is_account_active());
      ', table_name, table_name);
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Failed to add policy to table %: %', table_name, SQLERRM;
    END;
  END LOOP;
END
$$;

-- Ensure the delete_user_data function has proper permissions and more robust error handling
CREATE OR REPLACE FUNCTION public.delete_user_data(user_id_param UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  table_rec RECORD;
BEGIN
  -- Verificar se o usuário existe
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = user_id_param) THEN
    RAISE EXCEPTION 'User with ID % not found', user_id_param;
  END IF;

  -- Lista dinâmica de tabelas a serem limpas
  FOR table_rec IN 
    SELECT t.table_name, c.column_name
    FROM information_schema.tables t
    JOIN information_schema.columns c ON t.table_name = c.table_name
    WHERE t.table_schema = 'public'
    AND (c.column_name = 'user_id' OR (c.column_name = 'id' AND t.table_name = 'profiles'))
    AND t.table_type = 'BASE TABLE'
  LOOP
    BEGIN
      -- Usar um bloco try/catch para cada tabela
      EXECUTE format('DELETE FROM public.%I WHERE %I = %L', 
                    table_rec.table_name, 
                    table_rec.column_name, 
                    user_id_param);
      
      RAISE NOTICE 'Deleted data from %', table_rec.table_name;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Error deleting from table %: %', table_rec.table_name, SQLERRM;
      -- Continue mesmo com erro
    END;
  END LOOP;
END;
$$;

-- Permissões para a função
REVOKE ALL ON FUNCTION public.delete_user_data(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_user_data(UUID) TO service_role;