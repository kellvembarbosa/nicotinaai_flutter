# Migração para BLoC Pattern

Este documento descreve o processo de migração do padrão Provider para o padrão BLoC (Business Logic Component) no aplicativo NicotinaAI.

## Motivação

A migração do Provider para o BLoC visa:

1. **Separação de responsabilidades**: Melhor separação entre UI e lógica de negócios
2. **Testabilidade**: Componentes mais fáceis de testar isoladamente
3. **Previsibilidade**: Fluxo de dados unidirecional que torna as mudanças de estado mais previsíveis
4. **Reuso de código**: Lógica de negócios pode ser reutilizada em diferentes partes da UI
5. **Escalabilidade**: Melhor estrutura para lidar com o crescimento do app

## Novas Dependências

Foram adicionadas as seguintes dependências:

```yaml
dependencies:
  flutter_bloc: ^9.1.1
  bloc: ^9.0.0
  equatable: ^2.0.7
```

## Estrutura de Arquivos

A nova estrutura segue este padrão para cada feature:

```
lib/
├── blocs/
│   ├── <feature>/
│   │   ├── <feature>_bloc.dart
│   │   ├── <feature>_event.dart
│   │   └── <feature>_state.dart
│   └── app_bloc_observer.dart
```

## Componentes Principais

### 1. Events

Os eventos representam ações do usuário ou do sistema que disparam mudanças no estado:

```dart
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
```

### 2. States

Os estados representam o estado atual da UI e dos dados:

```dart
class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });
  
  @override
  List<Object?> get props => [status, user, errorMessage, isLoading];
}
```

### 3. BLoCs

Os BLoCs processam eventos e emitem novos estados:

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  AuthBloc({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository,
       super(AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    // ...
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthState.authenticating());
      
      final user = await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}
```

## Uso na UI

### Fornecendo BLoCs

No `main.dart`, usamos o `MultiBlocProvider` para fornecer os BLoCs:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        authRepository: authRepository,
      ),
    ),
    // Outros BLoCs...
  ],
  child: MaterialApp(
    // ...
  ),
)
```

### Consumindo BLoCs

Para acessar e reagir a mudanças no estado:

```dart
// Acesso ao BLoC
final authBloc = context.read<AuthBloc>();

// Disparar evento
authBloc.add(LoginRequested(email: email, password: password));

// Construir UI baseada no estado
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state.isLoading) {
      return CircularProgressIndicator();
    } else if (state.isAuthenticated) {
      return AuthenticatedView();
    } else {
      return LoginForm();
    }
  },
)

// Reagir a mudanças de estado
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }
  },
  child: MyWidget(),
)
```

## BLoCs Implementados

1. **AuthBloc**: Gerencia o estado de autenticação, incluindo login, registro e logout.
2. **TrackingBloc**: Gerencia dados de rastreamento, estatísticas do usuário e recuperações de saúde.
3. **SkeletonBloc**: Fornece um padrão simples para loading de dados.

## Debug

Foi implementado um `AppBlocObserver` para facilitar o debugging:

```dart
// Inicialização no main.dart
Bloc.observer = AppBlocObserver();
```

## Exemplos de Implementação

Para ver exemplos completos de implementação, consulte:

- `lib/blocs/auth/auth_bloc.dart`
- `lib/features/auth/screens/login_screen_bloc.dart`
- `lib/features/tracking/screens/dashboard_screen_with_bloc.dart`

## Próximos Passos

1. Migrar os providers restantes para o padrão BLoC
2. Adaptar todas as telas para usar BLoCs
3. Adicionar testes unitários para os BLoCs

## Referências

- [Documentação oficial do flutter_bloc](https://bloclibrary.dev)
- [Flutter Architecture Samples - BLoC](https://fluttersamples.com)