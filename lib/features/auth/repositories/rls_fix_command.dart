// Comando SQL para ser executado no Console do Supabase para corrigir o problema de RLS

/*
-- Execute este comando no Console SQL do Supabase para corrigir problemas com políticas RLS

-- Remover as políticas existentes que estão causando problemas
DROP POLICY IF EXISTS "Users can insert their own device tokens" ON user_fcm_tokens;
DROP POLICY IF EXISTS "Users can update their own device tokens" ON user_fcm_tokens;

-- Criar política que permite qualquer usuário autenticado inserir tokens
CREATE POLICY "Any authenticated user can insert tokens" 
  ON user_fcm_tokens FOR INSERT 
  TO authenticated
  WITH CHECK (true);

-- Criar política que permite usuários autenticados atualizar qualquer token
CREATE POLICY "Any authenticated user can update tokens" 
  ON user_fcm_tokens FOR UPDATE 
  TO authenticated
  USING (true);

-- Criar função SECURITY DEFINER para bypassing de RLS
CREATE OR REPLACE FUNCTION save_fcm_token(
  p_user_id UUID,
  p_fcm_token TEXT,
  p_device_info JSONB DEFAULT '{}'
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
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
*/

// Esta é uma classe de suporte para documentar a solução de RLS
class RlsFixCommand {
  // Mensagem explicando o problema
  static const String explanation = '''
O problema encontrado é que as políticas RLS (Row Level Security) atuais na tabela
'user_fcm_tokens' estão impedindo os usuários de inserir seus tokens FCM.

Como solução temporária, utilize o método saveTokenToDatabase que foi atualizado para
tentar múltiplas abordagens ao salvar tokens FCM. Se todas falharem, o token será
armazenado localmente para tentativas futuras.

Para uma solução permanente, execute o comando SQL acima no console do Supabase.
''';
}