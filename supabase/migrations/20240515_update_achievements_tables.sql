-- Add the missing function to add XP to users when unlocking achievements
CREATE OR REPLACE FUNCTION public.add_user_xp(
  p_user_id UUID, 
  p_amount INTEGER, 
  p_source TEXT DEFAULT 'SYSTEM',
  p_reference_id TEXT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- In the future, we can create a user_xp table to track XP awards
  -- For now, we'll just log the XP award
  RAISE NOTICE 'XP awarded: % to user % from % (ref: %)', 
               p_amount, p_user_id, p_source, p_reference_id;
  
  -- This is a placeholder for future XP system implementation
  -- CREATE TABLE IF NOT EXISTS public.user_xp_history
  -- INSERT INTO public.user_xp_history...
END;
$$;

-- Create a function to consolidate viewed_achievements table for compatibility
CREATE OR REPLACE FUNCTION public.consolidate_achievement_tables()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  viewed_exists BOOLEAN;
  user_exists BOOLEAN;
BEGIN
  -- Check if viewed_achievements table exists
  SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'viewed_achievements'
  ) INTO viewed_exists;
  
  -- Check if user_achievements table exists
  SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'user_achievements'
  ) INTO user_exists;
  
  -- If both tables exist, migrate data from viewed_achievements to user_achievements
  IF viewed_exists AND user_exists THEN
    -- Update is_viewed flag in user_achievements based on viewed_achievements
    UPDATE public.user_achievements ua
    SET is_viewed = true
    FROM public.viewed_achievements va
    WHERE ua.user_id = va.user_id
    AND ua.achievement_id = va.achievement_id;
    
    -- Insert viewed achievements that don't have a corresponding user_achievement
    -- This assumes they are unlocked but not yet in user_achievements
    INSERT INTO public.user_achievements (user_id, achievement_id, unlocked_at, is_viewed)
    SELECT va.user_id, va.achievement_id, va.viewed_at, true
    FROM public.viewed_achievements va
    LEFT JOIN public.user_achievements ua ON 
      va.user_id = ua.user_id AND 
      va.achievement_id = ua.achievement_id
    WHERE ua.id IS NULL;
    
    RAISE NOTICE 'Achievement tables consolidated successfully';
  ELSE
    RAISE NOTICE 'One or both tables do not exist. viewed_achievements: %, user_achievements: %', 
                 viewed_exists, user_exists;
  END IF;
END;
$$;

-- Grant execute permission on functions
GRANT EXECUTE ON FUNCTION public.add_user_xp TO authenticated;
GRANT EXECUTE ON FUNCTION public.consolidate_achievement_tables TO service_role;