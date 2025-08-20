// lib/models/journal_models.dart
import 'dart:convert';

class JournalEntry {
  final String id;
  DateTime date;            // Erstell-/Änderungszeit
  String title;
  String body;
  List<String> tags;        // z.B. #Zug, #Prüfung
  int mood;                 // -1, 0, 1 (traurig, neutral, froh) – einfach & robust
  bool lucid;               // Klartraum-Flag

  JournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
    required this.tags,
    required this.mood,
    required this.lucid,
  });

  factory JournalEntry.newDraft() {
    final now = DateTime.now();
    return JournalEntry(
      id: '${now.microsecondsSinceEpoch}',
      date: now,
      title: '',
      body: '',
      tags: <String>[],
      mood: 0,
      lucid: false,
    );
  }

  JournalEntry copyWith({
    DateTime? date,
    String? title,
    String? body,
    List<String>? tags,
    int? mood,
    bool? lucid,
  }) {
    return JournalEntry(
      id: id,
      date: date ?? this.date,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? List<String>.from(this.tags),
      mood: mood ?? this.mood,
      lucid: lucid ?? this.lucid,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'body': body,
        'tags': tags,
        'mood': mood,
        'lucid': lucid,
      };

  static JournalEntry fromJson(Map<String, dynamic> j) {
    return JournalEntry(
      id: j['id'] as String,
      date: DateTime.parse(j['date'] as String),
      title: (j['title'] as String?) ?? '',
      body: (j['body'] as String?) ?? '',
      tags: ((j['tags'] as List?) ?? const []).map((e) => e.toString()).toList(),
      mood: (j['mood'] as num?)?.toInt() ?? 0,
      lucid: (j['lucid'] as bool?) ?? false,
    );
  }

  static String encodeList(List<JournalEntry> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<JournalEntry> decodeList(String s) {
    final raw = jsonDecode(s) as List;
    return raw.map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class JournalIndexItem {
  final String id;
  final DateTime date;
  final String title;
  final List<String> tags;
  final int mood;
  final bool lucid;

  JournalIndexItem({
    required this.id,
    required this.date,
    required this.title,
    required this.tags,
    required this.mood,
    required this.lucid,
  });

  factory JournalIndexItem.fromEntry(JournalEntry e) => JournalIndexItem(
        id: e.id,
        date: e.date,
        title: e.title,
        tags: e.tags,
        mood: e.mood,
        lucid: e.lucid,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'tags': tags,
        'mood': mood,
        'lucid': lucid,
      };

  static JournalIndexItem fromJson(Map<String, dynamic> j) => JournalIndexItem(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        title: (j['title'] as String?) ?? '',
        tags: ((j['tags'] as List?) ?? const []).map((e) => e.toString()).toList(),
        mood: (j['mood'] as num?)?.toInt() ?? 0,
        lucid: (j['lucid'] as bool?) ?? false,
      );
}
