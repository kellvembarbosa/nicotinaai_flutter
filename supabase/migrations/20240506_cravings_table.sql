-- Create the 'cravings' table for storing user craving records
CREATE TABLE IF NOT EXISTS public.cravings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    location VARCHAR(50) NOT NULL,
    notes TEXT,
    trigger VARCHAR(50) NOT NULL,
    intensity VARCHAR(20) NOT NULL,
    resisted BOOLEAN NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ
);

-- Add RLS (Row Level Security) policies
ALTER TABLE public.cravings ENABLE ROW LEVEL SECURITY;

-- Create policy for users to read only their own cravings
CREATE POLICY "Users can read their own cravings" 
    ON public.cravings
    FOR SELECT 
    USING (auth.uid() = user_id);

-- Create policy for users to insert their own cravings
CREATE POLICY "Users can create their own cravings" 
    ON public.cravings
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Create policy for users to update their own cravings
CREATE POLICY "Users can update their own cravings" 
    ON public.cravings
    FOR UPDATE 
    USING (auth.uid() = user_id);

-- Create policy for users to delete their own cravings
CREATE POLICY "Users can delete their own cravings" 
    ON public.cravings
    FOR DELETE 
    USING (auth.uid() = user_id);

-- Create a trigger to update the 'updated_at' timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_cravings_timestamp
BEFORE UPDATE ON public.cravings
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Create an index on user_id for faster queries
CREATE INDEX idx_cravings_user_id ON public.cravings(user_id);

-- Create an index on timestamp for faster ordering
CREATE INDEX idx_cravings_timestamp ON public.cravings(timestamp DESC);