# Project Rules - Flutter Clean Architecture

## 📱 Visão Geral

Regras e diretrizes para o desenvolvimento deste projeto Flutter, baseado na Clean Architecture com BLoC, Go Router e Flutter Hooks.

## 🏗️ Regras de Arquitetura

- **Camadas**: Domain (regras de negócio), Data (implementações), Presentation (UI e estado).
- **Independência**: Domain não depende de camadas externas.

## 🛠️ Stack Tecnológica

- **State Management**: BLoC para separação de lógica e UI.
- **Navegação**: Go Router para rotas declarativas.
- **Widgets**: Flutter Hooks para código limpo.

## 📁 Estrutura de Pastas

```
lib/
├── core/                    # Infraestrutura
├── features/               # Módulos
│   └── [feature_name]/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/                 # Reutilizáveis
└── main.dart
```

## 🔄 Fluxo de Desenvolvimento

1. Definir Domain.
2. Implementar Data.
3. Criar Presentation.
4. Configurar Router e DI.
5. Escrever testes.

## Padrão de Nomenclatura

- Entities: User, Product.
- Use Cases: LoginUseCase.
- BLoCs: AuthBloc.

## 🧪 Testes

- Unit, Widget, Integration.
- Meta: >80% cobertura.

## 📋 Convenções

- Usar Equatable em states.
- Error handling com Either.

## 🚀 Comandos

- build_runner para code gen.
- flutter pub get para dependências.

## 🔧 Configurações

- DI com get_it.
- Network com dio.

Essas regras garantem consistência e escalabilidade.