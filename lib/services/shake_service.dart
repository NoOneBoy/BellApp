import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class ShakeService {
  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);

  void start(void Function() onShake) {
    stop();
    _sub = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      final gForce = (magnitude / 9.81 - 1).abs();
      if (gForce < 1.8) return;
      final now = DateTime.now();
      if (now.difference(_last) < const Duration(milliseconds: 1400)) return;
      _last = now;
      onShake();
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
