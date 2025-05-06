# NicotinAI - Onboarding Flow Documentation

Este documento detalha todo o fluxo de onboarding do aplicativo NicotinAI, um assistente pessoal para parar de fumar. O objetivo deste documento é fornecer uma especificação completa para implementação do mesmo fluxo em outros aplicativos, como Flutter.

## Visão Geral

O onboarding consiste em 13 etapas que coletam informações essenciais dos usuários para personalizar sua jornada de cessação do tabagismo. Cada tela tem um design consistente com:

- **Header**: Contém uma barra de progresso e título/subtítulo
- **Conteúdo**: Área principal com opções interativas 
- **Footer**: Botões de navegação (Voltar, Continuar/Próximo)

## Componentes UI Reutilizáveis

O onboarding utiliza os seguintes componentes:

- **Botões**:
  - `ContinueButton`: Botão primário grande
  - `BackButton`: Botão para voltar
  - `SkipButton`: Botão para pular (opcional)

- **Cards**:
  - `OptionCard`: Card para seleção única
  - `MultiSelectOptionCard`: Card para seleção múltipla
  - `InterestCard`: Card para layout em grade
  - `MultiSelectInterestCard`: Card para seleção múltipla em grade

- **Inputs**:
  - `NumberSelector`: Seletor numérico com botões de incremento/decremento
  - `PriceInput`: Campo para entrada de valores monetários

- **Layout**:
  - `OnboardingContainer`: Contêiner principal
  - `HeaderContainer`: Layout para o cabeçalho
  - `FooterContainer`: Layout para o rodapé
  - `ProgressBar`: Indicador de progresso

## Estrutura de Dados

Os dados coletados durante o onboarding são armazenados em uma estrutura consistente:

```typescript
interface UserOnboarding {
  // Informações básicas
  cigarettes_per_day: "LOW" | "MODERATE" | "HIGH" | "VERY_HIGH";
  cigarettes_per_day_count: number;
  pack_price: number; // em centavos
  pack_price_currency: string;
  cigarettes_per_pack: number;
  
  // Objetivos
  goal: "REDUCE" | "QUIT";
  goal_timeline: "SEVEN_DAYS" | "FOURTEEN_DAYS" | "THIRTY_DAYS" | "NO_DEADLINE";
  
  // Desafios e preferências
  quit_challenge: "STRESS" | "HABIT" | "SOCIAL" | "ADDICTION";
  help_preferences: string[];
  product_type: "CIGARETTE_ONLY" | "VAPE_ONLY" | "BOTH";
  
  // Dados adicionais
  additional_data: Record<string, any>;
}
```

## Detalhamento das Telas

### 1. Introdução (index.tsx)

- **Tipo**: Tela informativa
- **Título**: "Bem-vindo ao NicotinAI"
- **Subtítulo**: "Seu assistente pessoal para parar de fumar"
- **Descrição**: "RESPIRE LIBERDADE. SUA NOVA VIDA COMEÇA AGORA."
- **Botão de Ação**: "Começar"
- **Comportamento**: Apresenta a visão geral do app e inicia o processo

### 2. Personalização (personalize.tsx)

- **Tipo**: Seleção múltipla
- **Título**: "Quando você costuma fumar mais?"
- **Subtítulo**: "Selecione o momento em que você sente mais vontade de fumar"
- **Opções** (Múltipla escolha):
  - Depois das refeições
  - Durante pausas no trabalho
  - Em eventos sociais
  - Quando estou estressado
  - Quando bebo café ou álcool
  - Quando estou entediado
- **Comportamento**: Permite selecionar múltiplas opções
- **Armazenamento**: `additional_data.smoking_times`

### 3. Interesses/Desafios (interests.tsx)

- **Tipo**: Seleção múltipla em grade
- **Título**: "O que torna difícil parar de fumar para você?"
- **Subtítulo**: "Identificar seu principal desafio nos ajuda a fornecer melhor suporte"
- **Opções** (Múltipla escolha em grade):
  - Estresse
  - Hábito diário
  - Pressão social
  - Dependência
  - Cafeína ou álcool
  - Amigos fumantes
  - Sintomas de abstinência
  - Festas e eventos
  - Rotina e gatilhos
  - Ansiedade ou tédio
- **Comportamento**: Permite selecionar múltiplas opções usando cards em grade
- **Armazenamento**: `additional_data.challenges`

### 4. Locais (locations.tsx)

- **Tipo**: Seleção múltipla em grade
- **Título**: "Onde você geralmente fuma?"
- **Subtítulo**: "Selecione os lugares onde você mais costuma fumar"
- **Opções** (Múltipla escolha):
  - Em casa
  - No trabalho
  - No carro
  - Em bares/restaurantes
  - Na rua
  - Em parques/áreas externas
- **Comportamento**: Permite selecionar múltiplos locais usando cards
- **Armazenamento**: `additional_data.smoking_locations`

### 5. Ajuda do App (help.tsx)

- **Tipo**: Seleção múltipla em grade
- **Título**: "Como podemos ajudar você?"
- **Subtítulo**: "Selecione todos os recursos que te ajudariam"
- **Opções** (Múltipla escolha):
  - Lembretes
  - Motivação diária
  - Economia
  - Progresso
  - Dicas & Guias
  - Prevenção
  - Histórico
  - Conquistas
  - Saúde
  - Comunidade
- **Comportamento**: Permite selecionar múltiplas opções de ajuda
- **Armazenamento**: `help_preferences`

### 6. Cigarros Por Dia (cigarettes-per-day.tsx)

- **Tipo**: Seleção única com opção personalizada
- **Título**: "Quantos cigarros você fuma por dia?"
- **Subtítulo**: "Isso nos ajuda a entender seu nível de hábito"
- **Opções** (Seleção única):
  - 5 (Pouco)
  - 10 (Moderado)
  - 15 (Moderado)
  - 20 (Alto)
  - 25 (Alto)
  - 30 (Muito Alto)
  - 35 (Muito Alto)
  - 40+ (Muito Alto)
  - Outra quantidade (com seletor numérico)
- **Comportamento**: Permite selecionar uma opção ou inserir um valor personalizado
- **Armazenamento**: 
  - `cigarettes_per_day` (nível de consumo)
  - `cigarettes_per_day_count` (contagem exata)

### 7. Preço do Maço (pack-price.tsx)

- **Tipo**: Entrada de valor monetário
- **Título**: "Quanto custa um maço de cigarros?"
- **Subtítulo**: "Isso nos ajuda a calcular sua economia financeira"
- **Opções**:
  - Valores pré-definidos: $5.00, $6.00, $7.00
  - Entrada personalizada com formatação monetária
- **Comportamento**: Permite selecionar um valor predefinido ou inserir um personalizado
- **Armazenamento**: 
  - `pack_price` (valor em centavos)
  - `pack_price_currency` (moeda)

### 8. Cigarros Por Maço (cigarettes-per-pack.tsx)

- **Tipo**: Seleção única com opção personalizada
- **Título**: "Quantos cigarros vêm em um maço?"
- **Subtítulo**: "Selecione a quantidade padrão para seus maços de cigarros"
- **Opções**: 10, 20, 25, 40, ou personalizado
- **Comportamento**: Permite selecionar uma opção ou inserir um valor personalizado
- **Armazenamento**: `cigarettes_per_pack`

### 9. Objetivo (goal.tsx)

- **Tipo**: Seleção única
- **Título**: "Qual é o seu objetivo?"
- **Subtítulo**: "Selecione o que você deseja alcançar"
- **Opções** (Seleção única):
  - Reduzir gradualmente: "Reduzir o número de cigarros ao longo do tempo"
  - Parar completamente: "Parar de fumar completamente"
- **Comportamento**: Permite selecionar apenas uma opção
- **Armazenamento**: `goal` ("REDUCE" ou "QUIT")

### 10. Cronograma (timeline.tsx)

- **Tipo**: Seleção única
- **Título**: "Quando você deseja alcançar seu objetivo?"
- **Subtítulo**: "Estabeleça um prazo que pareça alcançável para você"
- **Opções** (Seleção única):
  - Em 7 dias
  - Em 14 dias
  - Em 30 dias
  - Sem prazo
- **Comportamento**: Permite selecionar apenas uma opção
- **Armazenamento**: `goal_timeline`

### 11. Desafio (challenge.tsx)

- **Tipo**: Seleção única
- **Título**: "O que torna difícil parar de fumar para você?"
- **Subtítulo**: "Identificar seu principal desafio nos ajuda a fornecer melhor suporte"
- **Opções** (Seleção única):
  - Estresse
  - Hábito diário
  - Pressão social
  - Dependência de nicotina
- **Comportamento**: Permite selecionar apenas uma opção principal
- **Armazenamento**: `quit_challenge`

### 12. Tipo de Produto (product-type.tsx)

- **Tipo**: Seleção única
- **Título**: "Que tipo de produto você consome?"
- **Subtítulo**: "Selecione o que se aplica a você"
- **Opções** (Seleção única):
  - Apenas cigarro
  - Apenas vape
  - Ambos
- **Comportamento**: Permite selecionar apenas uma opção
- **Armazenamento**: `product_type`

### 13. Conclusão (completion.tsx)

- **Tipo**: Tela informativa
- **Título**: "Tudo pronto!"
- **Subtítulo**: "Sua jornada personalizada começa agora"
- **Descrição**: "Criamos um plano personalizado com base em suas respostas. Sua jornada para uma vida sem fumo começa agora!"
- **Botão de Ação**: "Iniciar Minha Jornada"
- **Comportamento**: Apresenta um resumo e finaliza o onboarding
- **Armazenamento**: Marca `completed: true` e redireciona para o app principal

## Gerenciamento de Estado e Navegação

O onboarding utiliza um contexto central (`OnboardingContext`) para:

1. Gerenciar o estado atual da etapa (1-13)
2. Armazenar respostas do usuário
3. Salvar progresso (localmente e remotamente)
4. Fornecer navegação entre etapas

Cada tela:
1. Recupera dados do contexto para inicialização
2. Gerencia estado local para interação do usuário
3. Salva dados no contexto ao avançar
4. Utiliza a navegação do Expo Router para transição entre telas

## Internacionalização

O sistema suporta múltiplos idiomas:
- Inglês (en)
- Português (pt)
- Espanhol (es)

As traduções são gerenciadas através do arquivo `onboarding_translations.ts` e acessadas pelo hook `useTranslation()`.

## Considerações para Implementação Flutter

Ao implementar este fluxo em Flutter, considere:

1. **Gerenciamento de Estado**: Use uma solução como Provider, Riverpod ou Bloc
2. **Navegação**: Implemente navegação entre etapas com Navigator 2.0 ou Go Router
3. **Armazenamento**: Use SharedPreferences para armazenamento local e uma API para remoto
4. **Internacionalização**: Use o pacote `flutter_localizations` e o padrão `.arb`
5. **UI Consistente**: Mantenha os elementos visuais consistentes com o design aqui apresentado
6. **Componentes**: Crie widgets reutilizáveis para cada tipo de componente

## Armazenamento de Dados

Os dados do onboarding podem ser sincronizados com servidores externos (como no caso do Supabase neste aplicativo), mas também devem funcionar offline:

1. **Armazenamento Local**: Salve o progresso no dispositivo para retomar mesmo sem conexão
2. **Sincronização**: Sincronize com o servidor quando houver conexão
3. **Resiliência**: Trate falhas de conexão graciosamente

## Elementos de Design

Para garantir a consistência visual:

1. **Cores**: Use uma paleta consistente com cores primárias, secundárias e tons neutros
2. **Tipografia**: Mantenha uma família de fontes consistente com variações de peso para hierarquia
3. **Espaçamento**: Use um sistema de espaçamento consistente (ex: 8, 16, 24, 32px)
4. **Bordas e Sombras**: Mantenha raios de borda e estilo de sombras consistentes
5. **Animações**: Adicione animações sutis para transições e interações
6. **Iconografia**: Use um conjunto de ícones consistentes

## Conclusão

Este documento fornece todas as informações necessárias para implementar o fluxo de onboarding do NicotinAI em qualquer plataforma. Siga estas especificações para criar uma experiência de usuário consistente e eficaz para ajudar os usuários a iniciar sua jornada para parar de fumar.