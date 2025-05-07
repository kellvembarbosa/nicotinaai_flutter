# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Run app: `flutter run`
- Build for production: `flutter build apk` (Android) or `flutter build ios` (iOS)
- Install dependencies: `flutter pub get`

## Test Commands
- Run all tests: `flutter test`
- Run a single test: `flutter test test/path/to/test_file.dart`
- Run with coverage: `flutter test --coverage`

## Lint Commands
- Run analyzer: `flutter analyze`
- Fix formatting: `dart format lib`

## Currency Handling System
- All monetary values in the database are stored in cents (integer values)
- Use `currency_formatter` package for displaying monetary values to users
- Use existing `CurrencyUtils` class in `/lib/utils/currency_utils.dart` for conversions
- The app detects the user's device currency by default
- Users can change their preferred currency in Settings
- When displaying monetary values:
  - Always use the user's preferred currency for display
  - Use `CurrencyFormatter` for input fields
  - Use `CurrencyUtils.format()` for output display
  - Use `CurrencyUtils.parseToCents()` before saving to database
- Key functions:
  - `format(int valueInCents)` - Display formatted currency with symbol
  - `formatCompact(int valueInCents)` - Display without decimal places
  - `parseToCents(String value)` - Convert string to cents for storage
  - `detectDeviceCurrencySymbol()` - Get device currency symbol
  - `detectDeviceCurrencyCode()` - Get device currency code

## Code Style Guidelines
- Follow Flutter's official style guide and linting rules
- Use named parameters for widgets with required annotation
- Prefer const constructors when possible
- Organize imports: dart:core first, then dart:*, then package imports, then relative imports
- Use PascalCase for classes/enums/typedefs, camelCase for variables/methods
- Prefix private members with underscore (_)
- Handle errors with try/catch blocks, use Result pattern or nullable returns
- Comments should explain "why" not "what"
- Use features from latest stable Flutter/Dart versions available

## Cursor Rules
- Always place cursor at the relevant position when showing code examples
- When demonstrating a function, position cursor at the function name
- For conditional statements, place cursor at the condition
- When explaining a loop, place cursor at the loop declaration
- For method calls, position cursor at the method name
- When editing widget properties, place cursor at the property being modified
- For errors, place cursor at the exact error location
- When explaining Optimistic State implementation:
  - For state backup, place cursor at the backup variable declaration
  - For state updates, place cursor at the setState call
  - For API/DB operations, place cursor at the await expression
  - For error handling, place cursor at the catch statement
  - For state rollback, place cursor at the rollback setState call

## Navigation and Routing
- Always use the AppRoutes enum for navigation instead of hardcoded strings
- Example: `context.go(AppRoutes.login.path)` instead of `context.go('/login')`
- All routes are defined in `/lib/core/routes/app_routes.dart`
- Available routes:
  - Authentication: `login`, `register`, `forgotPassword`
  - Main navigation: `main` (with tabs)
  - Individual tabs: `home`, `achievements`, `settings`
  - Other routes: `profile`, `editProfile`, `notifications`, `about`
- For navigation with parameters, use `AppRoutes.routeName.withParams({params})`
- When adding new screens, always add the corresponding route to the AppRoutes enum

## Optimistic State Pattern
- The app uses the Optimistic State pattern for "Craving" and "New Record" sheets
- Reference: [Flutter Optimistic State Design Pattern](https://docs.flutter.dev/app-architecture/design-patterns/optimistic-state)
- Implementation principles:
  - Immediately update UI assuming the operation will succeed
  - Capture the current state before the operation for potential rollback
  - Perform the actual operation (API call, DB update) in the background
  - Handle errors by reverting to the previous state if needed
  - Show appropriate feedback (success/error) after the operation completes
- When implementing:
  - Store a backup of the current state before modifying it
  - Update the UI immediately for better user experience
  - Use try/catch blocks to handle potential errors
  - Provide clear visual indicators of success/failure
  - Include undo functionality where appropriate
- Example code structure:
  ```dart
  // 1. Store original state
  final originalState = {..._currentState};
  
  // 2. Update state optimistically
  setState(() {
    _currentState = {..._currentState, ...newChanges};
  });
  
  try {
    // 3. Perform the actual operation
    await repository.saveChanges(newChanges);
    
    // 4. Operation succeeded, show success feedback
    showSuccessMessage('Changes saved successfully');
  } catch (e) {
    // 5. Operation failed, revert to original state
    setState(() {
      _currentState = originalState;
    });
    
    // 6. Show error feedback
    showErrorMessage('Failed to save changes: ${e.message}');
  }
  ```

## Expert Context
You are an expert in Flutter, Dart, Signals (state manager), Freezed, Flutter Hooks, and Supabase.

### Princípios-chave

* Escreva código Dart técnico e conciso com exemplos precisos.
* Use padrões funcionais e declarativos quando apropriado.
* Prefira composição ao invés de herança.
* Use nomes de variáveis descritivos com verbos auxiliares (ex.: `isLoading`, `hasError`).
* Estruture arquivos em camadas: widgets exportados, subwidgets, helpers, conteúdo estático, tipos.

### Arquitetura e Estado

* **MVC**: Separe camadas de Model, View e Controller. Controllers orquestram lógica e interagem com o Model. Views (Widgets) ficam puras.
* **Signals**: Utilize o gerenciador Signals para reatividade leve.

  * Crie `Signal<T>` para propriedades mutáveis e use `SignalBuilder` ou `useSignal` em Hooks para reconstruir Widgets.
  * Consulte a documentação completa de cada módulo do Signals:

    * Signal Core: [https://dartsignals.dev/core/signal/](https://dartsignals.dev/core/signal/)
    * Computed Core: [https://dartsignals.dev/core/computed/](https://dartsignals.dev/core/computed/)
    * Effect Core: [https://dartsignals.dev/core/effect/](https://dartsignals.dev/core/effect/)
    * Untracked Core: [https://dartsignals.dev/core/untracked/](https://dartsignals.dev/core/untracked/)
    * Batch Core: [https://dartsignals.dev/core/batch/](https://dartsignals.dev/core/batch/)
  * Minimize listeners manuais; deixe Signals notificar automaticamente.
* **Singletons & GetIt**: Registre controllers e serviços via GetIt:

  ```dart
  final getIt = GetIt.instance;
  getIt.registerLazySingleton<MyController>(() => MyController());
  ```

  * Recupere instâncias com `getIt<MyController>()` dentro de Views e Controllers.

### Dart/Flutter

* Utilize `const` constructors para Widgets imutáveis.
* Aproveite Freezed para classes de estado imutáveis e unions.
* Use sintaxe arrow (`=>`) para funções e métodos simples.
* Prefira corpos de expressão para getters/setters de uma linha.
* Use vírgulas finais para melhor formatação e diffs.

### Tratamento de Erros e Validação

* Trate erros em Views usando `SelectableText.rich` ao invés de SnackBars.
* Exiba mensagens de erro em vermelho para melhor visibilidade.
* Gerencie estados vazios com telas dedicadas de empty state.
* Com Signals: use `AsyncSignal<T>` ou combine `Signal<AsyncValue<T>>` para loading e error states.

### Signals-Specific Guidelines

* Crie providers de Signals no Controller, não na View.
* Use `dispose()` no Controller para liberar subscriptions de Streams ou timers.
* Injeção de dependências: Signals podem receber outras signals, mas evite dependências circulares.
* Forçar update: chame `signal.notifyListeners()` somente quando necessário.

### Otimizações de Performance

* Utilize `const` Widgets para reduzir rebuilds.
* Otimize listas com `ListView.builder`.
* Carregue imagens estáticas com `AssetImage` e remotas com `CachedNetworkImage`.
* Trate erros de Supabase (rede, autenticação) com captura nas requests e exiba feedback no Controller.

### Convenções Principais

1. Use `go_router` ou `auto_route` para navegação e deep linking.
2. Foque em métricas de performance: primeira pintura significativa, time-to-interactive.
3. Prefira Widgets sem estado:

   * `HookConsumerWidget` para Hooks + Signals.
   * `ConsumerWidget` apenas para dependência de Signals simples.

### UI e Estilo

* Use Widgets nativos e componha custom widgets pequenos.
* Design responsivo via `LayoutBuilder` ou `MediaQuery`.
* Utilize `Theme.of(context).textTheme.titleLarge` em vez de `headline6`.
* Separe estilos no tema do App (`ThemeData`).

### Modelagem e Banco de Dados

* Inclua `createdAt`, `updatedAt`, `isDeleted` nas tabelas.
* Use `@JsonSerializable(fieldRename: FieldRename.snake)`.
* Marque campos somente leitura com `@JsonKey(includeFromJson: true, includeToJson: false)`.

### Widgets e Componentes

* Crie pequenas classes privadas ao invés de métodos `_build...`.
* Implemente `RefreshIndicator` para pull-to-refresh.
* Configure `textCapitalization`, `keyboardType`, `textInputAction` em `TextField`.
* Sempre use `errorBuilder` em `Image.network`.

### Miscellaneous

* Use `log()` ao invés de `print()`.
* Use Flutter Hooks e Signals Hooks onde fizer sentido.
* Limite linhas a 80 caracteres; vírgula antes do `)` em multi-parâmetros.
* Enum para banco: `@JsonValue(int)`.

### Geração de Código

* Utilize `build_runner` para gerar código (Freezed, Signals, JSON).
* Após alterações, rode:

  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

### Documentação

* Documente lógica complexa e decisões não óbvias.
* Siga guias oficiais do Flutter, Signals e Supabase para melhores práticas.