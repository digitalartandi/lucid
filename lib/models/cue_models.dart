// lib/models/cue_models.dart
import 'package:flutter/foundation.dart';

@immutable
class CueSound {
  final String id;        // z.B. "birds01"
  final String name;      // z.B. "Vogelgesang sanft"
  final String category;  // z.B. "Tiere"
  final String asset;     // z.B. "assets/audio/cues/birdsong01.mp3"

  const CueSound({
    required this.id,
    required this.name,
    required this.category,
    required this.asset,
  });

  CueSound copyWith({
    String? id,
    String? name,
    String? category,
    String? asset,
  }) => CueSound(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        asset: asset ?? this.asset,
      );
}

// Optional: einfache Kategorie-Konstanten (wenn du sie brauchst)
class CueCategories {
  static const animals   = 'Tiere';
  static const water     = 'Wasser & Regen';
  static const wind      = 'Wind & Natur';
  static const chimes    = 'Glocken & Chimes';
  static const synth     = 'Synth & Space';
  static const ambience  = 'Ambience';
}
