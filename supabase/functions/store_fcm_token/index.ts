// Edge Function para armazenar tokens FCM, contornando problemas de RLS
import { serve } from 'https://deno.land/std@0.131.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'

interface RequestPayload {
  token: string;
  user_id: string;
  device_info?: Record<string, any>;
}

serve(async (req) => {
  // Obter as variáveis de ambiente necessárias
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

  // Verificar se as variáveis de ambiente estão configuradas
  if (!supabaseUrl || !supabaseServiceKey) {
    return new Response(
      JSON.stringify({ 
        error: 'Missing environment variables',
        success: false
      }),
      { 
        headers: { 'Content-Type': 'application/json' },
        status: 500
      }
    );
  }

  // Criar um cliente Supabase com service role key (acesso admin)
  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  try {
    // Verificar o método da requisição
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ 
          error: 'Method not allowed',
          success: false
        }),
        { 
          headers: { 'Content-Type': 'application/json' },
          status: 405
        }
      );
    }

    // Verificar e analisar o corpo da requisição
    const payload: RequestPayload = await req.json();
    const { token, user_id, device_info = {} } = payload;

    if (!token || !user_id) {
      return new Response(
        JSON.stringify({ 
          error: 'Missing required fields',
          success: false
        }),
        { 
          headers: { 'Content-Type': 'application/json' },
          status: 400
        }
      );
    }

    // Verificar se o token já existe
    const { data: existingTokens, error: selectError } = await supabase
      .from('user_fcm_tokens')
      .select('id')
      .eq('fcm_token', token)
      .limit(1);

    if (selectError) {
      console.error('Error checking token:', selectError);
      return new Response(
        JSON.stringify({ 
          error: 'Database query error',
          details: selectError.message,
          success: false
        }),
        { 
          headers: { 'Content-Type': 'application/json' },
          status: 500
        }
      );
    }

    let result;
    
    if (existingTokens && existingTokens.length > 0) {
      // Atualizar o token existente
      const { data, error } = await supabase
        .from('user_fcm_tokens')
        .update({
          user_id,
          device_info,
          last_used_at: new Date().toISOString()
        })
        .eq('fcm_token', token)
        .select();

      if (error) throw error;
      result = { updated: true, data };
    } else {
      // Inserir um novo token
      const { data, error } = await supabase
        .from('user_fcm_tokens')
        .insert({
          user_id,
          fcm_token: token,
          device_info,
          created_at: new Date().toISOString(),
          last_used_at: new Date().toISOString()
        })
        .select();

      if (error) throw error;
      result = { inserted: true, data };
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        message: 'FCM token stored successfully',
        result
      }),
      { 
        headers: { 'Content-Type': 'application/json' },
        status: 200
      }
    );
  } catch (error) {
    console.error('Error storing FCM token:', error);
    
    return new Response(
      JSON.stringify({ 
        error: 'Server error',
        details: error.message,
        success: false
      }),
      { 
        headers: { 'Content-Type': 'application/json' },
        status: 500
      }
    );
  }
});