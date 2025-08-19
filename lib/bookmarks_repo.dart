// lib/bookmarks_repo.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/study.dart';

/// Keys (halten wir bewusst getrennt von evtl. alten Keys)
const _kSavedIds = 'studies_saved_ids_v1';
const _kSavedItems = 'studies_saved_items_v1';

class BookmarksRepo {
  const BookmarksRepo();

  Future<Set<String>> loadSavedIds() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_kSavedIds)?.toSet() ?? <String>{};
  }

  Future<List<Study>> loadSavedItems() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kSavedItems);
    if (raw == null) return [];
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Study.fromJson).toList();
  }

  Future<void> _persist(Set<String> ids, List<Study> items) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_kSavedIds, ids.toList());
    await sp.setString(_kSavedItems, json.encode(items.map((e) => e.toJson()).toList()));
  }

  /// Toggle Bookmark für eine Studie (id = DOI oder PMID)
  Future<void> toggle(Study s) async {
    final ids = await loadSavedIds();
    final items = await loadSavedItems();

    if (ids.contains(s.id)) {
      ids.remove(s.id);
      items.removeWhere((e) => e.id == s.id);
    } else {
      ids.add(s.id);
      // kompaktes Objekt speichern (alles on-device)
      final compact = Study(
        id: s.id,
        title: s.title,
        source: s.source,
        doi: s.doi,
        url: s.url,
        published: s.published,
        journal: s.journal,
        authors: s.authors,
        abstractText: s.abstractText,
      );
      // Dedupe by id
      final map = <String, Study>{for (final e in items) e.id: e};
      map[compact.id] = compact;
      // zurück in Liste
      final merged = map.values.toList()
        ..sort((a, b) => (b.published ?? DateTime(1900)).compareTo(a.published ?? DateTime(1900)));
      await _persist(ids, merged);
      return;
    }

    await _persist(ids, items);
  }

  Future<bool> isSaved(String id) async {
    final ids = await loadSavedIds();
    return ids.contains(id);
  }
}
