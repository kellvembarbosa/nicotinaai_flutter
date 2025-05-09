-- Correção de políticas RLS para a tabela user_fcm_tokens
-- Remove políticas existentes que podem estar causando problemas
DROP POLICY IF EXISTS "Users can view their own FCM tokens" ON public.user_fcm_tokens;
DROP POLICY IF EXISTS "Users can insert their own FCM tokens" ON public.user_fcm_tokens;
DROP POLICY IF EXISTS "Users can update their own FCM tokens" ON public.user_fcm_tokens;
DROP POLICY IF EXISTS "Any authenticated user can insert tokens" ON public.user_fcm_tokens;
DROP POLICY IF EXISTS "Any authenticated user can update tokens" ON public.user_fcm_tokens;

-- Cria políticas mais permissivas para inserção e atualização
CREATE POLICY "Any authenticated user can insert FCM tokens" 
  ON public.user_fcm_tokens 
  FOR INSERT 
  TO authenticated 
  WITH CHECK (true);

CREATE POLICY "Any authenticated user can update FCM tokens" 
  ON public.user_fcm_tokens 
  FOR UPDATE 
  TO authenticated 
  USING (true);

CREATE POLICY "Users can view their own FCM tokens" 
  ON public.user_fcm_tokens 
  FOR SELECT 
  TO authenticated 
  USING (auth.uid() = user_id);

-- Garante que existe a função save_fcm_token para uso alternativo
CREATE OR REPLACE FUNCTION public.save_fcm_token(
  p_user_id uuid,
  p_fcm_token text,
  p_device_info jsonb DEFAULT '{}'::jsonb
) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_exists boolean;
BEGIN
  -- Verificar se o token já existe
  SELECT EXISTS (
    SELECT 1 FROM public.user_fcm_tokens
    WHERE fcm_token = p_fcm_token
  ) INTO v_exists;
  
  IF v_exists THEN
    -- Atualizar o token existente
    UPDATE public.user_fcm_tokens
    SET 
      user_id = p_user_id,
      device_info = p_device_info,
      last_used_at = now()
    WHERE fcm_token = p_fcm_token;
  ELSE
    -- Inserir novo token
    INSERT INTO public.user_fcm_tokens (
      user_id,
      fcm_token,
      device_info,
      created_at,
      last_used_at
    ) VALUES (
      p_user_id,
      p_fcm_token,
      p_device_info,
      now(),
      now()
    );
  END IF;
  
  RETURN true;
EXCEPTION
  WHEN OTHERS THEN
    RAISE LOG 'Erro ao salvar token FCM: %', SQLERRM;
    RETURN false;
END;
$$;