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

  // Web configuration - will need to be updated if web support is added
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC1pn6ADCydmkiMYaGA9wdmRQa2DgXImkM',
    appId: '1:583479321628:web:cc372828056bdcbe9aabd9',
    messagingSenderId: '583479321628',
    projectId: 'nicotinaai',
    authDomain: 'nicotinaai.firebaseapp.com',
    storageBucket: 'nicotinaai.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX', // Placeholder - update if needed
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1pn6ADCydmkiMYaGA9wdmRQa2DgXImkM',
    appId: '1:583479321628:android:f4ffbb59a78e6b789aabd9',
    messagingSenderId: '583479321628',
    projectId: 'nicotinaai',
    storageBucket: 'nicotinaai.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1pn6ADCydmkiMYaGA9wdmRQa2DgXImkM',
    appId: '1:583479321628:ios:cc372828056bdcbe9aabd9',
    messagingSenderId: '583479321628',
    projectId: 'nicotinaai',
    storageBucket: 'nicotinaai.firebasestorage.app',
    iosBundleId: 'ai.nicotina',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC1pn6ADCydmkiMYaGA9wdmRQa2DgXImkM',
    appId: '1:583479321628:ios:cc372828056bdcbe9aabd9',
    messagingSenderId: '583479321628',
    projectId: 'nicotinaai',
    storageBucket: 'nicotinaai.firebasestorage.app',
    iosBundleId: 'ai.nicotina',
  );
}