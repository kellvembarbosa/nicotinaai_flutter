import { serve } from "https://deno.land/std@0.131.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.2.0";

interface FeedbackRequest {
  is_satisfied: boolean;
  rating?: string;
  feedback_text?: string;
  feedback_category?: string;
  has_reviewed_app?: boolean;
}

serve(async (req) => {
  try {
    // Parse the request body
    const feedbackData: FeedbackRequest = await req.json();
    
    // Create a Supabase client with the service role key
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    
    // Get the user JWT token from authorization header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "No authorization header provided" }),
        { headers: { "Content-Type": "application/json" }, status: 401 }
      );
    }
    
    // Extract the JWT token
    const token = authHeader.replace('Bearer ', '');
    
    // Verify the JWT token and get the user
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired authentication token" }),
        { headers: { "Content-Type": "application/json" }, status: 401 }
      );
    }
    
    // Log the function call
    await supabase.from("function_call_log").insert({
      function_name: "app-feedback",
      user_id: user.id,
      params: { 
        is_satisfied: feedbackData.is_satisfied,
        has_rating: !!feedbackData.rating,
        has_text: !!feedbackData.feedback_text,
        category: feedbackData.feedback_category || null,
      }
    });
    
    // Check required fields
    if (feedbackData.is_satisfied === undefined) {
      return new Response(
        JSON.stringify({ error: "is_satisfied field is required" }),
        { headers: { "Content-Type": "application/json" }, status: 400 }
      );
    }
    
    // Check for existing feedback from this user
    const { data: existingFeedback, error: checkError } = await supabase
      .from("user_feedback")
      .select()
      .eq("user_id", user.id)
      .limit(1)
      .maybeSingle();
    
    if (checkError) {
      return new Response(
        JSON.stringify({ error: "Error checking existing feedback" }),
        { headers: { "Content-Type": "application/json" }, status: 500 }
      );
    }
    
    // Prepare feedback data
    const feedbackRecord = {
      user_id: user.id,
      is_satisfied: feedbackData.is_satisfied,
      rating: feedbackData.rating || null,
      feedback_text: feedbackData.feedback_text || null,
      feedback_category: feedbackData.feedback_category || null,
      has_reviewed_app: feedbackData.has_reviewed_app || false,
    };
    
    let result;
    
    // Insert or update feedback
    if (existingFeedback) {
      // Update existing feedback
      const { data, error: updateError } = await supabase
        .from("user_feedback")
        .update(feedbackRecord)
        .eq("id", existingFeedback.id)
        .select()
        .single();
      
      if (updateError) {
        return new Response(
          JSON.stringify({ error: "Failed to update feedback", details: updateError }),
          { headers: { "Content-Type": "application/json" }, status: 500 }
        );
      }
      
      result = data;
    } else {
      // Insert new feedback
      const { data, error: insertError } = await supabase
        .from("user_feedback")
        .insert(feedbackRecord)
        .select()
        .single();
      
      if (insertError) {
        return new Response(
          JSON.stringify({ error: "Failed to submit feedback", details: insertError }),
          { headers: { "Content-Type": "application/json" }, status: 500 }
        );
      }
      
      result = data;
    }
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        message: "Feedback submitted successfully",
        data: result
      }),
      { headers: { "Content-Type": "application/json" } }
    );
    
  } catch (error) {
    return new Response(
      JSON.stringify({ error: `Internal server error: ${error.message}` }),
      { headers: { "Content-Type": "application/json" }, status: 500 }
    );
  }
});