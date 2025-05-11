import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_event.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_state.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';

/// BLoC for analytics tracking events
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsService _analyticsService;
  
  AnalyticsBloc({AnalyticsService? analyticsService})
      : _analyticsService = analyticsService ?? AnalyticsService(),
        super(const AnalyticsState()) {
    on<InitializeAnalyticsEvent>(_onInitialize);
    on<TrackCustomEvent>(_onTrackCustomEvent);
    on<SetUserPropertiesEvent>(_onSetUserProperties);
    on<ClearUserDataEvent>(_onClearUserData);
    on<AddAnalyticsProviderEvent>(_onAddAnalyticsProvider);
    on<RemoveAnalyticsProviderEvent>(_onRemoveAnalyticsProvider);
    
    // Convenience events
    on<LogAppOpenEvent>(_onLogAppOpen);
    on<LogLoginEvent>(_onLogLogin);
    on<LogSignUpEvent>(_onLogSignUp);
    on<LogSmokingFreeMilestoneEvent>(_onLogSmokingFreeMilestone);
    on<LogHealthRecoveryAchievedEvent>(_onLogHealthRecoveryAchieved);
    on<LogCravingResistedEvent>(_onLogCravingResisted);
    on<LogMoneySavedMilestoneEvent>(_onLogMoneySavedMilestone);
    on<LogCompletedOnboardingEvent>(_onLogCompletedOnboarding);
    on<LogFeatureUsageEvent>(_onLogFeatureUsage);
  }
  
  Future<void> _onInitialize(InitializeAnalyticsEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.initialize();
      
      emit(state.copyWith(
        isInitialized: true,
        activeProviders: _analyticsService.activeAdapters,
      ));
      
      debugPrint('✅ [AnalyticsBloc] Analytics initialized successfully');
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to initialize analytics: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error initializing analytics: $e');
    }
  }
  
  Future<void> _onTrackCustomEvent(TrackCustomEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.trackEvent(event.eventName, parameters: event.parameters);
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to track event: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error tracking event: $e');
    }
  }
  
  Future<void> _onSetUserProperties(SetUserPropertiesEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.setUserProperties(
        userId: event.userId,
        email: event.email,
        daysSmokeFree: event.daysSmokeFree,
        cigarettesPerDay: event.cigarettesPerDay,
        pricePerPack: event.pricePerPack,
        currency: event.currency,
        additionalProperties: event.additionalProperties,
      );
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to set user properties: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error setting user properties: $e');
    }
  }
  
  Future<void> _onClearUserData(ClearUserDataEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.clearUserData();
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to clear user data: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error clearing user data: $e');
    }
  }
  
  Future<void> _onAddAnalyticsProvider(AddAnalyticsProviderEvent event, Emitter<AnalyticsState> emit) async {
    try {
      final success = await _analyticsService.addAdapter(event.providerName, config: event.providerConfig);
      
      if (success) {
        emit(state.copyWith(
          activeProviders: _analyticsService.activeAdapters,
        ));
        debugPrint('✅ [AnalyticsBloc] Added analytics provider: ${event.providerName}');
      } else {
        emit(state.copyWith(
          error: () => 'Failed to add analytics provider: ${event.providerName}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to add analytics provider: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error adding analytics provider: $e');
    }
  }
  
  Future<void> _onRemoveAnalyticsProvider(RemoveAnalyticsProviderEvent event, Emitter<AnalyticsState> emit) async {
    try {
      final success = _analyticsService.removeAdapter(event.providerName);
      
      if (success) {
        emit(state.copyWith(
          activeProviders: _analyticsService.activeAdapters,
        ));
        debugPrint('✅ [AnalyticsBloc] Removed analytics provider: ${event.providerName}');
      } else {
        emit(state.copyWith(
          error: () => 'Failed to remove analytics provider: ${event.providerName}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to remove analytics provider: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error removing analytics provider: $e');
    }
  }
  
  // Convenience event handlers
  
  Future<void> _onLogAppOpen(LogAppOpenEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.logAppOpen();
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to log app open: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error logging app open: $e');
    }
  }
  
  Future<void> _onLogLogin(LogLoginEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.logLogin(method: event.method);
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to log login: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error logging login: $e');
    }
  }
  
  Future<void> _onLogSignUp(LogSignUpEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.logSignUp(method: event.method);
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to log sign up: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error logging sign up: $e');
    }
  }
  
  Future<void> _onLogSmokingFreeMilestone(LogSmokingFreeMilestoneEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.logSmokingFreeMilestone(event.days);
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to log smoking free milestone: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error logging smoking free milestone: $e');
    }
  }
  
  Future<void> _onLogHealthRecoveryAchieved(LogHealthRecoveryAchievedEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.logHealthRecoveryAchieved(event.recoveryName);
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to log health recovery achieved: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error logging health recovery achieved: $e');
    }
  }
  
  Future<void> _onLogCravingResisted(LogCravingResistedEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.logCravingResisted(triggerType: event.triggerType);
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to log craving resisted: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error logging craving resisted: $e');
    }
  }
  
  Future<void> _onLogMoneySavedMilestone(LogMoneySavedMilestoneEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.logMoneySavedMilestone(event.amount, event.currency);
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to log money saved milestone: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error logging money saved milestone: $e');
    }
  }
  
  Future<void> _onLogCompletedOnboarding(LogCompletedOnboardingEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.logCompletedOnboarding();
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to log completed onboarding: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error logging completed onboarding: $e');
    }
  }
  
  Future<void> _onLogFeatureUsage(LogFeatureUsageEvent event, Emitter<AnalyticsState> emit) async {
    try {
      await _analyticsService.logFeatureUsage(event.featureName);
      emit(state.clearError());
    } catch (e) {
      emit(state.copyWith(
        error: () => 'Failed to log feature usage: $e',
      ));
      debugPrint('❌ [AnalyticsBloc] Error logging feature usage: $e');
    }
  }
}