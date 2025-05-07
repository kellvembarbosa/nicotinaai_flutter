# Plano de Implementação: Sistema de Motivação Diária e Notificações

Este documento descreve o plano para implementar um sistema de motivação diária personalizada que utiliza Edge Functions do Supabase, integração com a API OpenAI e notificações push para os usuários do aplicativo NicotinaAI.

## Visão Geral

O sistema consistirá em:

1. **Edge Function para geração de frases motivacionais personalizadas** usando a API da OpenAI com o modelo gpt-4o-mini-2024-07-18.
2. **Esquema de banco de dados** para armazenar notificações e registros de conquistas.
3. **Sistema de notificações push** para enviar alertas aos usuários.
4. **Interface de usuário** para exibir mensagens motivacionais e recompensas.
5. **Suporte a múltiplos idiomas** (Português, Inglês e Espanhol) em todas as mensagens e notificações.

## 1. Esquema de Banco de Dados

### 1.1 Tabela de Notificações

Vamos criar uma tabela `user_notifications` para armazenar as notificações geradas:

```sql
CREATE TABLE user_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL, -- 'motivation', 'achievement', 'reminder', etc.
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE,
  xp_reward INTEGER DEFAULT 0,
  viewed_at TIMESTAMP WITH TIME ZONE,
  
  CONSTRAINT user_notifications_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Índice para consultas rápidas por usuário
CREATE INDEX user_notifications_user_id_idx ON user_notifications(user_id);

-- RLS para garantir que usuários só vejam suas próprias notificações
ALTER TABLE user_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
  ON user_notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Only supabase functions can insert notifications"
  ON user_notifications FOR INSERT
  USING (auth.uid() = user_id OR (auth.role() = 'service_role'));

CREATE POLICY "Users can mark their notifications as read"
  ON user_notifications FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id AND (
    is_read = TRUE OR 
    viewed_at IS NOT NULL
  ));
```

### 1.2 Tabela de Registros de Notificações Diárias

Para garantir que a mensagem motivacional seja exibida apenas uma vez por dia, vamos criar uma tabela de registro:

```sql
CREATE TABLE daily_motivation_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  notification_id UUID REFERENCES user_notifications(id),
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Garantir uma entrada única por dia e por usuário
  CONSTRAINT daily_motivation_logs_user_date_unique UNIQUE (user_id, date)
);

-- RLS para esta tabela
ALTER TABLE daily_motivation_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Only services can insert daily logs"
  ON daily_motivation_logs FOR INSERT
  USING (auth.role() = 'service_role');

CREATE POLICY "Users can view their own logs"
  ON daily_motivation_logs FOR SELECT
  USING (auth.uid() = user_id);
```

### 1.3 Tabela de Dispositivos para Notificações Push

Para armazenar os tokens de dispositivo para notificações push:

```sql
CREATE TABLE user_fcm_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  device_info JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT user_fcm_tokens_token_unique UNIQUE (fcm_token)
);

-- RLS para esta tabela
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own device tokens"
  ON user_fcm_tokens FOR INSERT
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own device tokens"
  ON user_fcm_tokens FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own device tokens"
  ON user_fcm_tokens FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own device tokens"
  ON user_fcm_tokens FOR DELETE
  USING (auth.uid() = user_id);
```

## 2. Edge Functions do Supabase

### 2.1 Edge Function: `generate-daily-motivation`

Esta função gerará as frases motivacionais personalizada usando a API da OpenAI e os dados dos logs do usuário.

```typescript
// supabase/functions/generate-daily-motivation/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { Configuration, OpenAIApi } from 'https://esm.sh/openai@3.2.1'

// Inicialização do cliente OpenAI
const openaiConfig = new Configuration({
  apiKey: Deno.env.get('OPENAI_API_KEY'),
})
const openai = new OpenAIApi(openaiConfig)

// Inicialização do cliente Supabase (usando variáveis de ambiente do Supabase)
const supabaseClient = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

interface WebhookPayload {
  type: 'GENERATE_DAILY_MOTIVATION'
  user_id?: string
}

serve(async (req: Request) => {
  try {
    // Verificar se é uma solicitação da Supabase
    const authHeader = req.headers.get('Authorization')
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Parse do corpo da solicitação
    const payload: WebhookPayload = await req.json()
    
    // Se o tipo não for para gerar motivação diária, retorna erro
    if (payload.type !== 'GENERATE_DAILY_MOTIVATION') {
      return new Response(JSON.stringify({ error: 'Invalid webhook type' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Processa para um usuário específico ou para todos os usuários se não for especificado
    const userIds = payload.user_id 
      ? [payload.user_id]
      : await getAllActiveUserIds()

    const results = []
    for (const userId of userIds) {
      try {
        const alreadyHasDailyMotivation = await checkDailyMotivationStatus(userId)
        if (alreadyHasDailyMotivation) {
          results.push({ userId, status: 'skipped', message: 'User already has motivation for today' })
          continue
        }

        const userProfile = await getUserProfile(userId)
        const smokingLogs = await getRecentSmokingLogs(userId, 5)
        const cravingLogs = await getRecentCravingLogs(userId, 5)

        if (!userProfile) {
          results.push({ userId, status: 'error', message: 'User profile not found' })
          continue
        }

        // Gera a frase motivacional com base nos dados do usuário
        const motivationalMessage = await generateMotivationalMessage(userProfile, smokingLogs, cravingLogs)
        
        // Calcula a recompensa de XP (entre 5 e 15 pontos)
        const xpReward = 5 + Math.floor(Math.random() * 11)
        
        // Cria a notificação no banco de dados
        const notification = await createNotification(userId, motivationalMessage, xpReward)
        
        // Registra o log diário de motivação
        await logDailyMotivation(userId, notification.id)
        
        // Envia notificação push para o dispositivo do usuário
        await sendPushNotification(userId, 'Sua dose diária de motivação chegou!', 'Toque para ver sua mensagem personalizada e ganhar XP.')
        
        results.push({ userId, status: 'success', notificationId: notification.id })
      } catch (error) {
        console.error(`Error processing user ${userId}:`, error)
        results.push({ userId, status: 'error', message: error.message })
      }
    }

    return new Response(JSON.stringify({ results }), {
      headers: { 'Content-Type': 'application/json' }
    })
  } catch (error) {
    console.error('Error in webhook handler:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})

// Função para obter todos os IDs de usuários ativos
async function getAllActiveUserIds(): Promise<string[]> {
  const { data, error } = await supabaseClient
    .from('user_profiles')
    .select('user_id')
    .eq('is_active', true)
  
  if (error) throw error
  return data.map(row => row.user_id)
}

// Verificar se o usuário já recebeu motivação hoje
async function checkDailyMotivationStatus(userId: string): Promise<boolean> {
  const today = new Date().toISOString().split('T')[0]
  
  const { data, error } = await supabaseClient
    .from('daily_motivation_logs')
    .select('id')
    .eq('user_id', userId)
    .eq('date', today)
    .maybeSingle()
  
  if (error) throw error
  return data !== null
}

// Obtém o perfil do usuário
async function getUserProfile(userId: string) {
  const { data, error } = await supabaseClient
    .from('user_profiles')
    .select('*')
    .eq('user_id', userId)
    .single()
  
  if (error) throw error
  return data
}

// Obtém logs recentes de fumo
async function getRecentSmokingLogs(userId: string, limit: number) {
  const { data, error } = await supabaseClient
    .from('smoking_records')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(limit)
  
  if (error) throw error
  return data || []
}

// Obtém logs recentes de desejos de fumar
async function getRecentCravingLogs(userId: string, limit: number) {
  const { data, error } = await supabaseClient
    .from('cravings')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(limit)
  
  if (error) throw error
  return data || []
}

// Gera mensagem motivacional usando OpenAI
async function generateMotivationalMessage(userProfile: any, smokingLogs: any[], cravingLogs: any[]) {
  // Formatando os dados para enviar para a API
  const smokingLocations = smokingLogs.map(log => log.location).filter(Boolean)
  const smokingTimes = smokingLogs.map(log => {
    const date = new Date(log.created_at)
    return `${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`
  })
  
  const cravingTriggers = cravingLogs.map(log => log.trigger_type).filter(Boolean)
  const cravingLocations = cravingLogs.map(log => log.location).filter(Boolean)
  
  // Criando o prompt para o OpenAI
  const prompt = `
    Gere uma mensagem motivacional personalizada para um usuário que está tentando ${userProfile.goal_type === 'quit' ? 'parar de fumar' : 'reduzir o consumo de tabaco'}.
    
    Dados do usuário:
    - Objetivo: ${userProfile.goal_type === 'quit' ? 'Parar de fumar' : 'Reduzir o consumo'}
    - Maior desafio: ${userProfile.main_challenge || 'Não especificado'}
    
    Dados recentes de fumo:
    - Locais comuns onde fumou: ${smokingLocations.join(', ') || 'Sem dados'}
    - Horários comuns: ${smokingTimes.join(', ') || 'Sem dados'}
    
    Dados recentes de desejos de fumar:
    - Gatilhos comuns: ${cravingTriggers.join(', ') || 'Sem dados'}
    - Locais onde sentiu desejo: ${cravingLocations.join(', ') || 'Sem dados'}
    
    Baseado nesses dados, crie uma mensagem motivacional curta (máximo 3 parágrafos) que:
    1. Reconheça o esforço do usuário
    2. Forneça uma sugestão específica para evitar um gatilho com base nos dados acima
    3. Termine com uma frase positiva e encorajadora
    
    Mantenha um tom amigável, motivador e não-julgador. Seja específico nos conselhos.
  `
  
  // Chamada para a API da OpenAI
  const userLocale = userProfile.locale || 'pt_BR'; // Obter o idioma do usuário do perfil
  const isEnglish = userLocale && userLocale.startsWith('en');
  const isSpanish = userLocale && userLocale.startsWith('es');
  
  // Ajustar o prompt para o idioma do usuário
  let promptInUserLanguage = prompt; // Português (padrão)
  
  if (isEnglish) {
    promptInUserLanguage = `
      Generate a personalized motivational message for a user who is trying to ${userProfile.goal_type === 'quit' ? 'quit smoking' : 'reduce tobacco consumption'}.
      
      User data:
      - Goal: ${userProfile.goal_type === 'quit' ? 'Quit smoking' : 'Reduce consumption'}
      - Biggest challenge: ${userProfile.main_challenge || 'Not specified'}
      
      Recent smoking data:
      - Common places where they smoked: ${smokingLocations.join(', ') || 'No data'}
      - Common times: ${smokingTimes.join(', ') || 'No data'}
      
      Recent cravings data:
      - Common triggers: ${cravingTriggers.join(', ') || 'No data'}
      - Places where they felt cravings: ${cravingLocations.join(', ') || 'No data'}
      
      Based on this data, create a short motivational message (maximum 3 paragraphs) that:
      1. Acknowledges the user's effort
      2. Provides a specific suggestion to avoid a trigger based on the data above
      3. Ends with a positive and encouraging statement
      
      Keep a friendly, motivational, and non-judgmental tone. Be specific in your advice.
    `;
  } else if (isSpanish) {
    promptInUserLanguage = `
      Genera un mensaje motivacional personalizado para un usuario que está tratando de ${userProfile.goal_type === 'quit' ? 'dejar de fumar' : 'reducir el consumo de tabaco'}.
      
      Datos del usuario:
      - Objetivo: ${userProfile.goal_type === 'quit' ? 'Dejar de fumar' : 'Reducir el consumo'}
      - Mayor desafío: ${userProfile.main_challenge || 'No especificado'}
      
      Datos recientes de consumo:
      - Lugares comunes donde fumó: ${smokingLocations.join(', ') || 'Sin datos'}
      - Horarios frecuentes: ${smokingTimes.join(', ') || 'Sin datos'}
      
      Datos recientes de antojos:
      - Desencadenantes comunes: ${cravingTriggers.join(', ') || 'Sin datos'}
      - Lugares donde sintió antojos: ${cravingLocations.join(', ') || 'Sin datos'}
      
      Basado en estos datos, crea un mensaje motivacional breve (máximo 3 párrafos) que:
      1. Reconozca el esfuerzo del usuario
      2. Proporcione una sugerencia específica para evitar un desencadenante basado en los datos anteriores
      3. Termine con una declaración positiva y alentadora
      
      Mantén un tono amigable, motivador y sin prejuicios. Sé específico en tus consejos.
    `;
  }
  
  // Chamada para a API da OpenAI com o novo modelo
  const completion = await openai.createCompletion({
    model: "gpt-4o-mini-2024-07-18", // Versão correta do modelo
    prompt: promptInUserLanguage,
    max_tokens: 300,
    temperature: 0.7,
  })
  
  // Mensagens padrão de fallback nos três idiomas
  let defaultMessage;
  if (isEnglish) {
    defaultMessage = "Keep going on your journey! Each day without smoking is a victory. You are stronger than you think.";
  } else if (isSpanish) {
    defaultMessage = "¡Continúa con tu viaje! Cada día sin fumar es una victoria. Eres más fuerte de lo que piensas.";
  } else {
    defaultMessage = "Continue sua jornada! Cada dia sem fumar é uma vitória. Você está mais forte do que pensa.";
  }
  
  const message = completion.data.choices[0]?.text?.trim() || defaultMessage;
  
  // Título da notificação no idioma do usuário
  let title;
  if (isEnglish) {
    title = "Your daily dose of motivation";
  } else if (isSpanish) {
    title = "Tu dosis diaria de motivación";
  } else {
    title = "Sua dose diária de motivação";
  };
  
  return {
    title: title,
    message: message
  }
}

// Cria uma notificação no banco de dados
async function createNotification(userId: string, motivationalMessage: any, xpReward: number) {
  const { data, error } = await supabaseClient
    .from('user_notifications')
    .insert({
      user_id: userId,
      title: motivationalMessage.title,
      message: motivationalMessage.message,
      type: 'motivation',
      data: { xp_reward: xpReward },
      xp_reward: xpReward,
      expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(), // Expira em 7 dias
    })
    .select()
    .single()
  
  if (error) throw error
  return data
}

// Registra o log diário de motivação
async function logDailyMotivation(userId: string, notificationId: string) {
  const { error } = await supabaseClient
    .from('daily_motivation_logs')
    .insert({
      user_id: userId,
      notification_id: notificationId,
      date: new Date().toISOString().split('T')[0]
    })
  
  if (error) throw error
  return true
}

// Função para enviar notificações push
async function sendPushNotification(userId: string, title: string, body: string) {
  // Buscar tokens FCM e perfil do usuário
  const { data: userTokens, error: tokensError } = await supabaseClient
    .from('user_fcm_tokens')
    .select('fcm_token')
    .eq('user_id', userId)
  
  if (tokensError) throw tokensError
  
  if (!userTokens || userTokens.length === 0) {
    console.log(`No FCM tokens found for user ${userId}`)
    return
  }
  
  // Buscar o perfil e preferências de idioma do usuário
  const { data: userProfile, error: profileError } = await supabaseClient
    .from('user_profiles')
    .select('locale')
    .eq('user_id', userId)
    .single()
  
  if (profileError) {
    console.error(`Error getting user profile: ${profileError.message}`)
  }
  
  // Determinar o idioma para as notificações push
  const userLocale = userProfile?.locale || 'pt_BR'
  const isEnglish = userLocale.startsWith('en')
  const isSpanish = userLocale.startsWith('es')
  
  // Traduzir título e corpo da mensagem conforme o idioma do usuário
  let localizedTitle, localizedBody;
  
  if (isEnglish) {
    localizedTitle = "Your Daily Motivation";
    localizedBody = "Your personalized motivation message is waiting for you. Tap to view and earn XP!";
  } else if (isSpanish) {
    localizedTitle = "Tu Motivación Diaria";
    localizedBody = "Tu mensaje de motivación personalizado te está esperando. ¡Toca para verlo y ganar XP!";
  } else {
    // Português (padrão)
    localizedTitle = "Sua Motivação Diária";
    localizedBody = "Sua mensagem de motivação personalizada está esperando por você. Toque para visualizar e ganhar XP!";
  }
  
  // Configuração da API do Firebase
  const firebaseKey = Deno.env.get('FIREBASE_SERVER_KEY')
  if (!firebaseKey) {
    throw new Error('Firebase server key not found in environment variables')
  }
  
  // Enviar notificações para cada token
  for (const tokenData of userTokens) {
    try {
      const response = await fetch('https://fcm.googleapis.com/fcm/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `key=${firebaseKey}`
        },
        body: JSON.stringify({
          to: tokenData.fcm_token,
          notification: {
            title: localizedTitle,
            body: localizedBody,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
          },
          data: {
            type: 'motivation',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            locale: userLocale
          }
        })
      })
      
      if (!response.ok) {
        const errorData = await response.text()
        console.error(`Error sending FCM to ${tokenData.fcm_token}:`, errorData)
      }
    } catch (error) {
      console.error(`Error sending notification to token ${tokenData.fcm_token}:`, error)
    }
  }
}
```

### 2.2 Edge Function: `claim-motivation-reward`

Esta função será chamada quando o usuário visualizar a notificação motivacional e reivindicar sua recompensa.

```typescript
// supabase/functions/claim-motivation-reward/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Inicialização do cliente Supabase
const supabaseClient = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

serve(async (req: Request) => {
  try {
    // Verificar autenticação
    const authHeader = req.headers.get('Authorization')
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Autenticação JWT para obter o userId
    const token = authHeader.split(' ')[1]
    
    // Validar o token JWT para obter o ID do usuário
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(token)
    
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Invalid token' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      })
    }
    
    const userId = user.id
    
    // Parse do corpo da solicitação
    const { notification_id } = await req.json()
    
    if (!notification_id) {
      return new Response(JSON.stringify({ error: 'Notification ID is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }
    
    // Verificar se a notificação pertence ao usuário e ainda não foi visualizada
    const { data: notification, error: notifError } = await supabaseClient
      .from('user_notifications')
      .select('*')
      .eq('id', notification_id)
      .eq('user_id', userId)
      .is('viewed_at', null)
      .single()
      
    if (notifError || !notification) {
      return new Response(JSON.stringify({ 
        error: 'Notification not found or already claimed' 
      }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      })
    }
    
    // Iniciar transação para atualizar a notificação e adicionar XP
    const xpAmount = notification.xp_reward || 5
    
    // 1. Marcar a notificação como visualizada
    const { error: updateError } = await supabaseClient
      .from('user_notifications')
      .update({ 
        viewed_at: new Date().toISOString(),
        is_read: true
      })
      .eq('id', notification_id)
    
    if (updateError) {
      throw updateError
    }
    
    // 2. Adicionar XP ao usuário
    const { error: xpError } = await supabaseClient.rpc('add_user_xp', {
      p_user_id: userId,
      p_amount: xpAmount,
      p_source: 'daily_motivation',
      p_source_id: notification_id
    })
    
    if (xpError) {
      throw xpError
    }
    
    // Verificar conquistas desbloqueadas após adicionar XP
    const unlockedAchievements = await checkForUnlockedAchievements(userId)
    
    return new Response(JSON.stringify({ 
      success: true, 
      xp_gained: xpAmount,
      notification: notification,
      unlocked_achievements: unlockedAchievements
    }), {
      headers: { 'Content-Type': 'application/json' }
    })
    
  } catch (error) {
    console.error('Error in claim reward handler:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})

// Verificar se o usuário desbloqueou novas conquistas após receber XP
async function checkForUnlockedAchievements(userId: string) {
  try {
    // Chamar a função RPC para verificar conquistas
    const { data, error } = await supabaseClient.rpc('check_user_achievements', {
      p_user_id: userId
    })
    
    if (error) throw error
    
    return data || []
  } catch (error) {
    console.error('Error checking achievements:', error)
    return []
  }
}
```

## 3. Funções e Procedimentos do PostgreSQL

### 3.1 Função para Adicionar XP ao Usuário

```sql
-- Função para adicionar XP ao usuário
CREATE OR REPLACE FUNCTION add_user_xp(
  p_user_id UUID,
  p_amount INTEGER,
  p_source TEXT,
  p_source_id TEXT
) RETURNS BOOLEAN AS $$
DECLARE
  v_current_xp INTEGER;
  v_current_level INTEGER;
  v_new_xp INTEGER;
  v_level_up BOOLEAN := FALSE;
BEGIN
  -- Obter XP e nível atual
  SELECT current_xp, level 
  INTO v_current_xp, v_current_level
  FROM user_profiles
  WHERE user_id = p_user_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User profile not found for user %', p_user_id;
  END IF;
  
  -- Calcular novo XP
  v_new_xp := v_current_xp + p_amount;
  
  -- Registrar a transação de XP
  INSERT INTO user_xp_transactions (
    user_id,
    amount,
    source,
    source_id,
    previous_xp,
    new_xp
  ) VALUES (
    p_user_id,
    p_amount,
    p_source,
    p_source_id,
    v_current_xp,
    v_new_xp
  );
  
  -- Atualizar o perfil do usuário
  UPDATE user_profiles
  SET current_xp = v_new_xp
  WHERE user_id = p_user_id;
  
  -- Verificar se o usuário subiu de nível (outra função fará isso via trigger)
  
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 3.2 Agendamento de Tarefas para Gerar Motivação Diária

Para configurar o sistema a gerar frases motivacionais automaticamente todos os dias:

1. Configurar um cron job usando pgBoss ou o scheduler do Supabase (necessário plano Pro)
2. Alternativamente, configurar um serviço de agendamento externo como Vercel Cron ou AWS Lambda para chamar a Edge Function diariamente.

Exemplo de código para agendamento usando pgBoss (se disponível):

```sql
-- Instalar a extensão pg_cron se ainda não estiver instalada
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Agendar a chamada diária às 9h da manhã
SELECT cron.schedule(
  'daily-motivation-generator',
  '0 9 * * *', -- Executa às 9h todos os dias
  $$
  SELECT http_post(
    'https://your-project-ref.functions.supabase.co/generate-daily-motivation',
    '{"type":"GENERATE_DAILY_MOTIVATION"}',
    'application/json',
    $HEADERS${"Authorization": "Bearer your-service-role-key"}$HEADERS$
  );
  $$
);
```

## 4. Interface do Usuário

### 4.1 Widget de Notificação Motivacional

Vamos criar um widget que exibe a mensagem motivacional diária com um design atraente:

```dart
// lib/widgets/daily_motivation_card.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/services/supabase_service.dart';
import 'package:nicotinaai_flutter/providers/user_provider.dart';

class DailyMotivationCard extends StatefulWidget {
  final Map<String, dynamic> notification;
  
  const DailyMotivationCard({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  State<DailyMotivationCard> createState() => _DailyMotivationCardState();
}

class _DailyMotivationCardState extends State<DailyMotivationCard> {
  late ConfettiController _confettiController;
  bool _isRewardClaimed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _claimReward() async {
    if (_isLoading || _isRewardClaimed) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      final response = await supabaseService.claimMotivationReward(
        widget.notification['id'],
      );
      
      if (response != null) {
        _confettiController.play();
        setState(() {
          _isRewardClaimed = true;
        });
        
        // Atualizar XP do usuário via Provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.addXP(response['xp_gained']);
        
        // Mostrar conquistas desbloqueadas, se houver
        if (response['unlocked_achievements'] != null && 
            response['unlocked_achievements'].isNotEmpty) {
          // Exibir conquistas desbloqueadas
          _showUnlockedAchievements(response['unlocked_achievements']);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao reivindicar recompensa: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showUnlockedAchievements(List<dynamic> achievements) {
    // Implementar lógica para mostrar conquistas desbloqueadas
    // Usando um Dialog ou ModalBottomSheet
  }

  @override
  Widget build(BuildContext context) {
    final xpReward = widget.notification['data']['xp_reward'] ?? 5;
    final title = widget.notification['title'];
    final message = widget.notification['message'];
    
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Confetti animation
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          particleDrag: 0.05,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          gravity: 0.05,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple
          ],
        ),
        
        // Main Card
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.8),
                  Theme.of(context).primaryColorDark,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone animado de motivação
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Lottie.asset(
                    'assets/animations/motivation.json',
                    repeat: true,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Título
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Mensagem
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Botão de recompensa
                if (!_isRewardClaimed)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _claimReward,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.star),
                    label: Text('Ganhar ${xpReward} XP'),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recompensa recebida: ${xpReward} XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

### 4.2 Implementação da Tela de Notificações

```dart
// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/services/supabase_service.dart';
import 'package:nicotinaai_flutter/widgets/daily_motivation_card.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;
  
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  void _loadNotifications() {
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    _notificationsFuture = supabaseService.getUserNotifications();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadNotifications();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar notificações: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/empty_notifications.png',
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma notificação ainda!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Continue usando o app para receber\nmensagens motivacionais e conquistas.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          final notifications = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final notificationType = notification['type'];
              final isRead = notification['is_read'] ?? false;
              final createdAt = DateTime.parse(notification['created_at']);
              final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(createdAt);
              
              // Special handling for motivation notifications
              if (notificationType == 'motivation' && !(notification['viewed_at'] != null)) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DailyMotivationCard(notification: notification),
                );
              }
              
              // Regular notification item
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: isRead ? 1 : 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isRead
                        ? BorderSide.none
                        : BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.5,
                          ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: _buildNotificationIcon(notificationType),
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification['message']),
                        const SizedBox(height: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Marcar como lida se ainda não estiver
                      if (!isRead) {
                        final supabaseService = Provider.of<SupabaseService>(
                          context,
                          listen: false,
                        );
                        supabaseService.markNotificationAsRead(notification['id']);
                        
                        // Atualizar a lista
                        setState(() {
                          notifications[index]['is_read'] = true;
                        });
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildNotificationIcon(String type) {
    switch (type) {
      case 'motivation':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.psychology,
            color: Colors.blue,
          ),
        );
      case 'achievement':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.emoji_events,
            color: Colors.amber,
          ),
        );
      case 'reminder':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_active,
            color: Colors.purple,
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.message,
            color: Colors.green,
          ),
        );
    }
  }
}
```

### 4.3 Serviço de Supabase para Notificações

```dart
// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  
  // Obter notificações do usuário
  Future<List<Map<String, dynamic>>> getUserNotifications() async {
    final response = await _client
        .from('user_notifications')
        .select('*')
        .order('created_at', ascending: false)
        .limit(20);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  // Marcar uma notificação como lida
  Future<void> markNotificationAsRead(String notificationId) async {
    await _client
        .from('user_notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }
  
  // Reivindicar recompensa de motivação diária
  Future<Map<String, dynamic>?> claimMotivationReward(String notificationId) async {
    final response = await _client.functions.invoke(
      'claim-motivation-reward',
      body: {'notification_id': notificationId},
    );
    
    if (response.status != 200) {
      throw Exception(response.data['error'] ?? 'Erro ao reivindicar recompensa');
    }
    
    return Map<String, dynamic>.from(response.data);
  }
  
  // Registrar token FCM para notificações push
  Future<void> registerFcmToken(String fcmToken, Map<String, dynamic> deviceInfo) async {
    // Verificar se o token já existe
    final existing = await _client
        .from('user_fcm_tokens')
        .select('id')
        .eq('fcm_token', fcmToken)
        .maybeSingle();
    
    if (existing != null) {
      // Atualizar o token existente
      await _client
        .from('user_fcm_tokens')
        .update({
          'last_used_at': DateTime.now().toIso8601String(),
          'device_info': deviceInfo,
        })
        .eq('fcm_token', fcmToken);
    } else {
      // Inserir novo token
      await _client
        .from('user_fcm_tokens')
        .insert({
          'fcm_token': fcmToken,
          'device_info': deviceInfo,
        });
    }
  }
}
```

### 4.4 Configuração de Notificações Push no Flutter

```dart
// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/services/supabase_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // Inicializar o serviço de notificações
  Future<void> initialize() async {
    // Configurar permissões
    await _requestPermissions();
    
    // Configurar notificações locais
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Tratar notificações quando o app está em primeiro plano (iOS < 10)
      },
    );
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Tratar quando o usuário toca em uma notificação
        _handleNotificationClick(details.payload);
      },
    );
    
    // Configurar handlers de mensagens FCM
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
    
    // Verificar notificação inicial (se o app foi aberto a partir de uma notificação)
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }
    
    // Obter e registrar token FCM
    await _getAndRegisterFcmToken();
  }
  
  // Solicitar permissões para enviar notificações
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      // Em Android 13+ (API 33+), é necessário solicitar permissão explícita
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    }
  }
  
  // Obter token FCM e registrá-lo no Supabase
  Future<void> _getAndRegisterFcmToken() async {
    final fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      final deviceInfo = await _getDeviceInfo();
      
      // Registrar o token no backend
      final supabaseService = SupabaseService();
      await supabaseService.registerFcmToken(fcmToken, deviceInfo);
      
      // Configurar listener para refreshes de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        supabaseService.registerFcmToken(newToken, deviceInfo);
      });
    }
  }
  
  // Obter informações do dispositivo
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final Map<String, dynamic> deviceData = <String, dynamic>{};
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData['platform'] = 'android';
        deviceData['version'] = androidInfo.version.release;
        deviceData['model'] = androidInfo.model;
        deviceData['brand'] = androidInfo.brand;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData['platform'] = 'ios';
        deviceData['version'] = iosInfo.systemVersion;
        deviceData['model'] = iosInfo.model;
        deviceData['name'] = iosInfo.name;
      }
    } catch (e) {
      deviceData['error'] = e.toString();
    }
    
    return deviceData;
  }
  
  // Tratar mensagens recebidas quando o app está em primeiro plano
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final data = message.data;
    
    if (notification != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'motivation_channel',
            'Motivação Diária',
            channelDescription: 'Notificações de motivação diária',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF2962FF),
            icon: android?.smallIcon ?? 'notification_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: data.toString(),
      );
    }
  }
  
  // Tratar quando o usuário toca em uma notificação
  void _handleNotificationClick(dynamic messageOrPayload) {
    // Implementar a navegação baseada no tipo de notificação
    // Por exemplo, navegar para a tela de notificações
  }
}
```

## 5. Implementação do Sistema de Agendamento

### 5.1 GitHub Actions para Agendamento (Opção Alternativa)

Se o Supabase não oferecer agendamento (cron), podemos usar o GitHub Actions:

```yaml
# .github/workflows/daily-motivation.yml
name: Generate Daily Motivation

on:
  schedule:
    # Executa todos os dias às 9h UTC
    - cron: '0 9 * * *'
  workflow_dispatch:
    # Permite execução manual

jobs:
  generate-motivation:
    runs-on: ubuntu-latest
    
    steps:
      - name: Call Supabase Edge Function
        run: |
          curl -X POST ${{ secrets.SUPABASE_FUNCTIONS_URL }}/generate-daily-motivation \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}" \
            -d '{"type":"GENERATE_DAILY_MOTIVATION"}'
```

## 6. Plano de Implantação

1. **Fase 1: Criação da Infraestrutura**
   - Criar as tabelas no Supabase
   - Configurar políticas RLS
   - Criar as funções e procedimentos PostgreSQL
   - Configurar suporte para os três idiomas (Português, Inglês e Espanhol)

2. **Fase 2: Desenvolvimento Backend**
   - Desenvolver as Edge Functions
   - Configurar o sistema de agendamento
   - Testar a geração de frases e notificações
   - Implementar lógica para detecção e manipulação dos três idiomas

3. **Fase 3: Desenvolvimento Frontend**
   - Implementar o serviço de notificações no Flutter
   - Criar as interfaces de usuário
   - Adicionar suporte para notificações push
   - Criar arquivos de localização em espanhol (app_es.arb e notification_strings_es.arb)
   - Implementar seleção de idioma na interface

4. **Fase 4: Testes e Otimização**
   - Realizar testes com usuários reais em diferentes idiomas
   - Otimizar os prompts da OpenAI para melhor personalização em cada idioma
   - Ajustar o design e a experiência do usuário
   - Validar traduções com falantes nativos

5. **Fase 5: Monitoramento e Evolução**
   - Monitorar o engajamento dos usuários por região/idioma
   - Coletar feedback específico para cada idioma
   - Evoluir o sistema com base nos dados coletados
   - Considerar adicionar mais idiomas conforme a expansão do aplicativo

## 7. Considerações Adicionais

### 7.1 Proteção de Chaves API

É fundamental proteger as chaves da API (OpenAI, Firebase) usando variáveis de ambiente do Supabase.

### 7.2 Custos

- **OpenAI API**: ~$0.0015-0.0030 por chamada (gpt-4o-mini-2024-07-18)
- **Firebase Cloud Messaging**: Gratuito para volumes típicos
- **Supabase**: Depende do plano, mas o uso básico está dentro do plano gratuito

### 7.3 Estratégia de Backup

Configurar backups regulares do banco de dados para evitar perda de dados.

### 7.4 Monitoramento

Implementar logging e monitoramento para rastrear erros e uso da API.

## 8. Conclusão

Este sistema de motivação diária personalizada aumentará significativamente o engajamento dos usuários, fornecendo valor diário e incentivos para continuar usando o aplicativo. A combinação de conteúdo personalizado usando IA, notificações push e recompensas de XP criará um loop de feedback positivo que ajudará os usuários a manter o foco em seus objetivos de parar de fumar ou reduzir o consumo.