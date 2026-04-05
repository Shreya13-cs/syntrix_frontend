import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBxxx', // Replace with your web API key
    appId: '1:xxxxx:web:xxxxx',
    messagingSenderId: 'xxxxx',
    projectId: 'syntrix-430f9',
    authDomain: 'syntrix-430f9.firebaseapp.com',
    storageBucket: 'syntrix-430f9.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxxx', // Replace with your Android API key
    appId: '1:xxxxx:android:xxxxx',
    messagingSenderId: 'xxxxx',
    projectId: 'syntrix-430f9',
    authDomain: 'syntrix-430f9.firebaseapp.com',
    storageBucket: 'syntrix-430f9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBxxx', // Replace with your iOS API key
    appId: '1:xxxxx:ios:xxxxx',
    messagingSenderId: 'xxxxx',
    projectId: 'syntrix-430f9',
    authDomain: 'syntrix-430f9.firebaseapp.com',
    storageBucket: 'syntrix-430f9.appspot.com',
    iosBundleId: 'com.example.syntrix',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBxxx', // Replace with your macOS API key
    appId: '1:xxxxx:macos:xxxxx',
    messagingSenderId: 'xxxxx',
    projectId: 'syntrix-430f9',
    authDomain: 'syntrix-430f9.firebaseapp.com',
    storageBucket: 'syntrix-430f9.appspot.com',
    iosBundleId: 'com.example.syntrix',
  );
}
