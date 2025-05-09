-- Only for tracking viewed state to avoid re-showing notifications
CREATE TABLE IF NOT EXISTS public.viewed_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_id TEXT NOT NULL, -- References the string ID in code
  viewed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

-- Add indexes
CREATE INDEX idx_viewed_achievements_user_id ON public.viewed_achievements(user_id);
CREATE INDEX idx_viewed_achievements_achievement_id ON public.viewed_achievements(achievement_id);

-- Setup RLS
ALTER TABLE public.viewed_achievements ENABLE ROW LEVEL SECURITY;

-- RLS policies
CREATE POLICY "Users can view their viewed achievements" 
  ON public.viewed_achievements
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their viewed achievements" 
  ON public.viewed_achievements
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their viewed achievements" 
  ON public.viewed_achievements
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Trigger for updated_at (if update_modified_column function exists)
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_modified_column') THEN
    EXECUTE 'CREATE TRIGGER update_viewed_achievements_modtime
             BEFORE UPDATE ON public.viewed_achievements
             FOR EACH ROW
             EXECUTE FUNCTION update_modified_column()';
  END IF;
END $$;