import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'clients.dart';

class ResearchFeedRepo {
  static Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/research_feed.json');
  }

  static Future<Map<String, dynamic>> _loadRaw() async {
    final f = await _file();
    if (!await f.exists()) return {'items': []};
    try { return jsonDecode(await f.readAsString()); } catch (_) { return {'items': []}; }
  }

  static Future<void> _saveRaw(Map<String, dynamic> j) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(j));
  }

  static Future<List<Map<String, dynamic>>> refresh({String q = 'lucid dream OR lucid dreaming OR targeted memory reactivation dream'}) async {
    final pub = await PubMedClient.search(query: q, retmax: 25);
    final cr = await CrossRefClient.search(query: q, rows: 25);
    final seen = <String>{};
    final items = <Map<String, dynamic>>[];
    for (final p in pub) {
      final key = (p.title + p.url).toLowerCase();
      if (seen.add(key)) {
        items.add({'source':'pubmed','title':p.title,'authors':p.authors,'venue':p.journal,'date':p.date,'url':p.url});
      }
    }
    for (final c in cr) {
      final key = (c.title + c.url).toLowerCase();
      if (seen.add(key)) {
        items.add({'source':'crossref','title':c.title,'authors':c.authors,'venue':c.container ?? '', 'date':c.date,'url':c.url,'doi':c.doi});
      }
    }
    items.sort((a,b)=> (b['date'] ?? '').toString().compareTo((a['date'] ?? '').toString()));
    await _saveRaw({'items': items, 'ts': DateTime.now().toIso8601String(), 'q': q});
    return items;
  }

  static Future<List<Map<String, dynamic>>> loadCached() async {
    final j = await _loadRaw();
    return (j['items'] as List).cast<Map<String, dynamic>>();
  }
}
