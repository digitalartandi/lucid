import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReadingItem {
  final String id; // hash of title+url
  final String title;
  final List<String> authors;
  final String venue;
  final String date;
  final String url;
  final String? doi;
  final String source; // pubmed|crossref|manual
  final String? note;
  final String savedAtIso;

  ReadingItem({
    required this.id,
    required this.title,
    required this.authors,
    required this.venue,
    required this.date,
    required this.url,
    required this.source,
    this.doi,
    this.note,
    String? savedAtIso,
  }) : savedAtIso = savedAtIso ?? DateTime.now().toIso8601String();

  ReadingItem copyWith({String? note}) => ReadingItem(
    id: id, title: title, authors: authors, venue: venue, date: date, url: url, source: source, doi: doi, note: note, savedAtIso: savedAtIso,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'authors': authors, 'venue': venue, 'date': date, 'url': url, 'doi': doi, 'source': source, 'note': note, 'savedAtIso': savedAtIso
  };
  static ReadingItem fromJson(Map<String, dynamic> j) => ReadingItem(
    id: j['id'], title: j['title'], authors: (j['authors'] as List?)?.cast<String>() ?? const [], venue: j['venue'] ?? '',
    date: j['date'] ?? '', url: j['url'] ?? '', source: j['source'] ?? 'manual', doi: j['doi'], note: j['note'], savedAtIso: j['savedAtIso'],
  );
}

class ReadingListRepo {
  static Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/reading_list.json');
  }

  static Future<List<ReadingItem>> list() async {
    final f = await _file();
    if (!await f.exists()) return <ReadingItem>[];
    try {
      final j = jsonDecode(await f.readAsString());
      final arr = (j as List).cast<Map<String, dynamic>>();
      return arr.map(ReadingItem.fromJson).toList();
    } catch (_) { return <ReadingItem>[]; }
  }

  static Future<void> _saveAll(List<ReadingItem> items) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(items.map((e)=> e.toJson()).toList()));
  }

  static Future<void> addOrUpdate(ReadingItem item) async {
    final items = await list();
    final idx = items.indexWhere((e)=> e.id == item.id);
    if (idx >= 0) {
      items[idx] = item; // update
    } else {
      items.add(item);
    }
    await _saveAll(items);
  }

  static Future<void> remove(String id) async {
    final items = await list();
    items.removeWhere((e)=> e.id == id);
    await _saveAll(items);
  }

  static Future<String> exportJson() async {
    final items = await list();
    final f = await _file();
    final dir = f.parent;
    final out = File('${dir.path}/reading_list_export.json');
    await out.writeAsString(jsonEncode(items.map((e)=> e.toJson()).toList()));
    return out.path;
  }

  static Future<String> exportCsv() async {
    final items = await list();
    final f = await _file();
    final dir = f.parent;
    final out = File('${dir.path}/reading_list_export.csv');
    final buf = StringBuffer('saved_at,title,authors,venue,date,doi,url,note\n');
    for (final i in items) {
      final authors = i.authors.join('; ');
      String esc(String s) => '"${s.replaceAll('"', '""')}"';
      buf.writeln('${i.savedAtIso},${esc(i.title)},${esc(authors)},${esc(i.venue)},${esc(i.date)},${esc(i.doi ?? '')},${esc(i.url)},${esc(i.note ?? '')}');
    }
    await out.writeAsString(buf.toString());
    return out.path;
  }

  static String makeId(String title, String url) => base64Url.encode(utf8.encode('${title.trim()}|${url.trim()}'));
}
