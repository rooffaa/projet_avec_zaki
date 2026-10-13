
import 'package:audioplayers/audioplayers.dart';

class MusicService {
  MusicService._();

  static final MusicService instance = MusicService._();

  final AudioPlayer _player = AudioPlayer();

  bool _initialisee = false;

  Future<void> demarrer() async {
    if (_initialisee) return;

    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.25);

      await _player.play(
        AssetSource('audio/jeux.mp3'),
      );

      _initialisee = true;
    } catch (e) {
      print('Erreur de lecture musicale : $e');
    }
  }

  Future<void> mettreEnPause() async {
    await _player.pause();
  }

  Future<void> reprendre() async {
    if (_initialisee) {
      await _player.resume();
    } else {
      await demarrer();
    }
  }

  Future<void> arreter() async {
    await _player.stop();
    _initialisee = false;
  }

  Future<void> reglerVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }
}
