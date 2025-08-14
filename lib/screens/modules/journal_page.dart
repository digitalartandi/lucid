import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});
  @override State<JournalPage> createState()=> _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final _controller = TextEditingController();
  List<String> entries = [];

  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(()=> entries = sp.getStringList('journal') ?? []);
  }
  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList('journal', entries);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Journal')),
      child: SafeArea(child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: CupertinoTextField(
              controller: _controller,
              placeholder: 'Kurzer Traum-Eintrag â€¦',
              maxLines: 3,
            ),
          ),
          CupertinoButton.filled(
            child: const Text('Speichern'),
            onPressed: () async {
              final t = _controller.text.trim();
              if (t.isEmpty) return;
              setState(()=> entries.insert(0, t));
              _controller.clear();
              await _save();
            },
          ),
          const SizedBox(height: 10),
          Expanded(child: ListView.separated(
            itemBuilder: (_, i)=> Padding(
              padding: const EdgeInsets.symmetric(horizontal:16, vertical:10),
              child: Text(entries[i]),
            ),
            separatorBuilder: (_, __)=> Container(height: 1, color: CupertinoColors.separator),
            itemCount: entries.length,
          )),
        ],
      )),
    );
  }
}


