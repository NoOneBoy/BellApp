import 'package:flutter/material.dart';

import '../../theme.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              const Icon(Icons.cloud_off, size: 64, color: BellTheme.gold),
              const SizedBox(height: 16),
              Text(
                'Falta conectar Firebase',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: BellTheme.cream,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                'El emparejamiento a distancia y el sonido con la app cerrada necesitan un proyecto Firebase (Auth anónima, Firestore, FCM y Cloud Functions en plan Blaze).',
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Crea un proyecto en https://console.firebase.google.com\n'
                '2. Añade una app Android con id com.sara.bellapp\n'
                '3. Activa Authentication (anónimo), Cloud Firestore y Cloud Messaging\n'
                '4. Coloca android/app/google-services.json\n'
                '5. Sustituye YOUR_* en lib/firebase_options.dart o ejecuta flutterfire configure\n'
                '6. firebase deploy --only functions,firestore',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
