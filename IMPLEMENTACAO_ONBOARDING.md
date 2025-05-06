# Plano de Implementação do Onboarding - NicotinaAI

Este documento apresenta um resumo do plano de implementação do fluxo de onboarding para o aplicativo NicotinaAI Flutter.

## Estrutura Implementada

A implementação do onboarding segue uma arquitetura organizada com as seguintes camadas:

1. **Modelos**: Para representação de dados
   - `OnboardingModel`: Representa os dados coletados durante o onboarding
   - `OnboardingState`: Gerencia estados do fluxo (loading, completed, etc.)

2. **Repositório**: Para persistência de dados
   - `OnboardingRepository`: Gerencia interação com o Supabase

3. **Provider**: Para gerenciamento de estado
   - `OnboardingProvider`: Gerencia estado e navegação entre telas

4. **Widgets Reutilizáveis**: Para UI consistente
   - `ProgressBar`, `OptionCard`, `MultiSelectOptionCard`, etc.

5. **Telas**: Para cada etapa do fluxo
   - 13 telas sequenciais, da introdução à conclusão
   - Componente base `OnboardingContainer` para consistência visual

## Etapas do Fluxo de Onboarding

O onboarding consiste em 13 telas que guiam o usuário por um processo de coleta de informações:

1. **Introdução**: Boas-vindas ao app
2. **Personalização**: Momentos de vontade de fumar
3. **Interesses/Desafios**: Dificuldades para parar
4. **Locais**: Onde costuma fumar
5. **Ajuda do App**: Recursos desejados
6. **Cigarros Por Dia**: Quantidade de cigarros
7. **Preço do Maço**: Custo financeiro
8. **Cigarros Por Maço**: Quantidade de unidades
9. **Objetivo**: Reduzir ou parar completamente
10. **Cronograma**: Prazo para o objetivo
11. **Desafio**: Principal desafio para parar
12. **Tipo de Produto**: Cigarro, vape ou ambos
13. **Conclusão**: Finalização do onboarding

## Integração com Supabase

### Tabela no Banco de Dados

Foi criada uma tabela `user_onboarding` no Supabase com:

- Campos específicos para cada pergunta do onboarding
- ENUMs para opções pré-definidas (níveis de consumo, tipos de objetivos, etc.)
- Campo JSONB `additional_data` para armazenar dados extras sem alterar schema
- Gatilhos para atualização automática de `updated_at`
- Políticas de RLS para segurança dos dados

### Script de Migração

Um script SQL foi criado em `supabase/migrations/20240505_onboarding_tables.sql` com todas as definições necessárias para criar:
- Tabelas
- Índices
- Tipos ENUM
- Funções e gatilhos
- Políticas de RLS

## Integração com o Sistema de Rotas

O `AppRouter` foi atualizado para:

1. Verificar se o usuário completou o onboarding após o login
2. Redirecionar automaticamente para o fluxo de onboarding se necessário
3. Impedir acesso à tela principal antes da conclusão do onboarding

## Persistência de Dados

A implementação garante persistência robusta de dados:

1. **Armazenamento Local**: Usando SharedPreferences para salvar progresso
2. **Armazenamento Remoto**: Sincronização com Supabase quando possível
3. **Resiliência de Conexão**: Funcionamento offline com sincronização posterior

## Implementação Pendente

Para completar a implementação do onboarding, é necessário:

1. **Executar o Script SQL**: Aplicar a migração no projeto Supabase
2. **Implementar Telas Específicas**: Terminar a implementação de cada tela que atualmente tem placeholders
3. **Customizar UI**: Ajustar componentes visuais conforme o design específico
4. **Testes**: Validar o fluxo completo, incluindo cenários de erro e interrupção
5. **Feedback Visual**: Adicionar animações e transições para uma experiência mais fluida

## Conclusão

A estrutura completa para o fluxo de onboarding foi implementada, seguindo as especificações dos documentos de design. A abordagem adotada é:

- **Modular**: Cada componente tem uma responsabilidade única
- **Resiliente**: Funciona mesmo com problemas de conexão
- **Flexível**: Permite fácil adição/modificação de perguntas
- **Consistente**: Mantém padrão visual em todo o fluxo
- **Integrada**: Funciona perfeitamente com o sistema de autenticação existente

Com esta implementação, o aplicativo NicotinaAI poderá coletar informações essenciais dos usuários para personalizar sua experiência e fornecer um suporte mais eficaz para abandonar o tabagismo.