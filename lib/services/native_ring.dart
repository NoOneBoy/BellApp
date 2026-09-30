import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeRing {
  NativeRing._();

  static const _channel = MethodChannel('com.sara.bellapp/ring');

  static Future<void> playRemoteBell() async {
    try {
      await _channel.invokeMethod<void>('playRemoteBell');
    } catch (error, stack) {
      debugPrint('Native ring error: $error\n$stack');
    }
  }
}
