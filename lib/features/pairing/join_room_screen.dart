import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/room_service.dart';
import '../../services/session_store.dart';
import '../../theme.dart';
import '../../widgets/bell_app_bar.dart';
import '../bell/bell_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final code = _controller.text.trim();
      await RoomService.instance.joinRoom(code);
      await SessionStore().saveRoom(code);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => BellScreen(roomCode: code)),
        (route) => false,
      );
    } catch (error) {
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BellAppBar(title: 'Unirse'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Escribe el código de 6 dígitos de la otra campana.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: BellTheme.cream),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 32,
                  letterSpacing: 12,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: BellTheme.surface,
                  hintText: '000000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onSubmitted: (_) => _join(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _busy ? null : _join,
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Emparejar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
