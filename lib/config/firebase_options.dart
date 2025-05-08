import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Placeholder configurations - replace with actual Firebase configurations
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'nicotinaai-app',
    authDomain: 'nicotinaai-app.firebaseapp.com',
    storageBucket: 'nicotinaai-app.appspot.com',
    measurementId: 'G-0000000000',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'nicotinaai-app',
    storageBucket: 'nicotinaai-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'nicotinaai-app',
    storageBucket: 'nicotinaai-app.appspot.com',
    iosClientId: '000000000000-00000000000000000000000000000000.apps.googleusercontent.com',
    iosBundleId: 'com.example.nicotinaaiFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'nicotinaai-app',
    storageBucket: 'nicotinaai-app.appspot.com',
    iosClientId: '000000000000-00000000000000000000000000000000.apps.googleusercontent.com',
    iosBundleId: 'com.example.nicotinaaiFlutter',
  );
}