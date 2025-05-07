import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicotinaai_flutter/config/supabase_config.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SupabaseClient _supabaseClient = SupabaseConfig.client;
  
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  
  // Retorna o número de notificações não lidas do usuário
  Future<int> getUnreadNotificationsCount() async {
    try {
      final response = await _supabaseClient
          .from('user_notifications')
          .select('id')
          .eq('is_read', false)
          .count();
          
      return response.count;
    } catch (e) {
      debugPrint('Erro ao contar notificações não lidas: $e');
      return 0;
    }
  }
  
  // Busca todas as notificações do usuário
  Future<List<Map<String, dynamic>>> getUserNotifications() async {
    try {
      final response = await _supabaseClient
          .from('user_notifications')
          .select('*')
          .order('created_at', ascending: false);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Erro ao buscar notificações: $e');
      return [];
    }
  }
  
  // Marcar notificação como lida
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabaseClient
          .from('user_notifications')
          .update({
            'is_read': true,
          })
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Erro ao marcar notificação como lida: $e');
    }
  }
  
  // Claim da recompensa de notificação
  Future<Map<String, dynamic>?> claimMotivationReward(String notificationId) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'claim-motivation-reward',
        body: {'notification_id': notificationId},
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Erro ao reivindicar recompensa');
      }
      
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      debugPrint('Erro ao reivindicar recompensa: $e');
      rethrow;
    }
  }
  
  // Inicializar o serviço de notificações
  Future<void> initialize(BuildContext context) async {
    // Store context-related information
    final Color primaryColor = Theme.of(context).primaryColor;
    
    // Configurar permissões
    await _requestPermissions();
    
    // Configurar notificações locais
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    // Define a notification handler that doesn't rely on the context
    void handleNotificationResponse(NotificationResponse details) {
      // Use a closure that captures the context at initialization time
      _handleNotificationClick(details.payload, context);
    }
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: handleNotificationResponse,
    );
    
    // Define message handlers as function declarations, so they capture the current context
    void onMessageHandler(RemoteMessage message) {
      _handleForegroundMessage(message, context, primaryColor);
    }
    
    void onMessageOpenedAppHandler(RemoteMessage message) {
      _handleNotificationClick(jsonEncode(message.data), context);
    }
    
    // Configurar handlers de mensagens FCM
    FirebaseMessaging.onMessage.listen(onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedAppHandler);
    
    // Store the click handler for the initial message
    void handleInitialMessage(RemoteMessage message) {
      _handleNotificationClick(jsonEncode(message.data), context);
    }
    
    // Verificar notificação inicial
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Use the stored handler which captured the original context
      handleInitialMessage(initialMessage);
    }
    
    // Obter e registrar token FCM
    await _getAndRegisterFcmToken();
  }
  
  // Solicitar permissões para enviar notificações
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      // Em Android 13+ (API 33+), é necessário solicitar permissão explícita
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      
      // In Flutter Local Notifications v16+, we need to use requestNotificationsPermission
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }
  
  // Obter token FCM e registrá-lo no Supabase
  Future<void> _getAndRegisterFcmToken() async {
    final fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      final deviceInfo = await _getDeviceInfo();
      
      // Verificar se o token já existe
      final existing = await _supabaseClient
          .from('user_fcm_tokens')
          .select('id')
          .eq('fcm_token', fcmToken)
          .maybeSingle();
      
      if (existing != null) {
        // Atualizar o token existente
        await _supabaseClient
          .from('user_fcm_tokens')
          .update({
            'last_used_at': DateTime.now().toIso8601String(),
            'device_info': deviceInfo,
          })
          .eq('fcm_token', fcmToken);
      } else {
        // Inserir novo token
        await _supabaseClient
          .from('user_fcm_tokens')
          .insert({
            'fcm_token': fcmToken,
            'device_info': deviceInfo,
          });
      }
      
      // Configurar listener para refreshes de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _registerFcmToken(newToken);
      });
    }
  }
  
  // Registrar token FCM no Supabase
  Future<void> _registerFcmToken(String token) async {
    try {
      final deviceInfo = await _getDeviceInfo();
      
      // Verificar se o token já existe
      final existing = await _supabaseClient
          .from('user_fcm_tokens')
          .select('id')
          .eq('fcm_token', token)
          .maybeSingle();
      
      if (existing != null) {
        // Atualizar o token existente
        await _supabaseClient
          .from('user_fcm_tokens')
          .update({
            'last_used_at': DateTime.now().toIso8601String(),
            'device_info': deviceInfo,
          })
          .eq('fcm_token', token);
      } else {
        // Inserir novo token
        await _supabaseClient
          .from('user_fcm_tokens')
          .insert({
            'fcm_token': token,
            'device_info': deviceInfo,
          });
      }
    } catch (e) {
      debugPrint('Erro ao registrar token FCM: $e');
    }
  }
  
  // Obter informações do dispositivo
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final Map<String, dynamic> deviceData = <String, dynamic>{};
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceData['platform'] = 'android';
        deviceData['version'] = androidInfo.version.release;
        deviceData['model'] = androidInfo.model;
        deviceData['brand'] = androidInfo.brand;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceData['platform'] = 'ios';
        deviceData['version'] = iosInfo.systemVersion;
        deviceData['model'] = iosInfo.model;
        deviceData['name'] = iosInfo.name;
      }
    } catch (e) {
      deviceData['error'] = e.toString();
    }
    
    return deviceData;
  }
  
  // Tratar mensagens recebidas quando o app está em primeiro plano
  Future<void> _handleForegroundMessage(
    RemoteMessage message, 
    BuildContext context,
    Color primaryColor,
  ) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final data = message.data;
    
    if (notification != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'motivation_channel',
            'Motivação Diária',
            channelDescription: 'Notificações de motivação diária',
            importance: Importance.high,
            priority: Priority.high,
            color: primaryColor, // Use the cached primaryColor instead of context
            icon: android?.smallIcon ?? 'notification_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(data),
      );
    }
  }
  
  // Tratar quando o usuário toca em uma notificação
  void _handleNotificationClick(String? payload, BuildContext context) {
    if (payload == null) return;
    
    try {
      final data = jsonDecode(payload);
      final type = data['type'];
      
      // Navegar conforme o tipo da notificação
      switch (type) {
        case 'motivation':
          // Navegar para a tela de notificações
          context.go('/notifications');
          break;
        case 'achievement':
          // Navegar para a tela de conquistas
          context.go('/achievements');
          break;
        default:
          // Navegar para a tela principal
          context.go('/main');
      }
    } catch (e) {
      debugPrint('Erro ao processar payload da notificação: $e');
    }
  }
}