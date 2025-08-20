import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/cue_models.dart';

const _cueAssetRoot = 'assets/audio/cues/';

class CueCategoryGroup {
  final String key;          // z.B. 'tiere', 'wasser', ...
  final String title;        // Anzeigename
  final String? imageAsset;  // z.B. assets/images/cue_categories/tiere.webp
  final List<CueSound> items;
  const CueCategoryGroup({required this.key, required this.title, required this.imageAsset, required this.items});
}

class CueSoundsRepo {
  CueSoundsRepo._();
  static final instance = CueSoundsRepo._();

  List<CueSound> _cache = const [];

  Future<List<CueSound>> all() async {
    if (_cache.isNotEmpty) return _cache;

    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = jsonDecode(manifestJson) as Map<String, dynamic>;

    final files = manifest.keys
        .where((k) => k.startsWith(_cueAssetRoot) && k.toLowerCase().endsWith('.mp3'))
        .toList()
      ..sort();

    _cache = files.map(_toCueSound).toList();
    return _cache;
  }

  /// Gruppiert nach konsolidierten Kategorien + liefert optionales Headerbild
  Future<List<CueCategoryGroup>> groupedWithImages() async {
    final list = await all();
    final map = <String, List<CueSound>>{};
    for (final c in list) {
      final key = _categoryKeyFor(c.category);
      (map[key] ??= []).add(c);
    }

    final out = <CueCategoryGroup>[];
    for (final entry in map.entries) {
      entry.value.sort((a, b) => a.name.compareTo(b.name));
      final title = _categoryTitle(entry.key);
      final img = _categoryImage(entry.key);
      out.add(CueCategoryGroup(key: entry.key, title: title, imageAsset: img, items: entry.value));
    }

    // Reihenfolge der Hauptkategorien
    out.sort((a, b) => _order(a.key).compareTo(_order(b.key)));
    return out;
  }

  // ---- Mapping & Helpers ----

  CueSound _toCueSound(String assetPath) {
    final file = assetPath.split('/').last; // birdsong01.mp3
    final base = file.replaceAll('.mp3', '');
    final cat  = _categoryFor(base);
    return CueSound(
      id: assetPath,
      name: _displayNameFor(base),
      category: cat,
    );
  }

  // Konsolidierte Kategorien
  String _categoryFor(String base) {
    final s = base.toLowerCase();

    // Tiere (alles Lebendige zusammenfassen)
    if (s.startsWith('bird') || s.startsWith('owl') || s.contains('cat') ||
        s.contains('cricket') || s.contains('bees')) return 'Tiere';

    // Wasser
    if (s.startsWith('light-rain') || s.startsWith('rain-on') || s.startsWith('rain') ||
        s.startsWith('sea') || s.contains('shoreline') || s.startsWith('water') ||
        s.contains('creek')) return 'Wasser';

    // Wetter/Umwelt
    if (s.startsWith('thunder') || s.contains('wind') || s.contains('storm')) return 'Wetter';

    // Feuer & Höhle
    if (s.contains('fireplace') || s.contains('dripstone') || s.contains('cave')) return 'Feuer & Höhle';

    // Weltraum/Technik
    if (s.contains('spacecraft') || s.contains('space') || s.contains('engine') || s.contains('hum'))
      return 'Weltraum & Technik';

    // Instrumente (inkl. Chimes/Bells)
    if (s.contains('harp') || s.contains('glockenspiel') || s.contains('tuning-fork') ||
        s.contains('glass-bell') || s.contains('chime'))
      return 'Instrumente';

    // Synth/Ping
    if (s.contains('sine') || s.contains('tone') || s.contains('ping')) return 'Synth & Pings';

    // Landschaft / Tag
    if (s.contains('meadow') || s.contains('mountain')) return 'Landschaft';

    return 'Sonstiges';
  }

  // „Sinnvolle Begriffe“ für Anzeigenamen
  String _displayNameFor(String base) {
    var s = base.toLowerCase();

    // spezifische Ersetzungen
    s = s
        .replaceAll('birdsong', 'Vogelgesang')
        .replaceAll('owl', 'Eule')
        .replaceAll('cricket', 'Grillen')
        .replaceAll('bees', 'Bienen')
        .replaceAll('cat', 'Katze')
        .replaceAll('light-rain', 'Leichter Regen')
        .replaceAll('rain-on-shoreline', 'Regen am Ufer')
        .replaceAll('rain', 'Regen')
        .replaceAll('sea', 'Meeresrauschen')
        .replaceAll('shoreline', 'Ufer')
        .replaceAll('water', 'Wasser')
        .replaceAll('creek', 'Bach')
        .replaceAll('dripstone-cave', 'Tropfsteinhöhle')
        .replaceAll('cave', 'Höhle')
        .replaceAll('fireplace', 'Kaminfeuer')
        .replaceAll('spacecraft-ambience', 'Raumschiff-Atmosphäre')
        .replaceAll('space', 'Weltraum')
        .replaceAll('engine', 'Maschine')
        .replaceAll('hum', 'Brummen')
        .replaceAll('harp', 'Harfe')
        .replaceAll('glockenspiel', 'Glockenspiel')
        .replaceAll('tuning-fork', 'Stimmgabel')
        .replaceAll('glass-bell', 'Glasglocke')
        .replaceAll('chime', 'Klangspiel')
        .replaceAll('sine', 'Sinus')
        .replaceAll('tone', 'Ton')
        .replaceAll('ping', 'Ping')
        .replaceAll('meadow', 'Wiese')
        .replaceAll('mountain', 'Bergwind');

    // Trennzeichen hübsch machen
    s = s.replaceAll('_', ' ').replaceAll('-', ' ');
    final words = s.split(' ').where((w) => w.isNotEmpty).map((w) {
      if (RegExp(r'^\d+$').hasMatch(w)) return w;
      return w[0].toUpperCase() + w.substring(1);
    });
    return words.join(' ');
  }

  // Normalisierte Keys für Titel/Asset-Order
  String _categoryKeyFor(String title) {
    switch (title) {
      case 'Tiere': return 'tiere';
      case 'Wasser': return 'wasser';
      case 'Wetter': return 'wetter';
      case 'Feuer & Höhle': return 'feuer_hoehle';
      case 'Weltraum & Technik': return 'weltraum_technik';
      case 'Instrumente': return 'instrumente';
      case 'Synth & Pings': return 'synth_pings';
      case 'Landschaft': return 'landschaft';
      default: return 'sonstiges';
    }
  }

  String _categoryTitle(String key) {
    switch (key) {
      case 'tiere': return 'Tiere';
      case 'wasser': return 'Wasser';
      case 'wetter': return 'Wetter';
      case 'feuer_hoehle': return 'Feuer & Höhle';
      case 'weltraum_technik': return 'Weltraum & Technik';
      case 'instrumente': return 'Instrumente';
      case 'synth_pings': return 'Synth & Pings';
      case 'landschaft': return 'Landschaft';
      default: return 'Sonstiges';
    }
  }

  // Optionales Headerbild pro Kategorie (lege die Dateien – siehe Abschnitt Assets – an)
  String? _categoryImage(String key) {
    const base = 'assets/images/cue_categories/';
    const known = <String>{
      'tiere', 'wasser', 'wetter', 'feuer_hoehle',
      'weltraum_technik', 'instrumente', 'synth_pings', 'landschaft', 'sonstiges'
    };
    if (!known.contains(key)) return null;
    return '$base$key.webp';
  }

  int _order(String key) {
    const order = <String, int>{
      'tiere': 0,
      'wasser': 1,
      'wetter': 2,
      'feuer_hoehle': 3,
      'weltraum_technik': 4,
      'instrumente': 5,
      'synth_pings': 6,
      'landschaft': 7,
      'sonstiges': 8,
    };
    return order[key] ?? 99;
  }
}
