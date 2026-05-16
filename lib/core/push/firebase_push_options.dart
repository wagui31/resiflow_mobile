import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebasePushOptions {
  const FirebasePushOptions._();

  static Future<FirebaseApp?> initializeAppForCurrentPlatform() async {
    if (kIsWeb) {
      return null;
    }

    if (Firebase.apps.isNotEmpty) {
      return Firebase.apps.first;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Firebase.initializeApp();
      case TargetPlatform.iOS:
        final options = _iosOptions();
        if (options == null) {
          return null;
        }
        return Firebase.initializeApp(options: options);
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  static FirebaseOptions? currentPlatformOrNull() {
    if (kIsWeb) {
      return null;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return null;
      case TargetPlatform.iOS:
        return _iosOptions();
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  static FirebaseOptions? _iosOptions() {
    const apiKey = String.fromEnvironment('FIREBASE_IOS_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
    const messagingSenderId = String.fromEnvironment(
      'FIREBASE_IOS_MESSAGING_SENDER_ID',
    );
    const projectId = String.fromEnvironment('FIREBASE_IOS_PROJECT_ID');
    const storageBucket = String.fromEnvironment('FIREBASE_IOS_STORAGE_BUCKET');
    const bundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

    if (!_hasRequiredValues(
      apiKey,
      appId,
      messagingSenderId,
      projectId,
      bundleId,
    )) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
      iosBundleId: bundleId,
    );
  }

  static bool _hasRequiredValues(String first, String second, String third, String fourth, [String? fifth]) {
    return first.isNotEmpty &&
        second.isNotEmpty &&
        third.isNotEmpty &&
        fourth.isNotEmpty &&
        (fifth == null || fifth.isNotEmpty);
  }
}
