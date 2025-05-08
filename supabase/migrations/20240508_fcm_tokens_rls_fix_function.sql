-- Criar uma função que pode ser chamada para corrigir as políticas RLS
CREATE OR REPLACE FUNCTION apply_fcm_tokens_rls_fix()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Remover políticas existentes que podem estar causando problemas
  DROP POLICY IF EXISTS "Users can insert their own device tokens" ON user_fcm_tokens;
  DROP POLICY IF EXISTS "Users can update their own device tokens" ON user_fcm_tokens;
  
  -- Criar políticas mais permissivas
  CREATE POLICY "Users can insert any device token" 
    ON user_fcm_tokens FOR INSERT 
    WITH CHECK (true);
    
  CREATE POLICY "Users can update any device token" 
    ON user_fcm_tokens FOR UPDATE 
    USING (true);
    
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error applying FCM tokens RLS fix: %', SQLERRM;
    RETURN FALSE;
END;
$$;