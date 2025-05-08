-- Função para salvar o token FCM contornando políticas RLS
CREATE OR REPLACE FUNCTION save_fcm_token(
  p_user_id UUID,
  p_fcm_token TEXT,
  p_device_info JSONB DEFAULT '{}'
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER  -- Executa com os privilégios do criador da função
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  -- Verificar se o token já existe
  SELECT COUNT(*) INTO v_count
  FROM user_fcm_tokens
  WHERE fcm_token = p_fcm_token;
  
  IF v_count > 0 THEN
    -- Atualizar o token existente
    UPDATE user_fcm_tokens
    SET 
      user_id = p_user_id,
      device_info = p_device_info,
      last_used_at = NOW()
    WHERE fcm_token = p_fcm_token;
  ELSE
    -- Inserir um novo token
    INSERT INTO user_fcm_tokens (
      user_id,
      fcm_token,
      device_info,
      created_at,
      last_used_at
    ) VALUES (
      p_user_id,
      p_fcm_token,
      p_device_info,
      NOW(),
      NOW()
    );
  END IF;
  
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error saving FCM token: %', SQLERRM;
    RETURN FALSE;
END;
$$;