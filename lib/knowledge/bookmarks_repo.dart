import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class KnowledgeBookmark {
  final String id; // asset#anchor
  final String asset;
  final String title;
  final String? note;
  final String savedAtIso;

  KnowledgeBookmark({required this.id, required this.asset, required this.title, this.note, String? savedAtIso})
    : savedAtIso = savedAtIso ?? DateTime.now().toIso8601String();

  KnowledgeBookmark copyWith({String? note}) => KnowledgeBookmark(id: id, asset: asset, title: title, note: note, savedAtIso: savedAtIso);

  Map<String, dynamic> toJson() => {'id': id, 'asset': asset, 'title': title, 'note': note, 'savedAtIso': savedAtIso};
  static KnowledgeBookmark fromJson(Map<String, dynamic> j) => KnowledgeBookmark(id: j['id'], asset: j['asset'], title: j['title'], note: j['note'], savedAtIso: j['savedAtIso']);
}

class KnowledgeBookmarksRepo {
  static Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/knowledge_bookmarks.json');
  }

  static Future<List<KnowledgeBookmark>> list() async {
    final f = await _file();
    if (!await f.exists()) return <KnowledgeBookmark>[];
    try {
      final arr = (jsonDecode(await f.readAsString()) as List).cast<Map<String, dynamic>>();
      return arr.map(KnowledgeBookmark.fromJson).toList();
    } catch (_) { return <KnowledgeBookmark>[]; }
  }

  static Future<void> _saveAll(List<KnowledgeBookmark> items) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(items.map((e)=> e.toJson()).toList()));
  }

  static Future<bool> isSaved(String id) async {
    final items = await list();
    return items.any((e)=> e.id == id);
  }

  static Future<void> toggle(KnowledgeBookmark bm) async {
    final items = await list();
    final idx = items.indexWhere((e)=> e.id == bm.id);
    if (idx >= 0) {
      items.removeAt(idx);
    } else {
      items.add(bm);
    }
    await _saveAll(items);
  }

  static Future<void> updateNote(String id, String note) async {
    final items = await list();
    final idx = items.indexWhere((e)=> e.id == id);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(note: note);
      await _saveAll(items);
    }
  }

  static Future<void> remove(String id) async {
    final items = await list();
    items.removeWhere((e)=> e.id == id);
    await _saveAll(items);
  }
}
