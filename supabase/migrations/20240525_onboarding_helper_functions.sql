-- Migration para adicionar funções de ajuda para sincronização de onboarding
-- Este script cria funções que ajudam a garantir que os dados do onboarding sejam 
-- corretamente sincronizados para a tabela user_stats

-- Função para atualizar user_stats a partir do onboarding
CREATE OR REPLACE FUNCTION update_user_stats_onboarding(
  user_id_param UUID,
  cigarettes_per_day_param INT,
  cigarettes_per_pack_param INT,
  pack_price_param INT,
  currency_code_param TEXT
)
RETURNS VOID AS $$
BEGIN
  -- Garante que todos os parâmetros são válidos
  IF cigarettes_per_day_param IS NULL THEN
    cigarettes_per_day_param := 10; -- Valor padrão
  END IF;

  IF cigarettes_per_pack_param IS NULL THEN 
    cigarettes_per_pack_param := 20; -- Valor padrão
  END IF;

  IF pack_price_param IS NULL THEN
    pack_price_param := 1000; -- Valor padrão (10,00 em centavos)
  END IF;

  IF currency_code_param IS NULL OR currency_code_param = '' THEN
    currency_code_param := 'BRL'; -- Valor padrão
  END IF;

  -- Atualiza o registro em user_stats
  UPDATE user_stats
  SET
    cigarettes_per_day = cigarettes_per_day_param,
    cigarettes_per_pack = cigarettes_per_pack_param,
    pack_price = pack_price_param,
    currency_code = currency_code_param
  WHERE user_id = user_id_param;
END;
$$ LANGUAGE plpgsql;

-- Função para criar user_stats a partir do onboarding
CREATE OR REPLACE FUNCTION create_user_stats_from_onboarding(
  user_id_param UUID,
  cigarettes_per_day_param INT,
  cigarettes_per_pack_param INT,
  pack_price_param INT,
  currency_code_param TEXT
)
RETURNS VOID AS $$
BEGIN
  -- Garante que todos os parâmetros são válidos
  IF cigarettes_per_day_param IS NULL THEN
    cigarettes_per_day_param := 10; -- Valor padrão
  END IF;

  IF cigarettes_per_pack_param IS NULL THEN 
    cigarettes_per_pack_param := 20; -- Valor padrão
  END IF;

  IF pack_price_param IS NULL THEN
    pack_price_param := 1000; -- Valor padrão (10,00 em centavos)
  END IF;

  IF currency_code_param IS NULL OR currency_code_param = '' THEN
    currency_code_param := 'BRL'; -- Valor padrão
  END IF;

  -- Insere o registro em user_stats
  INSERT INTO user_stats (
    user_id, 
    cigarettes_per_day, 
    cigarettes_per_pack, 
    pack_price, 
    currency_code,
    money_saved,
    cigarettes_avoided,
    cigarettes_smoked,
    smoking_records_count,
    cravings_count,
    cravings_resisted,
    current_streak_days
  )
  VALUES (
    user_id_param,
    cigarettes_per_day_param,
    cigarettes_per_pack_param,
    pack_price_param,
    currency_code_param,
    0, 0, 0, 0, 0, 0, 0
  )
  ON CONFLICT (user_id) DO UPDATE
  SET
    cigarettes_per_day = EXCLUDED.cigarettes_per_day,
    cigarettes_per_pack = EXCLUDED.cigarettes_per_pack,
    pack_price = EXCLUDED.pack_price,
    currency_code = EXCLUDED.currency_code;
END;
$$ LANGUAGE plpgsql;

-- Função para sincronizar todos os dados do onboarding para user_stats
CREATE OR REPLACE FUNCTION sync_onboarding_to_user_stats(
  user_id_param UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  onboarding_record RECORD;
  user_stats_exists BOOLEAN;
  cigarettes_per_day_val INT;
  cigarettes_per_pack_val INT;
  pack_price_val INT;
  currency_code_val TEXT;
BEGIN
  -- Verificar se o onboarding existe
  SELECT 
    o.* INTO onboarding_record
  FROM 
    user_onboarding o
  WHERE 
    o.user_id = user_id_param;
    
  IF onboarding_record IS NULL THEN
    RAISE EXCEPTION 'Onboarding não encontrado para o usuário %', user_id_param;
  END IF;
  
  -- Garantir que temos valores válidos
  cigarettes_per_day_val := COALESCE(onboarding_record.cigarettes_per_day_count, 10);
  cigarettes_per_pack_val := COALESCE(onboarding_record.cigarettes_per_pack, 20);
  pack_price_val := COALESCE(onboarding_record.pack_price, 1000);
  currency_code_val := COALESCE(onboarding_record.pack_price_currency, 'BRL');
  
  -- Verificar se o user_stats existe
  SELECT 
    EXISTS (
      SELECT 1 FROM user_stats WHERE user_id = user_id_param
    ) INTO user_stats_exists;
    
  -- Criar ou atualizar user_stats
  IF user_stats_exists THEN
    PERFORM update_user_stats_onboarding(
      user_id_param,
      cigarettes_per_day_val,
      cigarettes_per_pack_val,
      pack_price_val,
      currency_code_val
    );
  ELSE
    PERFORM create_user_stats_from_onboarding(
      user_id_param,
      cigarettes_per_day_val,
      cigarettes_per_pack_val,
      pack_price_val,
      currency_code_val
    );
  END IF;
  
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Erro ao sincronizar onboarding: %', SQLERRM;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;