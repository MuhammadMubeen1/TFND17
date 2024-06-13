
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.

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
    apiKey: 'AIzaSyDzr_rCbO7IuMaDnBQc49iZG4rhd32FBYc',
    appId: '1:1022131847009:web:95a3047404fc622a184f20',
    messagingSenderId: '1022131847009',
    projectId: 'tfnd-app',
    authDomain: 'tfnd-app.firebaseapp.com',
    storageBucket: 'tfnd-app.appspot.com',
    measurementId: 'G-P79WZ1ZH0K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQlTiFS0bjIVbSE-vyerzwjyqxB3PQ2Qk',
    appId: '1:1022131847009:android:7b0e782e1fd4f6c9184f20',
    messagingSenderId: '1022131847009',
    projectId: 'tfnd-app',
    storageBucket: 'tfnd-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAf00gPt2YJPqDlKEf2YWX_q8bTr_3XKz4',
    appId: '1:1022131847009:ios:914c4eb2aee2b1fe184f20',
    messagingSenderId: '1022131847009',
    projectId: 'tfnd-app',
    storageBucket: 'tfnd-app.appspot.com',
    iosBundleId: 'com.example.tfndApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAf00gPt2YJPqDlKEf2YWX_q8bTr_3XKz4',
    appId: '1:1022131847009:ios:10846362a94efe5f184f20',
    messagingSenderId: '1022131847009',
    projectId: 'tfnd-app',
    storageBucket: 'tfnd-app.appspot.com',
    iosBundleId: 'com.example.tfndApp.RunnerTests',
  );
}
