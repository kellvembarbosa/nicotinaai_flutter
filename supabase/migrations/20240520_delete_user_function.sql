-- Função para permitir que usuários excluam suas próprias contas
CREATE OR REPLACE FUNCTION public.delete_user()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  _user_id uuid;
BEGIN
  -- Obtém o ID do usuário atual da sessão
  _user_id := auth.uid();
  
  -- Verifica se um ID válido foi obtido
  IF _user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado';
  END IF;
  
  -- Remove os dados do usuário de várias tabelas
  DELETE FROM public.user_stats WHERE user_id = _user_id;
  DELETE FROM public.cravings WHERE user_id = _user_id;
  DELETE FROM public.smoking_records WHERE user_id = _user_id;
  DELETE FROM public.user_notifications WHERE user_id = _user_id;
  DELETE FROM public.user_achievements WHERE user_id = _user_id;
  DELETE FROM public.user_health_recoveries WHERE user_id = _user_id;
  DELETE FROM public.user_fcm_tokens WHERE user_id = _user_id;
  DELETE FROM public.profiles WHERE id = _user_id;
  
  -- Remove o próprio usuário
  -- Não podemos chamar auth.users diretamente, então marcamos como 'excluído'
  -- (Esta é uma solução temporária até Supabase oferecer API para usuários deletarem suas contas)
  UPDATE auth.users 
  SET raw_app_meta_data = 
    jsonb_set(
      COALESCE(raw_app_meta_data, '{}'::jsonb),
      '{deleted}',
      'true'::jsonb
    )
  WHERE id = _user_id;
END;
$$;

-- Permissões para a função
REVOKE ALL ON FUNCTION public.delete_user() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_user() TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_user() TO service_role;