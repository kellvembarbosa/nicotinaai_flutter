import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import FirebaseCore
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configurar Firebase - certifique-se de que seja chamado apenas uma vez
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
      print("Firebase configured successfully")
    } else {
      print("Firebase was already configured")
    }
    
    // Registrar para notificações remotas
    if #available(iOS 10.0, *) {
      // iOS 10+
      UNUserNotificationCenter.current().delegate = self
      
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      // iOS 8 & 9
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    
    // Definir delegado para o Messaging do Firebase
    Messaging.messaging().delegate = self
    
    // Configurar para funcionar em simulador (apenas para debug)
    #if targetEnvironment(simulator)
    print("Running on simulator - enabling special handling for Firebase Messaging")
    // No simulator, we'll handle token fetching directly instead of relying on APNs
    // Since there's no direct way to control APNs registration in newer Firebase SDKs
    Messaging.messaging().token { token, error in
      if let error = error {
        print("Error getting FCM token in simulator: \(error)")
      } else if let token = token {
        print("Successfully retrieved FCM token in simulator: \(token)")
      }
    }
    #endif
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Lidar com o recebimento de token de APNs
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Format and log the token for debugging
    let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
    let token = tokenParts.joined()
    print("APNS device token: \(token)")
    
    // Use a dispatch queue to not block the main thread during token registration
    DispatchQueue.main.async {
      Messaging.messaging().apnsToken = deviceToken
    }
    
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // Lidar com falhas no registro para notificações remotas
  override func application(_ application: UIApplication,
                           didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error)")
  }
}

// Extensão para lidar com o token FCM
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token received: \(String(describing: fcmToken))")
    
    // Adicionar atraso para garantir que o token seja processado corretamente
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      
      // Adicional: imprimir detalhes sobre o APNs token para debug
      if let apnsToken = Messaging.messaging().apnsToken {
        let tokenParts = apnsToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        print("APNS token available: \(token)")
      } else {
        print("No APNS token available - this might cause FCM token issues")
      }
      
      // Forçar atualização do FCM token se necessário
      if fcmToken == nil {
        print("Attempting to force FCM token refresh...")
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM token: \(error)")
          } else if let token = token {
            print("Successfully fetched FCM token after force refresh: \(token)")
          }
        }
      }
    }
  }
}
