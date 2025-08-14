import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistPage extends StatefulWidget {
  final String asset;
  final String title;
  const ChecklistPage({super.key, required this.asset, required this.title});
  @override State<ChecklistPage> createState()=> _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  List<dynamic> items = [];
  Set<String> done = {};

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final raw = await rootBundle.loadString(widget.asset);
    items = jsonDecode(raw) as List<dynamic>;
    final p = await SharedPreferences.getInstance();
    done = (p.getStringList('checklist.${widget.asset}') ?? <String>[]).toSet();
    if (mounted) setState((){});
  }

  Future<void> _toggle(String id) async {
    if (done.contains(id)) {
  done.remove(id);
} else {
  done.add(id);
}
    final p = await SharedPreferences.getInstance();
    await p.setStringList('checklist.${widget.asset}', done.toList());
    if (mounted) setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(title: widget.title, child: Column(children: [
      Section(children: [
        for (final it in items)
          RowItem(
            title: Text(it['title'] ?? ''),
            subtitle: Text(it['hint'] ?? ''),
            trailing: CupertinoSwitch(value: done.contains(it['id']), onChanged: (_)=> _toggle(it['id'])),
          ),
      ]),
    ]));
  }
}






