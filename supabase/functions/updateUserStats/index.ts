import { serve } from "https://deno.land/std@0.131.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.2.0";

interface SmokingLog {
  id: string;
  user_id: string;
  timestamp: string;
  amount: number;
}

interface Craving {
  id: string;
  user_id: string;
  timestamp: string;
  trigger?: string;
  outcome: string | number; // Support both string enum and numeric value
}

interface UserStats {
  id?: string;
  user_id: string;
  cigarettes_avoided: number;
  money_saved: number;
  cravings_resisted: number;
  current_streak_days: number;
  longest_streak_days: number;
  last_smoke_date?: string;
  cigarettes_smoked?: number;
  smoking_records_count?: number;
  total_smoke_free_days?: number;
  cigarettes_per_day?: number;
  cigarettes_per_pack?: number;
  pack_price?: number;
  product_type?: number;
  currency_code?: string;
  // Minutes gained fields
  minutes_gained_today?: number;
  total_minutes_gained?: number;
}

serve(async (req) => {
  try {
    const { userId } = await req.json();

    if (!userId) {
      return new Response(
        JSON.stringify({ error: "userId is required" }),
        { headers: { "Content-Type": "application/json" }, status: 400 }
      );
    }

    console.log(`Atualizando estatísticas para o usuário: ${userId}`);

    // Create Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Get smoking logs
    const { data: smokingLogs, error: smokingLogsError } = await supabase
      .from("smoking_logs")
      .select("*")
      .eq("user_id", userId)
      .order("timestamp", { ascending: false });

    if (smokingLogsError) {
      console.error("Error fetching smoking logs:", smokingLogsError);
      return new Response(
        JSON.stringify({ error: "Failed to fetch smoking logs", details: smokingLogsError }),
        { headers: { "Content-Type": "application/json" }, status: 500 }
      );
    }

    // Get all cravings first, we'll filter them in memory to support both string and integer values
    const { data: allCravings, error: cravingsError } = await supabase
      .from("cravings")
      .select("*")
      .eq("user_id", userId);

    if (cravingsError) {
      console.error("Error fetching cravings:", cravingsError);
      return new Response(
        JSON.stringify({ error: "Failed to fetch cravings", details: cravingsError }),
        { headers: { "Content-Type": "application/json" }, status: 500 }
      );
    }

    // Filter resisted cravings in memory - support both string "RESISTED" and integer 0
    const cravings = allCravings.filter(craving => 
      craving.outcome === "RESISTED" || 
      craving.outcome === 0 || 
      (typeof craving.outcome === 'string' && craving.outcome.toUpperCase() === 'RESISTED')
    );

    // Get user's onboarding data for cigarette prices
    const { data: onboardingData, error: onboardingError } = await supabase
      .from("onboarding_data")
      .select("data")
      .eq("user_id", userId)
      .maybeSingle();

    // Get existing user stats
    const { data: existingStats, error: statsError } = await supabase
      .from("user_stats")
      .select("*")
      .eq("user_id", userId)
      .maybeSingle();

    let cigarettesPerDay = 20; // Default value
    let cigarettesPerPack = 20; // Default value
    let packPrice = 1000; // Default value in cents (R$10,00)
    let productType = 0; // Default value (cigarette)
    let currencyCode = "BRL"; // Default value
    
    if (!onboardingError && onboardingData && onboardingData.data) {
      // Extract pricing info from onboarding data
      const data = onboardingData.data;
      cigarettesPerDay = data.cigarettesPerDay || cigarettesPerDay;
      cigarettesPerPack = data.cigarettesPerPack || cigarettesPerPack;
      packPrice = data.packPrice || packPrice;
      productType = data.productType || productType;
      currencyCode = data.currencyCode || currencyCode;
    }

    // Calculate price per cigarette
    const pricePerCigarette = packPrice / cigarettesPerPack;

    // Calculate stats
    let lastSmokeDate: Date | null = null;
    let cigarettesSmoked = 0;
    let smokingRecordsCount = 0;

    if (smokingLogs && smokingLogs.length > 0) {
      lastSmokeDate = new Date(smokingLogs[0].timestamp);
      smokingRecordsCount = smokingLogs.length;
      cigarettesSmoked = smokingLogs.reduce((total, log) => total + log.amount, 0);
    }

    // Count resisted cravings
    const cravingsResisted = cravings ? cravings.length : 0;

    // Calculate streak - days since last smoke
    let currentStreakDays = 0;
    let longestStreakDays = 0;

    if (lastSmokeDate) {
      const now = new Date();
      const lastSmokeDay = new Date(lastSmokeDate.getFullYear(), lastSmokeDate.getMonth(), lastSmokeDate.getDate());
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      
      // Calculate days difference
      const diffTime = today.getTime() - lastSmokeDay.getTime();
      currentStreakDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    }

    // Calculate total smoke-free days (simplified - counts all days since first record)
    const totalSmokeFreedays = currentStreakDays;

    // Update longest streak if current streak is longer
    if (existingStats && existingStats.longest_streak_days) {
      longestStreakDays = Math.max(existingStats.longest_streak_days, currentStreakDays);
    } else {
      longestStreakDays = currentStreakDays;
    }

    // IMPROVED: Calculate cigarettes avoided based on days without smoking
    let cigarettesAvoided = 0;
    
    if (lastSmokeDate) {
      // Calculate cigarettes avoided based on days without smoking * cigarettes per day
      cigarettesAvoided = currentStreakDays * cigarettesPerDay;
      console.log(`📊 Calculated cigarettes avoided: ${cigarettesAvoided} (${currentStreakDays} days * ${cigarettesPerDay} cigarettes/day)`);
    } else {
      // If no last smoke date, use cravings resisted as fallback (capped at 5 to avoid inflation)
      cigarettesAvoided = Math.min(cravingsResisted, 5);
      console.log(`⚠️ No last smoke date, using cravings resisted as fallback: ${cigarettesAvoided}`);
    }

    // IMPROVED: Calculate money saved based on cigarettes avoided
    const moneySaved = Math.round(cigarettesAvoided * pricePerCigarette);
    console.log(`💰 Calculated money saved: ${moneySaved} cents (${cigarettesAvoided} cigarettes * ${pricePerCigarette} cents/cigarette)`);

    // Calculate minutes gained
    const MINUTES_PER_CIGARETTE = 6;
    const totalMinutesGained = cigarettesAvoided * MINUTES_PER_CIGARETTE;

    // Calculate minutes gained today based on cigarettes avoided today
    // Filter today's cravings - support both string "RESISTED" and integer 0
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const todayCravings = allCravings ? allCravings.filter(craving => {
      const cravingDate = new Date(craving.timestamp);
      const isToday = cravingDate >= today;
      const isResisted = 
        craving.outcome === "RESISTED" || 
        craving.outcome === 0 || 
        (typeof craving.outcome === 'string' && craving.outcome.toUpperCase() === 'RESISTED');
      return isToday && isResisted;
    }) : [];
    
    const todayCravingsCount = todayCravings.length;
    
    // Se não houver cravings hoje, estimamos com base na média diária
    const minutesGainedToday = todayCravingsCount > 0 
      ? todayCravingsCount * MINUTES_PER_CIGARETTE
      : cigarettesPerDay > 0 
        ? Math.floor(MINUTES_PER_CIGARETTE * cigarettesPerDay / 24)
        : 0;
    
    const stats: UserStats = {
      user_id: userId,
      cigarettes_avoided: cigarettesAvoided,
      money_saved: moneySaved,
      cravings_resisted: cravingsResisted,
      current_streak_days: currentStreakDays,
      longest_streak_days: longestStreakDays,
      total_smoke_free_days: totalSmokeFreedays,
      cigarettes_smoked: cigarettesSmoked,
      smoking_records_count: smokingRecordsCount,
      cigarettes_per_day: cigarettesPerDay,
      cigarettes_per_pack: cigarettesPerPack,
      pack_price: packPrice,
      product_type: productType,
      currency_code: currencyCode,
      minutes_gained_today: minutesGainedToday,
      total_minutes_gained: totalMinutesGained,
    };

    if (lastSmokeDate) {
      stats.last_smoke_date = lastSmokeDate.toISOString();
    }

    let result;
    if (existingStats) {
      // Update existing stats
      const { data: updatedStats, error: updateError } = await supabase
        .from("user_stats")
        .update(stats)
        .eq("id", existingStats.id)
        .select()
        .single();

      if (updateError) {
        console.error("Error updating user stats:", updateError);
        return new Response(
          JSON.stringify({ error: "Failed to update user stats", details: updateError }),
          { headers: { "Content-Type": "application/json" }, status: 500 }
        );
      }

      result = updatedStats;
    } else {
      // Insert new stats
      const { data: newStats, error: insertError } = await supabase
        .from("user_stats")
        .insert(stats)
        .select()
        .single();

      if (insertError) {
        console.error("Error inserting user stats:", insertError);
        return new Response(
          JSON.stringify({ error: "Failed to insert user stats", details: insertError }),
          { headers: { "Content-Type": "application/json" }, status: 500 }
        );
      }

      result = newStats;
    }

    console.log("Estatísticas do usuário atualizadas com sucesso");
    console.log("Minutes gained today:", minutesGainedToday);
    console.log("Total minutes gained:", totalMinutesGained);
    console.log("Money saved (cents):", moneySaved);

    return new Response(
      JSON.stringify({
        success: true,
        message: "User stats updated successfully",
        data: result
      }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Unexpected error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { "Content-Type": "application/json" }, status: 500 }
    );
  }
});