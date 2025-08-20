class MeditationTrack {
  final String id;
  final String title;
  final String category;
  final String asset;  // mp3
  final String cover;  // image

  const MeditationTrack({
    required this.id,
    required this.title,
    required this.category,
    required this.asset,
    required this.cover,
  });

  factory MeditationTrack.fromJson(Map<String, dynamic> m) => MeditationTrack(
    id: m['id'] as String,
    title: m['title'] as String,
    category: (m['category'] ?? '') as String,
    asset: m['asset'] as String,
    cover: (m['cover'] ?? '') as String,
  );
}
