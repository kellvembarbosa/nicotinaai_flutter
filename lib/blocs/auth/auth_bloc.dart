import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nicotinaai_flutter/core/exceptions/auth_exception.dart' as app_exceptions;
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';
import 'package:nicotinaai_flutter/services/storage_service.dart';
import 'package:nicotinaai_flutter/services/identity_service.dart';
import 'package:nicotinaai_flutter/core/routes/router_events.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final AnalyticsService _analyticsService = AnalyticsService();
  final IdentityService _identityService = IdentityService();
  
  AuthBloc({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository,
       super(AuthState.initial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RefreshAuthStateRequested>(_onRefreshAuthStateRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<UpdateUserDataRequested>(_onUpdateUserDataRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<UpdateProfile>(_onUpdateProfile);
    on<ClearAuthErrorRequested>(_onClearAuthErrorRequested);
    on<AccountDeletedLogout>(_onAccountDeletedLogout);
    
    // Verificar autenticação ao iniciar o BLoC
    add(const CheckAuthStatusRequested());
  }
  
  /// Verifica o estado atual de autenticação
  Future<void> _onCheckAuthStatusRequested(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Define o estado como carregando
      emit(AuthState.initial());
      
      print('🔍 [AuthBloc] Verificando estado de autenticação');
      
      // Verifica se há uma sessão válida
      final hasSession = await _authRepository.hasSession();
      
      if (!hasSession) {
        print('🔒 [AuthBloc] Nenhuma sessão encontrada');
        emit(AuthState.unauthenticated());
        return;
      }
      
      print('🔓 [AuthBloc] Sessão encontrada');
      
      // Obtém o usuário da sessão atual
      final user = await _authRepository.getSession();
      
      if (user != null) {
        print('👤 [AuthBloc] Usuário autenticado: ${user.email}');
        
        // Initialize user identity across platforms
        try {
          await _identityService.initializeUserIdentity(user);
          print('🔗 [AuthBloc] User identity initialized across platforms');
        } catch (identityError) {
          print('⚠️ [AuthBloc] Failed to initialize identity across platforms: $identityError');
        }
        
        emit(AuthState.authenticated(user));
      } else {
        print('⚠️ [AuthBloc] Sessão encontrada, mas sem usuário válido');
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      print('❌ [AuthBloc] Erro ao verificar autenticação: $e');
      emit(AuthState.unauthenticated());
    }
  }
  
  /// Realiza o login com e-mail e senha
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('🔄 [AuthBloc] Início do login: ${DateTime.now()}');
      emit(AuthState.authenticating());
      
      final user = await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      
      print('✅ [AuthBloc] Usuário autenticado: ${user.email}');
      
      // Salvar o token FCM para o usuário que acabou de logar
      await NotificationService().saveFcmTokenAfterLogin();
      print('🔔 [AuthBloc] Token FCM salvo após login');
      
      // Request tracking permissions for Facebook attribution
      try {
        await _analyticsService.requestTrackingPermissions();
        print('🔍 [AuthBloc] Requested tracking permissions for better attribution');
      } catch (trackingError) {
        print('⚠️ [AuthBloc] Failed to request tracking permissions: $trackingError');
      }
      
      // Initialize user identity and track login event across all platforms
      try {
        // Initialize user identity (RevenueCat, Superwall, PostHog)
        await _identityService.initializeUserIdentity(user);
        
        // Track login event separately
        await _analyticsService.logLogin(method: 'email');
        
        print('🔗 [AuthBloc] User identified and login event tracked across all platforms');
      } catch (identityError) {
        print('⚠️ [AuthBloc] Failed to manage user identity: $identityError');
      }
      
      emit(AuthState.authenticated(user));
      print('📊 [AuthBloc] Estado atualizado para autenticado: ${DateTime.now()}');
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthBloc] Erro na autenticação: ${error.message}');
      emit(AuthState.error(error.message));
    }
  }
  
  /// Realiza o registro com e-mail e senha
  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('🔄 [AuthBloc] Iniciando registro');
      emit(AuthState.authenticating());
      
      final user = await _authRepository.signUpWithEmailAndPassword(
        event.email,
        event.password,
        name: event.name,
      );
      
      print('✅ [AuthBloc] Usuário registrado com sucesso: ${user.email}');
      
      // Salvar o token FCM para o usuário recém-registrado
      await NotificationService().saveFcmTokenAfterLogin();
      print('🔔 [AuthBloc] Token FCM salvo após registro');
      
      // Request tracking permissions for Facebook attribution
      try {
        await _analyticsService.requestTrackingPermissions();
        print('🔍 [AuthBloc] Requested tracking permissions for better attribution');
      } catch (trackingError) {
        print('⚠️ [AuthBloc] Failed to request tracking permissions: $trackingError');
      }
      
      // Initialize user identity and track signup event across all platforms
      try {
        // Initialize user identity (RevenueCat, Superwall, PostHog)
        await _identityService.initializeUserIdentity(user);
        
        // Track signup event separately
        await _analyticsService.logSignUp(method: 'email');
        
        print('🔗 [AuthBloc] User identified and signup event tracked across all platforms');
      } catch (identityError) {
        print('⚠️ [AuthBloc] Failed to manage user identity: $identityError');
      }
      
      emit(AuthState.authenticated(user));
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthBloc] Erro no registro: ${error.message}');
      emit(AuthState.error(error.message));
    }
  }
  
  /// Realiza o logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('🔄 [AuthBloc] Iniciando logout');
      emit(state.copyWith(isLoading: true));
      
      // Reset user identity across all platforms before signing out
      try {
        await _identityService.resetUserIdentity();
        print('🧹 [AuthBloc] User identity reset across all platforms');
      } catch (identityError) {
        print('⚠️ [AuthBloc] Failed to reset user identity: $identityError');
      }
      
      // Limpar dados de armazenamento local usando SharedPreferences
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print('🧹 [AuthBloc] SharedPreferences cleared');
      } catch (prefsError) {
        print('⚠️ [AuthBloc] Failed to clear SharedPreferences: $prefsError');
      }
      
      // Limpar dados do storage seguro
      try {
        final storageService = StorageService();
        await storageService.clearAll();
        print('🧹 [AuthBloc] Secure storage cleared');
      } catch (storageError) {
        print('⚠️ [AuthBloc] Failed to clear secure storage: $storageError');
      }
      
      // Usar RouterEvents para limpar dados em todos os BLoCs se o contexto estiver disponível
      if (event.context != null) {
        try {
          RouterEvents.clearAllUserData(event.context!);
          print('🧹 [AuthBloc] Todos os dados de BLoCs foram limpos');
        } catch (routerEventsError) {
          print('⚠️ [AuthBloc] Erro ao usar RouterEvents: $routerEventsError');
        }
      } else {
        print('⚠️ [AuthBloc] Context não disponível para usar RouterEvents');
      }
      
      // Efetuar o logout no Supabase
      await _authRepository.signOut();
      print('✅ [AuthBloc] Logout realizado com sucesso');
      
      // Emitir o estado de não autenticado uma única vez é suficiente
      // Usando Future.delayed com emit() causava o erro "emit after completion"
      print('🔄 [AuthBloc] Emitindo estado final de não autenticado após logout');
      emit(AuthState.unauthenticated());
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthBloc] Erro no logout: ${error.message}');
      emit(AuthState.error(error.message));
    }
  }
  
  /// Força a verificação do estado atual de autenticação
  Future<void> _onRefreshAuthStateRequested(
    RefreshAuthStateRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 [AuthBloc] Atualizando estado de autenticação');
    add(const CheckAuthStatusRequested());
  }
  
  /// Envia e-mail para recuperação de senha
  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('🔄 [AuthBloc] Enviando e-mail de recuperação de senha');
      emit(state.copyWith(isLoading: true));
      
      await _authRepository.sendPasswordResetEmail(event.email);
      
      print('✉️ [AuthBloc] E-mail de recuperação enviado');
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthBloc] Erro ao enviar e-mail: ${error.message}');
      emit(AuthState.error(error.message));
    }
  }
  
  /// Atualiza os dados do usuário
  Future<void> _onUpdateUserDataRequested(
    UpdateUserDataRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('🔄 [AuthBloc] Atualizando dados do usuário');
      emit(state.copyWith(isLoading: true));
      
      final updatedUser = await _authRepository.updateUserData(
        name: event.name,
        avatarUrl: event.avatarUrl,
        currencyCode: event.currencyCode,
        currencySymbol: event.currencySymbol,
        currencyLocale: event.currencyLocale,
      );
      
      print('✅ [AuthBloc] Dados atualizados com sucesso');
      
      // Update user identity across platforms after data update
      try {
        await _identityService.updateUserIdentity(updatedUser);
        print('🔗 [AuthBloc] User identity updated across all platforms');
      } catch (identityError) {
        print('⚠️ [AuthBloc] Failed to update user identity: $identityError');
      }
      
      emit(AuthState.authenticated(updatedUser));
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthBloc] Erro ao atualizar dados: ${error.message}');
      emit(AuthState.error(error.message));
    }
  }
  
  /// Atualiza o perfil completo do usuário
  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('🔄 [AuthBloc] Atualizando perfil do usuário');
      emit(state.copyWith(isLoading: true));
      
      final updatedUser = await _authRepository.updateUserProfile(event.user);
      
      print('✅ [AuthBloc] Perfil atualizado com sucesso');
      
      // Update user identity across platforms after profile update
      try {
        await _identityService.updateUserIdentity(updatedUser);
        print('🔗 [AuthBloc] User identity updated across all platforms');
      } catch (identityError) {
        print('⚠️ [AuthBloc] Failed to update user identity: $identityError');
      }
      
      emit(AuthState.authenticated(updatedUser));
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthBloc] Erro ao atualizar perfil: ${error.message}');
      emit(AuthState.error(error.message));
    }
  }
  
  /// Atualiza o perfil do usuário (alternativa simplificada)
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('🔄 [AuthBloc] Atualizando perfil do usuário via UpdateProfile');
      emit(state.copyWith(isLoading: true));
      
      final updatedUser = await _authRepository.updateUserProfile(event.user);
      
      print('✅ [AuthBloc] Perfil atualizado com sucesso');
      
      // Update user identity across platforms after profile update
      try {
        await _identityService.updateUserIdentity(updatedUser);
        print('🔗 [AuthBloc] User identity updated across all platforms');
      } catch (identityError) {
        print('⚠️ [AuthBloc] Failed to update user identity: $identityError');
      }
      
      emit(AuthState.authenticated(updatedUser));
    } catch (e) {
      final error = e is app_exceptions.AuthException
          ? e
          : app_exceptions.AuthException.fromSupabaseError(e);
          
      print('❌ [AuthBloc] Erro ao atualizar perfil: ${error.message}');
      emit(AuthState.error(error.message));
    }
  }

  /// Limpa uma mensagem de erro
  void _onClearAuthErrorRequested(
    ClearAuthErrorRequested event,
    Emitter<AuthState> emit,
  ) {
    if (state.errorMessage != null) {
      emit(state.copyWith(
        errorMessage: null,
        status: state.user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      ));
    }
  }
  
  // Os métodos auxiliares para obter instâncias dos providers foram removidos
  // pois não são mais necessários com a migração para BLoCs
  
  /// Handler para forçar o logout após a exclusão da conta
  /// Similar ao _onLogoutRequested, mas sem tentar fazer signOut no Supabase
  /// já que a conta já foi excluída
  Future<void> _onAccountDeletedLogout(
    AccountDeletedLogout event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('🔄 [AuthBloc] Forçando logout após exclusão de conta');
      emit(state.copyWith(isLoading: true));
      
      // Reset user identity across all platforms after account deletion
      try {
        await _identityService.resetUserIdentity();
        print('🧹 [AuthBloc] User identity reset across all platforms after account deletion');
      } catch (identityError) {
        print('⚠️ [AuthBloc] Failed to reset user identity: $identityError');
      }
      
      // Limpar dados de armazenamento local usando SharedPreferences
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print('🧹 [AuthBloc] SharedPreferences cleared after account deletion');
      } catch (prefsError) {
        print('⚠️ [AuthBloc] Failed to clear SharedPreferences: $prefsError');
      }
      
      // Limpar dados do storage seguro
      try {
        final storageService = StorageService();
        await storageService.clearAll();
        print('🧹 [AuthBloc] Secure storage cleared after account deletion');
      } catch (storageError) {
        print('⚠️ [AuthBloc] Failed to clear secure storage: $storageError');
      }
      
      // Tentar limpar todos os dados possíveis do Supabase localmente
      try {
        // Criar uma nova sessão e invalidar a atual
        _authRepository.invalidateSession();
        print('🧹 [AuthBloc] Local Supabase session invalidated');
      } catch (sessionError) {
        print('⚠️ [AuthBloc] Failed to invalidate local session: $sessionError');
      }
      
      // NÃO tenta fazer signOut no Supabase, pois a conta já não existe mais
      
      // Emitir o estado de não autenticado uma única vez é suficiente
      // Usando Future.delayed com emit() causava o erro "emit after completion"
      print('🔄 [AuthBloc] Emitindo estado final de não autenticado');
      emit(AuthState.unauthenticated());
    } catch (e) {
      print('❌ [AuthBloc] Erro ao forçar logout após exclusão: $e');
      // Mesmo com erro, forçamos o estado de não autenticado
      emit(AuthState.unauthenticated());
    }
  }
}