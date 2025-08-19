import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';
import '../../apple_ui/a11y.dart';

import '../../research_feed/repo.dart';
import '../../research_feed/reading_list.dart';
import 'studien_feed_settings.dart';

// Optional (für später, falls du BookmarksRepo einbinden willst)
// import '../../bookmarks_repo.dart';

class StudienFeedPage extends StatefulWidget {
  const StudienFeedPage({super.key});
  @override
  State<StudienFeedPage> createState() => _StudienFeedPageState();
}

class _StudienFeedPageState extends State<StudienFeedPage> {
  bool loading = false;
  List<Map<String, dynamic>> items = [];

  // Default-Suchstring (breit, inkl. OR-Varianten)
  final qCtrl = TextEditingController(
    text: 'lucid dreaming OR lucid dream OR targeted memory reactivation dream',
  );

  // Persistente ID-Liste für UI (gefülltes Bookmark)
  static const _kSavedIdsKey = 'studies_saved_ids_ui_v1';
  Set<String> _savedIds = {};

  @override
  void initState() {
    super.initState();
    _loadSavedIds();
    _loadCached();
    _refresh();
  }

  @override
  void dispose() {
    qCtrl.dispose();
    super.dispose();
  }

  // -------------------------
  // Persistente UI-IDs laden
  // -------------------------
  Future<void> _loadSavedIds() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_kSavedIdsKey) ?? const <String>[];
    setState(() => _savedIds = list.toSet());
  }

  Future<void> _persistSavedIds() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_kSavedIdsKey, _savedIds.toList());
  }

  // -------------------------
  // Daten laden/aktualisieren
  // -------------------------
  Future<void> _loadCached() async {
    items = await ResearchFeedRepo.loadCached();
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    try {
      items = await ResearchFeedRepo.refresh(q: qCtrl.text.trim());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // -------------------------
  // Speichern / Bookmark-UI
  // -------------------------
  String _makeId(Map<String, dynamic> it) {
    return ReadingListRepo.makeId(
      (it['title'] ?? '') as String,
      (it['url'] ?? '') as String,
    );
  }

  Future<void> _saveItem(Map<String, dynamic> it) async {
    final id = _makeId(it);

    // 1) Inhalt in die Reading-List schreiben (deine bestehende Persistenz)
    final item = ReadingItem(
      id: id,
      title: (it['title'] ?? '') as String,
      authors: ((it['authors'] ?? []) as List).map((e) => e.toString()).toList(),
      venue: (it['venue'] ?? '') as String,
      date: (it['date'] ?? '') as String,
      url: (it['url'] ?? '') as String,
      doi: (it['doi'] as String?),
      source: (it['source'] ?? 'crossref') as String,
    );
    await ReadingListRepo.addOrUpdate(item);

    // 2) UI-Status (gefülltes Lesezeichen) persistieren
    _savedIds.add(id);
    await _persistSavedIds();

    await A11y.announce('Zur Leseliste hinzugefügt');
    if (mounted) setState(() {});
  }

  Future<void> _removeSaved(Map<String, dynamic> it) async {
    final id = _makeId(it);
    // Nur UI-Set zurücksetzen; ReadingList-Entfernen bleibt deiner ReadingList-Page überlassen.
    _savedIds.remove(id);
    await _persistSavedIds();

    await A11y.announce('Aus Leseliste entfernt');
    if (mounted) setState(() {});
  }

  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(
      title: 'Studien & News',
      child: Column(
        children: [
          Section(children: [
            RowItem(
              title: const Text('Suchbegriff(e)'),
              subtitle: Text(qCtrl.text),
              onTap: () async {
                await showCupertinoDialog(
                  context: context,
                  builder: (ctx) => CupertinoAlertDialog(
                    title: const Text('Suche'),
                    content: CupertinoTextField(
                      controller: qCtrl,
                      placeholder: 'lucid dream* …',
                      autofocus: true,
                    ),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Abbrechen'),
                      ),
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {}); // zeigt neuen Query-Text
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            RowItem(
              title: const Text('Aktualisieren'),
              subtitle: Text(loading ? 'Lädt …' : 'Jetzt suchen'),
              onTap: loading ? null : _refresh,
            ),
          ]),

          const StudienFeedSettings(),

          // Ergebnisse-Section ohne "footer" – Leer-/Ladezustände in children
          Section(
            header: 'Ergebnisse',
            children: [
              if (loading)
                const RowItem(
                  title: Text('Lädt …'),
                  subtitle: Text('Bitte kurz warten'),
                ),

              if (!loading && items.isEmpty)
                const RowItem(
                  title: Text('Keine Treffer'),
                  subtitle: Text('Passe den Suchbegriff an.'),
                ),

              for (final it in items.take(50))
                _ResultRow(
                  it: it,
                  saved: _savedIds.contains(_makeId(it)),
                  onOpen: () async {
                    final raw = (it['url'] ?? '') as String;
                    if (raw.isEmpty) return;
                    final url = Uri.tryParse(raw);
                    if (url != null && await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  onToggleSave: () async {
                    final id = _makeId(it);
                    if (_savedIds.contains(id)) {
                      await _removeSaved(it);
                    } else {
                      await _saveItem(it);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final Map<String, dynamic> it;
  final VoidCallback onOpen;
  final VoidCallback onToggleSave;
  final bool saved;

  const _ResultRow({
    required this.it,
    required this.onOpen,
    required this.onToggleSave,
    required this.saved,
  });

  @override
  Widget build(BuildContext context) {
    final title = (it['title'] ?? '') as String;
    final venue = (it['venue'] ?? '') as String;
    final date = (it['date'] ?? '') as String;

    final meta = [venue, date].where((s) => s.isNotEmpty).join(' • ');

    return RowItem(
      title: Text(title),
      subtitle: meta.isEmpty ? null : Text(meta),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onOpen,
            child: const Icon(CupertinoIcons.arrow_up_right_square),
          ),
          const SizedBox(width: 6),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onToggleSave,
            child: Icon(
              saved ? CupertinoIcons.bookmark_solid : CupertinoIcons.bookmark,
            ),
          ),
        ],
      ),
    );
  }
}
