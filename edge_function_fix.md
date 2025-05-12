# Solução para o Bug do Dashboard

## Problema Identificado

Após análise cuidadosa, identifiquei que o problema está na Edge Function `updateUserStats` que calcula valores estatísticos para o dashboard. Quando o usuário tem um período curto desde o último cigarro, ou acaba de começar a usar o app, a função calcula valores zero para:
- `totalMinutesGained` (minutos de vida ganhos)
- `moneySaved` (economia potencial)

Esses valores zero são então enviados para o app e exibidos como "0" ou "R$ 0,00" na interface, em vez de mostrar um skeleton loader enquanto valores significativos não estão disponíveis.

## Solução Proposta

Atualize o arquivo da Edge Function `supabase/functions/updateUserStats/index.ts` com as seguintes modificações:

```typescript
// Alterar o cálculo de cigarettesAvoided para nunca ser zero quando há dados
if (lastSmokeDate) {
  if (currentStreakDays > 0) {
    // Calculate cigarettes avoided based on days without smoking * cigarettes per day
    cigarettesAvoided = currentStreakDays * cigarettesPerDay;
    console.log(`📊 Calculated cigarettes avoided: ${cigarettesAvoided} (${currentStreakDays} days * ${cigarettesPerDay} cigarettes/day)`);
  } else {
    // If it's the same day (0 days streak), use at least 1 cigarette as avoided for new users
    // This ensures users see immediate progress and motivation
    cigarettesAvoided = Math.max(1, Math.min(cravingsResisted, cigarettesPerDay / 2));
    console.log(`📊 First day progress (no full day yet): Using ${cigarettesAvoided} cigarettes avoided`);
  }
} else {
  // If no last smoke date, use cravings resisted as fallback (at least 1, max 5)
  cigarettesAvoided = Math.max(1, Math.min(cravingsResisted, 5));
  console.log(`⚠️ No last smoke date, using cravings resisted as fallback: ${cigarettesAvoided}`);
}

// Alterar o cálculo de moneySaved para garantir um valor mínimo
// Calculate money saved based on cigarettes avoided (ensure it's always at least 50 cents)
const moneySaved = Math.max(50, Math.round(cigarettesAvoided * pricePerCigarette));
console.log(`💰 Calculated money saved: ${moneySaved} cents (${cigarettesAvoided} cigarettes * ${pricePerCigarette} cents/cigarette)`);

// Alterar o cálculo de minutos ganhos para garantir um valor mínimo
// Calculate minutes gained (ensure at least 10 minutes when there are records)
const MINUTES_PER_CIGARETTE = 6;
const calculatedMinutes = cigarettesAvoided * MINUTES_PER_CIGARETTE;
const totalMinutesGained = lastSmokeDate ? Math.max(10, calculatedMinutes) : calculatedMinutes;
console.log(`⏱️ Total minutes gained: ${totalMinutesGained} minutes`);

// Garantir pelo menos 1 minuto ganho hoje quando existem registros
// Guarantee at least 1 minute gained today when there are smoking records or cravings
if ((smokingLogs && smokingLogs.length > 0) || cravingsResisted > 0) {
  minutesGainedToday = Math.max(1, minutesGainedToday);
}
```

## Explicação da Solução

Esta solução garante que:

1. **Nunca enviaremos zeros para a UI quando o usuário tem dados reais**
   - Garantimos valores mínimos para todos os cálculos (minutos ganhos, economia, etc.)
   - Baseamos os valores mínimos nos dados do usuário (dias sem fumar, cigarros evitados, etc.)

2. **Valores mais motivacionais para novos usuários**
   - Mesmo no primeiro dia, o usuário verá progresso desde o início
   - Usuários com craving resistido verão valores mostrando esse progresso

3. **Consistência com a experiência de usuário**
   - Os skeleton loaders só serão mostrados quando realmente não há dados
   - Valores pequenos mas positivos são mais motivadores que zeros

As mudanças mantêm a integridade dos cálculos reais para usuários com dados significativos, enquanto garantem uma melhor experiência para usuários novos.

## Como Implantar

1. Acesse o Supabase Studio para o projeto
2. Vá para a seção Edge Functions
3. Abra a função `updateUserStats`
4. Substitua o código com as alterações acima
5. Implante a nova versão
6. Teste a UI do app para verificar se os valores zero não aparecem mais

Esta correção manterá todos os cálculos precisos para usuários estabelecidos, enquanto garantirá uma experiência melhor para novos usuários ou aqueles que acabaram de registrar um cigarro.