-- Fix for missing cravings_count column in user_stats table
DO $$
BEGIN
    -- Check if the column exists before trying to add it
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'user_stats'
        AND column_name = 'cravings_count'
    ) THEN
        -- Add the missing cravings_count column
        ALTER TABLE public.user_stats
        ADD COLUMN cravings_count INTEGER DEFAULT 0;
        
        -- Add a comment for the column
        COMMENT ON COLUMN public.user_stats.cravings_count IS 'Total count of cravings for the user';
        
        RAISE NOTICE 'Added missing cravings_count column to user_stats table';
    ELSE
        RAISE NOTICE 'cravings_count column already exists in user_stats table';
    END IF;
END
$$;

-- Fix for the enum_craving_outcome type conversion issue
DO $$
BEGIN
    -- Check if the outcome column exists in cravings table
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'cravings'
        AND column_name = 'outcome'
    ) THEN
        -- First, check if the enum type exists
        IF EXISTS (
            SELECT 1 FROM pg_type WHERE typname = 'craving_outcome'
        ) THEN
            -- Alter the column to use the craving_outcome enum type
            ALTER TABLE public.cravings
            ALTER COLUMN outcome TYPE craving_outcome USING 
            CASE
                WHEN outcome::text = 'RESISTED' THEN 'RESISTED'::craving_outcome
                WHEN outcome::text = 'SMOKED' THEN 'SMOKED'::craving_outcome
                WHEN outcome::text = 'ALTERNATIVE' THEN 'ALTERNATIVE'::craving_outcome
                WHEN resisted = true THEN 'RESISTED'::craving_outcome
                ELSE 'SMOKED'::craving_outcome
            END;
            
            RAISE NOTICE 'Fixed outcome column type in cravings table';
        ELSE
            -- Create the enum type first if it doesn't exist
            CREATE TYPE craving_outcome AS ENUM ('RESISTED', 'SMOKED', 'ALTERNATIVE');
            
            -- Then alter the column to use the new type
            ALTER TABLE public.cravings
            ALTER COLUMN outcome TYPE craving_outcome USING 
            CASE
                WHEN outcome::text = 'RESISTED' THEN 'RESISTED'::craving_outcome
                WHEN outcome::text = 'SMOKED' THEN 'SMOKED'::craving_outcome
                WHEN outcome::text = 'ALTERNATIVE' THEN 'ALTERNATIVE'::craving_outcome
                WHEN resisted = true THEN 'RESISTED'::craving_outcome
                ELSE 'SMOKED'::craving_outcome
            END;
            
            RAISE NOTICE 'Created craving_outcome enum type and fixed outcome column type';
        END IF;
    ELSE
        RAISE NOTICE 'outcome column not found in cravings table';
    END IF;
END
$$;