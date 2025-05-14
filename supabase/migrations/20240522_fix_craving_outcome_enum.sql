-- First, check if enum type already exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'craving_outcome') THEN
        -- Create the enum type if it doesn't exist
        CREATE TYPE craving_outcome AS ENUM ('RESISTED', 'SMOKED', 'ALTERNATIVE');
    END IF;
END$$;

-- Fix the column type if needed
-- This is a safe operation that will make sure the column is properly typed as enum
ALTER TABLE IF EXISTS public.cravings
    ALTER COLUMN outcome TYPE craving_outcome USING outcome::craving_outcome;

-- Add comment to explain the enum
COMMENT ON COLUMN public.cravings.outcome IS 'Outcome of the craving: RESISTED, SMOKED, or ALTERNATIVE action taken';