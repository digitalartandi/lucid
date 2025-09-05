import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class KnowledgeArticle {
  final String path;   // z.B. assets/wissen/grundlagen_de.md
  final String title;  // z.B. Grundlagen
  KnowledgeArticle({required this.path, required this.title});
}

class KnowledgeRepo {
  /// Liest das AssetManifest und liefert alle Markdown-Dateien aus dem
  /// passenden Wissen-Ordner (de oder en) sortiert zurück.
  static Future<List<KnowledgeArticle>> load({String? languageCode}) async {
    final String manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(manifestJson);

    // Sprache bestimmen (Default: de)
    final String lang = (languageCode ?? 'de').toLowerCase();
    final String prefix = (lang == 'de') ? 'assets/wissen/' : 'assets/wissen_en/';

    // Alle .md aus dem gewünschten Ordner
    final List<String> paths = manifest.keys
        .where((k) => k.startsWith(prefix) && k.endsWith('.md'))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return paths.map((p) {
      final file = p.split('/').last.replaceAll('.md', '');
      return KnowledgeArticle(
        path: p,
        title: _prettify(file),
      );
    }).toList();
  }

  /// Macht aus Dateinamen brauchbare Titel:
  /// z.B. "klartraum_grundlagen_de" -> "Klartraum Grundlagen"
  static String _prettify(String basename) {
    // _de / _en Suffixe entfernen
    final noLang = basename
        .replaceAll(RegExp(r'[_\-]?de$'), '')
        .replaceAll(RegExp(r'[_\-]?en$'), '');

    // Trenner vereinheitlichen
    final spaced = noLang.replaceAll('_', ' ').replaceAll('-', ' ');

    // Erste Buchstaben groß
    final titled = spaced.split(' ').where((w) => w.isNotEmpty).map((w) {
      if (w.length == 1) return w.toUpperCase();
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');

    // Optionale Feinkosmetik (ae -> ä etc.) – nur simple Fälle
    return titled
        .replaceAll('Ae', 'Ä')
        .replaceAll('Oe', 'Ö')
        .replaceAll('Ue', 'Ü')
        .replaceAll('ae', 'ä')
        .replaceAll('oe', 'ö')
        .replaceAll('ue', 'ü');
  }
}
