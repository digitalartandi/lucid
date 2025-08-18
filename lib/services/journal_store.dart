import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JournalEntry {
  final String id;
  final String text;
  final DateTime createdAt;

  JournalEntry({required this.id, required this.text, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  static JournalEntry fromMap(Map<String, dynamic> m) => JournalEntry(
    id: m['id'] as String,
    text: m['text'] as String,
    createdAt: DateTime.parse(m['createdAt'] as String),
  );
}

class JournalStore {
  static const _key = 'journal_v2';

  Future<List<JournalEntry>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(JournalEntry.fromMap).toList()
      ..sort((a,b)=> b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _save(List<JournalEntry> items) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e)=> e.toMap()).toList());
    await sp.setString(_key, raw);
  }

  Future<List<JournalEntry>> add(String text) async {
    final items = await load();
    final entry = JournalEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    items.insert(0, entry);
    await _save(items);
    return items;
  }

  Future<List<JournalEntry>> update(String id, String text) async {
    final items = await load();
    final idx = items.indexWhere((e)=> e.id == id);
    if (idx >= 0) {
      items[idx] = JournalEntry(id: id, text: text.trim(), createdAt: items[idx].createdAt);
      await _save(items);
    }
    return items;
  }

  Future<List<JournalEntry>> remove(String id) async {
    final items = await load();
    items.removeWhere((e)=> e.id == id);
    await _save(items);
    return items;
  }

  Future<String> exportJson() async {
    final items = await load();
    return jsonEncode(items.map((e)=> e.toMap()).toList());
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}
