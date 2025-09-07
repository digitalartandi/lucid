// lib/services/news_feed_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb, ValueNotifier;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/news_models.dart';
import 'link_sanitizer.dart';

class NewsFeedService {
  NewsFeedService._();
  static final NewsFeedService instance = NewsFeedService._();

  /// UI hört darauf und baut neu.
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Sichtbare Liste (Tabs/Query filtert die UI).
  List<NewsItem> _items = [];
  List<NewsItem> get items => _items;

  /// Gespeicherte Einträge (Lesezeichen).
  List<NewsItem> _saved = [];
  List<NewsItem> get saved => _saved;

  static const _savedKey = 'feed.saved.v1';

  /// Relativ (funktioniert lokal & auf GH Pages / Subpfad):
  static const _webStudiesRel = 'feed/studies.json';
  static const _webNewsRel    = 'feed/news.json';

  /// Assets-Fallback:
  static const _assetsStudies = 'assets/feed/studies.json';
  static const _assetsNews    = 'assets/feed/news.json';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _loadSaved();
    // Direkt live laden (nur aus den beiden JSON-Dateien).
    unawaited(refresh());
  }

  // ---------------------------------------------------------------------------
  // Public
  // ---------------------------------------------------------------------------

  Future<void> refresh() async {
    final List<NewsItem> fresh = [];

    // 1) Studien (nur aus JSON)
    final studies = await _loadJsonListPreferWeb(_webStudiesRel, _assetsStudies);
    fresh.addAll(studies);

    // 2) News (nur aus JSON)
    final news = await _loadJsonListPreferWeb(_webNewsRel, _assetsNews);
    fresh.addAll(news);

    // 3) Nur gültige Links, deduplizieren, sortieren
    final byId = <String, NewsItem>{};
    for (final n in fresh) {
      final uri = LinkSanitizer.normalizeForLaunch(n.link);
      if (uri == null) continue;

      final normalized = _copyWithLink(n, uri.toString());
      final key = normalized.id.isNotEmpty ? normalized.id : normalized.link;
      byId[key] = normalized;
    }

    final merged = byId.values.toList()
      ..sort((a, b) {
        final ad = a.published ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.published ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });

    // Behalte bisherigen Stand, wenn gar nichts geladen werden konnte.
    if (merged.isEmpty && _items.isNotEmpty) {
      _bump();
      return;
    }

    _items = merged;
    _bump();
  }

  bool isSaved(String id) => _saved.any((e) => e.id == id);

  Future<void> toggleSaved(NewsItem item) async {
    if (isSaved(item.id)) {
      _saved = _saved.where((e) => e.id != item.id).toList();
    } else {
      _saved = [..._saved, item];
    }
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _savedKey,
      jsonEncode(_saved.map((e) => e.toJson()).toList()),
    );
    _bump();
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  void _bump() => revision.value++;

  Future<void> _loadSaved() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_savedKey);
    if (raw == null || raw.isEmpty) {
      _saved = [];
      return;
    }
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _saved = list;
    } catch (_) {
      _saved = [];
    }
  }

  /// Liest eine JSON-Liste **zuerst** relativ über HTTP (nur Web),
  /// dann – falls nötig – aus den App-Assets.
  Future<List<NewsItem>> _loadJsonListPreferWeb(
    String relWebPath,
    String assetsPath,
  ) async {
    if (kIsWeb) {
      // Reihenfolge: (1) basis-relativ, (2) ab Root, (3) absolute GH-Pages-URL
      final candidates = <Uri>[
        Uri.base.resolve(relWebPath),
        Uri.parse('/$relWebPath'),
        Uri.parse('https://digitalartandi.github.io/lucid/$relWebPath'),
      ];

      for (final u in candidates) {
        final withCb = u.replace(queryParameters: {
          ...u.queryParameters,
          'v': DateTime.now().millisecondsSinceEpoch.toString(), // Cache-Buster
        });
        try {
          final r = await http.get(withCb).timeout(const Duration(seconds: 10));
          if (r.statusCode == 200 && r.body.isNotEmpty) {
            return _parseItems(r.body);
          }
        } catch (_) {
          // Nächsten Kandidaten probieren
        }
      }
    }

    // Asset-Fallback (funktioniert überall)
    try {
      final s = await rootBundle.loadString(assetsPath);
      return _parseItems(s);
    } catch (_) {
      return const [];
    }
  }

  List<NewsItem> _parseItems(String jsonText) {
    try {
      final list = (jsonDecode(jsonText) as List)
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      return const [];
    }
  }

  NewsItem _copyWithLink(NewsItem n, String link) => NewsItem(
        id: n.id,
        title: n.title,
        summary: n.summary,
        link: link,
        source: n.source,
        isStudy: n.isStudy,
        published: n.published,
        imageUrl: n.imageUrl,
        tags: n.tags,
      );
}
