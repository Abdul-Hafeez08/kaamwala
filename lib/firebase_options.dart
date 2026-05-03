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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCHdtMYUT7kiiHZp3mOWI1euQzcOdIjN74',
    appId: '1:1081530084240:web:6265d82ea939236666a115',
    messagingSenderId: '1081530084240',
    projectId: 'myapp-3da2e',
    authDomain: 'myapp-3da2e.firebaseapp.com',
    storageBucket: 'myapp-3da2e.firebasestorage.app',
    measurementId: 'G-DXRFDRJR9Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvErB96xb_ityQflE8KaDPP68lE0jEF58',
    appId: '1:1081530084240:android:a88d9fdf6e3c643166a115',
    messagingSenderId: '1081530084240',
    projectId: 'myapp-3da2e',
    storageBucket: 'myapp-3da2e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyByQLNVaPdk0AOCZGtDQl0kTd7mNeifqGA',
    appId: '1:1081530084240:ios:a2d652248cd2fee366a115',
    messagingSenderId: '1081530084240',
    projectId: 'myapp-3da2e',
    storageBucket: 'myapp-3da2e.firebasestorage.app',
    iosBundleId: 'com.example.kaamwala',
  );
}
