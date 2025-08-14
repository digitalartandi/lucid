import 'dart:convert';
import 'package:http/http.dart' as http;

class PubMedItem {
  final String title;
  final String journal;
  final String date;
  final String url;
  final List<String> authors;
  PubMedItem({required this.title, required this.journal, required this.date, required this.url, required this.authors});
}

class CrossRefItem {
  final String title;
  final String doi;
  final String date;
  final String url;
  final List<String> authors;
  final String? container;
  CrossRefItem({required this.title, required this.doi, required this.date, required this.url, required this.authors, this.container});
}

class PubMedClient {
  static Future<List<PubMedItem>> search({required String query, int retmax = 20}) async {
    final term = Uri.encodeQueryComponent(query);
    final es = await http.get(Uri.parse('https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=$retmax&sort=pub+date&term=$term'));
    if (es.statusCode != 200) return [];
    final ids = (jsonDecode(es.body)['esearchresult']['idlist'] as List).cast<String>();
    if (ids.isEmpty) return [];
    final summary = await http.get(Uri.parse('https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&retmode=json&id=${ids.join(",")}'));
    if (summary.statusCode != 200) return [];
    final data = jsonDecode(summary.body)['result'] as Map<String, dynamic>;
    final out = <PubMedItem>[];
    for (final id in ids) {
      final m = data[id];
      if (m == null) continue;
      final title = (m['title'] ?? '').toString();
      final journal = (m['fulljournalname'] ?? m['source'] ?? '').toString();
      final date = (m['pubdate'] ?? '').toString();
      final url = 'https://pubmed.ncbi.nlm.nih.gov/$id/';
      final authors = ((m['authors'] ?? []) as List).map((a)=> a['name'].toString()).toList();
      out.add(PubMedItem(title: title, journal: journal, date: date, url: url, authors: authors));
    }
    return out;
  }
}

class CrossRefClient {
  static Future<List<CrossRefItem>> search({required String query, int rows = 20}) async {
    final q = Uri.encodeQueryComponent(query);
    final res = await http.get(Uri.parse('https://api.crossref.org/works?query=$q&rows=$rows&sort=published&order=desc'));
    if (res.statusCode != 200) return [];
    final items = (jsonDecode(res.body)['message']['items'] as List);
    return items.map((m){
      final title = (m['title'] != null && (m['title'] as List).isNotEmpty) ? m['title'][0].toString() : '';
      final doi = (m['DOI'] ?? '').toString();
      final url = (m['URL'] ?? (doi.isNotEmpty ? 'https://doi.org/$doi' : '')) as String;
      final container = (m['container-title'] != null && (m['container-title'] as List).isNotEmpty) ? m['container-title'][0].toString() : null;
      String date = '';
      if (m['issued'] != null && m['issued']['date-parts'] != null) {
        final dp = (m['issued']['date-parts'] as List).first as List;
        date = dp.join('-');
      }
      final authors = ((m['author'] ?? []) as List).map((a){
        final g = a as Map<String, dynamic>;
        final given = (g['given'] ?? '').toString();
        final family = (g['family'] ?? '').toString();
        return [given, family].where((s)=> s.isNotEmpty).join(' ');
      }).toList();
      return CrossRefItem(title: title, doi: doi, date: date, url: url, authors: authors, container: container);
    }).toList();
  }
}
