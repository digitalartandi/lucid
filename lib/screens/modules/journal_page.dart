import 'package:flutter/cupertino.dart';
import '../../models/journal_models.dart';
import '../../services/journal_repo.dart';

const _bg = Color(0xFF0D0F16);
const _white = Color(0xFFE9EAFF);
const _glass = Color(0x1AFFFFFF);
const _line = Color(0x22FFFFFF);
const _accent = Color(0xFF7A6CFF);
const _card = Color(0xFF0A0A23);

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});
  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  final _repo = JournalRepo.instance;

  int _seg = 0; // 0=Alle, 1=Lucid, 2=Normal
  String _query = '';
  List<JournalIndexItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
    _repo.revision.addListener(_load);
  }

  @override
  void dispose() {
    _repo.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    await _repo.init();
    final list = await _repo.list();
    if (!mounted) return;
    setState(() => _items = list);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((e) {
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.tags.any((t) => t.toLowerCase().contains(q));
      final matchesSeg = switch (_seg) {
        0 => true,
        1 => e.tags.contains('lucid'),
        2 => !e.tags.contains('lucid'),
        _ => true,
      };
      return matchesQuery && matchesSeg;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: const Text('Journal', style: TextStyle(color: _white)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pushNamed('/journal/new'),
            child: const Icon(CupertinoIcons.add, color: _white),
          ),
        ]),
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
                backgroundColor: _glass,
                prefixIcon:
                    const Icon(CupertinoIcons.search, color: _white, size: 18),
                suffixIcon: const Icon(CupertinoIcons.xmark_circle_fill,
                    color: _white),
                onChanged: (q) => setState(() => _query = q),
              ),
            ),

            // Segmented – IMMER weiße Typo
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _seg,
                backgroundColor: const Color(0x33242742),
                thumbColor: _accent,
                children: {
                  0: _segLabel('Alle'),
                  1: _segLabel('Lucid'),
                  2: _segLabel('Normal'),
                },
                onValueChanged: (v) => setState(() => _seg = v ?? 0),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                itemBuilder: (_, i) {
                  final it = filtered[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _line),
                    ),
                    child: CupertinoListTile.notched(
                      title: Text(
                        it.title.isEmpty ? 'Ohne Titel' : it.title,
                        style: const TextStyle(color: _white),
                      ),
                      subtitle: Text(
                        _fmt(it.date),
                        style: const TextStyle(color: _white),
                      ),
                      trailing: const Icon(CupertinoIcons.chevron_right,
                          color: _white),
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

  Widget _segLabel(String s) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(s,
            style: const TextStyle(
                color: _white, fontWeight: FontWeight.w600, fontSize: 13)),
      );

  String _fmt(DateTime d) {
    String two(int x) => x < 10 ? '0$x' : '$x';
    return '${two(d.day)}.${two(d.month)}.${d.year}  ${two(d.hour)}:${two(d.minute)}';
    }
}
