// lib/models/news_models.dart
import 'dart:convert';

class FeedSource {
  final String name;
  final String url;       // RSS/Atom/JSON
  final bool isStudy;     // true => Studien/Research, false => allgemeine News
  const FeedSource({required this.name, required this.url, required this.isStudy});

  factory FeedSource.fromJson(Map<String, dynamic> m) => FeedSource(
    name: m['name'] as String? ?? 'Quelle',
    url:  m['url']  as String? ?? '',
    isStudy: (m['isStudy'] ?? false) as bool,
  );
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
    id: m['id'] as String,
    title: m['title'] as String? ?? '',
    link: m['link'] as String? ?? '',
    source: m['source'] as String? ?? '',
    published: (m['published'] as String?) != null ? DateTime.tryParse(m['published'] as String) : null,
    summary: m['summary'] as String? ?? '',
    imageUrl: m['imageUrl'] as String?,
    isStudy: (m['isStudy'] ?? false) as bool,
    tags: (m['tags'] as List?)?.cast<String>() ?? const [],
  );

  static String encodeList(List<NewsItem> list) => jsonEncode(list.map((e) => e.toJson()).toList());
  static List<NewsItem> decodeList(String s) {
    final raw = (jsonDecode(s) as List).cast<Map<String, dynamic>>();
    return raw.map(NewsItem.fromJson).toList();
  }
}
