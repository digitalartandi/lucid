import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CueLoopPlayer {
  CueLoopPlayer._();
  static final instance = CueLoopPlayer._();

  final _player = AudioPlayer();
  String? _currentAsset;

  Stream<PlayerState> get state => _player.playerStateStream;

  Future<void> playLoop(
    String asset, {
    double volume = 0.8,
    Duration fadeIn = const Duration(milliseconds: 250),
  }) async {
    if (_currentAsset == asset && _player.playing) {
      // Nur Lautstärke ggf. nachziehen
      await _player.setVolume(volume.clamp(0.0, 1.0));
      return;
    }
    _currentAsset = asset;

    await _player.setAsset(asset);
    await _player.setLoopMode(LoopMode.one);

    // Web/iOS Autoplay: mit minimal > 0 starten, dann smooth hoch
    final startVol = kIsWeb ? 0.001 : (volume.clamp(0.0, 1.0));
    await _player.setVolume(startVol);
    await _player.play();

    // sanft auf Ziel-Lautstärke
    if (startVol != volume) {
      unawaited(_fadeTo(volume, fadeIn));
    }
  }

  Future<void> stop({Duration fadeOut = const Duration(milliseconds: 200)}) async {
    await _fadeTo(0.0, fadeOut);
    await _player.stop();
    _currentAsset = null;
  }

  Future<void> setVolume(double v) => _player.setVolume(v.clamp(0.0, 1.0));

  Future<void> dispose() => _player.dispose();

  Future<void> _fadeTo(double target, Duration d) async {
    final start = _player.volume;
    final steps = (d.inMilliseconds / 30).clamp(1, 60).toInt();
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final v = start + (target - start) * t;
      await _player.setVolume(v);
      await Future.delayed(const Duration(milliseconds: 30));
    }
    await _player.setVolume(target);
  }
}
