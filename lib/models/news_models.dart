// lib/models/news_models.dart
import 'dart:convert';

class FeedSource {
  final String name;
  final String url;       // RSS/Atom/JSON
  final bool isStudy;     // true => Studien/Research, false => allgemeine News

  const FeedSource({
    required this.name,
    required this.url,
    required this.isStudy,
  });

  factory FeedSource.fromJson(Map<String, dynamic> m) => FeedSource(
        name: (m['name'] as String?)?.trim().isNotEmpty == true
            ? (m['name'] as String).trim()
            : 'Quelle',
        url: (m['url'] as String?)?.trim() ?? '',
        isStudy: (m['isStudy'] ?? false) as bool,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'isStudy': isStudy,
      };
}

class NewsItem {
  final String id;            // hash(url + published) oder guid
  final String title;
  final String link;
  final String source;        // z.B. "PubMed", "Nature", ...
  final DateTime? published;
  final String summary;       // kurzer Anleser/Abstract
  final String? imageUrl;     // optional
  final bool isStudy;         // ob als "Studie" eingeordnet
  final List<String> tags;

  const NewsItem({
    required this.id,
    required this.title,
    required this.link,
    required this.source,
    required this.published,
    required this.summary,
    required this.imageUrl,
    required this.isStudy,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'link': link,
        'source': source,
        'published': published?.toIso8601String(),
        'summary': summary,
        'imageUrl': imageUrl,
        'isStudy': isStudy,
        'tags': tags,
      };

  static NewsItem fromJson(Map<String, dynamic> m) => NewsItem(
        // Falls 'id' fehlt, auf 'link' zurückfallen, sonst leerer String
        id: (m['id'] as String?)?.trim().isNotEmpty == true
            ? (m['id'] as String).trim()
            : ((m['link'] as String?)?.trim() ?? ''),
        title: (m['title'] as String?)?.trim() ?? '',
        link: (m['link'] as String?)?.trim() ?? '',
        source: (m['source'] as String?)?.trim() ?? '',
        published: _parseAnyDate(m['published']),
        summary: (m['summary'] as String?)?.trim() ?? '',
        imageUrl: (m['imageUrl'] as String?)?.trim(),
        isStudy: (m['isStudy'] ?? false) as bool,
        tags: (m['tags'] as List?)
                ?.whereType<String>()
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList() ??
            const [],
      );

  static String encodeList(List<NewsItem> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<NewsItem> decodeList(String s) {
    if (s.trim().isEmpty) return const [];
    final raw = jsonDecode(s);
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .map(NewsItem.fromJson)
        .toList();
  }

  // -------- helpers --------

  static DateTime? _parseAnyDate(dynamic v) {
    if (v == null) return null;

    // ISO String
    if (v is String) {
      final t = v.trim();
      if (t.isEmpty) return null;
      return DateTime.tryParse(t);
    }

    // Milliseconds since epoch
    if (v is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(v, isUtc: false);
      } catch (_) {
        return null;
      }
    }

    // { "date": "...iso..." }
    if (v is Map) {
      final m = v.cast<String, dynamic>();
      final s = m['date'] as String?;
      if (s != null) return DateTime.tryParse(s);
    }

    return null;
  }
}
