// lib/models/cue_models.dart
import 'package:flutter/cupertino.dart';

@immutable
class CueSound {
  final String id;         // z.B. "assets/audio/cues/birdsong01.mp3"
  final String name;       // Schöner Anzeigename, z.B. "Birdsong 01"
  final String category;   // z.B. "Vögel"
  const CueSound({required this.id, required this.name, required this.category});
}
