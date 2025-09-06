// lib/services/cue_player.dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../models/cue_models.dart';

/// Singleton-Player für Cues (Intervall/Loop) + optionalen Hintergrund (dauerhaftes Loop).
/// Web-fix: normalisiert Asset-Pfade, damit es kein "/assets/assets/..." mehr gibt.
/// Wichtig: BytesSource wird NICHT verwendet (im Web nicht implementiert).
class CueLoopPlayer {
  CueLoopPlayer._() {
    _cue.onPlayerStateChanged.listen((s) => _cueState = s);
    _bed.onPlayerStateChanged.listen((s) => _bedState = s);
  }

  static final CueLoopPlayer instance = CueLoopPlayer._();

  final AudioPlayer _cue = AudioPlayer(playerId: 'cue');
  final AudioPlayer _bed = AudioPlayer(playerId: 'bed');

  PlayerState _cueState = PlayerState.stopped;
  PlayerState _bedState = PlayerState.stopped;
  Timer? _intervalTimer;

  bool get isPlaying => _cueState == PlayerState.playing || _intervalTimer != null;
  bool get isBedPlaying => _bedState == PlayerState.playing;

  // ---------------- interne Hilfe: Asset pfadsicher setzen ----------------
  Future<void> _setAssetSource(AudioPlayer p, String assetPath) async {
    final key = _normalizeAssetKey(assetPath);
    // key: z.B. "audio/cues/birdsong01.mp3" (ohne führendes "assets/")
    await p.setSource(AssetSource(key));
  }

  String _normalizeAssetKey(String raw) {
    var k = raw.trim();
    // führende Slashes entfernen
    while (k.startsWith('/')) k = k.substring(1);
    // doppelte Prefixe "assets/assets/..." auflösen
    if (k.startsWith('assets/assets/')) {
      k = k.substring('assets/'.length);
    }
    // einfaches "assets/" abwerfen → Web hängt selbst "/assets/" davor
    if (k.startsWith('assets/')) {
      k = k.substring('assets/'.length);
    }
    return k;
  }

  double _clampVol(double v) => v.isNaN ? 1.0 : v.clamp(0.0, 1.0);

  // ---------------- Cue: Einmal-Preview (z. B. in der Library) ----------------
  Future<void> playOnce(CueSound s, {int seconds = 5, double volume = .8}) async {
    _intervalTimer?.cancel();
    _intervalTimer = null;

    await _cue.stop();
    await _cue.setReleaseMode(ReleaseMode.stop);
    await _setAssetSource(_cue, s.asset);
    await _cue.setVolume(_clampVol(volume));
    await _cue.resume();

    if (seconds > 0) {
      Future.delayed(Duration(seconds: seconds), () {
        _cue.stop();
      });
    }
  }

  /// Einmal-Preview für reinen Asset-String (z. B. im Hintergrund-Picker).
  Future<void> playOnceAsset(String asset, {int seconds = 5, double volume = .8}) async {
    _intervalTimer?.cancel();
    _intervalTimer = null;

    await _cue.stop();
    await _cue.setReleaseMode(ReleaseMode.stop);
    await _setAssetSource(_cue, asset);
    await _cue.setVolume(_clampVol(volume));
    await _cue.resume();

    if (seconds > 0) {
      Future.delayed(Duration(seconds: seconds), () {
        _cue.stop();
      });
    }
  }

  // -------------------- Cue: Loop/Intervall (Tuning) --------------------
  /// Spielt den gewählten Cue als Dauerloop (**intervalMinutes == null oder <= 0**)
  /// oder im festen Intervall (**intervalMinutes > 0**, Cue wird zyklisch neu gestartet).
  Future<void> playLoop(
    CueSound s, {
    double volume = .8,
    int? intervalMinutes,
  }) async {
    await _cue.stop();
    _intervalTimer?.cancel();
    _intervalTimer = null;

    if (intervalMinutes == null || intervalMinutes <= 0) {
      // Dauerloop
      await _cue.setReleaseMode(ReleaseMode.loop);
      await _setAssetSource(_cue, s.asset);
      await _cue.setVolume(_clampVol(volume));
      await _cue.resume();
      return;
    }

    // Intervall-Spiel
    await _cue.setReleaseMode(ReleaseMode.stop);
    await _setAssetSource(_cue, s.asset);
    await _cue.setVolume(_clampVol(volume));
    await _cue.resume();

    _intervalTimer = Timer.periodic(Duration(minutes: intervalMinutes), (_) async {
      await _cue.seek(Duration.zero);
      await _cue.resume();
    });
  }

  // -------------------- Hintergrund (Bed): Dauer-Loop --------------------
  Future<void> startBedAsset(String asset, {double volume = .35}) async {
    await _bed.stop();
    await _bed.setReleaseMode(ReleaseMode.loop);
    await _setAssetSource(_bed, asset);
    await _bed.setVolume(_clampVol(volume));
    await _bed.resume();
  }

  Future<void> stopBed() async {
    await _bed.stop();
  }

  // ----------------------------- Stop alles ------------------------------
  Future<void> stop() async {
    await _cue.stop();
    await _bed.stop();
    _intervalTimer?.cancel();
    _intervalTimer = null;
  }
}
