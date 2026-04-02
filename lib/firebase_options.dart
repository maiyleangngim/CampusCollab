// File generated manually from google-services.json
// Project: campuscollab-1dacc

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'No Web configuration provided. Add a web app in the Firebase console.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'No iOS configuration provided. Add an iOS app in the Firebase console.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDhN0_oWuXlMOr-Y5hRAAURIsHC-_wufEI',
    appId: '1:675632311641:android:7d578c2056a267d7337048',
    messagingSenderId: '675632311641',
    projectId: 'campuscollab-1dacc',
    storageBucket: 'campuscollab-1dacc.firebasestorage.app',
  );
}
