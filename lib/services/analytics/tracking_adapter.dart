import 'package:flutter/foundation.dart';

/// Interface for analytics tracking adapters
abstract class TrackingAdapter {
  /// Initialize the adapter
  Future<void> initialize();

  /// Track an event
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters});

  /// Track an event for paid features
  Future<void> trackEventOnlyPaid(
    String eventName, {
    Map<String, dynamic>? parameters,
    required VoidCallback onPaidFeature,
  });

  /// Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties);

  /// Clear user data
  Future<void> clearUserData();

  /// Get adapter name
  String get adapterName;

  /// Whether the adapter is initialized
  bool get isInitialized;

  /// Whether tracking is enabled for this adapter
  bool get isTrackingEnabled;

  /// Set whether tracking is enabled
  set isTrackingEnabled(bool value);
}

/// Configuration for tracking adapters
class TrackingAdapterConfig {
  final Map<String, dynamic> config;

  const TrackingAdapterConfig(this.config);

  /// Get a value from the configuration
  T? get<T>(String key) {
    return config[key] as T?;
  }

  /// Create an empty configuration
  factory TrackingAdapterConfig.empty() {
    return const TrackingAdapterConfig({});
  }
}

/// Factory for creating tracking adapters
abstract class TrackingAdapterFactory {
  /// Create a tracking adapter
  TrackingAdapter create(TrackingAdapterConfig config);

  /// Get the name of the adapter this factory creates
  String get adapterName;
}

/// Registry for tracking adapter factories
class TrackingAdapterRegistry {
  static final TrackingAdapterRegistry _instance =
      TrackingAdapterRegistry._internal();
  factory TrackingAdapterRegistry() => _instance;
  TrackingAdapterRegistry._internal();

  final Map<String, TrackingAdapterFactory> _factories = {};

  /// Register a tracking adapter factory
  void registerFactory(TrackingAdapterFactory factory) {
    _factories[factory.adapterName] = factory;
    debugPrint(
      '➕ [TrackingAdapterRegistry] Registered factory for ${factory.adapterName}',
    );
  }

  /// Unregister a tracking adapter factory
  void unregisterFactory(String adapterName) {
    _factories.remove(adapterName);
    debugPrint(
      '➖ [TrackingAdapterRegistry] Unregistered factory for $adapterName',
    );
  }

  /// Create a tracking adapter
  TrackingAdapter? createAdapter(
    String adapterName, [
    TrackingAdapterConfig? config,
  ]) {
    final factory = _factories[adapterName];
    if (factory == null) {
      debugPrint(
        '⚠️ [TrackingAdapterRegistry] No factory registered for $adapterName',
      );
      return null;
    }

    return factory.create(config ?? TrackingAdapterConfig.empty());
  }

  /// Get all registered adapter names
  List<String> get registeredAdapters => _factories.keys.toList();
}
