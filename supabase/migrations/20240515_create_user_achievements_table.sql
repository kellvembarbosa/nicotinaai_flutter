-- Create the user_achievements table to store persisted achievements
CREATE TABLE IF NOT EXISTS public.user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_id TEXT NOT NULL,
  unlocked_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  is_viewed BOOLEAN NOT NULL DEFAULT false,
  UNIQUE(user_id, achievement_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS user_achievements_user_id_idx ON public.user_achievements(user_id);
CREATE INDEX IF NOT EXISTS user_achievements_achievement_id_idx ON public.user_achievements(achievement_id);

-- Set up Row Level Security
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- Create policies that ensure users can only access their own records
CREATE POLICY "Users can view only their own achievements" 
  ON public.user_achievements FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert only their own achievements" 
  ON public.user_achievements FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update only their own achievements" 
  ON public.user_achievements FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete only their own achievements" 
  ON public.user_achievements FOR DELETE 
  USING (auth.uid() = user_id);

-- Create function to unlock an achievement with a text ID
CREATE OR REPLACE FUNCTION public.unlock_achievement_text(p_user_id UUID, p_achievement_id TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Insert the achievement if it doesn't exist, or do nothing if it does
  INSERT INTO public.user_achievements (user_id, achievement_id, unlocked_at, is_viewed)
  VALUES (p_user_id, p_achievement_id, now(), false)
  ON CONFLICT (user_id, achievement_id) DO NOTHING;
END;
$$;

-- Grant usage to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.user_achievements TO authenticated;
GRANT EXECUTE ON FUNCTION public.unlock_achievement_text TO authenticated;