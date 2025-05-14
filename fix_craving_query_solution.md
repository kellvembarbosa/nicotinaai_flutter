# Solução Pontual para o Erro na Edge Function updateUserStats

## Problema
O erro que estamos enfrentando é:
```
flutter: ❌ [TrackingRepository] Erro na edge function: FunctionException(status: 500, details: {status: 500, data: {error: operator does not exist: enum_craving_outcome = integer}}, reasonPhrase: Internal Server Error)
```

Isso ocorre porque na função edge `updateUserStats` há uma tentativa de comparar uma coluna de tipo enum com um valor inteiro, resultando em um erro de operador de comparação.

## Causa do Problema

Após analisar o código, vemos que o erro acontece na função `updateUserStats/index.ts`, onde a consulta problemática é:

```typescript
// Get cravings - using the correct enum value "RESISTED" (uppercase)
const { data: cravings, error: cravingsError } = await supabase
  .from("cravings")
  .select("*")
  .eq("user_id", userId)
  .eq("outcome", "RESISTED");
```

O problema específico é que na versão atual, a coluna `outcome` na tabela `cravings` está sendo comparada com um valor de string "RESISTED", mas de alguma forma está sendo interpretada como uma comparação com inteiro, possivelmente devido a uma inconsistência na definição do schema ou nos tipos de dados.

## Solução Pontual

### 1. Correção Apenas na Função Edge Afetada

Para resolver esse problema específico, modifique apenas a consulta na função edge `updateUserStats/index.ts`:

```typescript
// ANTES (código com problema)
const { data: cravings, error: cravingsError } = await supabase
  .from("cravings")
  .select("*")
  .eq("user_id", userId)
  .eq("outcome", "RESISTED");

// DEPOIS (correção pontual)
const { data: cravings, error: cravingsError } = await supabase
  .from("cravings")
  .select("*")
  .eq("user_id", userId)
  .filter('outcome::text', 'eq', 'RESISTED');
```

Esta mudança:
- Converte explicitamente o campo outcome para texto antes da comparação
- Mantém a funcionalidade existente sem alterar o modelo de dados
- Não requer alterações em outros locais do código

### 2. Como Implementar a Correção

1. **Edite apenas o arquivo da função Edge**:
   - Navegue até `supabase/functions/updateUserStats/index.ts`
   - Localize o trecho de código que usa `.eq("outcome", "RESISTED")`
   - Substitua por `.filter('outcome::text', 'eq', 'RESISTED')`
   - Salve o arquivo

2. **Implante somente a função atualizada**:
   ```bash
   supabase functions deploy updateUserStats
   ```

Esta abordagem é mais econômica e focalizada, pois:
- Corrige apenas onde o erro está ocorrendo
- Não requer migrações de banco de dados
- Não afeta outras partes do sistema que já funcionam
- Evita custos desnecessários de reimplantação de todo o sistema

Após esta correção pontual, a função edge deve ser capaz de processar cravings corretamente sem gerar mais erros.