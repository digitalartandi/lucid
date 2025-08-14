import 'package:flutter/cupertino.dart';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';
import '../../prefs/lang_prefs.dart';

class KnowledgeSettingsPage extends StatefulWidget {
  const KnowledgeSettingsPage({super.key});
  @override State<KnowledgeSettingsPage> createState()=> _KnowledgeSettingsPageState();
}

class _KnowledgeSettingsPageState extends State<KnowledgeSettingsPage> {
  String lang = 'de';
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { lang = await LangPrefs.get(); if (mounted) setState((){}); }
  Future<void> _save(String v) async { await LangPrefs.set(v); if (mounted) setState(()=> lang=v); }

  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(title: 'Wissen â€“ Einstellungen', child: Column(children: [
      Section(header: 'Sprache', children: [
        RowItem(title: const Text('Deutsch'), trailing: CupertinoSwitch(value: lang=='de', onChanged: (v){ if(v) _save('de'); })),
        RowItem(title: const Text('English'), trailing: CupertinoSwitch(value: lang=='en', onChanged: (v){ if(v) _save('en'); })),
      ]),
    ]));
  }
}






