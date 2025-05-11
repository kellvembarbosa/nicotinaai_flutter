import 'package:equatable/equatable.dart';

/// Base class for all analytics events
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize analytics providers
class InitializeAnalyticsEvent extends AnalyticsEvent {
  const InitializeAnalyticsEvent();
}

/// Track a custom event
class TrackCustomEvent extends AnalyticsEvent {
  final String eventName;
  final Map<String, dynamic>? parameters;

  const TrackCustomEvent(this.eventName, {this.parameters});

  @override
  List<Object?> get props => [eventName, parameters];
}

/// Set user properties
class SetUserPropertiesEvent extends AnalyticsEvent {
  final String? userId;
  final String? email;
  final int? daysSmokeFree;
  final int? cigarettesPerDay;
  final double? pricePerPack;
  final String? currency;
  final Map<String, dynamic>? additionalProperties;

  const SetUserPropertiesEvent({
    this.userId,
    this.email,
    this.daysSmokeFree,
    this.cigarettesPerDay,
    this.pricePerPack,
    this.currency,
    this.additionalProperties,
  });

  @override
  List<Object?> get props => [
        userId,
        email,
        daysSmokeFree,
        cigarettesPerDay,
        pricePerPack,
        currency,
        additionalProperties,
      ];
}

/// Clear user data
class ClearUserDataEvent extends AnalyticsEvent {
  const ClearUserDataEvent();
}

/// Add analytics provider
class AddAnalyticsProviderEvent extends AnalyticsEvent {
  final String providerName;
  final Map<String, dynamic>? providerConfig;

  const AddAnalyticsProviderEvent(this.providerName, {this.providerConfig});

  @override
  List<Object?> get props => [providerName, providerConfig];
}

/// Remove analytics provider
class RemoveAnalyticsProviderEvent extends AnalyticsEvent {
  final String providerName;

  const RemoveAnalyticsProviderEvent(this.providerName);

  @override
  List<Object?> get props => [providerName];
}

/// Convenience event: Log app open
class LogAppOpenEvent extends AnalyticsEvent {
  const LogAppOpenEvent();
}

/// Convenience event: Log login
class LogLoginEvent extends AnalyticsEvent {
  final String? method;

  const LogLoginEvent({this.method});

  @override
  List<Object?> get props => [method];
}

/// Convenience event: Log sign up
class LogSignUpEvent extends AnalyticsEvent {
  final String? method;

  const LogSignUpEvent({this.method});

  @override
  List<Object?> get props => [method];
}

/// Convenience event: Log smoking free milestone
class LogSmokingFreeMilestoneEvent extends AnalyticsEvent {
  final int days;

  const LogSmokingFreeMilestoneEvent(this.days);

  @override
  List<Object?> get props => [days];
}

/// Convenience event: Log health recovery achieved
class LogHealthRecoveryAchievedEvent extends AnalyticsEvent {
  final String recoveryName;

  const LogHealthRecoveryAchievedEvent(this.recoveryName);

  @override
  List<Object?> get props => [recoveryName];
}

/// Convenience event: Log craving resisted
class LogCravingResistedEvent extends AnalyticsEvent {
  final String? triggerType;

  const LogCravingResistedEvent({this.triggerType});

  @override
  List<Object?> get props => [triggerType];
}

/// Convenience event: Log money saved milestone
class LogMoneySavedMilestoneEvent extends AnalyticsEvent {
  final double amount;
  final String currency;

  const LogMoneySavedMilestoneEvent(this.amount, this.currency);

  @override
  List<Object?> get props => [amount, currency];
}

/// Convenience event: Log completed onboarding
class LogCompletedOnboardingEvent extends AnalyticsEvent {
  const LogCompletedOnboardingEvent();
}

/// Convenience event: Log feature usage
class LogFeatureUsageEvent extends AnalyticsEvent {
  final String featureName;

  const LogFeatureUsageEvent(this.featureName);

  @override
  List<Object?> get props => [featureName];
}