import 'package:equatable/equatable.dart';

/// State for the analytics BLoC
class AnalyticsState extends Equatable {
  /// Whether the analytics service is initialized
  final bool isInitialized;
  
  /// List of active analytics providers
  final List<String> activeProviders;
  
  /// Whether analytics is enabled
  final bool isAnalyticsEnabled;
  
  /// Any error that occurred during analytics operations
  final String? error;

  const AnalyticsState({
    this.isInitialized = false,
    this.activeProviders = const [],
    this.isAnalyticsEnabled = true,
    this.error,
  });

  @override
  List<Object?> get props => [isInitialized, activeProviders, isAnalyticsEnabled, error];
  
  /// Create a copy of this state with modified properties
  AnalyticsState copyWith({
    bool? isInitialized,
    List<String>? activeProviders,
    bool? isAnalyticsEnabled,
    String? Function()? error,
  }) {
    return AnalyticsState(
      isInitialized: isInitialized ?? this.isInitialized,
      activeProviders: activeProviders ?? this.activeProviders,
      isAnalyticsEnabled: isAnalyticsEnabled ?? this.isAnalyticsEnabled,
      error: error != null ? error() : this.error,
    );
  }
  
  /// Reset any error
  AnalyticsState clearError() {
    return AnalyticsState(
      isInitialized: isInitialized,
      activeProviders: activeProviders,
      isAnalyticsEnabled: isAnalyticsEnabled,
      error: null,
    );
  }
}