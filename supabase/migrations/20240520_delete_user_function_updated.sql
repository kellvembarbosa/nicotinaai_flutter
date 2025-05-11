-- Função para excluir os dados de um usuário (chamada pela Edge Function)
CREATE OR REPLACE FUNCTION public.delete_user_data(user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Verificar se o usuário existe
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = user_id) THEN
    RAISE EXCEPTION 'User with ID % not found', user_id;
  END IF;

  -- Excluir dados do usuário de todas as tabelas relacionadas
  -- Usar bloco de transação para garantir consistência
  BEGIN
    -- Remove os dados do usuário das várias tabelas
    DELETE FROM public.user_stats WHERE user_id = user_id;
    DELETE FROM public.cravings WHERE user_id = user_id;
    DELETE FROM public.smoking_records WHERE user_id = user_id;
    DELETE FROM public.user_notifications WHERE user_id = user_id;
    DELETE FROM public.user_achievements WHERE user_id = user_id;
    DELETE FROM public.user_health_recoveries WHERE user_id = user_id;
    DELETE FROM public.user_fcm_tokens WHERE user_id = user_id;

    -- Remover dados do usuário da tabela de perfis por último
    DELETE FROM public.profiles WHERE id = user_id;
    
    -- Em caso de erro na transação, fazer rollback
    EXCEPTION
    WHEN OTHERS THEN
      RAISE EXCEPTION 'Error deleting user data: %', SQLERRM;
  END;
END;
$$;

-- Permissões para a função
REVOKE ALL ON FUNCTION public.delete_user_data(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_user_data(UUID) TO service_role;