import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_event.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart';
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';

// Criar classe mock para o repositório de autenticação
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository authRepository;
  late AuthBloc authBloc;
  
  // Configuração global antes de cada teste
  setUp(() {
    authRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: authRepository);
  });
  
  // Limpeza após cada teste
  tearDown(() {
    authBloc.close();
  });
  
  // Definindo dados de teste
  final testUser = UserModel(
    id: 'test-id',
    email: 'test@example.com',
    name: 'Test User',
  );
  
  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  
  group('AuthBloc', () {
    test('Estado inicial deve ser inicial', () {
      expect(authBloc.state, AuthState.initial());
    });
    
    blocTest<AuthBloc, AuthState>(
      'emite [loading, unauthenticated] quando não há sessão',
      build: () {
        when(() => authRepository.hasSession()).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [
        AuthState.initial(),
        AuthState.unauthenticated(),
      ],
    );
    
    blocTest<AuthBloc, AuthState>(
      'emite [loading, authenticated] quando há sessão',
      build: () {
        when(() => authRepository.hasSession()).thenAnswer((_) async => true);
        when(() => authRepository.getSession()).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [
        AuthState.initial(),
        AuthState.authenticated(testUser),
      ],
    );
    
    blocTest<AuthBloc, AuthState>(
      'emite [authenticating, authenticated] quando login bem-sucedido',
      build: () {
        when(() => authRepository.signInWithEmailAndPassword(
          testEmail, 
          testPassword,
        )).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        AuthState.authenticating(),
        AuthState.authenticated(testUser),
      ],
    );
    
    blocTest<AuthBloc, AuthState>(
      'emite [authenticating, error] quando login falha',
      build: () {
        when(() => authRepository.signInWithEmailAndPassword(
          testEmail, 
          testPassword,
        )).thenThrow(Exception('Login failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        AuthState.authenticating(),
        AuthState.error('Exception: Login failed'),
      ],
    );
    
    blocTest<AuthBloc, AuthState>(
      'emite [authenticating, authenticated] quando registro bem-sucedido',
      build: () {
        when(() => authRepository.signUpWithEmailAndPassword(
          testEmail,
          testPassword,
          name: 'New User',
        )).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignUpRequested(
        email: testEmail,
        password: testPassword,
        name: 'New User',
      )),
      expect: () => [
        AuthState.authenticating(),
        AuthState.authenticated(testUser),
      ],
    );
    
    blocTest<AuthBloc, AuthState>(
      'emite [loading, unauthenticated] após logout',
      build: () {
        when(() => authRepository.signOut()).thenAnswer((_) async {});
        return authBloc;
      },
      seed: () => AuthState.authenticated(testUser),
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        AuthState.authenticated(testUser).copyWith(isLoading: true),
        AuthState.unauthenticated(),
      ],
    );
    
    blocTest<AuthBloc, AuthState>(
      'emite estado sem erro quando ClearAuthError é chamado',
      build: () => authBloc,
      seed: () => AuthState.error('Some error'),
      act: (bloc) => bloc.add(const ClearAuthErrorRequested()),
      expect: () => [
        AuthState.error('Some error').copyWith(
          errorMessage: null,
          status: AuthStatus.unauthenticated,
        ),
      ],
    );
  });
}