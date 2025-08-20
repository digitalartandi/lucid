// lib/screens/journal/journal_list_page.dart
import 'package:flutter/cupertino.dart';
import '../../services/journal_repo.dart';
import '../../models/journal_models.dart';

const _bg     = Color(0xFF0D0F16);
const _white  = Color(0xFFE9EAFF);
const _card   = Color(0xFF0A0A23);
const _line   = Color(0x22FFFFFF);
const _violet = Color(0xFF7A6CFF);

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});
  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  final _repo = JournalRepo.instance;
  final _search = TextEditingController();

  List<JournalIndexItem> _items = [];
  int _tab = 0; // 0 alle, 1 lucid, 2 normal

  @override
  void initState() {
    super.initState();
    _init();
    _repo.revision.addListener(_refresh);
  }

  @override
  void dispose() {
    _repo.revision.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _init() async {
    await _repo.init();
    await _refresh();
  }

  Future<void> _refresh() async {
    final list = await _repo.listAll();
    if (!mounted) return;
    setState(() => _items = list);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();

    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: const Text('Journal', style: TextStyle(color: _white)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final text = await _repo.exportJson();
                // kleiner UX-Hinweis
                // ignore: use_build_context_synchronously
                showCupertinoDialog(
                  context: context,
                  builder: (_) => const CupertinoAlertDialog(
                    title: Text('Export'),
                    content: Text('JSON in Zwischenablage/Datei gespeichert (plattformabhängig).'),
                  ),
                ).then((_) => Navigator.of(context).pop());
              },
              child: const Icon(CupertinoIcons.square_arrow_up, color: _white),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pushNamed('/journal/new'),
              child: const Icon(CupertinoIcons.add_circled_solid, color: _violet),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: CupertinoSearchTextField(
                controller: _search,
                placeholder: 'Suchen…',
                style: const TextStyle(color: _white),
                placeholderStyle: const TextStyle(color: Color(0x66E9EAFF)),
                backgroundColor: const Color(0x1AFFFFFF),
                prefixIcon: const Icon(CupertinoIcons.search, color: _white, size: 18),
                suffixIcon: const Icon(CupertinoIcons.xmark_circle_fill, color: _white),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _tab,
                  onValueChanged: (v) => setState(() => _tab = v ?? 0),
                  children: const {
                    0: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text('Alle', style: TextStyle(color: _white)),
                    ),
                    1: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text('Lucid', style: TextStyle(color: _white)),
                    ),
                    2: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text('Normal', style: TextStyle(color: _white)),
                    ),
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyHint(onAdd: () => Navigator.of(context).pushNamed('/journal/new'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
                      itemBuilder: (_, i) {
                        final it = filtered[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _line),
                          ),
                          child: CupertinoListTile.notched(
                            title: Text(it.title.isEmpty ? 'Ohne Titel' : it.title,
                                style: const TextStyle(color: _white)),
                            subtitle: Text(_fmt(it.date), style: const TextStyle(color: _white)),
                            trailing: const Icon(CupertinoIcons.chevron_right, color: _white),
                            onTap: () => Navigator.of(context)
                                .pushNamed('/journal/edit', arguments: it.id),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: filtered.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<JournalIndexItem> _filtered() {
    final q = _search.text.trim().toLowerCase();
    final lucidFilter = _tab == 0 ? null : _tab == 1;
    return _items.where((e) {
      if (lucidFilter != null && e.lucid != lucidFilter) return false;
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) ||
          e.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  String _fmt(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}.${two(d.month)}.${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }
}

class _EmptyHint extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyHint({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(CupertinoIcons.square_pencil, color: _white, size: 40),
        const SizedBox(height: 10),
        const Text('Noch keine Einträge',
            style: TextStyle(color: _white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text(
          'Tippe oben rechts auf „+“, um einen\nneuen Tagebuch-Eintrag zu erstellen.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _white),
        ),
        const SizedBox(height: 12),
        CupertinoButton.filled(
          onPressed: onAdd,
          child: const Text('Jetzt hinzufügen'),
        ),
      ]),
    );
  }
}
