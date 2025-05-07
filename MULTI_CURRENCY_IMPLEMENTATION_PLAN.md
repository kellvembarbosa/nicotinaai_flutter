# Plano de Implementação do Sistema Multi-Moeda

Este documento descreve o plano para implementar um sistema de multi-moeda robusto no aplicativo NicotinaAI, permitindo que usuários utilizem o app com sua moeda local preferida.

## Princípios Básicos

1. **Armazenamento**: Todos os valores monetários são armazenados no banco de dados como inteiros em centavos (cents)
2. **Exibição**: Os valores são formatados na moeda preferida do usuário antes da exibição
3. **Entrada**: Os campos de entrada de valores monetários formatam automaticamente o valor conforme o usuário digita
4. **Conversão**: Ao alterar a moeda, os valores não são convertidos (apenas o formato muda)

## Componentes Necessários

### 1. Modelo de Dados

1. Adicionar campos ao modelo de usuário (`UserModel`):
   - `String currencyCode` - Código da moeda (ex: USD, BRL, EUR)
   - `String currencySymbol` - Símbolo da moeda (ex: $, R$, €)
   - `String currencyLocale` - Locale associada à moeda (ex: en_US, pt_BR)

### 2. Banco de Dados

1. Atualizar a tabela `profiles` no Supabase:
   ```sql
   ALTER TABLE profiles
   ADD COLUMN currency_code VARCHAR(3) DEFAULT 'BRL',
   ADD COLUMN currency_symbol VARCHAR(5) DEFAULT 'R$',
   ADD COLUMN currency_locale VARCHAR(10) DEFAULT 'pt_BR';
   ```

2. Garantir que toda tabela que armazena valores monetários use o tipo `INTEGER` para armazenar centavos.

### 3. Utilitários de Moeda

1. Atualizar `CurrencyUtils` para integrar com o pacote `currency_formatter`:
   - Adicionar métodos para criação de formatadores
   - Integrar com a API `CurrencyFormatter` para inputs e exibição
   - Manter a compatibilidade com o código existente

2. Criar uma lista de moedas suportadas com as seguintes informações:
   - Código da moeda (USD, BRL, EUR)
   - Símbolo (R$, $, €)
   - Nome (Dólar Americano, Real Brasileiro, Euro)
   - Locale (en_US, pt_BR, es_ES)

### 4. UI para Seleção de Moeda

1. Criar um novo componente de seleção de moeda:
   - Lista de moedas com código, símbolo e nome
   - Pesquisa com filtragem
   - Indicação visual da moeda selecionada

2. Adicionar à tela de Configurações:
   - Nova opção "Moeda" na seção "Configurações do Aplicativo"
   - Mostra a moeda atual por padrão
   - Ao clicar, abre o componente de seleção de moeda

### 5. Provider para Gerenciamento de Moeda

1. Criar `CurrencyProvider`:
   - Armazena a moeda atual do usuário
   - Fornece métodos para formatar valores
   - Manipula a mudança de moeda pelo usuário
   - Persiste a escolha no perfil do usuário

2. Integrar `CurrencyProvider` com `AuthProvider`:
   - Inicializar `CurrencyProvider` quando o usuário faz login
   - Atualizar os dados da moeda no perfil quando o usuário a altera

### 6. Widgets para Entrada e Exibição de Valores Monetários

1. `CurrencyInputField`:
   - Campo de entrada com formatação automática
   - Usa `currency_formatter` para formatação em tempo real
   - Converte automaticamente para centavos no evento onSaved/onChanged

2. `CurrencyText`:
   - Widget para exibição de valores monetários
   - Formata o valor de acordo com a moeda do usuário
   - Suporta diferentes estilos (compacto, completo)

## Integrações

### 1. Tela de Preço do Maço (Onboarding)

1. Substituir o campo de entrada atual por `CurrencyInputField`
2. Mostrar preço formatado na moeda do usuário

### 2. Tela Inicial (Home)

1. Atualizar os widgets que exibem economia de dinheiro para usar `CurrencyText`
2. Garantir que os cálculos de economia sejam feitos em centavos

### 3. Tela de Conquistas

1. Atualizar os widgets que exibem economia de dinheiro para usar `CurrencyText`
2. Formatar os valores de economia acumulada na moeda do usuário

### 4. Geração de Relatórios

1. Garantir que todos os relatórios exibam valores na moeda do usuário
2. Incluir o símbolo da moeda nos gráficos de economia

## Plano de Implementação

### Fase 1: Preparação do Banco de Dados

1. Criar e aplicar migração para adicionar colunas à tabela `profiles`
2. Verificar todas as tabelas que armazenam valores monetários

### Fase 2: Adaptar Utilitários e Criar Providers

1. Atualizar `CurrencyUtils` para integrar com `currency_formatter`
2. Implementar `CurrencyProvider`
3. Integrar com sistema de autenticação existente

### Fase 3: Desenvolver Componentes de UI

1. Implementar `CurrencyInputField`
2. Implementar `CurrencyText`
3. Criar tela de seleção de moeda

### Fase 4: Integrar nas Telas Existentes

1. Atualizar tela de configurações para incluir seleção de moeda
2. Atualizar telas de onboarding
3. Atualizar tela inicial e de conquistas

### Fase 5: Testes e Refinamento

1. Testar com diferentes moedas e locales
2. Verificar se todos os valores são armazenados corretamente como centavos
3. Confirmar que as alterações de moeda são refletidas imediatamente na UI
4. Testar com volumes grandes de dinheiro (para garantir que não há overflow)

## Lista de Moedas Suportadas (Fase Inicial)

1. Real Brasileiro (BRL, R$, pt_BR)
2. Dólar Americano (USD, $, en_US)
3. Euro (EUR, €, es_ES)
4. Libra Esterlina (GBP, £, en_GB)
5. Peso Argentino (ARS, $, es_AR)
6. Peso Mexicano (MXN, $, es_MX)
7. Dólar Canadense (CAD, $, en_CA)
8. Iene Japonês (JPY, ¥, ja_JP)
9. Yuan Chinês (CNY, ¥, zh_CN)
10. Dólar Australiano (AUD, $, en_AU)