// lib/models/affirmation_models.dart
import 'package:flutter/foundation.dart';

@immutable
class AffirmationTrack {
  final String id;          // z.B. "ich-bin-genug"
  final String title;       // z.B. "Ich bin genug"
  final String asset;       // z.B. "assets/audio/affirmations/ich-bin-genug.mp3"
  final String category;    // z.B. "Affirmation"
  final String? cover;      // optional, falls du Bilder hinzufügen willst

  const AffirmationTrack({
    required this.id,
    required this.title,
    required this.asset,
    this.category = 'Affirmation',
    this.cover,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'asset': asset,
    'category': category,
    'cover': cover,
  };

  factory AffirmationTrack.fromJson(Map<String, dynamic> m) => AffirmationTrack(
    id: m['id'] as String,
    title: m['title'] as String,
    asset: m['asset'] as String,
    category: (m['category'] as String?) ?? 'Affirmation',
    cover: m['cover'] as String?,
  );
}
