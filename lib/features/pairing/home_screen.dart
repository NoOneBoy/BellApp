import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme.dart';
import '../../widgets/bell_app_bar.dart';
import 'join_room_screen.dart';
import 'waiting_room_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BellAppBar(title: 'BellApp'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.notifications_active_rounded, size: 88, color: BellTheme.gold),
              const SizedBox(height: 16),
              Text(
                'Dos campanas, un mismo tañido',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: BellTheme.cream,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Crea una campana o únete con un código. Al tocarla o agitar el móvil, suenan las dos — aunque la otra app esté cerrada.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: BellTheme.cream.withValues(alpha: 0.78),
                    ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WaitingRoomScreen()),
                  );
                },
                child: const Text('Crear campana'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const JoinRoomScreen()),
                  );
                },
                child: const Text('Unirse con código'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
