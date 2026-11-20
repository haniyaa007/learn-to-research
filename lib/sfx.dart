import 'package:audioplayers/audioplayers.dart';

/// Tiny sound-effect helper. Files live in assets/audio/*.wav
class Sfx {
  static final _p = AudioPlayer();
  static Future<void> play(String name) async {
    try {
      await _p.stop();
      await _p.play(AssetSource('audio/$name.wav'));
    } catch (_) {/* never crash the game over sound */}
  }
}
