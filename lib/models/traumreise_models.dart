// lib/models/traumreise_models.dart
class Traumreise {
  final String id;
  final String title;
  final String subtitle;
  final String imageAsset; // 3:2 Banner
  final String audioAsset; // MP3
  final int? durationSec;  // optional
  final List<String> tags;

  const Traumreise({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.audioAsset,
    this.durationSec,
    this.tags = const [],
  });

  factory Traumreise.fromJson(Map<String, dynamic> j) => Traumreise(
        id: j['id'] as String,
        title: (j['title'] ?? '') as String,
        subtitle: (j['subtitle'] ?? '') as String,
        imageAsset: (j['image'] ?? '') as String,
        audioAsset: (j['audio'] ?? '') as String,
        durationSec: j['durationSec'] is int ? j['durationSec'] as int : null,
        tags: (j['tags'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'image': imageAsset,
        'audio': audioAsset,
        'durationSec': durationSec,
        'tags': tags,
      };
}
