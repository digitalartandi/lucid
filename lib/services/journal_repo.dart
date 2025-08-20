// lib/services/journal_repo.dart
import 'dart:convert';
import 'dart:io' show Directory, File;
import 'package:flutter/foundation.dart' show kIsWeb, ValueNotifier;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_models.dart';

class JournalRepo {
  static const _indexKey = 'journal_index_v1';
  static const _entryPrefix = 'journal_entry_v1_';

  static final JournalRepo instance = JournalRepo._();
  JournalRepo._();

  Directory? _dir; // mobile-only
  final List<JournalIndexItem> _index = [];
  final Map<String, JournalEntry> _cache = {};

  /// UI kann hierauf lauschen. Erhöht sich bei jeder Änderung.
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  // -------- init --------

  Future<void> init() async {
    if (!kIsWeb) {
      final base = await getApplicationSupportDirectory();
      _dir = Directory('${base.path}/journal');
      if (!await _dir!.exists()) {
        await _dir!.create(recursive: true);
      }
      await _loadIndexMobile();
    } else {
      await _loadIndexWeb();
    }
  }

  // -------- Index Laden/Speichern --------

  Future<void> _loadIndexMobile() async {
    final f = File('${_dir!.path}/index.json');
    if (await f.exists()) {
      final s = await f.readAsString();
      final list = (jsonDecode(s) as List)
          .map((e) => JournalIndexItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _index
        ..clear()
        ..addAll(list);
    } else {
      _index.clear();
    }
  }

  Future<void> _saveIndexMobile() async {
    final f = File('${_dir!.path}/index.json');
    final s = jsonEncode(_index.map((e) => e.toJson()).toList());
    await f.writeAsString(s);
  }

  Future<void> _loadIndexWeb() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_indexKey);
    if (s == null) {
      _index.clear();
      return;
    }
    final list = (jsonDecode(s) as List)
        .map((e) => JournalIndexItem.fromJson(e as Map<String, dynamic>))
        .toList();
    _index
      ..clear()
      ..addAll(list);
  }

  Future<void> _saveIndexWeb() async {
    final sp = await SharedPreferences.getInstance();
    final s = jsonEncode(_index.map((e) => e.toJson()).toList());
    await sp.setString(_indexKey, s);
  }

  Future<void> _saveIndex() => kIsWeb ? _saveIndexWeb() : _saveIndexMobile();

  void _bump() => revision.value = revision.value + 1;

  // -------- CRUD / Abfragen --------

  /// 🔹 NEU: Von der UI erwartete Methode (Fix für `journal_list_page.dart`)
  Future<List<JournalIndexItem>> list({int? limit}) async {
    await init();
    final all = await listAll();
    return limit == null ? all : all.take(limit).toList();
  }

  Future<List<JournalIndexItem>> listAll() async {
    _index.sort((a, b) => b.date.compareTo(a.date));
    return List<JournalIndexItem>.from(_index);
  }

  Future<List<JournalIndexItem>> latest({int count = 3}) async {
    final all = await listAll();
    return all.take(count).toList();
  }

  Future<int> count() async => _index.length;

  Future<JournalEntry?> getById(String id) async {
    if (_cache.containsKey(id)) return _cache[id];

    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      final s = sp.getString('$_entryPrefix$id');
      if (s == null) return null;
      final e = JournalEntry.fromJson(jsonDecode(s));
      _cache[id] = e;
      return e;
    } else {
      final f = File('${_dir!.path}/entries/$id.json');
      if (!await f.exists()) return null;
      final s = await f.readAsString();
      final e = JournalEntry.fromJson(jsonDecode(s));
      _cache[id] = e;
      return e;
    }
  }

  Future<void> upsert(JournalEntry e) async {
    e = e.copyWith(date: DateTime.now());
    _cache[e.id] = e;

    final idx = _index.indexWhere((x) => x.id == e.id);
    final item = JournalIndexItem.fromEntry(e);
    if (idx >= 0) {
      _index[idx] = item;
    } else {
      _index.add(item);
    }

    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('$_entryPrefix${e.id}', jsonEncode(e.toJson()));
      await _saveIndexWeb();
    } else {
      final entriesDir = Directory('${_dir!.path}/entries');
      if (!await entriesDir.exists()) {
        await entriesDir.create(recursive: true);
      }
      final f = File('${entriesDir.path}/${e.id}.json');
      await f.writeAsString(jsonEncode(e.toJson()));
      await _saveIndexMobile();
    }
    _bump();
  }

  Future<void> delete(String id) async {
    _cache.remove(id);
    _index.removeWhere((x) => x.id == id);

    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      await sp.remove('$_entryPrefix$id');
      await _saveIndexWeb();
    } else {
      final f = File('${_dir!.path}/entries/$id.json');
      if (await f.exists()) {
        await f.delete();
      }
      await _saveIndexMobile();
    }
    _bump();
  }

  // -------- Suche/Filter --------

  Future<List<JournalIndexItem>> search({
    String query = '',
    bool? lucid,
    String? tag,
    DateTime? from,
    DateTime? to,
  }) async {
    final q = query.trim().toLowerCase();
    final idsWhenFulltextNeeded = <String>{};

    List<JournalIndexItem> base = await listAll();

    if (lucid != null) base = base.where((e) => e.lucid == lucid).toList();
    if (tag != null && tag.isNotEmpty) base = base.where((e) => e.tags.contains(tag)).toList();
    if (from != null) base = base.where((e) => !e.date.isBefore(from)).toList();
    if (to != null) base = base.where((e) => !e.date.isAfter(to)).toList();
    if (q.isEmpty) return base;

    final result = <JournalIndexItem>[];
    for (final it in base) {
      final inTitle = it.title.toLowerCase().contains(q);
      final inTags = it.tags.any((t) => t.toLowerCase().contains(q));
      if (inTitle || inTags) {
        result.add(it);
      } else {
        idsWhenFulltextNeeded.add(it.id);
      }
    }
    for (final id in idsWhenFulltextNeeded) {
      final entry = await getById(id);
      if (entry == null) continue;
      if (entry.body.toLowerCase().contains(q)) {
        result.add(JournalIndexItem.fromEntry(entry));
      }
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  // -------- Export --------

  Future<String> exportJson({List<String>? onlyIds}) async {
    final ids = onlyIds ?? _index.map((e) => e.id).toList();
    final list = <Map<String, dynamic>>[];
    for (final id in ids) {
      final e = await getById(id);
      if (e != null) list.add(e.toJson());
    }
    return jsonEncode(list);
  }

  Future<String> exportCsv({List<String>? onlyIds}) async {
    final ids = onlyIds ?? _index.map((e) => e.id).toList();
    final buf = StringBuffer();
    buf.writeln('id;date;title;tags;mood;lucid;body');
    for (final id in ids) {
      final e = await getById(id);
      if (e == null) continue;
      final tags = e.tags.map((t) => t.replaceAll(';', ',')).join(',');
      String safe(String s) => s.replaceAll('\n', ' ').replaceAll(';', ',');
      buf.writeln([
        e.id,
        e.date.toIso8601String(),
        safe(e.title),
        tags,
        e.mood.toString(),
        e.lucid ? '1' : '0',
        safe(e.body),
      ].join(';'));
    }
    return buf.toString();
  }
}
