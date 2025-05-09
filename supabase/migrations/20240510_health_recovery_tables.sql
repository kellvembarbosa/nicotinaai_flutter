-- Create health_recoveries table
CREATE TABLE IF NOT EXISTS public.health_recoveries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  days_to_achieve INTEGER NOT NULL,
  icon_name TEXT,
  order_index INTEGER NOT NULL,
  xp_reward INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_health_recoveries table
CREATE TABLE IF NOT EXISTS public.user_health_recoveries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recovery_id UUID NOT NULL REFERENCES public.health_recoveries(id) ON DELETE CASCADE,
  achieved_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_viewed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes
CREATE INDEX idx_user_health_recoveries_user_id ON public.user_health_recoveries(user_id);
CREATE INDEX idx_user_health_recoveries_recovery_id ON public.user_health_recoveries(recovery_id);

-- Setup RLS
ALTER TABLE public.health_recoveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_health_recoveries ENABLE ROW LEVEL SECURITY;

-- RLS policies for health_recoveries
CREATE POLICY "Anyone can view health recoveries" 
  ON public.health_recoveries
  FOR SELECT
  USING (true);

-- RLS policies for user_health_recoveries
CREATE POLICY "Users can view their own health recoveries" 
  ON public.user_health_recoveries
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own health recoveries" 
  ON public.user_health_recoveries
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own health recoveries" 
  ON public.user_health_recoveries
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Trigger for updated_at
CREATE TRIGGER update_health_recoveries_modtime
BEFORE UPDATE ON public.health_recoveries
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_user_health_recoveries_modtime
BEFORE UPDATE ON public.user_health_recoveries
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Insert initial health recovery data
INSERT INTO public.health_recoveries (name, description, days_to_achieve, icon_name, order_index, xp_reward)
VALUES
  ('Taste', 'Your sense of taste has begun recovering as nerve endings heal', 3, 'taste', 1, 20),
  ('Smell', 'Your sense of smell is improving as nerve endings heal', 3, 'smell', 2, 20),
  ('Circulation', 'Your circulation has improved, making physical activities easier', 14, 'circulation', 3, 50),
  ('Lungs', 'Your lung function has increased by up to 30%', 21, 'lungs', 4, 100),
  ('Heart', 'Your heart attack risk has decreased significantly', 365, 'heart', 5, 300);