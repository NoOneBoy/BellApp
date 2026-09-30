import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'features/bell/bell_screen.dart';
import 'features/pairing/home_screen.dart';
import 'features/pairing/waiting_room_screen.dart';
import 'features/setup/firebase_setup_screen.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/fcm_service.dart';
import 'services/room_service.dart';
import 'services/session_store.dart';
import 'theme.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!DefaultFirebaseOptions.isConfigured) return;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await handleBackgroundRing(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = DefaultFirebaseOptions.isConfigured;
  if (firebaseReady) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (error) {
      firebaseReady = false;
      debugPrint('Firebase init failed: $error');
    }
  }
  runApp(BellApp(firebaseReady: firebaseReady));
}

class BellApp extends StatelessWidget {
  const BellApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BellApp',
      debugShowCheckedModeBanner: false,
      theme: BellTheme.dark(),
      home: firebaseReady ? const _LaunchGate() : const FirebaseSetupScreen(),
    );
  }
}

class _LaunchGate extends StatefulWidget {
  const _LaunchGate();

  @override
  State<_LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<_LaunchGate> {
  Widget? _home;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await AuthService.instance.ensureSignedIn();
      await FcmService.instance.requestPermissions();
      FcmService.instance.attach();
      final room = await SessionStore().readRoom();
      final home = await _homeForRoom(room);
      if (!mounted) return;
      setState(() => _home = home);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  Future<Widget> _homeForRoom(String? room) async {
    if (room == null) return const HomeScreen();
    try {
      final snap = await RoomService.instance.roomRef(room).get();
      final status = snap.data()?['status'] as String?;
      if (!snap.exists || status == null) {
        await SessionStore().clearRoom();
        return const HomeScreen();
      }
      if (status == 'waiting') {
        return WaitingRoomScreen(existingCode: room);
      }
      return BellScreen(roomCode: room);
    } catch (_) {
      return BellScreen(roomCode: room);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error al iniciar: $_error')));
    }
    if (_home == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _home!;
  }
}
