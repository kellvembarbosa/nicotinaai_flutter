# Nicotina.AI Onboarding Implementation Plan

## 1. Database Structure

### Table: user_onboarding

This table will store all onboarding information for each user. The structure is designed to be flexible and allow for future expansion.

```sql
CREATE TABLE public.user_onboarding (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  
  -- Core onboarding questions
  cigarettes_per_day ENUM_CONSUMPTION_LEVEL DEFAULT NULL, -- 'LOW', 'MODERATE', 'HIGH', 'VERY_HIGH'
  cigarettes_per_day_count INTEGER DEFAULT NULL,
  pack_price INTEGER DEFAULT NULL, -- Stored in cents to avoid floating-point issues
  pack_price_currency TEXT DEFAULT 'USD',
  cigarettes_per_pack INTEGER DEFAULT NULL,
  
  -- Goals
  goal ENUM_GOAL_TYPE DEFAULT NULL, -- 'REDUCE', 'QUIT'
  goal_timeline ENUM_GOAL_TIMELINE DEFAULT NULL, -- 'SEVEN_DAYS', 'FOURTEEN_DAYS', 'THIRTY_DAYS', 'NO_DEADLINE'
  
  -- Challenges and preferences
  quit_challenge ENUM_QUIT_CHALLENGE DEFAULT NULL, -- 'STRESS', 'HABIT', 'SOCIAL', 'ADDICTION'
  
  -- App help preferences (stored as an array to allow multiple selections)
  help_preferences TEXT[] DEFAULT NULL, -- ['REMINDERS', 'MOTIVATION', 'TIPS', 'TRACKING']
  
  -- Product type
  product_type ENUM_PRODUCT_TYPE DEFAULT NULL, -- 'CIGARETTE_ONLY', 'VAPE_ONLY', 'BOTH'
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Extra JSON field for future additions without schema changes
  additional_data JSONB DEFAULT '{}'::JSONB
);

-- Create enums for the various option types
CREATE TYPE ENUM_CONSUMPTION_LEVEL AS ENUM ('LOW', 'MODERATE', 'HIGH', 'VERY_HIGH');
CREATE TYPE ENUM_GOAL_TYPE AS ENUM ('REDUCE', 'QUIT');
CREATE TYPE ENUM_GOAL_TIMELINE AS ENUM ('SEVEN_DAYS', 'FOURTEEN_DAYS', 'THIRTY_DAYS', 'NO_DEADLINE');
CREATE TYPE ENUM_QUIT_CHALLENGE AS ENUM ('STRESS', 'HABIT', 'SOCIAL', 'ADDICTION');
CREATE TYPE ENUM_PRODUCT_TYPE AS ENUM ('CIGARETTE_ONLY', 'VAPE_ONLY', 'BOTH');

-- Indexes
CREATE INDEX idx_user_onboarding_user_id ON public.user_onboarding(user_id);

-- Add trigger for updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_onboarding_modtime
BEFORE UPDATE ON public.user_onboarding
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();
```

### RLS (Row Level Security) Policies

```sql
-- Enable RLS on user_onboarding table
ALTER TABLE public.user_onboarding ENABLE ROW LEVEL SECURITY;

-- Create policy for users to see only their own onboarding data
CREATE POLICY "Users can view their own onboarding data" 
  ON public.user_onboarding
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy for users to insert their own onboarding data
CREATE POLICY "Users can insert their own onboarding data" 
  ON public.user_onboarding
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create policy for users to update their own onboarding data
CREATE POLICY "Users can update their own onboarding data" 
  ON public.user_onboarding
  FOR UPDATE
  USING (auth.uid() = user_id);
```

## 2. Onboarding Flow Overview

The onboarding process will be presented to users after they successfully log in for the first time. It will consist of 7 screens, each focused on a specific question about their smoking habits and goals.

### Screen Flow:
1. **Introduction Screen**: Welcome message explaining the purpose of onboarding
2. **Cigarettes Per Day**: Ask how many cigarettes they smoke per day
3. **Pack Price**: Ask about the price of cigarette packs
4. **Cigarettes Per Pack**: Ask how many cigarettes come in a pack
5. **Goal Setting**: Ask about their quitting/reduction goals
6. **Timeline**: Ask when they want to achieve their goal
7. **Challenges**: Ask what makes quitting difficult for them
8. **App Help**: Ask how the app can help them
9. **Product Type**: Ask what smoking products they use
10. **Completion**: Thank you screen with summary of their answers

## 3. UI Design and Components

The onboarding UI will follow the same visual style as the login/signup screens, with consistent use of colors, typography, and component styles.

### Common UI Elements:
- **Progress Indicator**: Shows progress through the onboarding process
- **Question Title**: Clear, concise question text
- **Option Cards**: Selectable cards for each answer option
- **Navigation Buttons**: Next and Back buttons
- **Skip Option**: Allow users to skip certain questions if needed

### Colors and Styles:
- Use the same color palette from login/signup screens
- Primary color for selected options and buttons
- Clean white background for main content
- Consistent typography using Inter font family

## 4. Implementation Details

### Storage Strategy:

1. **First Login Detection**:
   - After successful authentication, check if the user has completed onboarding by querying the user_onboarding table
   - If no record exists or `completed = false`, redirect to onboarding flow

2. **Progressive Data Storage**:
   - Create a record in user_onboarding table when user starts onboarding
   - Update the record as the user progresses through each screen
   - Set `completed = true` when user finishes the entire flow

3. **Handling Interruptions**:
   - Store progress in both Supabase and local storage
   - If user exits during onboarding, they can continue where they left off

### Components to Create:

1. **OnboardingContainer**: Main wrapper component with progress tracker
2. **OptionCard**: Reusable component for selectable options
3. **NumberSelector**: Component for numerical inputs with +/- buttons
4. **PriceInput**: Specialized input for currency values
5. **MultiSelectOptions**: Component for multiple-choice selection
6. **ProgressBar**: Visual indicator of onboarding progress

### Navigation:

- Use Expo Router for navigation between onboarding screens
- Create a separate onboarding stack with its own layout
- Implement conditional routing to direct users to onboarding or main app based on their onboarding status

## 5. Data Mapping

### Cigarettes Per Day:
- 5 cigarettes → 'LOW'
- 10-15 cigarettes → 'MODERATE'
- 20-25 cigarettes → 'HIGH'
- 30-40+ cigarettes → 'VERY_HIGH'
- Actual count stored in cigarettes_per_day_count

### Pack Price:
- Store in cents (integer) to avoid floating-point issues
- $5.00 → 500
- $6.00 → 600
- $7.00 → 700
- Custom values stored as entered (converted to cents)

### Goal Types:
- "Reduce" → 'REDUCE'
- "Quit completely" → 'QUIT'

### Goal Timeline:
- "In 7 days" → 'SEVEN_DAYS'
- "In 14 days" → 'FOURTEEN_DAYS'
- "In 30 days" → 'THIRTY_DAYS'
- "No deadline" → 'NO_DEADLINE'

### Quit Challenges:
- "Stress" → 'STRESS'
- "Daily habit" → 'HABIT'
- "Social pressure" → 'SOCIAL'
- "Nicotine addiction" → 'ADDICTION'

### Help Preferences:
- "Reminders and alerts" → 'REMINDERS'
- "Daily motivation" → 'MOTIVATION'
- "Tips to resist cravings" → 'TIPS'
- "Track my progress" → 'TRACKING'

### Product Type:
- "Apenas cigarro" (Only cigarettes) → 'CIGARETTE_ONLY'
- "Apenas vape" (Only vape) → 'VAPE_ONLY'
- "Ambos" (Both) → 'BOTH'

## 6. Implementation Steps

1. **Database Setup**:
   - Execute SQL to create user_onboarding table and related enums
   - Set up RLS policies for security

2. **Supabase Integration**:
   - Create TypeScript types for onboarding data
   - Implement API functions for CRUD operations on user_onboarding

3. **Context Provider**:
   - Create OnboardingContext to manage state across screens
   - Implement methods to save progress to database

4. **Screen Development**:
   - Develop each onboarding screen following the UI design
   - Implement validation and error handling

5. **Navigation Logic**:
   - Set up routing to direct users to onboarding when needed
   - Implement ability to resume onboarding

6. **Testing**:
   - Test onboarding flow completion
   - Test different user inputs and edge cases
   - Test interruption and resumption scenarios

## 7. Multi-language Support

Ensure all onboarding screens support multiple languages using the existing i18n infrastructure:

- Create translations for all onboarding questions and options
- Add new translations to the i18n/translations.ts file
- Use the useTranslation hook consistently across all screens

## 8. Wireframes & Screen Mockups

Include simple mockups for key screens in the onboarding flow, focusing on layout and component placement.

## 9. Future Expansion Considerations

The database schema and UI are designed to accommodate future changes:

- The additional_data JSONB field can store new question responses without schema changes
- The UI components are reusable for new question types
- The progress indicator can adapt to additional screens

This implementation plan provides a comprehensive roadmap for creating the onboarding experience while ensuring flexibility for future enhancements.