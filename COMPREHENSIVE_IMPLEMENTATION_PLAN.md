# Comprehensive Implementation Plan for Nicotina.AI

This document outlines a complete implementation plan for the Nicotina.AI application, including database schema design, core features, edge functions, and development roadmap. The plan takes into account the existing onboarding functionality and expands the application to create a fully functional smoking cessation and tracking app.

## Table of Contents
1. [Database Schema](#database-schema)
2. [Edge Functions](#edge-functions)
3. [Core Features](#core-features)
4. [User Journey](#user-journey)
5. [Implementation Phases](#implementation-phases)
6. [Technical Considerations](#technical-considerations)
7. [Testing Plan](#testing-plan)

## Database Schema

### Existing Tables
- `profiles`: User profile information
- `user_onboarding`: Stores onboarding information (consumption level, goals, preferences)
- `user_onboarding_progress`: Tracks progress through the onboarding flow

### New Tables

#### 1. `smoking_logs`
Records every smoking event to track usage over time.

```sql
CREATE TABLE public.smoking_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  product_type ENUM_PRODUCT_TYPE NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  location TEXT,
  mood TEXT,
  trigger TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_smoking_logs_user_id ON public.smoking_logs(user_id);
CREATE INDEX idx_smoking_logs_timestamp ON public.smoking_logs(timestamp);

-- RLS Policies
ALTER TABLE public.smoking_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own smoking logs" 
  ON public.smoking_logs FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own smoking logs" 
  ON public.smoking_logs FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own smoking logs" 
  ON public.smoking_logs FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own smoking logs" 
  ON public.smoking_logs FOR DELETE USING (auth.uid() = user_id);
```

#### 2. `cravings`
Records craving events when users feel the urge to smoke but resist.

```sql
CREATE TYPE ENUM_CRAVING_INTENSITY AS ENUM ('LOW', 'MODERATE', 'HIGH', 'VERY_HIGH');
CREATE TYPE ENUM_CRAVING_OUTCOME AS ENUM ('RESISTED', 'SMOKED', 'ALTERNATIVE');

CREATE TABLE public.cravings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  intensity ENUM_CRAVING_INTENSITY NOT NULL,
  trigger TEXT,
  location TEXT,
  duration_minutes INTEGER,
  outcome ENUM_CRAVING_OUTCOME NOT NULL DEFAULT 'RESISTED',
  coping_strategy TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_cravings_user_id ON public.cravings(user_id);
CREATE INDEX idx_cravings_timestamp ON public.cravings(timestamp);

-- RLS Policies
ALTER TABLE public.cravings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own cravings" 
  ON public.cravings FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own cravings" 
  ON public.cravings FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own cravings" 
  ON public.cravings FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own cravings" 
  ON public.cravings FOR DELETE USING (auth.uid() = user_id);
```

#### 3. `quit_attempts`
Tracks quit attempts and their outcomes.

```sql
CREATE TYPE ENUM_QUIT_STATUS AS ENUM ('ACTIVE', 'RELAPSED', 'COMPLETED', 'ABANDONED');

CREATE TABLE public.quit_attempts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  end_date TIMESTAMP WITH TIME ZONE,
  goal_type ENUM_GOAL_TYPE NOT NULL,
  target_reduction_percent INTEGER, -- Only for REDUCE goal
  timeline_days INTEGER,
  status ENUM_QUIT_STATUS NOT NULL DEFAULT 'ACTIVE',
  relapse_reason TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_quit_attempts_user_id ON public.quit_attempts(user_id);
CREATE INDEX idx_quit_attempts_status ON public.quit_attempts(status);

-- RLS Policies
ALTER TABLE public.quit_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own quit attempts" 
  ON public.quit_attempts FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own quit attempts" 
  ON public.quit_attempts FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own quit attempts" 
  ON public.quit_attempts FOR UPDATE USING (auth.uid() = user_id);
```

#### 4. `health_recoveries`
Tracks health recovery milestones based on quit duration.

```sql
CREATE TABLE public.health_recoveries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  days_to_achieve INTEGER NOT NULL,
  icon_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Data seeding for predefined health milestones
INSERT INTO public.health_recoveries (name, description, days_to_achieve, icon_name) VALUES
('Blood Oxygen Normalization', 'Your blood oxygen levels have returned to normal.', 1, 'blood_drop'),
('Carbon Monoxide Eliminated', 'Carbon monoxide has been eliminated from your body.', 2, 'lungs'),
('Improved Sense of Taste', 'Your sense of taste has begun to improve.', 3, 'taste'),
('Improved Sense of Smell', 'Your sense of smell has begun to improve.', 3, 'smell'),
('Nicotine Expulsion', 'Nicotine has been completely expelled from your body.', 4, 'chemical'),
('Improved Breathing', 'Your lung function has started to improve.', 7, 'lungs'),
('Improved Circulation', 'Your circulation has begun to improve.', 14, 'heart'),
('Decreased Coughing', 'Coughing and shortness of breath decrease.', 30, 'lungs'),
('Lung Cilia Recovery', 'Lung cilia regrow, increasing ability to handle mucus and clean the lungs.', 90, 'lungs'),
('Reduced Heart Disease Risk', 'Your risk of coronary heart disease has decreased to half.', 365, 'heart');

-- No RLS needed as this is public reference data
```

#### 5. `user_health_recoveries`
Links users to their achieved health recovery milestones.

```sql
CREATE TABLE public.user_health_recoveries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recovery_id UUID NOT NULL REFERENCES public.health_recoveries(id) ON DELETE CASCADE,
  achieved_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_viewed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, recovery_id)
);

-- Indexes
CREATE INDEX idx_user_health_recoveries_user_id ON public.user_health_recoveries(user_id);

-- RLS Policies
ALTER TABLE public.user_health_recoveries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own health recoveries" 
  ON public.user_health_recoveries FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own health recoveries" 
  ON public.user_health_recoveries FOR UPDATE USING (auth.uid() = user_id);
```

#### 6. `achievements`
Stores predefined achievements for users to unlock.

```sql
CREATE TYPE ENUM_ACHIEVEMENT_CATEGORY AS ENUM ('MILESTONE', 'STREAK', 'HEALTH', 'FINANCIAL', 'BEHAVIOR', 'COMMUNITY');

CREATE TABLE public.achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category ENUM_ACHIEVEMENT_CATEGORY NOT NULL,
  icon_name TEXT NOT NULL,
  condition_type TEXT NOT NULL, -- 'days_smoke_free', 'cravings_resisted', 'money_saved', etc.
  condition_value INTEGER NOT NULL, -- number required to achieve
  xp_reward INTEGER NOT NULL DEFAULT 50,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Data seeding for predefined achievements
INSERT INTO public.achievements (name, description, category, icon_name, condition_type, condition_value, xp_reward) VALUES
('First Step', 'Complete the onboarding process', 'MILESTONE', 'first_step', 'onboarding_complete', 1, 50),
('One Day Wonder', 'Stay smoke-free for 1 day', 'STREAK', 'streak', 'days_smoke_free', 1, 100),
('Week Warrior', 'Stay smoke-free for 7 days', 'STREAK', 'streak', 'days_smoke_free', 7, 200),
('Month Master', 'Stay smoke-free for 30 days', 'STREAK', 'streak', 'days_smoke_free', 30, 500),
('Craving Crusher', 'Successfully resist 10 cravings', 'BEHAVIOR', 'willpower', 'cravings_resisted', 10, 150),
('Money Mindful', 'Save $50 by not smoking', 'FINANCIAL', 'money', 'money_saved', 50, 100),
('Centurion', 'Save $100 by not smoking', 'FINANCIAL', 'money', 'money_saved', 100, 200);

-- No RLS needed as this is public reference data
```

#### 7. `user_achievements`
Tracks achievements unlocked by users.

```sql
CREATE TABLE public.user_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES public.achievements(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_viewed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

-- Indexes
CREATE INDEX idx_user_achievements_user_id ON public.user_achievements(user_id);

-- RLS Policies
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own achievements" 
  ON public.user_achievements FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own achievements" 
  ON public.user_achievements FOR UPDATE USING (auth.uid() = user_id);
```

#### 8. `user_stats`
Caches key user statistics for quick retrieval and performance optimization.

```sql
CREATE TABLE public.user_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cigarettes_avoided INTEGER NOT NULL DEFAULT 0,
  money_saved INTEGER NOT NULL DEFAULT 0, -- stored in cents
  cravings_resisted INTEGER NOT NULL DEFAULT 0,
  current_streak_days INTEGER NOT NULL DEFAULT 0,
  longest_streak_days INTEGER NOT NULL DEFAULT 0,
  healthiest_day_date DATE,
  last_smoke_date TIMESTAMP WITH TIME ZONE,
  total_smoke_free_days INTEGER NOT NULL DEFAULT 0,
  total_xp INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Indexes
CREATE INDEX idx_user_stats_user_id ON public.user_stats(user_id);

-- RLS Policies
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own stats" 
  ON public.user_stats FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own stats" 
  ON public.user_stats FOR UPDATE USING (auth.uid() = user_id);
```

#### 9. `user_notifications`
Tracks notifications and reminders for each user.

```sql
CREATE TYPE ENUM_NOTIFICATION_TYPE AS ENUM ('ACHIEVEMENT', 'MILESTONE', 'REMINDER', 'TIP', 'STREAK', 'HEALTH', 'SAVINGS');
CREATE TYPE ENUM_NOTIFICATION_STATUS AS ENUM ('PENDING', 'SENT', 'READ', 'DISMISSED');

CREATE TABLE public.user_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  notification_type ENUM_NOTIFICATION_TYPE NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  data JSONB DEFAULT '{}'::JSONB,
  scheduled_for TIMESTAMP WITH TIME ZONE,
  status ENUM_NOTIFICATION_STATUS NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_user_notifications_user_id ON public.user_notifications(user_id);
CREATE INDEX idx_user_notifications_status ON public.user_notifications(status);
CREATE INDEX idx_user_notifications_scheduled_for ON public.user_notifications(scheduled_for);

-- RLS Policies
ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications" 
  ON public.user_notifications FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" 
  ON public.user_notifications FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notifications" 
  ON public.user_notifications FOR DELETE USING (auth.uid() = user_id);
```

#### 10. `daily_tips`
Stores motivational tips and advice.

```sql
CREATE TYPE ENUM_TIP_CATEGORY AS ENUM ('HEALTH', 'MOTIVATION', 'COPING', 'SAVINGS', 'LIFESTYLE', 'GENERAL');

CREATE TABLE public.daily_tips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tip_text TEXT NOT NULL,
  category ENUM_TIP_CATEGORY NOT NULL DEFAULT 'GENERAL',
  source TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed with initial tips
INSERT INTO public.daily_tips (tip_text, category) VALUES
('The first 3 days are the hardest. Stay strong, it gets easier!', 'MOTIVATION'),
('Drink plenty of water to help flush nicotine from your system.', 'HEALTH'),
('When a craving hits, take 10 deep breaths before deciding what to do.', 'COPING'),
('Calculate how much you've saved by not buying cigarettes this week.', 'SAVINGS'),
('Regular exercise can help reduce cravings and withdrawal symptoms.', 'LIFESTYLE');

-- No RLS needed as this is public reference data
```

#### 11. `user_goals`
Stores personalized goals beyond the initial onboarding goals.

```sql
CREATE TYPE ENUM_GOAL_STATUS AS ENUM ('ACTIVE', 'COMPLETED', 'ABANDONED');

CREATE TABLE public.user_goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  target_date DATE,
  status ENUM_GOAL_STATUS NOT NULL DEFAULT 'ACTIVE',
  completion_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_user_goals_user_id ON public.user_goals(user_id);
CREATE INDEX idx_user_goals_status ON public.user_goals(status);

-- RLS Policies
ALTER TABLE public.user_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own goals" 
  ON public.user_goals FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own goals" 
  ON public.user_goals FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own goals" 
  ON public.user_goals FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own goals" 
  ON public.user_goals FOR DELETE USING (auth.uid() = user_id);
```

## Edge Functions

Edge Functions will handle critical background processing and provide API endpoints for the app. These functions will be deployed to Supabase.

### 1. `updateUserStats`
Recalculates and updates user statistics based on logs, cravings, and quit attempts.

```typescript
import { serve } from 'https://deno.land/std@0.131.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';

serve(async (req) => {
  const { userId } = await req.json();
  
  // Create Supabase client
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const supabase = createClient(supabaseUrl, supabaseKey);
  
  try {
    // Get user onboarding data for baseline values
    const { data: onboardingData } = await supabase
      .from('user_onboarding')
      .select('*')
      .eq('user_id', userId)
      .single();
      
    if (!onboardingData) {
      return new Response(
        JSON.stringify({ success: false, error: 'User onboarding data not found' }),
        { headers: { 'Content-Type': 'application/json' }, status: 404 }
      );
    }
    
    // Get smoking logs to calculate cigarettes avoided
    const { data: smokingLogs } = await supabase
      .from('smoking_logs')
      .select('*')
      .eq('user_id', userId)
      .order('timestamp', { ascending: false });
      
    // Find last smoking date
    const lastSmokeDate = smokingLogs && smokingLogs.length > 0 
      ? new Date(smokingLogs[0].timestamp) 
      : null;
      
    // Calculate current streak
    let currentStreakDays = 0;
    if (lastSmokeDate) {
      const now = new Date();
      const diffTime = Math.abs(now.getTime() - lastSmokeDate.getTime());
      currentStreakDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    }
    
    // Calculate money saved based on smoking habits and cigarettes avoided
    const cigsPerDay = onboardingData.cigarettes_per_day_count || 10; // Default to 10 if not specified
    const packPrice = onboardingData.pack_price || 1000; // Default to $10 if not specified
    const cigsPerPack = onboardingData.cigarettes_per_pack || 20; // Default to 20 if not specified
    
    const cigPrice = packPrice / cigsPerPack;
    const cigarettesAvoided = currentStreakDays * cigsPerDay;
    const moneySaved = Math.floor(cigarettesAvoided * cigPrice);
    
    // Get cravings resisted
    const { data: cravings } = await supabase
      .from('cravings')
      .select('*')
      .eq('user_id', userId)
      .eq('outcome', 'RESISTED');
      
    const cravingsResisted = cravings ? cravings.length : 0;
    
    // Update user stats
    const { data: updatedStats, error } = await supabase
      .from('user_stats')
      .upsert({
        user_id: userId,
        cigarettes_avoided: cigarettesAvoided,
        money_saved: moneySaved,
        cravings_resisted: cravingsResisted,
        current_streak_days: currentStreakDays,
        longest_streak_days: Math.max(currentStreakDays, onboardingData.longest_streak_days || 0),
        last_smoke_date: lastSmokeDate,
        updated_at: new Date().toISOString()
      }, { onConflict: 'user_id' })
      .select()
      .single();
      
    if (error) throw error;
    
    return new Response(
      JSON.stringify({ success: true, data: updatedStats }),
      { headers: { 'Content-Type': 'application/json' }, status: 200 }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
```

### 2. `checkHealthRecoveries`
Checks and updates health milestones achieved by users.

```typescript
import { serve } from 'https://deno.land/std@0.131.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';

serve(async (req) => {
  const { userId } = await req.json();
  
  // Create Supabase client
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const supabase = createClient(supabaseUrl, supabaseKey);
  
  try {
    // Get user stats to find current streak and last smoke date
    const { data: userStats } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', userId)
      .single();
      
    if (!userStats || !userStats.last_smoke_date) {
      return new Response(
        JSON.stringify({ success: false, error: 'User stats or last smoke date not found' }),
        { headers: { 'Content-Type': 'application/json' }, status: 404 }
      );
    }
    
    const lastSmokeDate = new Date(userStats.last_smoke_date);
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - lastSmokeDate.getTime());
    const daysSinceLastSmoke = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    
    // Get all health recoveries
    const { data: allRecoveries } = await supabase
      .from('health_recoveries')
      .select('*')
      .order('days_to_achieve', { ascending: true });
      
    if (!allRecoveries) {
      return new Response(
        JSON.stringify({ success: false, error: 'Health recoveries not found' }),
        { headers: { 'Content-Type': 'application/json' }, status: 404 }
      );
    }
    
    // Get user's existing health recoveries
    const { data: existingUserRecoveries } = await supabase
      .from('user_health_recoveries')
      .select('recovery_id')
      .eq('user_id', userId);
      
    const existingRecoveryIds = existingUserRecoveries
      ? existingUserRecoveries.map(r => r.recovery_id)
      : [];
      
    // Find newly achieved recoveries
    const newRecoveries = allRecoveries.filter(recovery => 
      !existingRecoveryIds.includes(recovery.id) && 
      recovery.days_to_achieve <= daysSinceLastSmoke
    );
    
    if (newRecoveries.length === 0) {
      return new Response(
        JSON.stringify({ success: true, message: 'No new health recoveries' }),
        { headers: { 'Content-Type': 'application/json' }, status: 200 }
      );
    }
    
    // Insert new user health recoveries
    const userRecoveriesToInsert = newRecoveries.map(recovery => ({
      user_id: userId,
      recovery_id: recovery.id,
      achieved_at: new Date().toISOString(),
      is_viewed: false
    }));
    
    const { data: insertedRecoveries, error } = await supabase
      .from('user_health_recoveries')
      .insert(userRecoveriesToInsert)
      .select();
      
    if (error) throw error;
    
    // Create notifications for each new recovery
    const notifications = newRecoveries.map(recovery => ({
      user_id: userId,
      notification_type: 'HEALTH',
      title: 'Health Milestone Achieved!',
      message: `${recovery.name}: ${recovery.description}`,
      data: { recovery_id: recovery.id },
      status: 'PENDING'
    }));
    
    await supabase.from('user_notifications').insert(notifications);
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        message: `${insertedRecoveries.length} new health recoveries achieved`,
        data: insertedRecoveries
      }),
      { headers: { 'Content-Type': 'application/json' }, status: 200 }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
```

### 3. `checkAchievements`
Checks and awards any newly completed achievements.

```typescript
import { serve } from 'https://deno.land/std@0.131.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';

serve(async (req) => {
  const { userId } = await req.json();
  
  // Create Supabase client
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const supabase = createClient(supabaseUrl, supabaseKey);
  
  try {
    // Get user stats
    const { data: userStats } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', userId)
      .single();
      
    if (!userStats) {
      return new Response(
        JSON.stringify({ success: false, error: 'User stats not found' }),
        { headers: { 'Content-Type': 'application/json' }, status: 404 }
      );
    }
    
    // Get onboarding status
    const { data: onboarding } = await supabase
      .from('user_onboarding')
      .select('completed')
      .eq('user_id', userId)
      .single();
    
    // Get all achievements
    const { data: allAchievements } = await supabase
      .from('achievements')
      .select('*');
      
    if (!allAchievements) {
      return new Response(
        JSON.stringify({ success: false, error: 'Achievements not found' }),
        { headers: { 'Content-Type': 'application/json' }, status: 404 }
      );
    }
    
    // Get user's existing achievements
    const { data: existingUserAchievements } = await supabase
      .from('user_achievements')
      .select('achievement_id')
      .eq('user_id', userId);
      
    const existingAchievementIds = existingUserAchievements
      ? existingUserAchievements.map(a => a.achievement_id)
      : [];
    
    const newAchievements = [];
    let totalXpEarned = 0;
    
    // Check each achievement to see if conditions are met
    for (const achievement of allAchievements) {
      // Skip if already achieved
      if (existingAchievementIds.includes(achievement.id)) {
        continue;
      }
      
      let isAchieved = false;
      
      // Check different condition types
      switch (achievement.condition_type) {
        case 'onboarding_complete':
          isAchieved = onboarding && onboarding.completed;
          break;
        case 'days_smoke_free':
          isAchieved = userStats.current_streak_days >= achievement.condition_value;
          break;
        case 'cravings_resisted':
          isAchieved = userStats.cravings_resisted >= achievement.condition_value;
          break;
        case 'money_saved':
          isAchieved = userStats.money_saved >= (achievement.condition_value * 100); // Convert dollars to cents
          break;
        // Add more condition types as needed
      }
      
      if (isAchieved) {
        newAchievements.push({
          achievement_id: achievement.id,
          user_id: userId,
          unlocked_at: new Date().toISOString(),
          is_viewed: false
        });
        totalXpEarned += achievement.xp_reward;
      }
    }
    
    if (newAchievements.length === 0) {
      return new Response(
        JSON.stringify({ success: true, message: 'No new achievements unlocked' }),
        { headers: { 'Content-Type': 'application/json' }, status: 200 }
      );
    }
    
    // Insert new user achievements
    const { data: insertedAchievements, error: insertError } = await supabase
      .from('user_achievements')
      .insert(newAchievements)
      .select();
      
    if (insertError) throw insertError;
    
    // Update total XP in user stats
    const { error: updateError } = await supabase
      .from('user_stats')
      .update({ 
        total_xp: userStats.total_xp + totalXpEarned,
        updated_at: new Date().toISOString()
      })
      .eq('user_id', userId);
      
    if (updateError) throw updateError;
    
    // Create notifications for each achievement
    const achievementDetails = allAchievements.filter(a => 
      newAchievements.some(na => na.achievement_id === a.id)
    );
    
    const notifications = achievementDetails.map(achievement => ({
      user_id: userId,
      notification_type: 'ACHIEVEMENT',
      title: 'Achievement Unlocked!',
      message: `${achievement.name}: ${achievement.description}`,
      data: { 
        achievement_id: achievement.id,
        xp_reward: achievement.xp_reward
      },
      status: 'PENDING'
    }));
    
    await supabase.from('user_notifications').insert(notifications);
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        message: `${insertedAchievements.length} new achievements unlocked`,
        data: {
          achievements: insertedAchievements,
          xp_earned: totalXpEarned
        }
      }),
      { headers: { 'Content-Type': 'application/json' }, status: 200 }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
```

### 4. `dailyNotificationsScheduler`
Schedules daily notifications, tips, and reminders based on user preferences.

```typescript
import { serve } from 'https://deno.land/std@0.131.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';

serve(async (req) => {
  // Create Supabase client
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const supabase = createClient(supabaseUrl, supabaseKey);
  
  try {
    // Get all active users with onboarding completed
    const { data: activeUsers, error: userError } = await supabase
      .from('user_onboarding')
      .select('user_id, help_preferences')
      .eq('completed', true);
      
    if (userError) throw userError;
    
    if (!activeUsers || activeUsers.length === 0) {
      return new Response(
        JSON.stringify({ success: true, message: 'No active users found' }),
        { headers: { 'Content-Type': 'application/json' }, status: 200 }
      );
    }
    
    // Get random daily tip
    const { data: tipData, error: tipError } = await supabase
      .from('daily_tips')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(20);
      
    if (tipError) throw tipError;
    
    if (!tipData || tipData.length === 0) {
      return new Response(
        JSON.stringify({ success: false, error: 'No tips found' }),
        { headers: { 'Content-Type': 'application/json' }, status: 404 }
      );
    }
    
    const randomTip = tipData[Math.floor(Math.random() * tipData.length)];
    
    // Schedule notifications for each user
    const notifications = [];
    const now = new Date();
    
    for (const user of activeUsers) {
      // Only schedule tips for users who want them
      if (user.help_preferences && user.help_preferences.includes('Daily tips')) {
        // Schedule for next day
        const tomorrow = new Date(now);
        tomorrow.setDate(tomorrow.getDate() + 1);
        tomorrow.setHours(9, 0, 0, 0); // 9 AM
        
        notifications.push({
          user_id: user.user_id,
          notification_type: 'TIP',
          title: 'Daily Tip',
          message: randomTip.tip_text,
          data: { tip_id: randomTip.id, category: randomTip.category },
          scheduled_for: tomorrow.toISOString(),
          status: 'PENDING'
        });
      }
    }
    
    if (notifications.length === 0) {
      return new Response(
        JSON.stringify({ success: true, message: 'No notifications to schedule' }),
        { headers: { 'Content-Type': 'application/json' }, status: 200 }
      );
    }
    
    // Insert notifications
    const { data: insertedNotifications, error: insertError } = await supabase
      .from('user_notifications')
      .insert(notifications)
      .select();
      
    if (insertError) throw insertError;
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        message: `${insertedNotifications.length} notifications scheduled`,
        data: insertedNotifications
      }),
      { headers: { 'Content-Type': 'application/json' }, status: 200 }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
```

### 5. `sendPushNotifications`
Sends push notifications to users' devices.

```typescript
import { serve } from 'https://deno.land/std@0.131.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';

serve(async (req) => {
  // Create Supabase client
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const supabase = createClient(supabaseUrl, supabaseKey);
  
  try {
    const now = new Date();
    
    // Get all pending notifications scheduled for now or earlier
    const { data: pendingNotifications, error: notificationError } = await supabase
      .from('user_notifications')
      .select('*')
      .eq('status', 'PENDING')
      .lte('scheduled_for', now.toISOString())
      .order('scheduled_for', { ascending: true });
      
    if (notificationError) throw notificationError;
    
    if (!pendingNotifications || pendingNotifications.length === 0) {
      return new Response(
        JSON.stringify({ success: true, message: 'No pending notifications to send' }),
        { headers: { 'Content-Type': 'application/json' }, status: 200 }
      );
    }
    
    // In a real implementation, here you would:
    // 1. Retrieve the user's device tokens from a device_tokens table
    // 2. Send pushes using FCM, APNS, or a service like OneSignal
    // 3. Update notification status based on delivery result
    
    // For this plan, we'll simulate successful sending by marking all as sent
    const notificationIds = pendingNotifications.map(notification => notification.id);
    
    const { error: updateError } = await supabase
      .from('user_notifications')
      .update({ 
        status: 'SENT',
        updated_at: now.toISOString()
      })
      .in('id', notificationIds);
      
    if (updateError) throw updateError;
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        message: `${notificationIds.length} notifications sent`,
        data: { notification_count: notificationIds.length }
      }),
      { headers: { 'Content-Type': 'application/json' }, status: 200 }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
```

## Core Features

Based on the database schema and edge functions, the application will implement the following core features:

### 1. Smoking Tracker
- Log cigarettes smoked with contextual information (location, mood, triggers)
- Track smoking patterns over time
- Visualize smoking frequency through interactive charts
- Calculate cost of smoking habits

### 2. Quitting Journey
- Transition from onboarding goals to active quit attempts
- Track progress toward reduction or complete cessation
- Celebrate milestones and streaks
- Recover from relapses with encouragement

### 3. Craving Management
- Log cravings when they occur
- Select coping strategies used
- Track craving patterns to identify triggers
- View historical craving data to recognize patterns

### 4. Health Recovery Timeline
- Visual timeline of health recovery milestones
- Celebrate each health recovery achievement
- Educational content about each health benefit
- Share progress on social media

### 5. Achievements System
- Unlock achievements for reaching goals
- Earn XP for positive behaviors
- Track progress toward upcoming achievements
- Showcase unlocked achievements profile

### 6. Financial Savings Calculator
- Calculate money saved by not smoking
- Visualize savings over time
- Set financial goals for saved money
- Compare savings to the cost of desired items/experiences

### 7. Community Support
- Share milestones and achievements
- View global community statistics
- Anonymized leaderboards
- Success stories from former smokers

### 8. Statistics Dashboard
- Cigarettes avoided
- Current and longest streak
- Money saved
- Health improvements
- Overall progress visualization

## User Journey

The typical user journey through the Nicotina.AI app:

1. **Onboarding**
   - Complete the existing onboarding questionnaire
   - Set initial goals and timeline
   - Identify challenges and smoking patterns

2. **Daily Tracking**
   - Log cigarettes when smoked
   - Record cravings and how they were handled
   - Receive daily tips and encouragement

3. **Progress Monitoring**
   - View personalized dashboard of stats
   - Track streak of smoke-free days
   - Monitor health recoveries unlocked
   - Calculate financial savings

4. **Milestone Achievement**
   - Receive notifications for health milestones
   - Unlock achievements for reaching goals
   - Celebrate success through badges and XP

5. **Challenge Management**
   - Identify and track smoking triggers
   - Develop personalized coping strategies
   - Get support during difficult periods

6. **Relapse Recovery** (if applicable)
   - Log relapses without judgment
   - Learn from circumstances that led to relapse
   - Restart quit attempt with adjusted strategies

7. **Long-term Success**
   - Graduate to maintenance mode after extended quit period
   - Occasional check-ins to prevent relapse
   - Contribute to community (optional)

## Implementation Phases

### Phase 1: Database Schema and Core Infrastructure
- Implement database tables and migrations
- Set up edge functions infrastructure
- Establish basic API endpoints
- Create Flutter models and repositories

### Phase 2: Smoking and Craving Tracking
- Implement logging of cigarettes and cravings
- Build basic dashboard for statistics
- Create initial stats calculations
- Implement streak tracking

### Phase 3: Achievements and Health Recoveries
- Implement achievement system
- Add health recovery milestones
- Create notifications for accomplishments
- Build UI for showcasing progress

### Phase 4: Enhanced Analytics and Insights
- Implement detailed statistics views
- Add pattern recognition for triggers
- Create visualizations for all key metrics
- Develop insights and recommendations

### Phase 5: Community and Social Features
- Add anonymized community statistics
- Implement leaderboards
- Create sharing functionality
- Add success stories

### Phase 6: Personalization and Advanced Features
- Develop personalized recommendations
- Add advanced coping strategies
- Implement machine learning for trigger prediction
- Personalize notification timing and content

## Technical Considerations

### State Management
- Use Riverpod for state management throughout the app
- Create providers for each major feature (smoking, cravings, achievements, etc.)
- Implement repository pattern for data access

### Offline Support
- Implement local storage for all tracking features
- Sync with Supabase when online using queue system
- Maintain app functionality even without internet connection

### Notifications
- Use Firebase Cloud Messaging for cross-platform push notifications
- Schedule local notifications for reminders when app is in background
- Implement notification preferences with fine-grained control

### Performance
- Use caching strategies for frequently accessed data
- Implement pagination for historical data
- Optimize database queries with appropriate indexes
- Use edge functions for intensive calculations

### Security
- Implement Row Level Security for all tables
- Ensure sensitive data is properly secured
- Use service role only in trusted edge functions
- Audit all data access paths

## Testing Plan

### Unit Tests
- Test all models and converters
- Verify business logic in repositories
- Test edge function logic

### Widget Tests
- Test UI components and screens
- Verify user flows and interactions
- Test error handling and edge cases

### Integration Tests
- Test end-to-end flows with actual database
- Verify sync between online and offline modes
- Test notifications and background processes

### User Acceptance Testing
- Test with real users in beta phase
- Collect feedback on usability and features
- Iterate based on user feedback

This comprehensive plan provides a roadmap for building a fully functional Nicotina.AI application. The implementation approach focuses on creating a supportive, data-driven experience to help users reduce or quit smoking, with features that engage users daily and provide meaningful insights into their progress.