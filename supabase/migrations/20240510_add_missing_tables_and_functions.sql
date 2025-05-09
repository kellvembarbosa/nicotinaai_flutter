-- Criação da tabela onboarding_data (se não existir)
CREATE TABLE IF NOT EXISTS public.onboarding_data (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users NOT NULL,
  data jsonb NOT NULL DEFAULT '{}'::jsonb,
  is_completed boolean NOT NULL DEFAULT false,
  completed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT onboarding_data_user_id_key UNIQUE (user_id)
);

-- Adicionar RLS para onboarding_data
ALTER TABLE public.onboarding_data ENABLE ROW LEVEL SECURITY;

-- Adicionar políticas RLS para onboarding_data
DROP POLICY IF EXISTS "Users can view their own onboarding data" ON public.onboarding_data;
DROP POLICY IF EXISTS "Users can insert their own onboarding data" ON public.onboarding_data;
DROP POLICY IF EXISTS "Users can update their own onboarding data" ON public.onboarding_data;

CREATE POLICY "Users can view their own onboarding data"
  ON public.onboarding_data
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own onboarding data"
  ON public.onboarding_data
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own onboarding data"
  ON public.onboarding_data
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Criação da tabela user_xp (se não existir)
CREATE TABLE IF NOT EXISTS public.user_xp (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users NOT NULL,
  amount integer NOT NULL,
  source varchar(255) NOT NULL,
  reference_id varchar(255),
  created_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Adicionar RLS para user_xp
ALTER TABLE public.user_xp ENABLE ROW LEVEL SECURITY;

-- Adicionar políticas RLS para user_xp
DROP POLICY IF EXISTS "Users can view their own xp" ON public.user_xp;
DROP POLICY IF EXISTS "Users can insert xp via function only" ON public.user_xp;

CREATE POLICY "Users can view their own xp"
  ON public.user_xp
  FOR SELECT
  USING (auth.uid() = user_id);

-- Função para adicionar XP ao usuário
CREATE OR REPLACE FUNCTION public.add_user_xp(
  p_amount integer,
  p_reference_id varchar,
  p_source varchar,
  p_user_id uuid DEFAULT auth.uid()
) RETURNS json
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_result json;
BEGIN
  -- Verificar se o usuário existe
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = p_user_id) THEN
    RETURN json_build_object('success', false, 'message', 'User not found');
  END IF;

  -- Verificar se o valor de XP é positivo
  IF p_amount <= 0 THEN
    RETURN json_build_object('success', false, 'message', 'XP amount must be positive');
  END IF;

  -- Inserir o registro de XP
  INSERT INTO public.user_xp (user_id, amount, source, reference_id)
  VALUES (p_user_id, p_amount, p_source, p_reference_id);

  -- Retornar resultado de sucesso
  RETURN json_build_object(
    'success', true,
    'message', 'XP added successfully',
    'data', json_build_object(
      'user_id', p_user_id,
      'amount', p_amount,
      'source', p_source,
      'reference_id', p_reference_id
    )
  );
END;
$$;

-- Adiciona triggers para atualizar campos updated_at
CREATE OR REPLACE FUNCTION public.trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para onboarding_data
DROP TRIGGER IF EXISTS set_timestamp_onboarding_data ON public.onboarding_data;
CREATE TRIGGER set_timestamp_onboarding_data
BEFORE UPDATE ON public.onboarding_data
FOR EACH ROW
EXECUTE PROCEDURE public.trigger_set_timestamp();