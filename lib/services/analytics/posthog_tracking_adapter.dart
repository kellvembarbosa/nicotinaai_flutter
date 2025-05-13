import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:nicotinaai_flutter/services/analytics/tracking_adapter.dart';

/// PostHog tracking adapter
class PostHogTrackingAdapter implements TrackingAdapter {
  // Usamos diretamente o singleton do PostHog
  final Posthog _posthog = Posthog();
  bool _isInitialized = false;
  bool _isTrackingEnabled = true;
  final String _apiKey;
  final String _host;

  PostHogTrackingAdapter(this._apiKey, {String? host})
    : _host = host ?? 'https://app.posthog.com';

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Inicializar PostHog - versão 5.0.0
      final config = PostHogConfig(_apiKey);
      config.debug = true;
      config.captureApplicationLifecycleEvents = true;
      config.sessionReplay = true;
      config.sessionReplayConfig.maskAllTexts = false;
      config.sessionReplayConfig.maskAllImages = false;
      config.sessionReplayConfig.throttleDelay = const Duration(
        milliseconds: 1000,
      );
      config.flushAt = 1;
      config.host = _host;

      // O método setup retorna Future<void>, não uma instância de Posthog
      await _posthog.setup(config);

      debugPrint(
        '✅ [PostHogTracking] Initialized with API key: ${_apiKey.substring(0, 8)}...',
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ [PostHogTracking] Error initializing: $e');
    }
  }

  @override
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isTrackingEnabled) {
      debugPrint(
        '⚠️ [PostHogTracking] Tracking disabled, event not logged: $eventName',
      );
      return;
    }

    try {
      // Converter Map<String, dynamic>? para Map<String, Object>?
      final convertedParams =
          parameters != null
              ? parameters.map((key, value) => MapEntry(key, value as Object))
              : null;

      await _posthog.capture(eventName: eventName, properties: convertedParams);

      debugPrint(
        '📊 [PostHogTracking] Logged event: $eventName with parameters: $parameters',
      );
    } catch (e) {
      debugPrint('❌ [PostHogTracking] Error logging event: $e');
    }
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isTrackingEnabled) {
      debugPrint(
        '⚠️ [PostHogTracking] Tracking disabled, user properties not set',
      );
      return;
    }

    try {
      // Converter Map<String, dynamic> para Map<String, Object>
      final convertedProps = properties.map(
        (key, value) => MapEntry(key, value as Object),
      );

      if (properties.containsKey('user_id')) {
        final userId = properties['user_id'].toString();

        // Criar nova cópia sem user_id para evitar duplicação
        final userProps = Map<String, Object>.from(convertedProps);
        userProps.remove('user_id');

        await _posthog.identify(userId: userId, userProperties: userProps);
      } else {
        // For PostHog we need to set properties via an identify call
        // Get the current distinct ID to maintain identity
        final distinctId = await _posthog.getDistinctId();

        await _posthog.identify(
          userId: distinctId,
          userProperties: convertedProps,
        );
      }

      debugPrint('👤 [PostHogTracking] Set user properties: $properties');
    } catch (e) {
      debugPrint('❌ [PostHogTracking] Error setting user properties: $e');
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await _posthog.reset();

      debugPrint('🧹 [PostHogTracking] Cleared user data');
    } catch (e) {
      debugPrint('❌ [PostHogTracking] Error clearing user data: $e');
    }
  }

  @override
  String get adapterName => 'PostHog';

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isTrackingEnabled => _isTrackingEnabled;

  @override
  set isTrackingEnabled(bool value) {
    _isTrackingEnabled = value;

    // Como o PostHog não tem um método optOut(), usamos nossa própria lógica
    // para desabilitar o tracking sem desligar o adaptador
    debugPrint(
      '🔄 [PostHogTracking] Tracking ${value ? 'enabled' : 'disabled'}',
    );
  }

  @override
  Future<void> trackEventOnlyPaid(
    String eventName, {
    Map<String, dynamic>? parameters,
    VoidCallback? onPaidFeature,
  }) async {
    // Implementação específica para eventos pagos
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isTrackingEnabled) {
      debugPrint(
        '⚠️ [PostHogTracking] Tracking disabled, event not logged: $eventName',
      );
      return;
    }

    print('🔒 [PostHogTracking] Tracking paid feature: $eventName');

    // Execute the paid feature callback if provided
    onPaidFeature?.call();

    // Track the event
    return trackEvent(eventName, parameters: parameters);
  }
}

/// Factory for creating PostHog tracking adapters
class PostHogTrackingAdapterFactory implements TrackingAdapterFactory {
  @override
  TrackingAdapter create(TrackingAdapterConfig config) {
    final apiKey = config.get<String>('apiKey');
    final host = config.get<String>('host');

    if (apiKey == null) {
      throw ArgumentError('PostHog API key is required');
    }

    return PostHogTrackingAdapter(apiKey, host: host);
  }

  @override
  String get adapterName => 'PostHog';
}
