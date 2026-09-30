import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../services/audio_service.dart';
import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';
import '../../services/ring_deduper.dart';
import '../../services/room_service.dart';
import '../../services/session_store.dart';
import '../../services/shake_service.dart';
import '../../theme.dart';
import '../pairing/home_screen.dart';
import 'bell_visual.dart';

class BellScreen extends StatefulWidget {
  const BellScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<BellScreen> createState() => _BellScreenState();
}

class _BellScreenState extends State<BellScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _shake = ShakeService();
  late final AnimationController _swing;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _rings;
  DateTime? _ignoreBefore;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _swing = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ignoreBefore = DateTime.now().subtract(const Duration(seconds: 2));
    WakelockPlus.enable();
    RoomService.instance.refreshToken(widget.roomCode);
    FcmService.instance.onForegroundRing = (ringId) {
      unawaited(
        _ringRemote(
          ringId,
          playAudio: _lifecycle == AppLifecycleState.resumed,
        ),
      );
    };
    _shake.start(_ringLocal);
    _rings = RoomService.instance.watchLatestRing(widget.roomCode).listen(_onRings);
  }

  @override
  void dispose() {
    FcmService.instance.onForegroundRing = null;
    WidgetsBinding.instance.removeObserver(this);
    _shake.stop();
    _rings?.cancel();
    _swing.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
  }

  void _onRings(QuerySnapshot<Map<String, dynamic>> snap) {
    if (snap.docs.isEmpty) return;
    final doc = snap.docs.first;
    final data = doc.data();
    final fromUid = data['fromUid'] as String? ?? '';
    if (fromUid == AuthService.instance.uid) return;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    if (createdAt != null && _ignoreBefore != null && createdAt.isBefore(_ignoreBefore!)) {
      return;
    }
    final playAudio = _lifecycle == AppLifecycleState.resumed;
    unawaited(_ringRemote(doc.id, playAudio: playAudio));
  }

  Future<void> _ringLocal() async {
    if (_busy) return;
    _busy = true;
    try {
      HapticFeedback.mediumImpact();
      _animate();
      await BellAudioService.instance.play();
      await RoomService.instance.sendRing(widget.roomCode);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo avisar a la otra campana: $error')),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> _ringRemote(String ringId, {required bool playAudio}) async {
    if (!RingDeduper.claim(ringId)) return;
    _animate();
    if (playAudio) {
      await BellAudioService.instance.play();
    }
  }

  void _animate() {
    _swing
      ..stop()
      ..reset()
      ..forward();
  }

  Future<void> _disconnect() async {
    await RoomService.instance.leaveRoom(widget.roomCode);
    await SessionStore().clearRoom();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Desconectar',
                    onPressed: _disconnect,
                    icon: const Icon(Icons.link_off),
                  ),
                  Expanded(
                    child: Text(
                      'Código ${widget.roomCode}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: BellTheme.cream,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _ringLocal,
              child: AnimatedBuilder(
                animation: _swing,
                builder: (context, _) {
                  final t = Curves.elasticOut.transform(_swing.value);
                  final angle = (1 - t) * 0.42 * ((_swing.value * 8).remainder(2) > 1 ? -1 : 1);
                  return BellVisual(swing: _swing.isAnimating ? angle : 0);
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Toca la campana o agita el móvil',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: BellTheme.cream),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                'Si la otra campana no suena con la app cerrada, desactiva la optimización de batería para BellApp en Ajustes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BellTheme.cream.withValues(alpha: 0.65),
                    ),
              ),
            ),
            TextButton(
              onPressed: openAppSettings,
              child: const Text('Abrir ajustes del sistema'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
