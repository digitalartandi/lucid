// lib/services/affirmation_repo.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/affirmation_models.dart';

/// Lädt alle Affirmations-MP3s aus dem Asset-Manifest.
/// Erwartet Pfad-Präfix: assets/audio/affirmations/
class AffirmationRepo {
  static final AffirmationRepo instance = AffirmationRepo._();
  AffirmationRepo._();

  static const _prefix = 'assets/audio/affirmations/';
  List<AffirmationTrack> _cache = [];

  /// Einmalig scannen. Kann beliebig oft aufgerufen werden (idempotent).
  Future<void> init() async {
    if (_cache.isNotEmpty) return;
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = jsonDecode(manifestJson);

    final keys = manifest.keys
        .where((k) => k.startsWith(_prefix) && k.toLowerCase().endsWith('.mp3'))
        .toList()
      ..sort();

    _cache = keys.map((assetPath) {
      final file = assetPath.split('/').last; // z.B. ich-bin-genug.mp3
      final base = file.endsWith('.mp3') ? file.substring(0, file.length - 4) : file;

      // "ich-bin-genug" -> "Ich bin genug"
      String prettify(String s) =>
          s.replaceAll(RegExp(r'[_\-]+'), ' ')
              .trim()
              .split(' ')
              .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
              .join(' ');

      return AffirmationTrack(
        id: base,
        title: prettify(base),
        asset: assetPath,
      );
    }).toList();
  }

  Future<List<AffirmationTrack>> list() async {
    await init();
    return List<AffirmationTrack>.from(_cache);
  }

  Future<AffirmationTrack?> byId(String id) async {
    await init();
    try {
      return _cache.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
