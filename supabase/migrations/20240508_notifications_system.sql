-- Tabela para armazenar notificações dos usuários
CREATE TABLE IF NOT EXISTS user_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL, -- 'motivation', 'achievement', 'reminder', etc.
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE,
  xp_reward INTEGER DEFAULT 0,
  viewed_at TIMESTAMP WITH TIME ZONE,
  
  CONSTRAINT user_notifications_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Índice para consultas rápidas por usuário
CREATE INDEX user_notifications_user_id_idx ON user_notifications(user_id);

-- RLS para garantir que usuários só vejam suas próprias notificações
ALTER TABLE user_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
  ON user_notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Only supabase functions can insert notifications"
  ON user_notifications FOR INSERT
  USING (auth.uid() = user_id OR (auth.role() = 'service_role'));

CREATE POLICY "Users can mark their notifications as read"
  ON user_notifications FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id AND (
    is_read = TRUE OR 
    viewed_at IS NOT NULL
  ));

-- Tabela para registrar quando as motivações diárias foram enviadas
CREATE TABLE IF NOT EXISTS daily_motivation_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  notification_id UUID REFERENCES user_notifications(id),
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Garantir uma entrada única por dia e por usuário
  CONSTRAINT daily_motivation_logs_user_date_unique UNIQUE (user_id, date)
);

-- RLS para esta tabela
ALTER TABLE daily_motivation_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Only services can insert daily logs"
  ON daily_motivation_logs FOR INSERT
  USING (auth.role() = 'service_role');

CREATE POLICY "Users can view their own logs"
  ON daily_motivation_logs FOR SELECT
  USING (auth.uid() = user_id);

-- Tabela para armazenar tokens FCM dos dispositivos para notificações push
CREATE TABLE IF NOT EXISTS user_fcm_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  device_info JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT user_fcm_tokens_token_unique UNIQUE (fcm_token)
);

-- RLS para tokens FCM
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own device tokens"
  ON user_fcm_tokens FOR INSERT
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own device tokens"
  ON user_fcm_tokens FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own device tokens"
  ON user_fcm_tokens FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own device tokens"
  ON user_fcm_tokens FOR DELETE
  USING (auth.uid() = user_id);

-- Tabela para registro de transações de XP
CREATE TABLE IF NOT EXISTS user_xp_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount INTEGER NOT NULL,
  source TEXT NOT NULL, -- 'daily_motivation', 'achievement', 'streak', etc.
  source_id TEXT,
  previous_xp INTEGER NOT NULL,
  new_xp INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para transações de XP
ALTER TABLE user_xp_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own XP transactions"
  ON user_xp_transactions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Only services can insert XP transactions"
  ON user_xp_transactions FOR INSERT
  USING (auth.role() = 'service_role');

-- Função para adicionar XP ao usuário
CREATE OR REPLACE FUNCTION add_user_xp(
  p_user_id UUID,
  p_amount INTEGER,
  p_source TEXT,
  p_source_id TEXT
) RETURNS BOOLEAN AS $$
DECLARE
  v_current_xp INTEGER;
  v_current_level INTEGER;
  v_new_xp INTEGER;
  v_level_up BOOLEAN := FALSE;
BEGIN
  -- Obter XP e nível atual
  SELECT current_xp, level 
  INTO v_current_xp, v_current_level
  FROM user_profiles
  WHERE user_id = p_user_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User profile not found for user %', p_user_id;
  END IF;
  
  -- Calcular novo XP
  v_new_xp := v_current_xp + p_amount;
  
  -- Registrar a transação de XP
  INSERT INTO user_xp_transactions (
    user_id,
    amount,
    source,
    source_id,
    previous_xp,
    new_xp
  ) VALUES (
    p_user_id,
    p_amount,
    p_source,
    p_source_id,
    v_current_xp,
    v_new_xp
  );
  
  -- Atualizar o perfil do usuário
  UPDATE user_profiles
  SET current_xp = v_new_xp
  WHERE user_id = p_user_id;
  
  -- Verificar se o usuário subiu de nível (outra função fará isso via trigger)
  
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;