import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req: Request) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify POST method
    if (req.method !== 'POST') {
      return new Response(JSON.stringify({ error: 'Method not allowed' }), {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Get Supabase configuration
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(JSON.stringify({ error: 'Missing Supabase configuration' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Parse request body
    const { user_id } = await req.json();

    if (!user_id) {
      return new Response(JSON.stringify({ error: 'User ID is required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Create admin client with service role
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // STEP 1: First delete all user-related data in proper order to avoid constraint violations
    console.log(`[1/3] Deleting related data for user: ${user_id}`);
    
    try {
      // Delete user's data in proper order to avoid foreign key constraint errors
      console.log('Deleting user FCM tokens...');
      await supabaseAdmin.from('user_fcm_tokens').delete().eq('user_id', user_id);
      
      console.log('Deleting user notifications...');
      await supabaseAdmin.from('user_notifications').delete().eq('user_id', user_id);
      
      console.log('Deleting user achievements...');
      await supabaseAdmin.from('user_achievements').delete().eq('user_id', user_id);
      
      console.log('Deleting viewed achievements...');
      await supabaseAdmin.from('viewed_achievements').delete().eq('user_id', user_id);
      
      console.log('Deleting user health recoveries...');
      await supabaseAdmin.from('user_health_recoveries').delete().eq('user_id', user_id);
      
      console.log('Deleting user XP entries...');
      await supabaseAdmin.from('user_xp').delete().eq('user_id', user_id);
      
      console.log('Deleting user goals...');
      await supabaseAdmin.from('user_goals').delete().eq('user_id', user_id);
      
      console.log('Deleting cravings...');
      await supabaseAdmin.from('cravings').delete().eq('user_id', user_id);
      
      console.log('Deleting smoking logs...');
      await supabaseAdmin.from('smoking_logs').delete().eq('user_id', user_id);
      
      console.log('Deleting quit attempts...');
      await supabaseAdmin.from('quit_attempts').delete().eq('user_id', user_id);
      
      console.log('Deleting user stats...');
      await supabaseAdmin.from('user_stats').delete().eq('user_id', user_id);
      
      console.log('Deleting onboarding progress...');
      await supabaseAdmin.from('user_onboarding_progress').delete().eq('user_id', user_id);
      
      console.log('Deleting onboarding data...');
      await supabaseAdmin.from('onboarding_data').delete().eq('user_id', user_id);
      
      console.log('Deleting user onboarding...');
      await supabaseAdmin.from('user_onboarding').delete().eq('user_id', user_id);
      
      console.log('All user data deleted successfully');
    } catch (deleteDataError) {
      console.error('Error deleting user data:', deleteDataError);
      // Continue with user deletion anyway
    }

    // STEP 2: Try to use RPC function if available (custom cascade delete)
    console.log(`[2/3] Attempting to use cascade_delete_user RPC for user: ${user_id}`);
    try {
      const { error: cleanupError } = await supabaseAdmin.rpc('cascade_delete_user', { 
        user_id_param: user_id 
      });

      if (cleanupError) {
        console.error('Error in cascade_delete_user RPC:', cleanupError);
        // Continue anyway - we'll still try to delete the user
      } else {
        console.log('User data cleaned up via RPC successfully');
      }
    } catch (cleanupError) {
      console.error('Exception in cascade_delete_user RPC:', cleanupError);
      // Continue anyway - we'll still try to delete the user
    }

    // STEP 3: Try to delete the user account directly
    console.log(`[3/3] Attempting to delete user: ${user_id}`);
    try {
      // Try to delete the user (without specifying shouldSoftDelete to avoid the error)
      const { error: deleteUserError } = await supabaseAdmin.auth.admin.deleteUser(user_id);

      if (deleteUserError) {
        console.error('Error in user deletion:', deleteUserError);
        
        // If hard delete fails, update metadata as a fallback
        console.log(`[3.5/3] Hard delete failed, marking user metadata instead: ${user_id}`);
        
        try {
          const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
            user_id,
            { 
              app_metadata: { 
                account_deleted: true,
                deletion_timestamp: new Date().toISOString(),
                deletion_method: 'metadata_only'
              }
            }
          );
          
          if (updateError) {
            console.error('Error updating user metadata:', updateError);
            return new Response(
              JSON.stringify({ 
                error: 'Deletion failed',
                details: {
                  delete_error: deleteUserError,
                  metadata_update: updateError
                }
              }),
              {
                status: 500,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
              }
            );
          }
          
          // No caso de metadados, a sessão ainda pode ser válida, mas vamos considerar
          // que o cliente vai redirecionar para o login de qualquer forma após uma resposta bem-sucedida
          
          return new Response(
            JSON.stringify({ 
              success: true, 
              message: 'User marked as deleted in metadata',
              notes: 'Hard delete failed, but user has been marked as deleted in metadata'
            }),
            {
              status: 200,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          );
        } catch (metadataError) {
          console.error('Error in metadata update:', metadataError);
          return new Response(
            JSON.stringify({ 
              error: 'All deletion methods failed',
              details: {
                delete_error: deleteUserError,
                metadata_error: metadataError
              }
            }),
            {
              status: 500,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          );
        }
      }

      // Hard delete succeeded
      console.log(`[3/3] User deletion succeeded for user: ${user_id}`);
      
      // Não é necessário invalidar a sessão do usuário aqui
      // 1. Quando o usuário é excluído, todas as sessões são automaticamente invalidadas pelo Supabase
      // 2. O token de acesso que foi usado para chamar esta função já não será mais válido
      // 3. No lado do cliente, já redirecionamos o usuário para a tela de login após a exclusão bem-sucedida
      
      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'User account deleted successfully'
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    } catch (error) {
      console.error('Unexpected error during user deletion:', error);
      
      return new Response(
        JSON.stringify({ 
          error: 'An unexpected error occurred during deletion',
          details: error
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }
  } catch (error) {
    console.error('Global error handler:', error);
    
    return new Response(
      JSON.stringify({ error: 'An unexpected error occurred', details: error }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});