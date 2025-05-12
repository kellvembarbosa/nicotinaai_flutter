-- Função para limpar dados do usuário antes de tentar hard delete
-- Esta função executará uma exclusão em cascata para todas as tabelas conhecidas
CREATE OR REPLACE FUNCTION public.cascade_delete_user(user_id_param UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  table_name TEXT;
  column_name TEXT;
BEGIN
  -- Verificar se o usuário existe
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = user_id_param) THEN
    RAISE EXCEPTION 'User with ID % not found', user_id_param;
  END IF;

  -- Tabelas e colunas conhecidas - adicionar todas as tabelas que podem ter relação com o usuário
  -- Remover em ordem para evitar problemas com chaves estrangeiras
  
  -- 1. Primeiro excluir as tabelas que podem ter referências para outras tabelas
  EXECUTE 'DELETE FROM public.user_fcm_tokens WHERE user_id = $1' USING user_id_param;
  EXECUTE 'DELETE FROM public.viewed_achievements WHERE user_id = $1' USING user_id_param;
  EXECUTE 'DELETE FROM public.user_achievements WHERE user_id = $1' USING user_id_param;
  EXECUTE 'DELETE FROM public.user_notifications WHERE user_id = $1' USING user_id_param;
  EXECUTE 'DELETE FROM public.user_health_recoveries WHERE user_id = $1' USING user_id_param;
  EXECUTE 'DELETE FROM public.daily_motivations WHERE user_id = $1' USING user_id_param;
  EXECUTE 'DELETE FROM public.saved_motivations WHERE user_id = $1' USING user_id_param;

  -- 2. Excluir tabelas de dados principais
  EXECUTE 'DELETE FROM public.cravings WHERE user_id = $1' USING user_id_param;
  EXECUTE 'DELETE FROM public.smoking_logs WHERE user_id = $1' USING user_id_param;
  EXECUTE 'DELETE FROM public.user_stats WHERE user_id = $1' USING user_id_param;
  
  -- 3. Finalmente excluir a tabela profiles que normalmente tem a referência principal
  EXECUTE 'DELETE FROM public.profiles WHERE id = $1' USING user_id_param;
  
  -- 4. Procurar dinamicamente por outras tabelas que possam ter o user_id
  FOR table_name, column_name IN 
    SELECT t.tablename, c.column_name
    FROM pg_tables t
    JOIN information_schema.columns c ON t.tablename = c.table_name
    WHERE 
      t.schemaname = 'public' 
      AND (c.column_name = 'user_id' OR (c.column_name = 'id' AND t.tablename = 'profiles'))
      AND t.tablename NOT IN (
        'profiles', 'user_stats', 'cravings', 'smoking_logs', 
        'user_fcm_tokens', 'viewed_achievements', 'user_achievements',
        'user_notifications', 'user_health_recoveries', 
        'daily_motivations', 'saved_motivations'
      )
  LOOP
    BEGIN
      EXECUTE format('DELETE FROM public.%I WHERE %I = %L', 
                     table_name, column_name, user_id_param);
      RAISE NOTICE 'Deleted data from %', table_name;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Error cleaning table %: %', table_name, SQLERRM;
      -- Continue mesmo em caso de erro
    END;
  END LOOP;

  -- 5. Atualizar metadados do usuário para indicar que foi excluído
  UPDATE auth.users 
  SET raw_app_meta_data = 
    raw_app_meta_data || 
    jsonb_build_object(
      'account_deleted', TRUE,
      'deleted_at', CURRENT_TIMESTAMP
    )
  WHERE id = user_id_param;

  RAISE NOTICE 'Successfully cleaned up all data for user %', user_id_param;
END;
$$;

-- Conceder permissões apenas para role de serviço
REVOKE ALL ON FUNCTION public.cascade_delete_user(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.cascade_delete_user(UUID) TO service_role;