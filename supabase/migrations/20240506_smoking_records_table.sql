-- Create the 'smoking_records' table for storing smoking instances
CREATE TABLE IF NOT EXISTS public.smoking_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reason VARCHAR(50) NOT NULL,
    notes TEXT,
    amount VARCHAR(20) NOT NULL,
    duration VARCHAR(20) NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ
);

-- Add RLS (Row Level Security) policies
ALTER TABLE public.smoking_records ENABLE ROW LEVEL SECURITY;

-- Create policy for users to read only their own records
CREATE POLICY "Users can read their own smoking records" 
    ON public.smoking_records
    FOR SELECT 
    USING (auth.uid() = user_id);

-- Create policy for users to insert their own records
CREATE POLICY "Users can create their own smoking records" 
    ON public.smoking_records
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Create policy for users to update their own records
CREATE POLICY "Users can update their own smoking records" 
    ON public.smoking_records
    FOR UPDATE 
    USING (auth.uid() = user_id);

-- Create policy for users to delete their own records
CREATE POLICY "Users can delete their own smoking records" 
    ON public.smoking_records
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

CREATE TRIGGER update_smoking_records_timestamp
BEFORE UPDATE ON public.smoking_records
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Create an index on user_id for faster queries
CREATE INDEX idx_smoking_records_user_id ON public.smoking_records(user_id);

-- Create an index on timestamp for faster ordering
CREATE INDEX idx_smoking_records_timestamp ON public.smoking_records(timestamp DESC);