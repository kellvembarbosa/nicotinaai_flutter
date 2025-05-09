# Health Recovery Implementation Plan

## Overview

This document outlines the implementation plan for the Health Recovery feature in the NicotinaAI Flutter app. The feature will track and display health improvements after a user quits smoking, generate notifications when milestones are reached, and award XP to engage users.

## Health Recovery Timeline

Based on scientific research, here's the timeline for health improvements after quitting smoking:

| Time Since Quitting | Health Recovery                                       | Body System     |
|---------------------|-------------------------------------------------------|-----------------|
| 20 minutes          | Heart rate normalizes                                 | Heart           |
| 12 hours            | Carbon monoxide levels return to normal               | Blood           |
| 2 days              | Nerve endings for taste and smell begin to heal       | Taste/Smell     |
| 2-3 days            | Improved sense of taste                               | Taste           |
| 2-3 days            | Improved sense of smell                               | Smell           |
| 2-3 days            | Nicotine is eliminated from the body                  | General         |
| 2 weeks             | Improved circulation                                  | Circulation     |
| 2-3 weeks           | Lung function increases up to 30%                     | Lungs           |
| 1 month             | Improved lung capacity, reduced shortness of breath   | Lungs           |
| 1-3 months          | Improved energy levels                                | General         |
| 3-9 months          | Cilia regrow in lungs, reducing infections            | Lungs           |
| 1 year              | Heart attack risk reduced by 50%                      | Heart           |
| 5 years             | Stroke risk reduced to that of a non-smoker           | Circulation     |
| 10 years            | Lung cancer risk reduced by 50%                       | Lungs           |
| 15 years            | Coronary heart disease risk same as a non-smoker      | Heart           |

## Database Design

We'll need to create two tables:

1. `health_recoveries` - Master list of all possible health recoveries
2. `user_health_recoveries` - Tracks which recoveries a user has achieved

### SQL Migration

```sql
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
```

## Edge Function

Create an edge function that checks for health recovery achievements:

```typescript
// checkHealthRecoveries.ts
import { serve } from 'https://deno.land/std@0.131.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.2.0';

interface HealthRecovery {
  id: string;
  name: string;
  days_to_achieve: number;
  xp_reward: number;
}

serve(async (req) => {
  try {
    const { userId } = await req.json();

    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Get user's last smoke date
    const { data: userStats, error: statsError } = await supabase
      .from('user_stats')
      .select('last_smoke_date')
      .eq('user_id', userId)
      .single();

    if (statsError || !userStats || !userStats.last_smoke_date) {
      return new Response(
        JSON.stringify({ error: 'Unable to find last smoke date' }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 }
      );
    }

    const lastSmokeDate = new Date(userStats.last_smoke_date);
    const now = new Date();
    const daysSinceLastSmoke = Math.floor((now.getTime() - lastSmokeDate.getTime()) / (1000 * 60 * 60 * 24));

    // Get all health recoveries
    const { data: healthRecoveries, error: recoveriesError } = await supabase
      .from('health_recoveries')
      .select('*')
      .order('days_to_achieve', { ascending: true });

    if (recoveriesError) {
      return new Response(
        JSON.stringify({ error: 'Unable to fetch health recoveries' }),
        { headers: { 'Content-Type': 'application/json' }, status: 500 }
      );
    }

    // Get user's existing health recoveries
    const { data: userRecoveries, error: userRecoveriesError } = await supabase
      .from('user_health_recoveries')
      .select('recovery_id')
      .eq('user_id', userId);

    if (userRecoveriesError) {
      return new Response(
        JSON.stringify({ error: 'Unable to fetch user health recoveries' }),
        { headers: { 'Content-Type': 'application/json' }, status: 500 }
      );
    }

    const achievedRecoveryIds = new Set((userRecoveries || []).map(r => r.recovery_id));
    const newAchievements = [];

    // Check for new achievements
    for (const recovery of healthRecoveries) {
      if (daysSinceLastSmoke >= recovery.days_to_achieve && !achievedRecoveryIds.has(recovery.id)) {
        // Add user health recovery
        const { data: newRecovery, error: insertError } = await supabase
          .from('user_health_recoveries')
          .insert({
            user_id: userId,
            recovery_id: recovery.id,
            achieved_at: new Date().toISOString(),
            is_viewed: false
          })
          .select()
          .single();

        if (!insertError && newRecovery) {
          newAchievements.push({
            id: newRecovery.id,
            recovery_id: recovery.id,
            name: recovery.name,
            xp_reward: recovery.xp_reward
          });

          // Award XP to user
          await supabase.rpc('add_user_xp', {
            user_id: userId,
            xp_amount: recovery.xp_reward,
            action_type: 'HEALTH_RECOVERY',
            reference_id: recovery.id
          });

          // Create notification
          await supabase.from('notifications').insert({
            user_id: userId,
            title: `Health Recovery: ${recovery.name}`,
            message: `Your ${recovery.name.toLowerCase()} has improved after ${recovery.days_to_achieve} days without smoking.`,
            type: 'HEALTH_RECOVERY',
            reference_id: newRecovery.id,
            is_read: false
          });
        }
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        days_smoke_free: daysSinceLastSmoke,
        new_achievements: newAchievements 
      }),
      { headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
```

## UI Implementation

### Health Recovery Display

Create a UI component to display health recoveries in the home screen:

1. Display recoveries as a horizontal scrollable list
2. Show checkmarks for completed recoveries
3. For each recovery, display:
   - Icon
   - Name
   - Progress (if not achieved)
   - Checkmark (if achieved)

### Health Recovery Detail Screen

When a user taps on a recovery item:

1. Show detailed information about the recovery
2. Display scientific information about the health benefit
3. Show date achieved (if applicable)
4. Show progress toward next milestone

### Relapse Handling

When a user records a smoking event:

1. Reset the "days since last smoke" counter
2. Do not remove previously earned recoveries
3. Show "in progress" status for recoveries that require longer periods
4. Display encouraging message about getting back on track

## Notification System

Use Firebase Cloud Messaging (FCM) for notifications:

1. Send local notifications when health recoveries are achieved
2. Include motivational messages specific to the achievement
3. Create a notification preference setting for users

## XP Reward System

Award XP for health recovery achievements:

1. Smaller rewards for early achievements (taste, smell)
2. Larger rewards for long-term achievements (heart health)
3. Display XP gain animation when a recovery is achieved
4. Show achievements in user profile

## Implementation Phases

### Phase 1: Database Setup
- Create SQL migration
- Add initial health recovery data
- Test database with basic queries

### Phase 2: Business Logic
- Create edge function for checking recoveries
- Update tracking_repository and tracking_provider
- Implement relapse handling logic

### Phase 3: UI Implementation
- Create health recovery display component
- Build detail screen
- Implement progress indicators

### Phase 4: Notification & XP System
- Integrate with existing notification system
- Add XP rewards for health recoveries
- Test notifications and XP awards

## Testing Plan

1. Test database migrations and RLS policies
2. Verify edge function correctly calculates days since quitting
3. Test different scenarios:
   - New user with no smoking records
   - User with multiple quit attempts
   - User who achieves long-term milestones
4. Test notification delivery
5. Verify XP rewards are awarded correctly

## Conclusion

The Health Recovery feature will provide users with tangible evidence of their health improvements as they progress in their quit smoking journey. By combining scientific information with gamification elements like XP rewards and achievements, we can increase user engagement and motivation to remain smoke-free.