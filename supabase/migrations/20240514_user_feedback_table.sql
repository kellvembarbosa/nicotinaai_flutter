-- Create enum type for app ratings
CREATE TYPE public.enum_app_rating AS ENUM ('1', '2', '3', '4', '5');

-- Create user_feedback table
CREATE TABLE IF NOT EXISTS public.user_feedback (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  is_satisfied BOOLEAN NOT NULL,
  rating enum_app_rating,
  feedback_text TEXT,
  feedback_category TEXT,
  has_reviewed_app BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add RLS policies
ALTER TABLE public.user_feedback ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to view only their own feedback
CREATE POLICY "Users can view own feedback" ON public.user_feedback
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy to allow users to insert their own feedback
CREATE POLICY "Users can insert own feedback" ON public.user_feedback
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy to allow users to update their own feedback
CREATE POLICY "Users can update own feedback" ON public.user_feedback
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Add tracking for updates to updated_at field
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.user_feedback
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

-- Create function to log function calls
CREATE TABLE IF NOT EXISTS public.function_call_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  function_name TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  params JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add RLS policies for function call log
ALTER TABLE public.function_call_log ENABLE ROW LEVEL SECURITY;

-- Policy to allow service role to insert function call logs
CREATE POLICY "Service role can insert function call logs" ON public.function_call_log
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Only service role and authenticated users can view their own logs
CREATE POLICY "Users can view own function call logs" ON public.function_call_log
  FOR SELECT
  USING (auth.uid() = user_id);