import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/core/exceptions/auth_exception.dart' as app_exceptions;
import 'package:nicotinaai_flutter/features/auth/repositories/auth_repository.dart';
import 'package:nicotinaai_flutter/features/home/providers/craving_provider.dart';
import 'package:nicotinaai_flutter/features/home/providers/smoking_record_provider.dart';
import 'package:nicotinaai_flutter/features/tracking/providers/tracking_provider.dart';
import 'package:nicotinaai_flutter/services/analytics_service.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';
import 'package:nicotinaai_flutter/services/storage_service.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
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
    on<ClearAuthErrorRequested>(_onClearAuthErrorRequested);
    
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
      
      // Track login event in analytics
      try {
        await AnalyticsService().logLogin(method: 'email');
        await AnalyticsService().setUserProperties(
          userId: user.id,
          email: user.email,
        );
        print('📊 [AuthBloc] Login event tracked in analytics');
      } catch (analyticsError) {
        print('⚠️ [AuthBloc] Failed to track login event: $analyticsError');
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
      
      // Track signup event in analytics
      try {
        await AnalyticsService().logSignUp(method: 'email');
        await AnalyticsService().setUserProperties(
          userId: user.id,
          email: user.email,
        );
        print('📊 [AuthBloc] Signup event tracked in analytics');
      } catch (analyticsError) {
        print('⚠️ [AuthBloc] Failed to track signup event: $analyticsError');
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
      
      // Clear analytics data before signing out
      try {
        await AnalyticsService().clearUserData();
        print('🧹 [AuthBloc] Analytics data cleared');
      } catch (analyticsError) {
        print('⚠️ [AuthBloc] Failed to clear analytics data: $analyticsError');
      }
      
      // Limpar dados locais dos providers
      try {
        // Importar os providers necessários
        final cravingProvider = _getCravingProvider();
        final smokingRecordProvider = _getSmokingRecordProvider();
        final trackingProvider = _getTrackingProvider();
        
        if (cravingProvider != null) {
          cravingProvider.clearCravings();
          print('🧹 [AuthBloc] Cravings data cleared');
        }
        
        if (smokingRecordProvider != null) {
          smokingRecordProvider.clearRecords();
          print('🧹 [AuthBloc] Smoking records data cleared');
        }
        
        if (trackingProvider != null) {
          trackingProvider.resetStats();
          print('🧹 [AuthBloc] Tracking stats reset');
        }
      } catch (providersError) {
        print('⚠️ [AuthBloc] Failed to clear providers data: $providersError');
      }
      
      // Limpar dados do storage seguro
      try {
        final storageService = StorageService();
        await storageService.clearAll();
        print('🧹 [AuthBloc] Secure storage cleared');
      } catch (storageError) {
        print('⚠️ [AuthBloc] Failed to clear secure storage: $storageError');
      }
      
      await _authRepository.signOut();
      print('✅ [AuthBloc] Logout realizado com sucesso');
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
  
  // Métodos auxiliares para obter instâncias dos providers
  // Nota: Estes métodos são simplificados e devem ser adaptados para uma
  // solução de injeção de dependência adequada no futuro
  CravingProvider? _getCravingProvider() {
    try {
      return null; // Deve ser implementado com uma solução real de DI
    } catch (e) {
      print('⚠️ [AuthBloc] Erro ao obter CravingProvider: $e');
      return null;
    }
  }
  
  SmokingRecordProvider? _getSmokingRecordProvider() {
    try {
      return null; // Deve ser implementado com uma solução real de DI
    } catch (e) {
      print('⚠️ [AuthBloc] Erro ao obter SmokingRecordProvider: $e');
      return null;
    }
  }
  
  TrackingProvider? _getTrackingProvider() {
    try {
      return null; // Deve ser implementado com uma solução real de DI
    } catch (e) {
      print('⚠️ [AuthBloc] Erro ao obter TrackingProvider: $e');
      return null;
    }
  }
}