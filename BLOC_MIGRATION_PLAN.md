# Plano de Migração Provider → BLoC

Este documento descreve o plano para finalizar a migração do estado da aplicação de Provider para BLoC.

## Estado Atual

A migração foi concluída com sucesso!

- Todos os BLoCs correspondentes aos Providers foram implementados
- Todas as referências a Provider foram removidas do código
- O `AppRouter` agora usa `AuthBloc` e `OnboardingBloc`
- O Builder no `main.dart` agora usa `context.read<Bloc>()` em vez de `Provider.of`
- O pacote `provider` foi removido das dependências em pubspec.yaml

## Etapas Realizadas

### 1. Criado Adaptador para GoRouter com BLoC
Implementamos o `RouterRefreshStream` para adaptar BLoCs para o sistema de refresh do GoRouter:

```dart
class RouterRefreshStream<B extends BlocBase<S>, S> extends ChangeNotifier {
  final B _bloc;
  final bool Function(S state)? _shouldRefresh;
  
  late final StreamSubscription<S> _subscription;
  
  RouterRefreshStream(this._bloc, {bool Function(S state)? shouldRefresh}) 
    : _shouldRefresh = shouldRefresh {
    _subscription = _bloc.stream.listen((state) {
      if (_shouldRefresh == null || _shouldRefresh(state)) {
        notifyListeners();
      }
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

### 2. Atualizado o AppRouter para usar BLoC
AppRouter foi completamente atualizado para usar AuthBloc e OnboardingBloc:

```dart
class AppRouter {
  final AuthBloc authBloc;
  final OnboardingBloc onboardingBloc;
  
  AppRouter({
    required this.authBloc,
    required this.onboardingBloc,
  });
  
  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: RouterRefreshStream(authBloc),
    initialLocation: SplashScreen.routeName,
    redirect: _handleRedirect,
    // ...
  );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    // ...
    final isAuthenticated = authBloc.state.isAuthenticated;
    final onboardingCompleted = onboardingBloc.state.isCompleted;
    // ...
  }
}
```

### 3. Atualizado main.dart
Substituído MultiProvider por MultiBlocProvider e atualizadas todas as instanciações:

```dart
child: Builder(
  builder: (context) {
    // Inicializar o router usando os BLoCs
    final authBloc = context.read<AuthBloc>();
    final onboardingBloc = context.read<OnboardingBloc>();
      
    // Criar router usando BLoCs para evitar loop de reconstrução
    final appRouter = AppRouter(
      authBloc: authBloc,
      onboardingBloc: onboardingBloc,
    );
    
    // ...
  }
)
```

### 4. Atualizado todos os widgets
Todos os widgets que usavam Provider.of foram atualizados para usar context.watch ou context.read.

### 5. Removido Provider do pubspec.yaml
O pacote provider foi removido das dependências do projeto.

### 6. Verificação Final
Confirmado que não existem mais referências ao pacote provider no código.

## Benefícios da Migração

1. **Manutenibilidade**: Uma única solução de gerenciamento de estado em vez de duas
2. **Testabilidade**: BLoCs são mais facilmente testáveis que Providers
3. **Separação de Responsabilidades**: Melhor separação entre UI, lógica de negócios e estado
4. **Performance**: Redução de rebuilds desnecessários

## Prazo Sugerido

1. Planejamento e Análise: 1 dia
2. Implementação da Migração: 2-3 dias
3. Testes e Correções: 1-2 dias
4. Total: 4-6 dias de trabalho

## Notas Adicionais

- Não implementar novas funcionalidades durante a migração
- Fazer commits incrementais para cada parte da migração
- Manter testes automatizados rodando durante todo o processo