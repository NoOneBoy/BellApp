import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opciones de Firebase.
///
/// Sustituye los valores YOUR_* ejecutando `flutterfire configure`
/// o rellenando las constantes de [android] a mano.
class DefaultFirebaseOptions {
  static bool get isConfigured {
    const key = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
    if (key.isNotEmpty) return true;
    return android.apiKey != 'YOUR_API_KEY' && android.appId != 'YOUR_APP_ID';
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('BellApp no incluye web en el MVP.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no están configuradas para $defaultTargetPlatform.',
        );
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _env('FIREBASE_API_KEY', 'YOUR_API_KEY'),
        appId: _env('FIREBASE_APP_ID', 'YOUR_APP_ID'),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID', 'YOUR_SENDER_ID'),
        projectId: _env('FIREBASE_PROJECT_ID', 'YOUR_PROJECT_ID'),
        storageBucket: _env('FIREBASE_STORAGE_BUCKET', ''),
      );

  static String _env(String name, String fallback) {
    const defines = <String, String>{
      'FIREBASE_API_KEY': String.fromEnvironment('FIREBASE_API_KEY'),
      'FIREBASE_APP_ID': String.fromEnvironment('FIREBASE_APP_ID'),
      'FIREBASE_MESSAGING_SENDER_ID': String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID',
      ),
      'FIREBASE_PROJECT_ID': String.fromEnvironment('FIREBASE_PROJECT_ID'),
      'FIREBASE_STORAGE_BUCKET': String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    };
    final value = defines[name] ?? '';
    return value.isEmpty ? fallback : value;
  }
}
