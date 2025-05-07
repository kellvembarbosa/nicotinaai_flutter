-- Add currency fields to profiles table
ALTER TABLE public.profiles
ADD COLUMN currency_code VARCHAR(3) DEFAULT 'BRL',
ADD COLUMN currency_symbol VARCHAR(5) DEFAULT 'R$',
ADD COLUMN currency_locale VARCHAR(10) DEFAULT 'pt_BR';

-- Create function to detect device currency and update user profile
CREATE OR REPLACE FUNCTION public.set_default_currency()
RETURNS TRIGGER AS $$
BEGIN
  -- Set default values if they don't exist
  NEW.currency_code := COALESCE(NEW.currency_code, 'BRL');
  NEW.currency_symbol := COALESCE(NEW.currency_symbol, 'R$');
  NEW.currency_locale := COALESCE(NEW.currency_locale, 'pt_BR');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to set default currency on profile creation
CREATE TRIGGER set_default_currency_trigger
BEFORE INSERT ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_default_currency();

-- Comment on columns
COMMENT ON COLUMN public.profiles.currency_code IS 'ISO 4217 currency code (e.g., USD, EUR, BRL)';
COMMENT ON COLUMN public.profiles.currency_symbol IS 'Currency symbol (e.g., $, €, R$)';
COMMENT ON COLUMN public.profiles.currency_locale IS 'Locale string for currency formatting (e.g., en_US, pt_BR)';

-- Ensure pack_price is saved as cents (integer) in user_onboarding 
COMMENT ON COLUMN public.user_onboarding.pack_price IS 'Price of cigarette pack in cents (integer)';

-- Ensure money_saved is saved as cents (integer) in user_stats
COMMENT ON COLUMN public.user_stats.money_saved IS 'Money saved in cents (integer)';