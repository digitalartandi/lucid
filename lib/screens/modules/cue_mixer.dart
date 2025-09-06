import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Sehr schlanker Mixer: ein Cue + optionaler Hintergrund.
/// Nutzt zwei Player-Instanzen, damit beide Quellen gleichzeitig laufen können.
class CueMixer {
  final AudioPlayer cue = AudioPlayer(playerId: 'cue');
  final AudioPlayer bed = AudioPlayer(playerId: 'bed');

  String? cueAsset;
  String? bedAsset;

  double cueVolume = 1.0;
  double bedVolume = 0.25;

  Duration interval = const Duration(minutes: 10);
  Timer? _timer;
  bool _looping = false;

  CueMixer() {
    // Mischmodus: parallel abspielen erlauben
    AudioPlayer.global.setAudioContext(const AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: [AVAudioSessionOptions.mixWithOthers],
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    ));

    cue.setReleaseMode(ReleaseMode.stop);
    bed.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> setCue(String? asset) async {
    cueAsset = asset;
  }

  Future<void> setBed(String? asset) async {
    bedAsset = asset;
  }

  Future<void> setCueVolume(double v) async {
    cueVolume = v.clamp(0, 1);
    await cue.setVolume(cueVolume);
  }

  Future<void> setBedVolume(double v) async {
    bedVolume = v.clamp(0, 1);
    await bed.setVolume(bedVolume);
  }

  Future<void> probe({Duration cueLength = const Duration(seconds: 5)}) async {
    if (cueAsset == null) return;

    // Hintergrund nur für die Probedauer starten (falls vorhanden)
    if (bedAsset != null) {
      await bed.setSource(AssetSource(bedAsset!));
      await bed.setVolume(bedVolume);
      await bed.resume();
    }

    await cue.setSource(AssetSource(cueAsset!));
    await cue.setVolume(cueVolume);
    await cue.resume();

    // Nach Ablauf alles wieder stoppen
    Future.delayed(cueLength, () async {
      await cue.stop();
      if (bedAsset != null) await bed.stop();
    });
  }

  Future<void> startLoop() async {
    if (_looping) return;
    _looping = true;

    if (bedAsset != null) {
      await bed.setSource(AssetSource(bedAsset!));
      await bed.setVolume(bedVolume);
      await bed.resume(); // Dauerschleife
    }

    // sofort ein erstes Mal spielen…
    await _playCueOnce();
    // …und dann im Intervall
    _timer = Timer.periodic(interval, (_) => _playCueOnce());
  }

  Future<void> _playCueOnce() async {
    if (cueAsset == null) return;
    await cue.stop();
    await cue.setSource(AssetSource(cueAsset!));
    await cue.setVolume(cueVolume);
    await cue.resume();
  }

  Future<void> stopLoop() async {
    _looping = false;
    await cue.stop();
    await bed.stop();
    _timer?.cancel();
    _timer = null;
  }

  bool get isLooping => _looping;

  Future<void> dispose() async {
    await stopLoop();
    await cue.dispose();
    await bed.dispose();
  }
}
