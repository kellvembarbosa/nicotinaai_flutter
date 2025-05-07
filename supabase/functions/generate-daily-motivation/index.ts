import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';
import { Configuration, OpenAIApi } from 'https://esm.sh/openai@3.1.0';

// Define tipos para o suporte a idiomas
type SupportedLanguages = 'pt' | 'en' | 'es';

// Interface para os perfis de usuário
interface UserProfile {
  user_id: string;
  username: string;
  full_name?: string;
  currency_locale?: string;
  language_preference?: string;
}

// Interface para estatísticas do usuário
interface UserStats {
  cigarettes_avoided?: number;
  money_saved?: number;
  cravings_resisted?: number;
  current_streak_days?: number;
}

// Interface para dados de onboarding
interface UserOnboarding {
  goal: string;
  help_preferences?: string[];
  product_type?: string;
  cigarettes_per_day_count?: number;
}

serve(async (req) => {
  try {
    // Obter parâmetros da solicitação
    const { userId } = await req.json();
    
    if (!userId) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'User ID is required' 
        }),
        { 
          headers: { 'Content-Type': 'application/json' }, 
          status: 400 
        }
      );
    }

    // Criar cliente do Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseKey);
    
    // Verificar se já enviamos uma motivação hoje para este usuário
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const { data: existingMotivation } = await supabase
      .from('daily_motivation_logs')
      .select('id')
      .eq('user_id', userId)
      .eq('date', today.toISOString().split('T')[0])
      .maybeSingle();
      
    if (existingMotivation) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Daily motivation already sent today for this user' 
        }),
        { 
          headers: { 'Content-Type': 'application/json' }, 
          status: 400 
        }
      );
    }
    
    // Obter o perfil do usuário
    const { data: userProfile, error: profileError } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('user_id', userId)
      .single();
      
    if (profileError) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: `Failed to get user profile: ${profileError.message}` 
        }),
        { 
          headers: { 'Content-Type': 'application/json' }, 
          status: 500 
        }
      );
    }
    
    // Obter dados de onboarding do usuário
    const { data: onboardingData } = await supabase
      .from('user_onboarding')
      .select('*')
      .eq('user_id', userId)
      .single();
    
    // Obter estatísticas do usuário
    const { data: userStats } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();
    
    // Obter registros recentes de tabagismo
    const { data: recentSmokingLogs } = await supabase
      .from('smoking_logs')
      .select('*')
      .eq('user_id', userId)
      .order('timestamp', { ascending: false })
      .limit(5);
    
    // Obter desejos recentes
    const { data: recentCravings } = await supabase
      .from('cravings')
      .select('*')
      .eq('user_id', userId)
      .order('timestamp', { ascending: false })
      .limit(5);
    
    // Determinar o idioma do usuário
    const userLocale = userProfile.currency_locale || 'pt_BR';
    const isEnglish = userLocale?.startsWith('en');
    const isSpanish = userLocale?.startsWith('es');
    
    // Definir idioma baseado na configuração do usuário
    const userLanguage: SupportedLanguages = isEnglish ? 'en' : isSpanish ? 'es' : 'pt';
    
    // Preparar dados para o prompt
    const userName = userProfile.full_name || userProfile.username || 'Amigo';
    const streak = userStats?.current_streak_days || 0;
    const cigarettesAvoided = userStats?.cigarettes_avoided || 0;
    const moneySaved = userStats?.money_saved || 0;
    const cravingsResisted = userStats?.cravings_resisted || 0;
    const goal = onboardingData?.goal || '';
    const productType = onboardingData?.product_type || 'cigarettes';
    const cigsPerDay = onboardingData?.cigarettes_per_day_count || 10;
    
    // Formatar valor economizado para display
    const formatMoneySaved = () => {
      if (moneySaved === 0) return '0';
      
      // Converter de centavos para unidade monetária
      const amount = moneySaved / 100;
      
      // Formatação baseada no idioma
      if (isEnglish) {
        return new Intl.NumberFormat('en-US', { 
          style: 'currency', 
          currency: 'USD',
          maximumFractionDigits: 0
        }).format(amount);
      } else if (isSpanish) {
        return new Intl.NumberFormat('es-ES', { 
          style: 'currency', 
          currency: 'EUR',
          maximumFractionDigits: 0
        }).format(amount);
      } else {
        return new Intl.NumberFormat('pt-BR', { 
          style: 'currency', 
          currency: 'BRL',
          maximumFractionDigits: 0
        }).format(amount);
      }
    };

    // Prompts específicos de cada idioma
    const prompts = {
      pt: `Você é um assistente motivacional para um app de parar de fumar chamado Nicotina.AI. Gere uma mensagem motivacional curta (máximo 240 caracteres) e personalizada para o usuário com os seguintes dados:
Nome: ${userName}
Dias sem fumar: ${streak}
${productType === 'cigarettes' ? 'Cigarros' : 'Unidades'} evitados: ${cigarettesAvoided}
Dinheiro economizado: ${formatMoneySaved()}
Desejos resistidos: ${cravingsResisted}
Objetivo: ${goal}

A mensagem deve ser positiva, encorajadora e personalizada com os dados fornecidos. Destaque os progressos e benefícios já alcançados. Use linguagem simples e direta, evitando jargões médicos complicados. A mensagem deve ser breve e impactante, ideal para uma notificação push.

Importante: NÃO mencione "Nicotina.AI", "assistente" ou qualquer indicação de que você é uma IA. Escreva como se fosse uma mensagem direta enviada ao usuário por um coach empático. NÃO use emojis. Não inclua "Olá" ou saudações, comece direto com a mensagem motivacional.`,

      en: `You are a motivational assistant for a quit smoking app called Nicotina.AI. Generate a short (maximum 240 characters) and personalized motivational message for the user with the following data:
Name: ${userName}
Days smoke-free: ${streak}
${productType === 'cigarettes' ? 'Cigarettes' : 'Units'} avoided: ${cigarettesAvoided}
Money saved: ${formatMoneySaved()}
Cravings resisted: ${cravingsResisted}
Goal: ${goal}

The message should be positive, encouraging, and personalized with the provided data. Highlight the progress and benefits already achieved. Use simple and direct language, avoiding complicated medical jargon. The message should be brief and impactful, ideal for a push notification.

Important: DO NOT mention "Nicotina.AI", "assistant", or any indication that you are an AI. Write as if it were a direct message sent to the user by an empathetic coach. DO NOT use emojis. Do not include "Hello" or any greetings, start directly with the motivational message.`,

      es: `Eres un asistente motivacional para una aplicación para dejar de fumar llamada Nicotina.AI. Genera un mensaje motivacional corto (máximo 240 caracteres) y personalizado para el usuario con los siguientes datos:
Nombre: ${userName}
Días sin fumar: ${streak}
${productType === 'cigarettes' ? 'Cigarrillos' : 'Unidades'} evitados: ${cigarettesAvoided}
Dinero ahorrado: ${formatMoneySaved()}
Antojos resistidos: ${cravingsResisted}
Objetivo: ${goal}

El mensaje debe ser positivo, alentador y personalizado con los datos proporcionados. Destaca el progreso y los beneficios ya logrados. Usa un lenguaje simple y directo, evitando jerga médica complicada. El mensaje debe ser breve e impactante, ideal para una notificación push.

Importante: NO menciones "Nicotina.AI", "asistente" o cualquier indicación de que eres una IA. Escribe como si fuera un mensaje directo enviado al usuario por un coach empático. NO uses emojis. No incluyas "Hola" ni saludos, comienza directamente con el mensaje motivacional.`
    };

    // Selecionar o prompt baseado no idioma
    const promptInUserLanguage = prompts[userLanguage];
    
    // Mensagens de fallback caso a API da OpenAI falhe
    const fallbackMessages = {
      pt: [
        `${streak > 0 ? `${streak} dias sem fumar` : 'O início da jornada'} é um grande feito! Continue firme no seu objetivo, você está mais forte a cada dia.`,
        `Você já economizou ${formatMoneySaved()} e evitou ${cigarettesAvoided} ${productType === 'cigarettes' ? 'cigarros' : 'unidades'}. Seu corpo agradece!`,
        `Resistir a ${cravingsResisted} desejos mostra sua força de vontade. Continue assim!`,
        `Lembre-se do seu objetivo: ${goal}. Você está no caminho certo.`,
        `Cada dia sem fumar é uma vitória. Você está construindo um futuro mais saudável.`
      ],
      en: [
        `${streak > 0 ? `${streak} days smoke-free` : 'The beginning of your journey'} is a great achievement! Stay strong in your goal, you're getting stronger each day.`,
        `You've already saved ${formatMoneySaved()} and avoided ${cigarettesAvoided} ${productType === 'cigarettes' ? 'cigarettes' : 'units'}. Your body thanks you!`,
        `Resisting ${cravingsResisted} cravings shows your willpower. Keep it up!`,
        `Remember your goal: ${goal}. You're on the right track.`,
        `Every day without smoking is a victory. You're building a healthier future.`
      ],
      es: [
        `${streak > 0 ? `${streak} días sin fumar` : 'El comienzo de tu viaje'} es un gran logro! Mantente firme en tu objetivo, te estás haciendo más fuerte cada día.`,
        `Ya has ahorrado ${formatMoneySaved()} y evitado ${cigarettesAvoided} ${productType === 'cigarettes' ? 'cigarrillos' : 'unidades'}. ¡Tu cuerpo te lo agradece!`,
        `Resistir ${cravingsResisted} antojos muestra tu fuerza de voluntad. ¡Sigue así!`,
        `Recuerda tu objetivo: ${goal}. Estás en el camino correcto.`,
        `Cada día sin fumar es una victoria. Estás construyendo un futuro más saludable.`
      ]
    };
    
    let motivationalMessage = '';
    
    try {
      // Configurar o cliente da OpenAI
      const openaiApiKey = Deno.env.get('OPENAI_API_KEY');
      
      if (!openaiApiKey) {
        throw new Error('OpenAI API key not found');
      }
      
      const configuration = new Configuration({ apiKey: openaiApiKey });
      const openai = new OpenAIApi(configuration);
      
      // Chamar a API da OpenAI com o modelo correto
      const completion = await openai.createCompletion({
        model: "gpt-4o-mini-2024-07-18",
        prompt: promptInUserLanguage,
        max_tokens: 300,
        temperature: 0.7,
      });
      
      // Obter a resposta da API
      motivationalMessage = completion.data.choices[0].text?.trim() || '';
    } catch (error) {
      console.error('OpenAI API error:', error);
      
      // Usar uma mensagem de fallback se a chamada da API falhar
      const fallbackMessagesForUser = fallbackMessages[userLanguage];
      motivationalMessage = fallbackMessagesForUser[Math.floor(Math.random() * fallbackMessagesForUser.length)];
    }
    
    // Verificar se temos uma mensagem motivacional
    if (!motivationalMessage) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Failed to generate motivational message' 
        }),
        { 
          headers: { 'Content-Type': 'application/json' }, 
          status: 500 
        }
      );
    }
    
    // Títulos específicos de cada idioma
    const titles = {
      pt: 'Sua Motivação Diária',
      en: 'Your Daily Motivation',
      es: 'Tu Motivación Diaria'
    };
    
    // Inserir a notificação no banco de dados
    const { data: notification, error: notificationError } = await supabase
      .from('user_notifications')
      .insert({
        user_id: userId,
        title: titles[userLanguage],
        message: motivationalMessage,
        type: 'motivation',
        data: {
          stats: {
            streak,
            cigarettesAvoided,
            moneySaved,
            cravingsResisted
          }
        },
        is_read: false,
        xp_reward: 10,
        expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString() // Expira em 7 dias
      })
      .select()
      .single();
      
    if (notificationError) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: `Failed to create notification: ${notificationError.message}` 
        }),
        { 
          headers: { 'Content-Type': 'application/json' }, 
          status: 500 
        }
      );
    }
    
    // Registrar no log de motivações diárias
    const { error: logError } = await supabase
      .from('daily_motivation_logs')
      .insert({
        user_id: userId,
        notification_id: notification.id,
        date: new Date().toISOString().split('T')[0]
      });
      
    if (logError) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: `Failed to create motivation log: ${logError.message}` 
        }),
        { 
          headers: { 'Content-Type': 'application/json' }, 
          status: 500 
        }
      );
    }
    
    // Retornar sucesso com a notificação criada
    return new Response(
      JSON.stringify({ 
        success: true, 
        data: notification
      }),
      { 
        headers: { 'Content-Type': 'application/json' }, 
        status: 200 
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: `Unexpected error: ${error.message}` 
      }),
      { 
        headers: { 'Content-Type': 'application/json' }, 
        status: 500 
      }
    );
  }
});