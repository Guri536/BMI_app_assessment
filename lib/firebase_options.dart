// GENERATED PLACEHOLDER — replace by running the FlutterFire CLI:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// That command creates a real DefaultFirebaseOptions class wired to your
// Firebase project (Android + iOS) and overwrites this file automatically.
// See README.md "Firebase setup" for the full walkthrough.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform. '
      'Run `flutterfire configure` to generate real values.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIPZc8seKKGSUvJnsYwxMurQ8CzCF5cwU',
    appId: '1:124252071373:android:ec70e558033e30e8fc1084',
    messagingSenderId: '124252071373',
    projectId: 'bmi-app-e6397',
    storageBucket: 'bmi-app-e6397.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'REPLACE_ME',
  );
}
