import 'dart:math';
import 'dart:io';
import 'dart:convert';
// Firebase Core imported for FirebaseException
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Background message handler for Firebase Cloud Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Flutter notifications are set up
  await NotificationService().setupFlutterNotifications();
  
  // Show the notification
  await NotificationService().showNotificationFromMessage(message);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  // Firebase Messaging instance
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Device info
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  // Lazy getter for Supabase client to prevent initialization issues
  SupabaseClient get _supabaseClient {
    try {
      return SupabaseConfig.client;
    } catch (e) {
      debugPrint('Erro ao acessar Supabase client: $e');
      // Return null or handle the error as needed
      throw Exception('Supabase not initialized yet. Please ensure SupabaseConfig.initialize() is called before using notification features that require Supabase.');
    }
  }
  
  bool _isInitialized = false;
  bool _areNotificationsEnabled = true;
  bool _isFlutterLocalNotificationsInitialized = false;
  final String _notificationsEnabledKey = 'notifications_enabled';
  final String _fcmTokenKey = 'fcm_token_cache';
  
  // Armazena o último token FCM obtido
  String? _cachedFcmToken;
  
  // Android notification channel ID for FCM messages
  static const _androidFcmChannel = 'nicotinaai_high_importance_channel';

  /// Initialize notification settings and FCM
  Future<void> initialize() async {
    // Initialize local notifications
    await init();
    
    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // NÃO solicitar permissão aqui - será solicitada no onboarding
    // await _requestPermission();
    
    // Setup FCM message handlers
    await _setupMessageHandlers();
    
    // Verificar se já temos permissão sem solicitar ao usuário
    try {
      // Verifica as configurações atuais sem exibir diálogo
      final settings = await _messaging.getNotificationSettings();
      
      // Só tenta obter o token se o usuário já concedeu permissão anteriormente
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        debugPrint('💬 Permissão de notificações já concedida: ${settings.authorizationStatus}');
        
        // Obtém o token apenas se já temos permissão
        final token = await _messaging.getToken();
        if (token != null) {
          _cachedFcmToken = token;
          
          // Salvar em SharedPreferences para uso posterior
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_fcmTokenKey, token);
          
          debugPrint('FCM Token obtido e armazenado: $token');
          
          // Tentar salvar o token se o usuário já estiver logado
          await saveTokenToDatabase(token);
        }
      } else {
        debugPrint('💬 Permissão de notificações não concedida: ${settings.authorizationStatus}');
        debugPrint('💬 A permissão será solicitada durante o onboarding');
      }
    } catch (e) {
      debugPrint('Não foi possível verificar permissões ou obter token FCM: $e');
      // Não mostrar erro, já que o usuário terá oportunidade de conceder permissão no onboarding
    }
  }

  /// Initialize local notification settings
  Future<void> init() async {
    if (_isInitialized) return;
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification when app is in foreground
        if (response.payload != null) {
          debugPrint('Notification payload: ${response.payload}');
          // Further handling can be implemented based on payload
        }
      },
    );
    
    // Load user preferences
    final prefs = await SharedPreferences.getInstance();
    _areNotificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    
    _isInitialized = true;
  }
  
  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) await init();
    return _areNotificationsEnabled;
  }
  
  /// Enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    _areNotificationsEnabled = enabled;
  }

  /// Request FCM permission - accessible from onboarding flow
  Future<NotificationSettings> requestPermission() async {
    try {
      // Verificar se o Firebase está corretamente configurado
      if (_messaging == null) {
        throw FirebaseException(
          plugin: 'firebase_messaging',
          code: 'not_initialized',
          message: 'Firebase Messaging não está inicializado corretamente',
        );
      }
      
      // Solicitar permissão
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      debugPrint('Permission status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      // Capturar e tratar erros específicos do Firebase
      if (e.toString().contains('cannot parse response')) {
        debugPrint('Erro de configuração do Firebase: não foi possível processar a resposta');
        throw FirebaseException(
          plugin: 'firebase_messaging',
          code: 'parse_error',
          message: 'Não foi possível processar a resposta do Firebase. Verifique se as configurações do Firebase estão corretas.',
        );
      } else {
        // Repassar outros erros
        debugPrint('Erro ao solicitar permissão de notificação: $e');
        rethrow;
      }
    }
  }
  
  /// Private method to keep backward compatibility
  Future<void> _requestPermission() async {
    await requestPermission();
  }

  /// Set up FCM message handlers for different app states
  Future<void> _setupMessageHandlers() async {
    // Handler for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotificationFromMessage(message);
    });
    
    // Handler for when app is opened from a background notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // Check if app was opened from a notification when terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  /// Handle a background message
  void _handleBackgroundMessage(RemoteMessage message) {
    // You can implement custom logic based on the message type
    // For example, navigate to specific screens
    if (message.data['type'] == 'chat') {
      // Navigate to chat screen
      debugPrint('Should navigate to chat screen');
    } else if (message.data['type'] == 'achievement') {
      // Navigate to achievements screen
      debugPrint('Should navigate to achievements screen');
    }
    
    // Log message for debugging
    debugPrint('Background message: ${message.data}');
  }

  /// Setup Flutter local notifications for FCM (called from background handler)
  Future<void> setupFlutterNotifications() async {
    // Skip if already initialized
    if (_isFlutterLocalNotificationsInitialized) return;
    
    // Android initialization settings
    const AndroidInitializationSettings androidInitSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );
    
    // Initialize local notifications
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification when app is in foreground
        if (response.payload != null) {
          debugPrint('Notification payload: ${response.payload}');
          // Further handling can be implemented based on payload
        }
      },
    );
    
    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _androidFcmChannel,
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );
    
    // Create the Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    // Mark as initialized
    _isFlutterLocalNotificationsInitialized = true;
  }

  /// Show a notification from a FCM message
  Future<void> showNotificationFromMessage(RemoteMessage message) async {
    if (!_areNotificationsEnabled) return;
    
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    
    // If notification exists and we're on Android
    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidFcmChannel,
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
    
    // For iOS notifications
    if (notification != null && defaultTargetPlatform == TargetPlatform.iOS) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Show a motivational notification when user resisted a craving
  Future<void> showCravingResistedNotification(AppLocalizations l10n) async {
    if (!_isInitialized) await init();
    if (!_areNotificationsEnabled) return;
    
    // Select a random motivational message based on the user's language
    final message = _getRandomMotivationalMessage(l10n);
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'craving_resisted_channel',
      'Craving Resisted',
      channelDescription: 'Notifications shown when you resist a craving',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      0,
      l10n.motivationalMessage,
      message,
      platformChannelSpecifics,
    );
  }
  
  /// Get a random motivational message based on the user's language
  String _getRandomMotivationalMessage(AppLocalizations l10n) {
    // Messages in English
    final List<String> enMessages = [
      "Amazing job resisting that craving! Every time you say no, you get stronger.",
      "Impressive willpower! You just saved money and improved your health.",
      "Way to go! Each resisted craving adds 5 minutes to your life expectancy.",
      "Victory! Your lungs are thanking you for that decision.",
      "You're a champion! That's one more step toward freedom from smoking.",
      "Outstanding effort! Your future self will thank you for this moment of strength.",
      "Brilliant choice! You're breaking the addiction cycle one craving at a time.",
      "Success! Each time you resist, the cravings get easier to manage.",
      "Perfect decision! You're proving how strong you really are.",
      "Excellent job! Your willpower is stronger than any craving."
    ];
    
    // Messages in Portuguese (assuming pt is Portuguese)
    final List<String> ptMessages = [
      "Excelente trabalho resistindo a essa fissura! Cada vez que você diz não, fica mais forte.",
      "Força de vontade impressionante! Você acabou de economizar dinheiro e melhorar sua saúde.",
      "Muito bem! Cada fissura resistida adiciona 5 minutos à sua expectativa de vida.",
      "Vitória! Seus pulmões estão agradecendo por essa decisão.",
      "Você é um campeão! Esse é mais um passo em direção à liberdade do cigarro.",
      "Esforço incrível! Seu futuro eu agradecerá por este momento de força.",
      "Escolha brilhante! Você está quebrando o ciclo de dependência uma fissura de cada vez.",
      "Sucesso! Cada vez que você resiste, as fissuras ficam mais fáceis de administrar.",
      "Decisão perfeita! Você está provando o quão forte realmente é.",
      "Ótimo trabalho! Sua força de vontade é mais forte que qualquer fissura."
    ];
    
    // Select language based on current locale
    final currentLocale = l10n.localeName;
    final messages = currentLocale.startsWith('pt') ? ptMessages : enMessages;
    
    // Return a random message
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }
  
  /// Save FCM token to the Supabase database.
  /// Returns true if token was saved successfully, false otherwise.
  Future<bool> saveTokenToDatabase(String token) async {
    try {
      // Armazenar o token recebido na cache da memória
      _cachedFcmToken = token;
      
      // Também armazená-lo em SharedPreferences para permanência
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, token);
      
      // Verificar se o Supabase está inicializado
      if (!_isSupabaseInitialized()) {
        debugPrint('Supabase não inicializado. Token FCM armazenado apenas localmente: $token');
        return false;
      }
      
      // Verificar se o usuário está autenticado
      final session = _supabaseClient.auth.currentSession;
      
      // Se o usuário não estiver autenticado, apenas armazena localmente para uso futuro
      if (session == null) {
        debugPrint('Usuário não autenticado. Token FCM armazenado localmente: $token');
        return false;
      }
      
      final userId = session.user.id;
      debugPrint('Salvando token FCM para usuário autenticado: $userId');
      
      // Obter informações do dispositivo
      final deviceInfoJson = await _getDeviceInfo();
      
      try {
        try {
          // Verificar se o token já existe no banco de dados
          final existingTokens = await _supabaseClient
              .from('user_fcm_tokens')
              .select()
              .eq('fcm_token', token)
              .limit(1);
          
          if (existingTokens.isNotEmpty) {
            // Atualizar o token existente
            await _supabaseClient
                .from('user_fcm_tokens')
                .update({
                  'user_id': userId,
                  'last_used_at': DateTime.now().toIso8601String(),
                  'device_info': deviceInfoJson
                })
                .eq('fcm_token', token);
            
            debugPrint('Token FCM atualizado para o usuário: $userId');
          } else {
            // Tentar inserir um novo token - usando upsert para evitar erros de duplicação
            await _supabaseClient
                .from('user_fcm_tokens')
                .upsert({
                  'user_id': userId,
                  'fcm_token': token,
                  'device_info': deviceInfoJson,
                  'created_at': DateTime.now().toIso8601String(),
                  'last_used_at': DateTime.now().toIso8601String()
                }, 
                onConflict: 'fcm_token'); // Se houver conflito, atualiza
            
            debugPrint('Novo token FCM inserido ou atualizado para o usuário: $userId');
          }
        } catch (tokenError) {
          debugPrint('Erro ao inserir/atualizar token FCM (tentando via RPC): $tokenError');
          
          // Tenta via função RPC se falhar
          try {
            final result = await _supabaseClient.rpc(
              'save_fcm_token',
              params: {
                'p_user_id': userId,
                'p_fcm_token': token,
                'p_device_info': deviceInfoJson
              }
            );
            
            debugPrint('Token FCM salvo via RPC: $result');
          } catch (rpcError) {
            debugPrint('Erro ao salvar token via RPC também: $rpcError');
            throw rpcError; // Propaga o erro para tratamento posterior
          }
        }
        
        return true;
      } catch (supabaseError) {
        // Se ocorrer um erro de RLS policy, tenta usar a função RPC alternativa
        if (supabaseError.toString().contains('row-level security policy') || 
            supabaseError.toString().contains('42501') ||
            supabaseError.toString().contains('Forbidden')) {
          
          debugPrint('Erro de RLS detectado. Tentando método alternativo...');
          
          try {
            // Tenta aplicar o fix RLS primeiro
            await applyFcmTokensRlsFix();
            
            // Tenta novamente com a abordagem original após o fix
            await _supabaseClient
                .from('user_fcm_tokens')
                .insert({
                  'user_id': userId,
                  'fcm_token': token,
                  'device_info': deviceInfoJson,
                  'created_at': DateTime.now().toIso8601String(),
                  'last_used_at': DateTime.now().toIso8601String()
                });
            
            debugPrint('Token FCM inserido com sucesso após fix RLS');
            return true;
          } catch (fixError) {
            // Se ainda falhar, tenta usar a função RPC diretamente
            debugPrint('Fix RLS falhou, tentando método RPC: $fixError');
            
            try {
              // Usar uma função RPC para contornar as limitações de RLS
              final result = await _supabaseClient.rpc(
                'save_fcm_token',
                params: {
                  'p_user_id': userId,
                  'p_fcm_token': token,
                  'p_device_info': deviceInfoJson
                }
              );
              
              debugPrint('Token FCM salvo via RPC: $result');
              return true;
            } catch (rpcError) {
              debugPrint('Erro ao salvar token via RPC: $rpcError');
              
              // Tentar salvar via Edge Function como último recurso
              // Agora temos a função save_fcm_token aplicada via migração, então esse caminho deve funcionar
              try {
                final result = await _supabaseClient.rpc(
                  'save_fcm_token',
                  params: {
                    'p_user_id': userId,
                    'p_fcm_token': token,
                    'p_device_info': deviceInfoJson
                  }
                );
                
                debugPrint('Token FCM salvo via função save_fcm_token: $result');
                return true;
              } catch (funcError) {
                debugPrint('Erro ao salvar token via função save_fcm_token: $funcError');
                
                // Tentar ainda via Edge Function como recurso alternativo
                try {
                  final saved = await saveTokenViaEdgeFunction(token, userId);
                  if (saved) {
                    debugPrint('Token FCM salvo com sucesso via Edge Function');
                    return true;
                  }
                } catch (edgeFunctionError) {
                  debugPrint('Erro ao salvar token via Edge Function: $edgeFunctionError');
                }
              }
              
              // Se todas as tentativas falharem, salvar localmente apenas
              prefs.setString('pending_fcm_token', token);
              prefs.setString('pending_fcm_user_id', userId);
              debugPrint('Token FCM salvo localmente para tentativa futura');
              
              return false;
            }
          }
        } else {
          // Outro tipo de erro
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Erro ao salvar token FCM no banco de dados: $e');
      return false;
    }
  }
  
  /// Verifica se o Supabase está inicializado
  bool _isSupabaseInitialized() {
    try {
      // Tenta acessar o cliente Supabase, o que gerará uma exceção se não estiver inicializado
      SupabaseConfig.client;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Recupera o token FCM armazenado em cache ou SharedPreferences
  Future<String?> getCachedToken() async {
    // Se já tiver em memória, retornar diretamente
    if (_cachedFcmToken != null) {
      return _cachedFcmToken;
    }
    
    // Caso contrário, tentar recuperar do SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_fcmTokenKey);
      
      if (token != null && token.isNotEmpty) {
        _cachedFcmToken = token;
        return token;
      }
    } catch (e) {
      debugPrint('Erro ao recuperar token FCM do armazenamento: $e');
    }
    
    // Se não encontrou, retornar null
    return null;
  }
  
  /// Tenta salvar o token FCM no banco de dados quando o usuário faz login
  Future<void> saveFcmTokenAfterLogin() async {
    try {
      // Verifica se o Supabase está inicializado
      if (!_isSupabaseInitialized()) {
        debugPrint('Não foi possível salvar o token FCM: Supabase não inicializado');
        return;
      }
      
      // Verifica se o usuário está logado
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        debugPrint('Não foi possível salvar o token FCM: usuário não está logado');
        return;
      }
      
      // Recupera o token armazenado
      final token = await getCachedToken();
      
      // Se não tiver token armazenado, tenta obter um novo
      if (token == null || token.isEmpty) {
        final newToken = await _messaging.getToken();
        if (newToken != null) {
          await saveTokenToDatabase(newToken);
        }
      } else {
        // Usa o token armazenado
        await saveTokenToDatabase(token);
      }
    } catch (e) {
      debugPrint('Erro ao salvar token FCM após login: $e');
    }
  }
  
  /// Obtém informações do dispositivo para armazenar junto com o token FCM
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceData = <String, dynamic>{};
      
      if (kIsWeb) {
        deviceData['platform'] = 'web';
        deviceData['userAgent'] = 'web browser';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData['platform'] = 'android';
        deviceData['model'] = androidInfo.model;
        deviceData['brand'] = androidInfo.brand;
        deviceData['version'] = androidInfo.version.release;
        deviceData['id'] = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData['platform'] = 'ios';
        deviceData['model'] = iosInfo.model;
        deviceData['name'] = iosInfo.name;
        deviceData['systemName'] = iosInfo.systemName;
        deviceData['systemVersion'] = iosInfo.systemVersion;
        deviceData['id'] = iosInfo.identifierForVendor;
      }
      
      return deviceData;
    } catch (e) {
      debugPrint('Erro ao obter informações do dispositivo: $e');
      return {
        'platform': defaultTargetPlatform.toString(),
        'error': 'Não foi possível obter informações detalhadas'
      };
    }
  }
  
  /// Get the FCM token
  Future<String?> getToken() async {
    try {
      // Verificar se o Firebase está devidamente configurado
      if (_messaging == null) {
        debugPrint('Firebase Messaging não está inicializado. Não é possível obter token FCM.');
        return null;
      }
      
      final token = await _messaging.getToken();
      
      if (token == null || token.isEmpty) {
        debugPrint('Token FCM vazio ou nulo. Verifique as configurações do Firebase.');
      } else {
        debugPrint('Token FCM obtido com sucesso: ${token.substring(0, 10)}...');
      }
      
      return token;
    } catch (e) {
      // Capturar e registrar erros na obtenção do token
      debugPrint('Erro ao obter token FCM: $e');
      
      // Retornar null em caso de erro, em vez de propagar a exceção
      // Isso permite que o fluxo de onboarding continue mesmo sem o token
      return null;
    }
  }
  
  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      // Verificar se o Firebase está devidamente configurado
      if (_messaging == null) {
        debugPrint('Firebase Messaging não está inicializado. Não é possível inscrever-se no tópico: $topic');
        return;
      }
      
      await _messaging.subscribeToTopic(topic);
      debugPrint('Inscrito no tópico: $topic');
    } catch (e) {
      // Apenas registrar o erro, mas não propagar
      debugPrint('Erro ao inscrever-se no tópico $topic: $e');
    }
  }
  
  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      // Verificar se o Firebase está devidamente configurado
      if (_messaging == null) {
        debugPrint('Firebase Messaging não está inicializado. Não é possível cancelar inscrição no tópico: $topic');
        return;
      }
      
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Cancelou inscrição no tópico: $topic');
    } catch (e) {
      // Apenas registrar o erro, mas não propagar
      debugPrint('Erro ao cancelar inscrição no tópico $topic: $e');
    }
  }
  
  /// Get user notifications from database
  Future<List<Map<String, dynamic>>> getUserNotifications() async {
    try {
      if (!_isSupabaseInitialized()) {
        debugPrint('Não foi possível obter notificações: Supabase não inicializado');
        return [];
      }
      
      // Check if user is authenticated
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        debugPrint('Não foi possível obter notificações: usuário não está logado');
        return [];
      }
      
      // Get notifications from database
      final data = await _supabaseClient
          .from('notifications')
          .select('*')
          .eq('user_id', session.user.id)
          .order('created_at', ascending: false)
          .limit(50);
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Erro ao obter notificações: $e');
      return [];
    }
  }
  
  /// Mark a notification as read in the database
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      if (!_isSupabaseInitialized()) {
        debugPrint('Não foi possível marcar notificação como lida: Supabase não inicializado');
        return false;
      }
      
      // Check if user is authenticated
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        debugPrint('Não foi possível marcar notificação como lida: usuário não está logado');
        return false;
      }
      
      // Update the notification in the database
      await _supabaseClient
          .from('notifications')
          .update({
            'viewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
      
      debugPrint('Notificação marcada como lida: $notificationId');
      return true;
    } catch (e) {
      debugPrint('Erro ao marcar notificação como lida: $e');
      return false;
    }
  }
  
  /// Salvar o token FCM usando a Edge Function do Supabase
  /// Esta é uma alternativa que contorna as limitações de RLS
  Future<bool> saveTokenViaEdgeFunction(String token, String userId) async {
    try {
      final deviceInfo = await _getDeviceInfo();
      
      // Obter valores do ambiente para o Supabase
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      
      if (supabaseUrl.isEmpty || anonKey.isEmpty) {
        debugPrint('Configurações do Supabase não encontradas no arquivo .env');
        return false;
      }
      
      // Construir a URL da Edge Function
      final functionUrl = '$supabaseUrl/functions/v1/store_fcm_token';
      
      // Construir o payload
      final payload = {
        'token': token,
        'user_id': userId,
        'device_info': deviceInfo
      };
      
      // Fazer a requisição HTTP
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey'
        },
        body: jsonEncode(payload)
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('Token FCM salvo via Edge Function: $responseData');
        return true;
      } else {
        debugPrint('Erro ao salvar token via Edge Function: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exceção ao salvar token via Edge Function: $e');
      return false;
    }
  }
  
  /// Apply a fix for the RLS policies on user_fcm_tokens table
  /// This should be called when encountering RLS issues with FCM tokens
  Future<bool> applyFcmTokensRlsFix() async {
    if (!_isSupabaseInitialized()) {
      debugPrint('Não foi possível aplicar o fix RLS: Supabase não inicializado');
      return false;
    }
    
    try {
      // Tenta usar a função RPC para aplicar o fix
      const sql = '''
        -- Remover políticas existentes
        DROP POLICY IF EXISTS "Users can insert their own device tokens" ON user_fcm_tokens;
        DROP POLICY IF EXISTS "Users can update their own device tokens" ON user_fcm_tokens;
        
        -- Criar políticas mais permissivas
        CREATE POLICY "Any authenticated user can insert tokens" 
          ON user_fcm_tokens FOR INSERT 
          TO authenticated
          WITH CHECK (true);
          
        CREATE POLICY "Any authenticated user can update tokens" 
          ON user_fcm_tokens FOR UPDATE 
          TO authenticated
          USING (true);
      ''';
      
      // Tenta executar o SQL via RPC (precisa de permissões)
      await _supabaseClient.rpc(
        'exec_sql', 
        params: { 'sql': sql }
      );
      debugPrint('Fix RLS aplicado com sucesso via SQL');
      return true;
    } catch (e) {
      debugPrint('Erro ao aplicar fix RLS: $e');
      return false;
    }
  }
}