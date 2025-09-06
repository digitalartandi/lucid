// lib/services/cue_player.dart
//
// Player-Service für Cue-Tuning / RC-Reminder / Night Lite+.
// - Zwei Player: _cue (der eigentliche Cue), _bed (optionales Hintergrundbett)
// - Web-freundliches Laden: auf Web wird eine UrlSource mit URL-encodetem Pfad genutzt,
//   damit Sonderzeichen/Leerzeichen funktionieren.
// - API bleibt stabil:
//
//   final p = CueLoopPlayer.instance;
//   await p.playOnce(cue, seconds: 5, volume: 0.8);
//   await p.playLoop(cue, volume: 0.7, intervalMinutes: 0); // 0 = endloser Loop
//   await p.startBedAsset('assets/audio/meditation/xyz.mp3', volume: 0.35);
//   await p.stop();
//
//   Getter: p.isPlaying, p.isBedPlaying
//
//   Zusatz: playOnceAsset(...) für Altaufrufe.

import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audioplayers/audioplayers.dart';
import '../models/cue_models.dart'; // nur für den Typ CueSound

class CueLoopPlayer {
  CueLoopPlayer._internal() {
    _cue.setReleaseMode(ReleaseMode.stop);
    _bed.setReleaseMode(ReleaseMode.loop);
  }

  static final CueLoopPlayer instance = CueLoopPlayer._internal();

  final AudioPlayer _cue = AudioPlayer(playerId: 'cue-player');
  final AudioPlayer _bed = AudioPlayer(playerId: 'cue-bed');

  bool _cueActive = false; // cue läuft aktuell (Loop ODER gerade im "once")
  bool _bedActive = false; // bed läuft
  Timer? _intervalTimer;

  bool get isPlaying => _cueActive || _intervalTimer != null;
  bool get isBedPlaying => _bedActive;

  // ------------------ Quelle robust setzen ------------------

  Future<void> _setSourceAssetSafe(AudioPlayer p, String assetPath) async {
    if (kIsWeb) {
      // Segmente encoden (z. B. Leerzeichen, Klammern), Slash bleibt erhalten
      final encoded = assetPath.split('/').map(Uri.encodeComponent).join('/');
      await p.setSource(UrlSource(encoded)); // respektiert <base href>
    } else {
      await p.setSource(AssetSource(assetPath));
    }
  }

  // ------------------ Hintergrundbett -----------------------

  Future<void> startBedAsset(String asset, {double volume = 0.35}) async {
    await _bed.stop();
    await _setSourceAssetSafe(_bed, asset);
    await _bed.setVolume(volume);
    await _bed.setReleaseMode(ReleaseMode.loop);
    await _bed.resume();
    _bedActive = true;
  }

  // ------------------ Cue: Preview --------------------------

  Future<void> playOnce(CueSound cue, {int seconds = 5, double volume = 0.8}) async {
    await _playCueOnce(cue.asset, volume, seconds: seconds);
  }

  // Legacy-Helfer (wird in einzelnen Screens noch referenziert)
  Future<void> playOnceAsset(String asset, {int seconds = 5, double volume = 0.8}) async {
    await _playCueOnce(asset, volume, seconds: seconds);
  }

  Future<void> _playCueOnce(String asset, double vol, {int seconds = 5}) async {
    // Falls gerade Loop/Timer aktiv ist, unterbrechen wir kurz nur den Cue-Kanal
    await _cue.stop();
    await _setSourceAssetSafe(_cue, asset);
    await _cue.setVolume(vol);
    await _cue.setReleaseMode(ReleaseMode.stop);
    _cueActive = true;
    await _cue.resume();

    // nach 'seconds' wieder stoppen
    Timer(Duration(seconds: seconds), () async {
      await _cue.stop();
      _cueActive = false;
    });
  }

  // ------------------ Cue: Loop/Intervall -------------------

  /// Startet die Wiedergabe:
  /// - intervalMinutes <= 0  -> permanenter Loop (Repeat)
  /// - intervalMinutes > 0   -> alle N Minuten 5s „Ping“ (Once)
  Future<void> playLoop(CueSound cue, {required double volume, int? intervalMinutes}) async {
    await stopCueChannel(); // räumt Timer & Player
    final minutes = intervalMinutes ?? 0;

    if (minutes <= 0) {
      await _loopCueAsset(cue.asset, volume);
      return;
    }

    // 1x sofort abspielen, dann periodisch
    await _playCueOnce(cue.asset, volume, seconds: 5);
    _intervalTimer = Timer.periodic(Duration(minutes: minutes), (_) async {
      await _playCueOnce(cue.asset, volume, seconds: 5);
    });
  }

  Future<void> _loopCueAsset(String asset, double vol) async {
    await _cue.stop();
    await _setSourceAssetSafe(_cue, asset);
    await _cue.setVolume(vol);
    await _cue.setReleaseMode(ReleaseMode.loop);
    _cueActive = true;
    await _cue.resume();
  }

  // ------------------ Stop / Cleanup ------------------------

  Future<void> stopCueChannel() async {
    _intervalTimer?.cancel();
    _intervalTimer = null;
    await _cue.stop();
    _cueActive = false;
  }

  Future<void> stopBed() async {
    await _bed.stop();
    _bedActive = false;
  }

  Future<void> stop() async {
    await stopCueChannel();
    await stopBed();
  }
}
