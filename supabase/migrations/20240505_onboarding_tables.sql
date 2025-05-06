-- Criar enums
CREATE TYPE ENUM_CONSUMPTION_LEVEL AS ENUM ('LOW', 'MODERATE', 'HIGH', 'VERY_HIGH');
CREATE TYPE ENUM_GOAL_TYPE AS ENUM ('REDUCE', 'QUIT');
CREATE TYPE ENUM_GOAL_TIMELINE AS ENUM ('SEVEN_DAYS', 'FOURTEEN_DAYS', 'THIRTY_DAYS', 'NO_DEADLINE');
CREATE TYPE ENUM_QUIT_CHALLENGE AS ENUM ('STRESS', 'HABIT', 'SOCIAL', 'ADDICTION');
CREATE TYPE ENUM_PRODUCT_TYPE AS ENUM ('CIGARETTE_ONLY', 'VAPE_ONLY', 'BOTH');

-- Criar tabela
CREATE TABLE IF NOT EXISTS public.user_onboarding (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  
  -- Core onboarding questions
  cigarettes_per_day ENUM_CONSUMPTION_LEVEL DEFAULT NULL,
  cigarettes_per_day_count INTEGER DEFAULT NULL,
  pack_price INTEGER DEFAULT NULL, -- Stored in cents to avoid floating-point issues
  pack_price_currency TEXT DEFAULT 'BRL',
  cigarettes_per_pack INTEGER DEFAULT NULL,
  
  -- Goals
  goal ENUM_GOAL_TYPE DEFAULT NULL,
  goal_timeline ENUM_GOAL_TIMELINE DEFAULT NULL,
  
  -- Challenges and preferences
  quit_challenge ENUM_QUIT_CHALLENGE DEFAULT NULL,
  
  -- App help preferences (stored as an array to allow multiple selections)
  help_preferences TEXT[] DEFAULT NULL,
  
  -- Product type
  product_type ENUM_PRODUCT_TYPE DEFAULT NULL,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Extra JSON field for future additions without schema changes
  additional_data JSONB DEFAULT '{}'::JSONB
);

-- Índices
CREATE INDEX idx_user_onboarding_user_id ON public.user_onboarding(user_id);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_onboarding_modtime
BEFORE UPDATE ON public.user_onboarding
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- RLS (Row Level Security) Policies
ALTER TABLE public.user_onboarding ENABLE ROW LEVEL SECURITY;

-- Policy para visualização
CREATE POLICY "Users can view their own onboarding data" 
  ON public.user_onboarding
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy para inserção
CREATE POLICY "Users can insert their own onboarding data" 
  ON public.user_onboarding
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy para atualização
CREATE POLICY "Users can update their own onboarding data" 
  ON public.user_onboarding
  FOR UPDATE
  USING (auth.uid() = user_id);