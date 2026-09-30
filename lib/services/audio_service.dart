import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class BellAudioService {
  BellAudioService._();
  static final instance = BellAudioService._();

  final AudioPlayer _player = AudioPlayer();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _player.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          usageType: AndroidUsageType.notificationRingtone,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          contentType: AndroidContentType.sonification,
        ),
      ),
    );
    _ready = true;
  }

  Future<void> play() async {
    try {
      await init();
      await _player.stop();
      await _player.play(AssetSource('sounds/bell.mp3'));
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(duration: 180);
      }
    } catch (error, stack) {
      debugPrint('Bell audio error: $error\n$stack');
    }
  }

  Future<void> dispose() => _player.dispose();
}
