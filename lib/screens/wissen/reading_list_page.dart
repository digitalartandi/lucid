import 'package:flutter/cupertino.dart';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';
import '../../research_feed/reading_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ReadingListPage extends StatefulWidget {
  const ReadingListPage({super.key});
  @override State<ReadingListPage> createState()=> _ReadingListPageState();
}

class _ReadingListPageState extends State<ReadingListPage> {
  List<ReadingItem> items = [];
  String query = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    items = await ReadingListRepo.list();
    if (mounted) setState((){});
  }

  Future<void> _editNote(ReadingItem it) async {
    final ctrl = TextEditingController(text: it.note ?? '');
    await showCupertinoDialog(context: context, builder: (ctx)=> CupertinoAlertDialog(
      title: const Text('Notiz'),
      content: CupertinoTextField(controller: ctrl, placeholder: 'Kurze Notiz'),
      actions: [
        CupertinoDialogAction(onPressed: ()=> Navigator.pop(ctx), child: const Text('Abbrechen')),
        CupertinoDialogAction(isDefaultAction: true, onPressed: () async {
          final upd = it.copyWith(note: ctrl.text.trim());
          await ReadingListRepo.addOrUpdate(upd);
          if (mounted) Navigator.pop(ctx);
          await _load();
        }, child: const Text('Speichern')),
      ],
    ));
  }

  Future<void> _remove(ReadingItem it) async {
    await ReadingListRepo.remove(it.id);
    await _load();
  }

  Future<void> _exportJson() async {
    final path = await ReadingListRepo.exportJson();
    await Share.shareXFiles([XFile(path)], text: 'Leseliste (JSON)');
  }

  Future<void> _exportCsv() async {
    final path = await ReadingListRepo.exportCsv();
    await Share.shareXFiles([XFile(path)], text: 'Leseliste (CSV)');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = query.trim().isEmpty
      ? items
      : items.where((i)=> i.title.toLowerCase().contains(query.toLowerCase()) || (i.venue.toLowerCase().contains(query.toLowerCase()))).toList();
    return LargeNavScaffold(title: 'Leseliste', child: Column(children: [
      Section(children: [
        RowItem(title: const Text('Suchen'), subtitle: Text(query.isEmpty? '': query), onTap: () async {
          final ctrl = TextEditingController(text: query);
          await showCupertinoDialog(context: context, builder: (ctx)=> CupertinoAlertDialog(
            title: const Text('Suche'), content: CupertinoTextField(controller: ctrl, placeholder: 'Titel, Journal …'),
            actions: [
              CupertinoDialogAction(onPressed: ()=> Navigator.pop(ctx), child: const Text('Abbrechen')),
              CupertinoDialogAction(isDefaultAction: true, onPressed: (){ setState(()=> query = ctrl.text.trim()); Navigator.pop(ctx); }, child: const Text('OK')),
            ],
          ));
        }),
        RowItem(title: const Text('Export JSON'), subtitle: const Text('Teilen/Speichern'), onTap: _exportJson),
        RowItem(title: const Text('Export CSV'), subtitle: const Text('Teilen/Speichern'), onTap: _exportCsv),
      ]),
      Section(header: 'Einträge', children: [
        for (final it in filtered.reversed)
          RowItem(
            title: Text(it.title),
            subtitle: Text([it.venue, it.date].where((s)=> s.isNotEmpty).join(' • ')),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              CupertinoButton(padding: EdgeInsets.zero, onPressed: () async {
                final url = Uri.parse(it.url);
                if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
              }, child: const Icon(CupertinoIcons.arrow_up_right_square)),
              const SizedBox(width: 6),
              CupertinoButton(padding: EdgeInsets.zero, onPressed: ()=> _editNote(it), child: const Icon(CupertinoIcons.pencil)),
              const SizedBox(width: 6),
              CupertinoButton(padding: EdgeInsets.zero, onPressed: ()=> _remove(it), child: const Icon(CupertinoIcons.delete)),
            ]),
          ),
      ]),
    ]));
  }
}
