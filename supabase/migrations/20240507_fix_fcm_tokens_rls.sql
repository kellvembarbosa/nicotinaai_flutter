-- Corrigir as políticas RLS para a tabela de tokens FCM

-- Primeiro remover as políticas existentes
DROP POLICY IF EXISTS "Users can insert their own device tokens" ON user_fcm_tokens;
DROP POLICY IF EXISTS "Users can update their own device tokens" ON user_fcm_tokens;

-- Criar uma política mais permissiva para inserção
CREATE POLICY "Users can insert device tokens"
  ON user_fcm_tokens FOR INSERT
  WITH CHECK (true);  -- Permite qualquer inserção, pois os tokens podem ser inseridos antes do login

-- Criar uma política para atualização
CREATE POLICY "Users can update device tokens"
  ON user_fcm_tokens FOR UPDATE
  USING (true);  -- Permite atualização de qualquer token