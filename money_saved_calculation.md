# Análise do Cálculo de Dinheiro Economizado na Aplicação NicotinaAI

## Visão Geral

O aplicativo NicotinaAI calcula o dinheiro economizado quando o usuário deixa de fumar. Esta análise explora como essa lógica é implementada e como o valor é armazenado e exibido na interface.

## Armazenamento do Valor

### 1. Armazenamento de Dados

O dinheiro economizado é armazenado em centavos como um valor inteiro:

```dart
// lib/features/tracking/models/user_stats.dart
class UserStats {
  // ...
  final int moneySaved; // stored in cents
  // ...
}
```

Isso evita problemas com precisão de ponto flutuante e facilita cálculos.

### 2. Configuração durante Onboarding

Durante o processo de onboarding, o usuário fornece informações necessárias para o cálculo:

```dart
// lib/features/onboarding/models/onboarding_model.dart
class OnboardingModel {
  // ...
  final int? packPrice; // em centavos
  final String packPriceCurrency; // código ISO da moeda (ex: BRL, USD, EUR)
  final int? cigarettesPerPack;
  final int? cigarettesPerDayCount;
  // ...
}
```

Estes valores são essenciais para calcular quanto dinheiro é economizado quando o usuário não compra cigarros.

## Cálculo dos Valores

### 1. Processamento no Servidor

O cálculo principal é executado em uma função Edge no Supabase:

```dart
// lib/features/tracking/repositories/tracking_repository.dart
Future<void> updateUserStats() async {
  try {
    final user = _client.auth.currentUser;
    
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    // Call the edge function to update user stats
    await _client.functions.invoke('updateUserStats', 
      body: {'userId': user.id},
    );
  } catch (e) {
    rethrow;
  }
}
```

A função `updateUserStats` no servidor calcula:
1. Dias sem fumar desde o último registro
2. Cigarros não fumados com base nos dias sem fumar e cigarros por dia
3. Dinheiro economizado com base no preço do maço e cigarros por maço

### 2. Lógica de Cálculo

Embora a implementação exata esteja no código do servidor (Edge Function), a lógica é aproximadamente:

```
cigarrosEvitados = diasSemFumar * cigarrosPorDia
unidadesPorMaço = cigarrosPorMaço
preçoPorCigarro = preçoDoMaço / unidadesPorMaço
dinheiroEconomizado = cigarrosEvitados * preçoPorCigarro
```

O valor é armazenado em centavos para evitar erros de arredondamento.

## Exibição na Interface

### 1. Formatação para Exibição

O UserStats inclui um método para formatação do valor:

```dart
// lib/features/tracking/models/user_stats.dart
String get formattedMoneySaved {
  final dollars = moneySaved / 100;
  return 'R\$ ${dollars.toStringAsFixed(2)}';
}
```

### 2. Suporte Multi-moeda

O sistema também suporta multi-moeda através da classe CurrencyUtils:
- O valor é sempre armazenado em centavos
- A moeda é identificada pelo código ISO
- A formatação considera a localização do dispositivo ou a preferência do usuário

## Ciclo de Atualização

1. Quando um novo registro de cigarro é adicionado, a data do último cigarro é atualizada
2. Quando o usuário resiste a um desejo, isso é registrado para rastrear o progresso
3. A função `updateUserStats` é chamada para recalcular todas as estatísticas 
4. Os novos valores são carregados pela UI na HomeScreen

## Considerações de Design

1. Uso de unidades inteiras (centavos) para evitar erros de arredondamento
2. Cálculos no servidor para garantir consistência
3. Atualização em tempo real quando novos dados são adicionados
4. Suporte a diferentes moedas para usuários globais

## Conclusão

O cálculo de dinheiro economizado é um recurso motivacional importante do aplicativo, baseado em dados precisos fornecidos pelo usuário durante o onboarding e atualizados com cada interação com o aplicativo.