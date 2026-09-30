import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/room_service.dart';
import '../../services/session_store.dart';
import '../../theme.dart';
import '../../widgets/bell_app_bar.dart';
import '../bell/bell_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key, this.existingCode});

  final String? existingCode;

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  String? _code;
  String? _error;
  bool _creating = true;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _create();
  }

  Future<void> _create() async {
    try {
      final existing = widget.existingCode;
      final code = existing ?? await RoomService.instance.createRoom();
      await SessionStore().saveRoom(code);
      if (!mounted) return;
      setState(() {
        _code = code;
        _creating = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _creating = false;
      });
    }
  }

  void _onRoom(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (_opened) return;
    final status = snap.data()?['status'] as String?;
    if (status == 'paired' && _code != null) {
      _opened = true;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => BellScreen(roomCode: _code!)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _code;
    return Scaffold(
      appBar: BellAppBar(
        title: 'Tu código',
        actions: [
          if (code != null)
            IconButton(
              tooltip: 'Copiar',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código copiado')),
                );
              },
              icon: const Icon(Icons.copy),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _creating
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : StreamBuilder(
                      stream: RoomService.instance.watchRoom(code!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _onRoom(snapshot.data!);
                          });
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(),
                            Text(
                              code,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 8,
                                color: BellTheme.gold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Comparte este código con el otro móvil. Cuando se una, las campanas quedarán emparejadas.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: BellTheme.cream.withValues(alpha: 0.8),
                                  ),
                            ),
                            const SizedBox(height: 24),
                            const Center(child: CircularProgressIndicator()),
                            const SizedBox(height: 12),
                            const Text(
                              'Esperando a la otra campana…',
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                          ],
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
