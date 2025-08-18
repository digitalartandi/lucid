import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/journal_store.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});
  @override State<JournalPage> createState()=> _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final _input = TextEditingController();
  final _edit = TextEditingController();
  final _store = JournalStore();
  List<JournalEntry> _items = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _store.load();
    if (mounted) setState(()=> _items = data);
  }

  Future<void> _add() async {
    final t = _input.text.trim();
    if (t.isEmpty) return;
    final data = await _store.add(t);
    if (!mounted) return;
    setState(()=> _items = data);
    _input.clear();
  }

  Future<void> _remove(String id) async {
    final data = await _store.remove(id);
    if (!mounted) return;
    setState(()=> _items = data);
  }

  Future<void> _editEntry(JournalEntry e) async {
    _edit.text = e.text;
    await showCupertinoDialog(context: context, builder: (_)=> CupertinoAlertDialog(
      title: const Text('Eintrag bearbeiten'),
      content: Column(children: [
        const SizedBox(height: 8),
        CupertinoTextField(controller: _edit, maxLines: 5),
      ]),
      actions: [
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: ()=> Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () async {
            final txt = _edit.text.trim();
            if (txt.isNotEmpty) await _store.update(e.id, txt);
            if (mounted) Navigator.of(context).pop();
            _load();
          },
          child: const Text('Speichern'),
        ),
      ],
    ));
  }

  Future<void> _export() async {
    final json = await _store.exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    try { await Share.share(json, subject: 'Lucid Journal Export'); } catch (_) {}
    if (!mounted) return;
    showCupertinoDialog(context: context, builder: (_)=> const CupertinoAlertDialog(
      title: Text('Export'),
      content: Text('Export in Zwischenablage kopiert.'),
    )).then((_){ if (mounted) Navigator.of(context).pop(); });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
      ? _items
      : _items.where((e)=> e.text.toLowerCase().contains(_query.toLowerCase())).toList();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Journal'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _export,
          child: const Icon(CupertinoIcons.square_arrow_up),
        ),
      ),
      child: SafeArea(child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: CupertinoTextField(
              controller: _input,
              placeholder: 'Kurzer Traum-Eintrag …',
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:12),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoButton.filled(
                    onPressed: _add,
                    child: const Text('Speichern'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CupertinoSearchTextField(
              placeholder: 'Suchen …',
              onChanged: (q)=> setState(()=> _query = q),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.separated(
              itemBuilder: (_, i) {
                final e = filtered[i];
                return CupertinoListTile.notched(
                  title: Text(e.text),
                  subtitle: Text(_fmt(e.createdAt)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: ()=> _editEntry(e),
                      child: const Icon(CupertinoIcons.pencil),
                    ),
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: ()=> _remove(e.id),
                      child: const Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed),
                    ),
                  ]),
                );
              },
              separatorBuilder: (_, __)=> Container(height: 1, color: CupertinoColors.separator),
              itemCount: filtered.length,
            ),
          ),
        ],
      )),
    );
  }

  String _fmt(DateTime d) {
    final two = (int n)=> n.toString().padLeft(2,'0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}
