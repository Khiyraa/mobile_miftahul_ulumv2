import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web tidak didukung dalam konfigurasi ini.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS belum dikonfigurasi.');
      default:
        throw UnsupportedError(
          'Platform ${defaultTargetPlatform.name} tidak didukung.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCn6YP6eWKM5zTlIKoTazDPATPRtS_olQ0',
    appId: '1:195307192861:android:9627ca59d901f458043cf4',
    messagingSenderId: '195307192861',
    projectId: 'miftahul-ulum-e7e5a',
    storageBucket: 'miftahul-ulum-e7e5a.firebasestorage.app',
  );
}
