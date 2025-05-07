import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';

// Define tipos para o suporte a idiomas
type SupportedLanguages = 'pt' | 'en' | 'es';

// Interface para as mensagens do sistema
interface SystemMessages {
  notificationNotFound: string;
  xpAwarded: (xp: number) => string;
  alreadyViewed: string;
  errorTitle: string;
  successTitle: string;
}

serve(async (req) => {
  // Criar cliente do Supabase
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const supabase = createClient(supabaseUrl, supabaseServiceKey);
  
  try {
    // Autenticar o usuário com o token JWT
    const authorization = req.headers.get('Authorization');
    
    if (!authorization) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing authorization header' }),
        { headers: { 'Content-Type': 'application/json' }, status: 401 }
      );
    }
    
    // Extrair o token JWT
    const token = authorization.replace('Bearer ', '');
    
    // Verificar o JWT e obter o usuário
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    
    if (authError || !user) {
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid or expired token' }),
        { headers: { 'Content-Type': 'application/json' }, status: 401 }
      );
    }
    
    // Obter parâmetros da solicitação
    const { notificationId } = await req.json();
    
    if (!notificationId) {
      return new Response(
        JSON.stringify({ success: false, error: 'Notification ID is required' }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 }
      );
    }
    
    // Obter o perfil do usuário para determinar o idioma
    const { data: userProfile } = await supabase
      .from('user_profiles')
      .select('currency_locale')
      .eq('user_id', user.id)
      .single();
    
    // Determinar o idioma do usuário
    const userLocale = userProfile?.currency_locale || 'pt_BR';
    const isEnglish = userLocale && userLocale.startsWith('en');
    const isSpanish = userLocale && userLocale.startsWith('es');
    
    // Definir idioma baseado na configuração do usuário
    const userLanguage: SupportedLanguages = isEnglish ? 'en' : isSpanish ? 'es' : 'pt';
    
    // Definir mensagens do sistema baseadas no idioma
    const messages: Record<SupportedLanguages, SystemMessages> = {
      pt: {
        notificationNotFound: 'Notificação não encontrada ou não pertence a este usuário',
        xpAwarded: (xp) => `Você ganhou ${xp} pontos de XP por ler sua motivação diária!`,
        alreadyViewed: 'Esta notificação já foi visualizada anteriormente',
        errorTitle: 'Erro',
        successTitle: 'Sucesso'
      },
      en: {
        notificationNotFound: 'Notification not found or does not belong to this user',
        xpAwarded: (xp) => `You earned ${xp} XP points for reading your daily motivation!`,
        alreadyViewed: 'This notification has already been viewed',
        errorTitle: 'Error',
        successTitle: 'Success'
      },
      es: {
        notificationNotFound: 'Notificación no encontrada o no pertenece a este usuario',
        xpAwarded: (xp) => `¡Has ganado ${xp} puntos de XP por leer tu motivación diaria!`,
        alreadyViewed: 'Esta notificación ya ha sido vista',
        errorTitle: 'Error',
        successTitle: 'Éxito'
      }
    };
    
    const systemMsg = messages[userLanguage];
    
    // Obter a notificação
    const { data: notification, error: notificationError } = await supabase
      .from('user_notifications')
      .select('*')
      .eq('id', notificationId)
      .eq('user_id', user.id)
      .eq('type', 'motivation')
      .single();
      
    if (notificationError || !notification) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: systemMsg.notificationNotFound
        }),
        { headers: { 'Content-Type': 'application/json' }, status: 404 }
      );
    }
    
    // Verificar se a recompensa já foi reivindicada
    if (notification.viewed_at) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: systemMsg.alreadyViewed
        }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 }
      );
    }
    
    // Definir quantidade de XP a ser concedida
    const xpReward = notification.xp_reward || 10;
    
    // Atualizar a notificação para marcar como visualizada
    const { error: updateError } = await supabase
      .from('user_notifications')
      .update({
        is_read: true,
        viewed_at: new Date().toISOString()
      })
      .eq('id', notificationId);
      
    if (updateError) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: `Failed to update notification: ${updateError.message}`
        }),
        { headers: { 'Content-Type': 'application/json' }, status: 500 }
      );
    }
    
    // Conceder XP ao usuário usando a função RPC
    const { data: xpResult, error: xpError } = await supabase
      .rpc('add_user_xp', {
        p_user_id: user.id,
        p_amount: xpReward,
        p_source: 'daily_motivation',
        p_source_id: notificationId
      });
      
    if (xpError) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: `Failed to award XP: ${xpError.message}`
        }),
        { headers: { 'Content-Type': 'application/json' }, status: 500 }
      );
    }
    
    // Verificar se algum achievement foi desbloqueado (isto seria feito por outro Edge Function)
    // Por simplicidade, apenas registramos que a recompensa foi concedida
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        message: systemMsg.xpAwarded(xpReward),
        data: {
          xp_awarded: xpReward,
          notification_id: notificationId
        }
      }),
      { headers: { 'Content-Type': 'application/json' }, status: 200 }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: `Unexpected error: ${error.message}`
      }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});