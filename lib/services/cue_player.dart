// lib/services/cue_player.dart
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/cue_models.dart';

class CueLoopPlayer {
  CueLoopPlayer._();
  static final CueLoopPlayer instance = CueLoopPlayer._();

  final AudioPlayer _player = AudioPlayer();
  Timer? _intervalTimer;

  bool get isPlaying => _player.playing;

  Future<void> stop() async {
    _intervalTimer?.cancel();
    _intervalTimer = null;
    await _player.stop();
  }

  /// --- Bequeme Helfer: akzeptieren direkt Asset-Strings ---
  Future<void> playOnceAsset(String asset, {double volume = .8, int seconds = 5}) async {
    final s = CueSound(id: asset, name: _basename(asset), category: 'Custom', asset: asset);
    await playOnce(s, volume: volume, seconds: seconds);
  }

  Future<void> playLoopAsset(String asset, {double volume = .8, int? intervalMinutes}) async {
    final s = CueSound(id: asset, name: _basename(asset), category: 'Custom', asset: asset);
    await playLoop(s, volume: volume, intervalMinutes: intervalMinutes);
  }

  /// --- Haupt-APIs: CueSound-Objekt ---
  Future<void> playOnce(CueSound cue, {double volume = .8, int seconds = 5}) async {
    await stop();
    await _player.setAudioSource(AudioSource.asset(cue.asset));
    await _player.setLoopMode(LoopMode.off);
    await _player.setVolume(_clamp(volume, 0, 1));
    await _player.play();
    if (seconds > 0) {
      _intervalTimer?.cancel();
      _intervalTimer = Timer(Duration(seconds: seconds), () => stop());
    }
  }

  /// Spielt in Schleife. Optional kann in Intervallen neu „angestoßen“ werden (einfacher Timer).
  Future<void> playLoop(CueSound cue, {double volume = .8, int? intervalMinutes}) async {
    await stop();
    await _player.setAudioSource(AudioSource.asset(cue.asset));
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(_clamp(volume, 0, 1));
    await _player.play();

    // Optionales Intervall-Re-Triggering (einfach gehalten)
    if (intervalMinutes != null && intervalMinutes > 0) {
      _intervalTimer = Timer.periodic(Duration(minutes: intervalMinutes), (_) async {
        // kurzes "neustarten", um Cue wahrnehmbar zu machen
        await _player.seek(Duration.zero);
        if (!_player.playing) await _player.play();
      });
    }
  }

  String _basename(String p) {
    final i = p.lastIndexOf('/');
    return (i >= 0 ? p.substring(i + 1) : p).replaceAll('_', ' ').replaceAll('-', ' ');
  }

  double _clamp(double v, double min, double max) => v < min ? min : (v > max ? max : v);
}
