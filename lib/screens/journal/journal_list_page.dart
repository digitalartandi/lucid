// lib/screens/journal/journal_list_page.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/journal_models.dart';
import '../../services/journal_repo.dart';

enum _LucidFilter { all, lucid, normal }

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});
  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  final _repo = JournalRepo.instance;
  final _searchCtl = TextEditingController();
  Timer? _debounce;

  _LucidFilter _filterLucid = _LucidFilter.all;
  String _filterTag = '';
  List<JournalIndexItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _repo.init();
    // Live-Updates: auf Änderungen reagieren
    _repo.revision.addListener(_refresh);
    await _refresh();
  }

  @override
  void dispose() {
    _repo.revision.removeListener(_refresh);
    _debounce?.cancel();
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);

    bool? lucid;
    switch (_filterLucid) {
      case _LucidFilter.all: lucid = null; break;
      case _LucidFilter.lucid: lucid = true; break;
      case _LucidFilter.normal: lucid = false; break;
    }

    final res = await _repo.search(
      query: _searchCtl.text,
      lucid: lucid,
      tag: _filterTag.isEmpty ? null : _filterTag,
    );
    setState(() {
      _items = res;
      _loading = false;
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _refresh);
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF0E0D18);
    final titleColor = const Color(0xFFE9EAFF);
    final violet = const Color(0xFF7A6CFF);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: bg.withOpacity(0.9),
        middle: Text('Journal', style: TextStyle(color: titleColor, fontSize: 17)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _exportAll,
              child: Icon(CupertinoIcons.square_arrow_up, color: violet),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _newEntry,
              child: Icon(CupertinoIcons.add_circled_solid, color: violet),
            ),
          ],
        ),
        border: const Border(bottom: BorderSide(color: Color(0x22FFFFFF), width: 0.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            _SearchBar(
              controller: _searchCtl,
              onChanged: _onSearchChanged,
              onClear: () { _searchCtl.clear(); _refresh(); },
            ),
            _Filters(
              current: _filterLucid,
              onChanged: (v) { setState(() => _filterLucid = v ?? _LucidFilter.all); _refresh(); },
              onTagSubmitted: (t) { setState(() => _filterTag = t.trim()); _refresh(); },
              currentTag: _filterTag,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: _loading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _items.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, i) {
                            final it = _items[i];
                            return _JournalCard(
                              item: it,
                              onTap: () => _openEntry(it.id),
                              onDeleteTap: () => _confirmDelete(it.id),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
              child: Text(
                'Tipp: Eintrag nach links wischen oder Papierkorb tippen, um zu löschen.',
                style: TextStyle(color: titleColor.withOpacity(0.6), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _newEntry() async {
    final e = JournalEntry.newDraft();
    await _repo.upsert(e);
    if (!mounted) return;
    await Navigator.of(context).pushNamed('/journal/edit', arguments: e.id);
    _toast('Entwurf erstellt');
  }

  Future<void> _openEntry(String id) async {
    await Navigator.of(context).pushNamed('/journal/edit', arguments: id);
  }

  Future<void> _confirmDelete(String id) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (c) => CupertinoAlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text('Dieser Vorgang kann nicht rückgängig gemacht werden.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Löschen'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _repo.delete(id);
      _toast('Eintrag gelöscht');
    }
  }

  Future<void> _exportAll() async {
    final json = await _repo.exportJson();
    final now = DateTime.now().toIso8601String().replaceAll(':', '-');
    final name = 'lucid_journal_$now.json';
    await Share.shareXFiles(
      [XFile.fromData(Uint8List.fromList(json.codeUnits), name: name, mimeType: 'application/json')],
      text: 'Lucid Journal Export',
      subject: 'Lucid Journal Export',
    );
  }

  void _toast(String msg) {
    final entry = OverlayEntry(
      builder: (ctx) => _TopBanner(message: msg),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
    Future.delayed(const Duration(milliseconds: 1400), entry.remove);
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchBar({required this.controller, required this.onChanged, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final hairline = const Color(0x22FFFFFF);
    final titleColor = const Color(0xFFE9EAFF);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF17172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hairline, width: 0.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            const Icon(CupertinoIcons.search, color: Color(0xFF8FA2FF), size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: CupertinoTextField(
                controller: controller,
                placeholder: 'Suchen…',
                placeholderStyle: TextStyle(color: titleColor.withOpacity(0.7)),
                onChanged: onChanged,
                clearButtonMode: OverlayVisibilityMode.never,
                decoration: const BoxDecoration(color: Color(0x00000000)),
                style: TextStyle(color: titleColor, fontSize: 17),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              onPressed: onClear,
              child: const Icon(CupertinoIcons.xmark_circle_fill, size: 20, color: Color(0x778FA2FF)),
            )
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final _LucidFilter current;
  final ValueChanged<_LucidFilter?> onChanged;
  final void Function(String tag) onTagSubmitted;
  final String currentTag;
  const _Filters({
    required this.current,
    required this.onChanged,
    required this.onTagSubmitted,
    required this.currentTag,
  });

  @override
  Widget build(BuildContext context) {
    final violet = const Color(0xFF7A6CFF);
    final titleColor = const Color(0xFFE9EAFF);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          Semantics(
            label: 'Filter nach Art des Traums',
            child: CupertinoSlidingSegmentedControl<_LucidFilter>(
              groupValue: current,
              thumbColor: violet,
              children: const {
                _LucidFilter.all: Padding(padding: EdgeInsets.all(8), child: Text('Alle')),
                _LucidFilter.lucid: Padding(padding: EdgeInsets.all(8), child: Text('Lucid')),
                _LucidFilter.normal: Padding(padding: EdgeInsets.all(8), child: Text('Normal')),
              },
              onValueChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoTextField(
              placeholder: currentTag.isEmpty ? '#Tag' : currentTag,
              onSubmitted: onTagSubmitted,
              style: TextStyle(color: titleColor, fontSize: 16),
              placeholderStyle: TextStyle(color: titleColor.withOpacity(0.7)),
              decoration: const BoxDecoration(color: Color(0x11000000)),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final JournalIndexItem item;
  final VoidCallback onTap;
  final VoidCallback onDeleteTap;
  const _JournalCard({required this.item, required this.onTap, required this.onDeleteTap});

  @override
  Widget build(BuildContext context) {
    final hairline = const Color(0x22FFFFFF);
    final titleColor = const Color(0xFFE9EAFF);
    final violet = const Color(0xFF7A6CFF);

    return Semantics(
      button: true,
      label: 'Journal Eintrag ${item.title.isEmpty ? "Ohne Titel" : item.title}',
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: const Color(0xFF7A2A2A),
          child: const Icon(CupertinoIcons.delete_simple, color: CupertinoColors.white),
        ),
        confirmDismiss: (_) async {
          return await showCupertinoDialog<bool>(
                context: context,
                builder: (c) => CupertinoAlertDialog(
                  title: const Text('Eintrag löschen?'),
                  actions: [
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.of(c).pop(true),
                      child: const Text('Löschen'),
                    ),
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(c).pop(false),
                      child: const Text('Abbrechen'),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) => onDeleteTap(),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF141321), Color(0xFF0E0D18)],
            ),
            border: Border.all(color: hairline, width: 0.5),
          ),
          child: Row(
            children: [
              _MoodDot(mood: item.mood),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      if (item.lucid)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: violet.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Lucid', style: TextStyle(fontSize: 12, color: Color(0xFFE9EAFF))),
                        ),
                      if (item.lucid) const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.title.isEmpty ? 'Ohne Titel' : item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: titleColor, fontWeight: FontWeight.w600, fontSize: 17),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.date),
                      style: TextStyle(color: titleColor.withOpacity(0.75), fontSize: 13),
                    ),
                    if (item.tags.isNotEmpty) const SizedBox(height: 6),
                    if (item.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: -6,
                        children: item.tags.take(5).map((t) =>
                          Text(t, style: TextStyle(color: titleColor.withOpacity(0.9), fontSize: 13))
                        ).toList(),
                      ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(6),
                onPressed: onDeleteTap,
                child: const Icon(CupertinoIcons.delete, color: Color(0xFFEF9A9A), size: 20),
              ),
              const Icon(CupertinoIcons.chevron_right, size: 18, color: Color(0xFF8FA2FF)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${_two(d.day)}.${_two(d.month)}.${d.year} ${_two(d.hour)}:${_two(d.minute)}';

  String _two(int x) => x < 10 ? '0$x' : '$x';
}

class _MoodDot extends StatelessWidget {
  final int mood; // -1,0,1
  const _MoodDot({required this.mood});

  @override
  Widget build(BuildContext context) {
    Color c;
    if (mood > 0) c = const Color(0xFF39D353);
    else if (mood < 0) c = const Color(0xFFEF4444);
    else c = const Color(0xFF8FA2FF);
    return Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final titleColor = const Color(0xFFE9EAFF);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Noch keine Einträge. Tippe auf das Plus, um dein erstes Traum-Journal zu erstellen.',
          textAlign: TextAlign.center,
          style: TextStyle(color: titleColor, fontSize: 16),
        ),
      ),
    );
  }
}

/// kleines Top-Banner für Feedback
class _TopBanner extends StatelessWidget {
  final String message;
  const _TopBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF202033),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 10)],
            ),
            child: Text(message, style: const TextStyle(color: Color(0xFFE9EAFF), fontSize: 14)),
          ),
        ),
      ),
    );
  }
}
