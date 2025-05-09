-- Tabela para rastrear conquistas visualizadas pelo usuário
CREATE TABLE IF NOT EXISTS public.viewed_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_id TEXT NOT NULL,
  viewed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  
  -- Unique constraint para evitar duplicatas
  UNIQUE(user_id, achievement_id)
);

-- Configurar RLS para a tabela viewed_achievements
ALTER TABLE public.viewed_achievements ENABLE ROW LEVEL SECURITY;

-- Política para permitir que usuários vejam apenas suas próprias conquistas
CREATE POLICY "Users can view their own viewed achievements" 
  ON public.viewed_achievements 
  FOR SELECT USING (auth.uid() = user_id);

-- Política para permitir que usuários insiram suas próprias conquistas visualizadas
CREATE POLICY "Users can insert their own viewed achievements" 
  ON public.viewed_achievements 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para permitir que usuários atualizem suas próprias conquistas visualizadas
CREATE POLICY "Users can update their own viewed achievements" 
  ON public.viewed_achievements 
  FOR UPDATE USING (auth.uid() = user_id);

-- Política para permitir que usuários removam suas próprias conquistas visualizadas
CREATE POLICY "Users can delete their own viewed achievements" 
  ON public.viewed_achievements 
  FOR DELETE USING (auth.uid() = user_id);

-- Adicionar índice para melhorar consultas por usuário
CREATE INDEX viewed_achievements_user_id_idx ON public.viewed_achievements(user_id);

-- Adicionar índice para consultas por achievement_id
CREATE INDEX viewed_achievements_achievement_id_idx ON public.viewed_achievements(achievement_id);