import 'package:flutter/cupertino.dart';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';
import '../../research_feed/repo.dart';
import '../../research_feed/reading_list.dart';
import '../../apple_ui/a11y.dart';
import 'package:url_launcher/url_launcher.dart';
import 'studien_feed_settings.dart';

class StudienFeedPage extends StatefulWidget {
  const StudienFeedPage({super.key});
  @override State<StudienFeedPage> createState()=> _StudienFeedPageState();
}

class _StudienFeedPageState extends State<StudienFeedPage> {
  bool loading = false;
  List<Map<String, dynamic>> items = [];
  final qCtrl = TextEditingController(text: 'lucid dreaming OR lucid dream OR targeted memory reactivation dream');

  @override
  void initState() { super.initState(); _loadCached(); _refresh(); }

  Future<void> _loadCached() async {
    items = await ResearchFeedRepo.loadCached();
    if (mounted) setState((){});
  }

  Future<void> _refresh() async {
    setState(()=> loading = true);
    items = await ResearchFeedRepo.refresh(q: qCtrl.text.trim());
    setState(()=> loading = false);
  }

  Future<void> _saveItem(Map<String, dynamic> it) async {
    final id = ReadingListRepo.makeId((it['title'] ?? '') as String, (it['url'] ?? '') as String);
    final item = ReadingItem(
      id: id,
      title: (it['title'] ?? '') as String,
      authors: ((it['authors'] ?? []) as List).map((e)=> e.toString()).toList(),
      venue: (it['venue'] ?? '') as String,
      date: (it['date'] ?? '') as String,
      url: (it['url'] ?? '') as String,
      doi: (it['doi'] ?? '') as String?,
      source: (it['source'] ?? 'crossref') as String,
    );
    await ReadingListRepo.addOrUpdate(item);
    await A11y.announce('Zur Leseliste hinzugefÃ¼gt');
    if (mounted) setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(title: 'Studien & News', child: Column(children: [
      Section(children: [
        RowItem(title: const Text('Suchbegriff(e)'), subtitle: Text(qCtrl.text), onTap: () async {
          await showCupertinoDialog(context: context, builder: (ctx)=> CupertinoAlertDialog(
            title: const Text('Suche'), content: CupertinoTextField(controller: qCtrl, placeholder: 'lucid dream* ...'),
            actions: [
              CupertinoDialogAction(onPressed: ()=> Navigator.pop(ctx), child: const Text('Abbrechen')),
              CupertinoDialogAction(isDefaultAction: true, onPressed: ()=> Navigator.pop(ctx), child: const Text('OK')),
            ],
          ));
          setState((){});
        }),
        RowItem(title: const Text('Aktualisieren'), subtitle: Text(loading? 'LÃ¤dt ...':'Jetzt suchen'), onTap: _refresh),
      ]),
      const StudienFeedSettings(),
      Section(header: 'Ergebnisse', children: [
        for (final it in items.take(30))
          RowItem(
            title: Text(it['title'] ?? ''),
            subtitle: Text([it['venue'] ?? '', it['date'] ?? ''].where((s)=> (s as String).isNotEmpty).join(' â€¢ ')),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              CupertinoButton(padding: EdgeInsets.zero, onPressed: () async {
                final url = Uri.parse((it['url'] ?? '') as String);
                if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
              }, child: const Icon(CupertinoIcons.arrow_up_right_square)),
              const SizedBox(width: 6),
              CupertinoButton(padding: EdgeInsets.zero, onPressed: () => _saveItem(it), child: const Icon(CupertinoIcons.bookmark_solid)),
            ]),
          ),
      ]),
    ]));
  }
}






