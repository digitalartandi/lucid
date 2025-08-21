import 'dart:convert';
import 'package:flutter/foundation.dart' show ValueNotifier, kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_rss/dart_rss.dart';
import '../models/news_models.dart';

class NewsFeedService {
  static final NewsFeedService instance = NewsFeedService._();
  NewsFeedService._();

  static const _kSavedKey = 'feed.saved.v1';
  static const _kSourcesAsset = 'assets/feed/sources.json';
  static const _kCuratedAsset = 'assets/feed/curated.json';

  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  final List<FeedSource> _sources = [];
  final List<NewsItem> _items = [];
  final List<NewsItem> _saved = [];

  List<NewsItem> get items => List.unmodifiable(_items);
  List<NewsItem> get saved => List.unmodifiable(_saved);
  List<FeedSource> get sources => List.unmodifiable(_sources);

  Future<void> init() async {
    await _loadSources();
    await _loadSaved();
    if (_items.isEmpty) {
      await refresh();
    }
  }

  Future<void> _loadSources() async {
    try {
      final s = await rootBundle.loadString(_kSourcesAsset);
      final list = (jsonDecode(s) as List).cast<Map<String, dynamic>>();
      _sources
        ..clear()
        ..addAll(list.map(FeedSource.fromJson));
    } catch (_) {
      _sources
        ..clear()
        ..addAll(const [
          FeedSource(name: 'Curated', url: 'asset://curated', isStudy: true),
        ]);
    }
  }

  Future<void> _loadSaved() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kSavedKey);
    _saved
      ..clear()
      ..addAll(s == null ? const <NewsItem>[] : NewsItem.decodeList(s));
  }

  Future<void> _saveSaved() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kSavedKey, NewsItem.encodeList(_saved));
  }

  Future<void> refresh() async {
    final fetched = <NewsItem>[];
    bool anyNetworkOk = false;

    for (final src in _sources) {
      if (src.url == 'asset://curated') {
        final c = await _loadCurated();
        fetched.addAll(c);
        continue;
      }

      try {
        final r = await http.get(Uri.parse(src.url));
        if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}');
        final body = r.body;

        // RSS?
        try {
          final feed = RssFeed.parse(body);
          fetched.addAll(_rssToItems(feed, src));
          anyNetworkOk = true;
          continue;
        } catch (_) {}

        // Atom?
        try {
          final atom = AtomFeed.parse(body);
          fetched.addAll(_atomToItems(atom, src));
          anyNetworkOk = true;
          continue;
        } catch (_) {}

        // JSON Feed?
        final parsed = jsonDecode(body);
        if (parsed is Map && parsed['items'] is List) {
          final items = (parsed['items'] as List).cast<Map<String, dynamic>>();
          for (final m in items) {
            final title = (m['title'] ?? '').toString();
            final link = (m['url'] ?? m['link'] ?? '').toString();
            if (title.isEmpty || link.isEmpty) continue;
            fetched.add(NewsItem(
              id: '${src.name}:${link.hashCode}',
              title: title,
              link: link,
              source: src.name,
              published: DateTime.tryParse((m['date_published'] ?? m['published'] ?? '') as String? ?? ''),
              summary: (m['summary'] ?? m['content_text'] ?? '').toString(),
              imageUrl: (m['image'] ?? m['banner_image']) as String?,
              isStudy: src.isStudy,
              tags: const [],
            ));
          }
          anyNetworkOk = true;
          continue;
        }
      } catch (_) {
        // Ignorieren; Curated-Fallback greift
      }
    }

    if (!anyNetworkOk && fetched.isEmpty) {
      fetched.addAll(await _loadCurated());
    }

    // Deduplizieren + sortieren
    final map = <String, NewsItem>{};
    for (final it in fetched) {
      map[it.id] = it;
    }
    final list = map.values.toList()
      ..sort((a, b) {
        final ad = a.published ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.published ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });

    _items
      ..clear()
      ..addAll(list);

    revision.value++;
  }

  List<NewsItem> _rssToItems(RssFeed feed, FeedSource src) {
    return feed.items.map((i) {
      final link = i.link ?? i.guid ?? '';
      final img = i.enclosure?.url; // konservativ: enclosure (dart_rss garantiert vorhanden)

      return NewsItem(
        id: '${src.name}:${(link).hashCode}:${(i.pubDate ?? '').hashCode}',
        title: i.title ?? '(ohne Titel)',
        link: link,
        source: src.name,
        published: _tryRssDate(i.pubDate),
        summary: i.description ?? i.content?.value ?? '',
        imageUrl: img,
        isStudy: src.isStudy,
        tags: const [],
      );
    }).toList();
  }

  List<NewsItem> _atomToItems(AtomFeed feed, FeedSource src) {
    return feed.items.map((i) {
      final link = i.links.isNotEmpty ? (i.links.first.href ?? '') : '';
      final when = i.updated ?? i.published;
      return NewsItem(
        id: '${src.name}:${(link).hashCode}:${(when ?? '').hashCode}',
        title: i.title ?? '(ohne Titel)',
        link: link,
        source: src.name,
        published: when != null ? DateTime.tryParse(when) : null,
        summary: i.summary ?? '',
        imageUrl: null,
        isStudy: src.isStudy,
        tags: const [],
      );
    }).toList();
  }

  DateTime? _tryRssDate(String? s) {
    if (s == null) return null;
    // Konservativ: wir versuchen nur ISO-kompatibel; sonst null.
    try { return DateTime.parse(s); } catch (_) {}
    return null;
  }

  Future<List<NewsItem>> _loadCurated() async {
    try {
      final s = await rootBundle.loadString(_kCuratedAsset);
      final list = (jsonDecode(s) as List).cast<Map<String, dynamic>>();
      return list.map(NewsItem.fromJson).toList();
    } catch (_) {
      return const <NewsItem>[];
    }
  }

  bool isSaved(String id) => _saved.any((e) => e.id == id);

  Future<void> toggleSaved(NewsItem it) async {
    final idx = _saved.indexWhere((e) => e.id == it.id);
    if (idx >= 0) {
      _saved.removeAt(idx);
    } else {
      _saved.insert(0, it);
    }
    await _saveSaved();
    revision.value++;
  }
}
