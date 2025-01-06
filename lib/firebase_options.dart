// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        return windows;
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

  static FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_WEB_API_KEY']!,
    appId: '1:102035129247:web:6059eeb84cd4b3bcddf3aa',
    messagingSenderId: '102035129247',
    projectId: 'hooked-a21e9',
    authDomain: 'hooked-a21e9.firebaseapp.com',
    storageBucket: 'hooked-a21e9.firebasestorage.app',
    measurementId: 'G-SMFCG5ZYYK',
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY']!,
    appId: '1:102035129247:android:90f2dabc83bfad85ddf3aa',
    messagingSenderId: '102035129247',
    projectId: 'hooked-a21e9',
    storageBucket: 'hooked-a21e9.firebasestorage.app',
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_IOS_API_KEY']!,
    appId: '1:102035129247:ios:ea74e6be14b3723cddf3aa',
    messagingSenderId: '102035129247',
    projectId: 'hooked-a21e9',
    storageBucket: 'hooked-a21e9.firebasestorage.app',
    iosBundleId: 'com.example.hooked',
  );

  static FirebaseOptions macos = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_MACOS_API_KEY']!,
    appId: '1:102035129247:ios:ea74e6be14b3723cddf3aa',
    messagingSenderId: '102035129247',
    projectId: 'hooked-a21e9',
    storageBucket: 'hooked-a21e9.firebasestorage.app',
    iosBundleId: 'com.example.hooked',
  );

  static FirebaseOptions windows = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_WINDOWS_API_KEY']!,
    appId: '1:102035129247:web:793ae2ef5b2897b4ddf3aa',
    messagingSenderId: '102035129247',
    projectId: 'hooked-a21e9',
    authDomain: 'hooked-a21e9.firebaseapp.com',
    storageBucket: 'hooked-a21e9.firebasestorage.app',
    measurementId: 'G-1XW9HJZEE2',
  );
}
