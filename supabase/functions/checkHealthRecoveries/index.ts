import { serve } from "https://deno.land/std@0.131.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.2.0";

interface HealthRecovery {
  id: string;
  name: string;
  description: string;
  days_to_achieve: number;
  xp_reward: number;
}

serve(async (req) => {
  try {
    const { userId, updateAchievements = true } = await req.json();

    if (!userId) {
      return new Response(
        JSON.stringify({ error: "userId is required" }),
        { headers: { "Content-Type": "application/json" }, status: 400 }
      );
    }
    
    // Log whether achievements will be updated
    console.log(`Checking health recoveries for userId: ${userId}, updateAchievements: ${updateAchievements}`);

    // Create Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Get user's last smoke date from user_stats
    const { data: userStats, error: statsError } = await supabase
      .from("user_stats")
      .select("last_smoke_date")
      .eq("user_id", userId)
      .single();

    if (statsError || !userStats || !userStats.last_smoke_date) {
      console.log(`No user stats or last smoke date found for user ${userId}, initializing...`);

      // Verificar se houve uma tentativa de registrar craving
      const { data: cravings, error: cravingsError } = await supabase
        .from("cravings")
        .select("*")
        .eq("user_id", userId)
        .limit(1);

      if (!cravingsError && cravings && cravings.length > 0) {
        // Há registros de cravings, podemos inicializar user_stats com a data atual
        const now = new Date();

        // Criar registro em user_stats com a data atual como last_smoke_date
        const { data: newStats, error: insertError } = await supabase
          .from("user_stats")
          .upsert({
            user_id: userId,
            last_smoke_date: now.toISOString(),
            current_streak_days: 0,
            money_saved: 0,
            cigarettes_avoided: 0,
            cravings_resisted: 0
          })
          .select()
          .single();

        if (insertError) {
          return new Response(
            JSON.stringify({
              success: false,
              error: "Failed to initialize user stats",
              details: insertError
            }),
            { headers: { "Content-Type": "application/json" }, status: 500 }
          );
        }

        // Usar os stats recém-criados
        userStats = newStats;
        console.log(`Initialized user_stats for user ${userId} with current date as last_smoke_date`);
      } else {
        // Não há cravings ou smoking logs, retornar erro
        return new Response(
          JSON.stringify({
            success: false,
            error: "User has no smoking history or cravings to establish a baseline",
            details: cravingsError || "No craving or smoking data available"
          }),
          { headers: { "Content-Type": "application/json" }, status: 404 }
        );
      }
    }

    const lastSmokeDate = new Date(userStats.last_smoke_date);
    const now = new Date();
    const daysSinceLastSmoke = Math.floor((now.getTime() - lastSmokeDate.getTime()) / (1000 * 60 * 60 * 24));

    // Get all health recoveries
    const { data: healthRecoveries, error: recoveriesError } = await supabase
      .from("health_recoveries")
      .select("*")
      .order("days_to_achieve", { ascending: true });

    if (recoveriesError || !healthRecoveries) {
      return new Response(
        JSON.stringify({ 
          error: "Unable to fetch health recoveries",
          details: recoveriesError
        }),
        { headers: { "Content-Type": "application/json" }, status: 500 }
      );
    }
    
    // Check if this is a newly registered smoking event
    // This would be indicated by the lastSmokeDate being very recent (within the last hour)
    const smokeEventTimeDiff = now.getTime() - lastSmokeDate.getTime();
    const isRecentSmokeEvent = smokeEventTimeDiff < (60 * 60 * 1000); // Within 1 hour
    
    // If a new smoke was registered recently, reset any health recoveries
    if (isRecentSmokeEvent && daysSinceLastSmoke === 0) {
      console.log(`Recent smoke event detected for user ${userId}, checking for health recoveries to reset...`);
      
      // Get user's existing health recoveries
      const { data: existingRecoveries, error: userRecoveriesResetError } = await supabase
        .from("user_health_recoveries")
        .select("id, recovery_id")
        .eq("user_id", userId);
        
      if (!userRecoveriesResetError && existingRecoveries && existingRecoveries.length > 0) {
        // Reset all health recoveries for this user
        const { error: deleteError } = await supabase
          .from("user_health_recoveries")
          .delete()
          .eq("user_id", userId);
          
        if (deleteError) {
          console.error(`Failed to reset health recoveries: ${deleteError.message}`);
        } else {
          console.log(`Reset ${existingRecoveries.length} health recoveries for user ${userId} due to new smoking event`);
          
          // Create a notification about the reset if updateAchievements is true
          if (updateAchievements) {
            try {
              await supabase.from("notifications").insert({
                user_id: userId,
                title: "Health Recovery Reset",
                message: "Your health recovery progress has been reset due to a new smoking event.",
                type: "HEALTH_RECOVERY_RESET",
                reference_id: null,
                is_read: false
              });
              console.log(`Created health recovery reset notification for user ${userId}`);
            } catch (error) {
              console.error("Failed to create notification:", error);
            }
          }
        }
      } else {
        console.log(`No health recoveries to reset for user ${userId}`);
      }
    }

    // Get user's existing health recoveries
    const { data: userRecoveries, error: userRecoveriesError } = await supabase
      .from("user_health_recoveries")
      .select("recovery_id")
      .eq("user_id", userId);

    if (userRecoveriesError) {
      return new Response(
        JSON.stringify({ 
          error: "Unable to fetch user health recoveries",
          details: userRecoveriesError
        }),
        { headers: { "Content-Type": "application/json" }, status: 500 }
      );
    }

    const achievedRecoveryIds = new Set((userRecoveries || []).map(r => r.recovery_id));
    const newAchievements = [];

    // Check for new achievements
    for (const recovery of healthRecoveries) {
      if (daysSinceLastSmoke >= recovery.days_to_achieve && !achievedRecoveryIds.has(recovery.id)) {
        // Add user health recovery
        const { data: newRecovery, error: insertError } = await supabase
          .from("user_health_recoveries")
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
            description: recovery.description,
            xp_reward: recovery.xp_reward,
            days_to_achieve: recovery.days_to_achieve
          });

          // Award XP to user if the function exists and updateAchievements is true
          if (updateAchievements) {
            try {
              await supabase.rpc("add_user_xp", {
                p_user_id: userId,
                p_amount: recovery.xp_reward,
                p_source: "HEALTH_RECOVERY",
                p_reference_id: recovery.id
              });
              console.log(`Awarded ${recovery.xp_reward} XP for recovery ${recovery.name}`);
            } catch (error) {
              // If XP function doesn't exist, log but continue
              console.error("Failed to award XP:", error);
            }
          } else {
            console.log(`Skipping XP award for recovery ${recovery.name} (updateAchievements is false)`);
          }

          // Create notification if the table exists and updateAchievements is true
          if (updateAchievements) {
            try {
              await supabase.from("notifications").insert({
                user_id: userId,
                title: `Health Recovery: ${recovery.name}`,
                message: `Your ${recovery.name.toLowerCase()} has improved after ${recovery.days_to_achieve} days without smoking.`,
                type: "HEALTH_RECOVERY",
                reference_id: newRecovery.id,
                is_read: false
              });
              console.log(`Created notification for recovery ${recovery.name}`);
            } catch (error) {
              // If notifications table doesn't exist, log but continue
              console.error("Failed to create notification:", error);
            }
          } else {
            console.log(`Skipping notification for recovery ${recovery.name} (updateAchievements is false)`);
          }
        }
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        days_smoke_free: daysSinceLastSmoke,
        new_achievements: newAchievements,
        total_achievements: userRecoveries ? userRecoveries.length + newAchievements.length : newAchievements.length
      }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { "Content-Type": "application/json" }, status: 500 }
    );
  }
});