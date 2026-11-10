// lib/features/journal/journal_page.dart
//
// Journal: Träume festhalten, wiederfinden, Muster sehen.
import 'package:flutter/cupertino.dart';

import '../../models/journal_models.dart';
import '../../services/journal_repo.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';
import '../shell/app_shell.dart';

const List<String> _months = <String>[
  'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
  'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
];
const List<String> _weekdays = <String>['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

String journalDate(DateTime d) => '${_weekdays[d.weekday - 1]}, ${d.day}. ${_months[d.month - 1]}';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final JournalRepo _repo = JournalRepo.instance;
  final TextEditingController _search = TextEditingController();

  List<JournalIndexItem> _items = <JournalIndexItem>[];
  bool _lucidOnly = false;
  String? _tag;
  bool _loading = true;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _repo.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _repo.revision.removeListener(_load);
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final int req = ++_request;
    final List<JournalIndexItem> res = await _repo.search(
      query: _search.text,
      lucid: _lucidOnly ? true : null,
      tag: _tag,
    );
    if (!mounted || req != _request) return;
    setState(() {
      _items = res;
      _loading = false;
    });
  }

  List<String> _topTags() {
    final Map<String, int> count = <String, int>{};
    for (final JournalIndexItem e in _repo.snapshot) {
      for (final String t in e.tags) {
        count[t] = (count[t] ?? 0) + 1;
      }
    }
    final List<MapEntry<String, int>> sorted = count.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value));
    return sorted.take(8).map((MapEntry<String, int> e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<JournalIndexItem> all = _repo.snapshot;
    final int lucid = all.where((JournalIndexItem e) => e.lucid).length;
    final List<String> tags = _topTags();
    final bool filtered = _lucidOnly || _tag != null || _search.text.trim().isNotEmpty;

    // Nach Monat gruppieren.
    final List<Widget> rows = <Widget>[];
    String? lastMonth;
    for (final JournalIndexItem e in _items) {
      final String m = '${_months[e.date.month - 1]} ${e.date.year}';
      if (m != lastMonth) {
        lastMonth = m;
        rows.add(Padding(
          padding: const EdgeInsets.only(top: LS.xl, bottom: LS.sm),
          child: Text(m, style: LT.labelMuted),
        ));
      }
      rows.add(_EntryTile(
        item: e,
        onTap: () => openRoute(context, '/journal/edit', arg: e.id),
      ));
    }

    return LPage(
      child: Stack(
        children: <Widget>[
          LScroll(
            children: <Widget>[
              LHeader(
                title: 'Journal',
                subtitle: all.isEmpty
                    ? 'Dein Traumtagebuch'
                    : '${all.length} ${all.length == 1 ? 'Traum' : 'Träume'}, davon $lucid klar',
                trailing: LTap(
                  onTap: () => openRoute(context, '/insights'),
                  semanticLabel: 'Auswertung',
                  child: const LIconDot(CupertinoIcons.chart_bar, color: LC.muted),
                ),
              ),
              if (all.isNotEmpty) ...<Widget>[
                LField(
                  controller: _search,
                  placeholder: 'Suchen',
                  prefix: const Icon(CupertinoIcons.search, size: 18, color: LC.faint),
                  onChanged: (_) => _load(),
                ),
                const SizedBox(height: LS.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      LChip(
                        label: 'Klarträume',
                        icon: CupertinoIcons.sparkles,
                        tone: LC.moon,
                        selected: _lucidOnly,
                        onTap: () {
                          setState(() => _lucidOnly = !_lucidOnly);
                          _load();
                        },
                      ),
                      for (final String t in tags) ...<Widget>[
                        const SizedBox(width: LS.sm),
                        LChip(
                          label: t,
                          selected: _tag == t,
                          onTap: () {
                            setState(() => _tag = _tag == t ? null : t);
                            _load();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: LS.xxl),
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else if (all.isEmpty)
                LEmpty(
                  icon: CupertinoIcons.book,
                  title: 'Noch kein Traum notiert',
                  text:
                      'Schreib morgen früh als Erstes auf, woran du dich erinnerst. Wenige Stichworte reichen, und mit jedem Eintrag wird die Erinnerung besser.',
                  actionLabel: 'Ersten Traum notieren',
                  onAction: () => openRoute(context, '/journal/new'),
                )
              else if (_items.isEmpty && filtered)
                const LEmpty(
                  icon: CupertinoIcons.search,
                  title: 'Nichts gefunden',
                  text: 'Kein Eintrag passt zu Suche und Filter.',
                )
              else
                ...rows,
            ],
          ),
          if (all.isNotEmpty)
            Positioned(
              right: LS.page,
              bottom: MediaQuery.of(context).padding.bottom + LS.lg,
              child: LTap(
                onTap: () => openRoute(context, '/journal/new'),
                semanticLabel: 'Traum notieren',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: LS.xl, vertical: LS.lg),
                  decoration: const BoxDecoration(
                    color: LC.iris,
                    borderRadius: LRad.pill,
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(CupertinoIcons.pencil, size: 18, color: LC.night),
                      const SizedBox(width: LS.sm),
                      Text('Traum notieren', style: LT.heading.copyWith(color: LC.night, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.item, required this.onTap});
  final JournalIndexItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String title = item.title.trim().isEmpty ? 'Ohne Titel' : item.title.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: LS.sm),
      child: LCard(
        onTap: onTap,
        borderColor: item.lucid ? const Color(0x73F2C879) : LC.glassLine,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(journalDate(item.date), style: LT.caption),
                  const SizedBox(height: 4),
                  Text(title, style: LT.heading, maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (item.tags.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      item.tags.take(4).join(', '),
                      style: LT.labelMuted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (item.lucid) ...<Widget>[
              const SizedBox(width: LS.md),
              const LBadge('Klar', color: LC.moon, background: LC.moonSoft),
            ],
          ],
        ),
      ),
    );
  }
}
