import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'native_ring.dart';
import 'ring_deduper.dart';
import 'room_service.dart';
import 'session_store.dart';

class FcmService {
  FcmService._();
  static final instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  bool _attached = false;
  void Function(String ringId)? onForegroundRing;

  Future<void> requestPermissions() async {
    await Permission.notification.request();
    await _messaging.requestPermission(alert: true, sound: true, badge: true);
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (error, stack) {
      debugPrint('FCM token error: $error\n$stack');
      return null;
    }
  }

  void attach() {
    if (_attached) return;
    _attached = true;
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _messaging.onTokenRefresh.listen((_) async {
      final room = await SessionStore().readRoom();
      if (room != null) {
        await RoomService.instance.refreshToken(room);
      }
    });
  }

  void _onForegroundMessage(RemoteMessage message) {
    if (message.data['type'] != 'ring') return;
    final ringId = message.data['ringId'] ?? '';
    if (ringId.isEmpty) return;
    onForegroundRing?.call(ringId);
  }
}

@pragma('vm:entry-point')
Future<void> handleBackgroundRing(RemoteMessage message) async {
  if (message.data['type'] != 'ring') return;
  final ringId = message.data['ringId'] ?? '';
  if (!RingDeduper.claim(ringId)) return;
  // Con la app muerta el audio lo reproduce RingForegroundService (nativo).
  // Si este isolate llega a arrancar, pedimos el mismo servicio por canal.
  await NativeRing.playRemoteBell();
}
