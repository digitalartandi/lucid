// lib/screens/cues/cue_library_page.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cue_models.dart';
import '../../services/cue_player.dart';

// Farben
const _bg     = Color(0xFF0D0F16);
const _white  = Color(0xFFE9EAFF);
const _card   = Color(0xFF0A0A23);
const _line   = Color(0x22FFFFFF);
const _accent = Color(0xFF7A6CFF);

// ---- Persistenz: ausgewählte Cue (json) ----
const _kCueSelectedJson = 'cue.selected.v1';

class _CuePrefs {
  static Future<void> save(CueSound s) async {
    final sp = await SharedPreferences.getInstance();
    final dyn = s as dynamic;
    final data = {
      'id':        dyn.id as String? ?? '',
      'name':      dyn.name as String? ?? '',
      'category':  dyn.category as String? ?? '',
      'asset':     dyn.asset as String? ?? '',
    };
    await sp.setString(_kCueSelectedJson, jsonEncode(data));
  }

  static Future<CueSound?> load() async {
    final sp   = await SharedPreferences.getInstance();
    final json = sp.getString(_kCueSelectedJson);
    if (json == null) return null;
    final m = jsonDecode(json) as Map<String, dynamic>;
    // Kompatibel zu deinem CueSound (id, name, category, asset)
    return CueSound(
      id:        (m['id'] ?? '') as String,
      name:      (m['name'] ?? '') as String,
      category:  (m['category'] ?? '') as String,
      asset:     (m['asset'] ?? '') as String,
    );
  }
}

class CueLibraryPage extends StatefulWidget {
  const CueLibraryPage({super.key});
  @override
  State<CueLibraryPage> createState() => _CueLibraryPageState();
}

class _CueLibraryPageState extends State<CueLibraryPage> {
  bool _picker = false;
  String? _selectedId;
  String _query = '';

  final _player = CueLoopPlayer.instance;
  String? _previewId;

  late final List<CueSound> _all;

  @override
  void initState() {
    super.initState();
    _all = _buildCatalog();
    _preloadSelected();
  }

  Future<void> _preloadSelected() async {
    final sel = await _CuePrefs.load();
    if (!mounted) return;
    setState(() => _selectedId = sel?.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _picker = args['picker'] == true;
      _selectedId = (args['selectedId'] as String?) ?? _selectedId;
    }
  }

  @override
  void dispose() {
    _player.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filterAndGroup(_all, _query);

    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: const Text('Cues', style: TextStyle(color: _white)),
        trailing: _picker
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Abbrechen', style: TextStyle(color: _white)),
              )
            : null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: CupertinoSearchTextField(
                placeholder: 'Suchen…',
                style: const TextStyle(color: _white),
                placeholderStyle: const TextStyle(color: Color(0x66E9EAFF)),
                backgroundColor: const Color(0x1AFFFFFF),
                prefixIcon: const Icon(CupertinoIcons.search, color: _white, size: 18),
                suffixIcon: const Icon(CupertinoIcons.xmark_circle_fill, color: _white),
                onChanged: (q) => setState(() => _query = q),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                itemCount: visible.length,
                itemBuilder: (_, i) {
                  final block = visible[i];
                  if (block is _Header) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(2, 14, 2, 6),
                      child: Text(
                        block.title,
                        style: const TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    );
                  } else if (block is _Item) {
                    final s = block.sound;
                    final selected = _selectedId == s.id;
                    final isPreviewing = _previewId == s.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? _accent : _line,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: CupertinoListTile.notched(
                        title: Text(s.name, style: const TextStyle(color: _white)),
                        subtitle: Text('${s.category} · ${_pretty(s.asset)}',
                            style: const TextStyle(color: _white)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            onPressed: () => _togglePreview(s),
                            child: Icon(
                              isPreviewing ? CupertinoIcons.stop_fill : CupertinoIcons.play_fill,
                              color: _white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            selected
                                ? CupertinoIcons.check_mark_circled_solid
                                : CupertinoIcons.chevron_right,
                            color: selected ? _accent : _white,
                          ),
                        ]),
                        onTap: () => _choose(s),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _choose(CueSound s) async {
    await _CuePrefs.save(s);
    if (!mounted) return;
    setState(() => _selectedId = s.id);

    if (_picker) {
      Navigator.of(context).pop(s); // Übergibt die Auswahl an den Aufrufer
      return;
    }

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Gespeichert'),
        content: Text('„${s.name}“ wurde als Cue übernommen.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePreview(CueSound s) async {
    if (_previewId == s.id && _player.isPlaying) {
      _player.stop();
      setState(() => _previewId = null);
      return;
    }
    setState(() => _previewId = s.id);

    try {
      // bevorzugte API
      await _player.playOnce(s, seconds: 5, volume: .8);
    } catch (_) {
      // Legacy (nur Asset-String)
      try {
        await (_player as dynamic).playOnce(s.asset as String, seconds: 5, volume: .8);
      } catch (_) {}
    }

    if (mounted && _previewId == s.id) setState(() => _previewId = null);
  }

  // -------- Katalog / Gruppierung --------

  List<Object> _filterAndGroup(List<CueSound> sounds, String query) {
    final q = query.trim().toLowerCase();
    final filtered = sounds.where((s) {
      if (q.isEmpty) return true;
      final src =
          '${s.name.toLowerCase()} ${s.category.toLowerCase()} ${_pretty(s.asset).toLowerCase()}';
      return src.contains(q);
    }).toList();

    final Map<String, List<CueSound>> groups = {};
    for (final s in filtered) {
      groups.putIfAbsent(s.category, () => []).add(s);
    }

    // Reihenfolge der Hauptkategorien (übersichtlich)
    const order = [
      'Tiere',
      'Wasser & Regen',
      'Wind & Natur',
      'Glocken & Chimes',
      'Synth & Space',
      'Ambience',
    ];

    final keys = groups.keys.toList()
      ..sort((a, b) {
        final ia = order.indexOf(a);
        final ib = order.indexOf(b);
        if (ia == -1 && ib == -1) return a.compareTo(b);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });

    final List<Object> out = [];
    for (final k in keys) {
      out.add(_Header(k));
      for (final s in groups[k]!) {
        out.add(_Item(s));
      }
    }
    return out;
  }

  // ---- Dein kompletter Cue-Bestand (kuratiert und zusammengefasst) ----
  static const _base = 'assets/audio/cues/';

  List<CueSound> _buildCatalog() {
    // Hilfs-Funktion
    CueSound cue(String file, String name, String cat) =>
        CueSound(id: file, name: name, category: cat, asset: '$_base$file');

    // Tiere
    final birds = [
      cue('birdsong01.mp3', 'Vogelgesang 1', 'Tiere'),
      cue('birdsong02.mp3', 'Vogelgesang 2', 'Tiere'),
      cue('birdsong03.mp3', 'Vogelgesang 3', 'Tiere'),
      cue('birdsong04.mp3', 'Vogelgesang 4', 'Tiere'),
      cue('owl-distant01.mp3', 'Eule fern 1', 'Tiere'),
      cue('owl-distant02.mp3', 'Eule fern 2', 'Tiere'),
      cue('owl-distant03.mp3', 'Eule fern 3', 'Tiere'),
      cue('owl-distant04.mp3', 'Eule fern 4', 'Tiere'),
      cue('cricket-chorus01.mp3', 'Grillen 1', 'Tiere'),
      cue('cricket-chorus02.mp3', 'Grillen 2', 'Tiere'),
      cue('meadow-bees01.mp3', 'Wiese – Bienen 1', 'Tiere'),
      cue('meadow-bees02.mp3', 'Wiese – Bienen 2', 'Tiere'),
      cue('meadow-bees03.mp3', 'Wiese – Bienen 3', 'Tiere'),
      cue('cat-purring.mp3', 'Katze schnurrt', 'Tiere'),
      cue('jellyfish-soft.mp3', 'Quallen (sanft)', 'Tiere'), // falls vorhanden
    ];

    // Wasser & Regen
    final water = [
      cue('light-rain01.mp3', 'Leichter Regen 1', 'Wasser & Regen'),
      cue('rain-on-broad-leaf01.mp3', 'Regen auf Blättern 1', 'Wasser & Regen'),
      cue('rain-on-broad-leaf02.mp3', 'Regen auf Blättern 2', 'Wasser & Regen'),
      cue('rain-on-broad-leaf03.mp3', 'Regen auf Blättern 3', 'Wasser & Regen'),
      cue('rain-on-tent tarpaulin.mp3', 'Regen auf Zelt 1', 'Wasser & Regen'),
      cue('rain-on-tent tarpaulin2.mp3', 'Regen auf Zelt 2', 'Wasser & Regen'),
      cue('shallow-creek01.mp3', 'Bachlauf 1', 'Wasser & Regen'),
      cue('shallow-creek02.mp3', 'Bachlauf 2', 'Wasser & Regen'),
      cue('sea01.mp3', 'Meer 1', 'Wasser & Regen'),
      cue('sea02.mp3', 'Meer 2', 'Wasser & Regen'),
      cue('water01.mp3', 'Wasser 1', 'Wasser & Regen'),
      cue('water02.mp3', 'Wasser 2', 'Wasser & Regen'),
      cue('water03.mp3', 'Wasser 3', 'Wasser & Regen'),
      cue('calm-shoreline01.mp3', 'Ruhige Küste 1', 'Wasser & Regen'),
      cue('calm-shoreline02.mp3', 'Ruhige Küste 2', 'Wasser & Regen'),
    ];

    // Wind & Natur
    final wind = [
      cue('mountain-ridge-wind01.mp3', 'Bergwind 1', 'Wind & Natur'),
      cue('mountain-ridge-wind02.mp3', 'Bergwind 2', 'Wind & Natur'),
      cue('mountain-ridge-wind03.mp3', 'Bergwind 3', 'Wind & Natur'),
      cue('wind01.mp3', 'Wind 1', 'Wind & Natur'),
      cue('forest-ambience01.mp3', 'Wald – Ambience', 'Wind & Natur'), // falls vorhanden
    ];

    // Glocken & Chimes
    final chimes = [
      cue('soft-chim.mp3', 'Sanfte Glocke 1', 'Glocken & Chimes'),
      cue('soft-chim02.mp3', 'Sanfte Glocke 2', 'Glocken & Chimes'),
      cue('single-glass-bell.mp3', 'Glasglocke (einzeln)', 'Glocken & Chimes'),
      cue('soft-click-to-chime.mp3', 'Click → Chime 1', 'Glocken & Chimes'),
      cue('soft-click-to-chime02.mp3', 'Click → Chime 2', 'Glocken & Chimes'),
      cue('two-note-soft-chime01.mp3', 'Zweiton-Chime 1', 'Glocken & Chimes'),
      cue('two-note-soft-chime02.mp3', 'Zweiton-Chime 2', 'Glocken & Chimes'),
      cue('very-soft-glockenspiel01.mp3', 'Glockenspiel (sehr leise) 1', 'Glocken & Chimes'),
      cue('very-soft-glockenspiel02.mp3', 'Glockenspiel (sehr leise) 2', 'Glocken & Chimes'),
      cue('tuning-fork-A4-style01.mp3', 'Stimmgabel A4 1', 'Glocken & Chimes'),
      cue('tuning-fork-A4-style02.mp3', 'Stimmgabel A4 2', 'Glocken & Chimes'),
      cue('bowed-glass-harmonic01.mp3', 'Glasharmonika 1', 'Glocken & Chimes'),
      cue('bowed-glass-harmonic02.mp3', 'Glasharmonika 2', 'Glocken & Chimes'),
    ];

    // Synth & Space
    final synth = [
      cue('pure-sine-tone-ping.mp3', 'Sine-Ping', 'Synth & Space'),
      cue('spacecraft-interior.mp3', 'Raumschiff 1', 'Synth & Space'),
      cue('spacecraft-interior2.mp3', 'Raumschiff 2', 'Synth & Space'),
      cue('spacecraft-interior3.mp3', 'Raumschiff 3', 'Synth & Space'),
      cue('misty-horizons.mp3', 'Misty Horizons', 'Synth & Space'), // falls vorhanden
    ];

    // Ambience / Sonstiges
    final amb = [
      cue('fireplace01.mp3', 'Kamin 1', 'Ambience'),
      cue('fireplace02.mp3', 'Kamin 2', 'Ambience'),
      cue('fireplace03.mp3', 'Kamin 3', 'Ambience'),
      cue('thunder-rumbles01.mp3', 'Donnerrollen 1', 'Ambience'),
      cue('thunder-rumbles02.mp3', 'Donnerrollen 2', 'Ambience'),
      cue('thunder-rumbles03.mp3', 'Donnerrollen 3', 'Ambience'),
      cue('tropical-rainforest.mp3', 'Tropenwald', 'Ambience'),
      cue('woodland-breathing.mp3', 'Waldatmen', 'Ambience'), // falls vorhanden
    ];

    return [...birds, ...water, ...wind, ...chimes, ...synth, ...amb];
  }

  String _pretty(String asset) => asset.split('/').last;
}

class _Header { final String title; const _Header(this.title); }
class _Item   { final CueSound sound; const _Item(this.sound); }
