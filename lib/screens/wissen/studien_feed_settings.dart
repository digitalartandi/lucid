import 'package:flutter/cupertino.dart';
import '../../apple_ui/widgets/section_list.dart';
import '../../prefs/app_prefs_auto.dart';
import '../../services/auto_update_service.dart';

class StudienFeedSettings extends StatefulWidget {
  const StudienFeedSettings({super.key});
  @override State<StudienFeedSettings> createState()=> _StudienFeedSettingsState();
}

class _StudienFeedSettingsState extends State<StudienFeedSettings> {
  bool enabled = false;
  int mins = 1440;
  final qCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    enabled = await AutoUpdatePrefs.isEnabled();
    mins = await AutoUpdatePrefs.getFreqMins();
    qCtrl.text = await AutoUpdatePrefs.getQuery();
    if (mounted) setState((){});
  }

  Future<void> _save() async {
    await AutoUpdatePrefs.setEnabled(enabled);
    await AutoUpdatePrefs.setFreqMins(mins);
    await AutoUpdatePrefs.setQuery(qCtrl.text.trim());
    if (enabled) {
      await AutoUpdateService.schedule(minutes: mins);
    } else {
      await AutoUpdateService.cancel();
    }
    if (mounted) setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Section(header: 'Auto‑Update', children: [
        RowItem(title: const Text('Aktiviert'), subtitle: Text(enabled ? 'ein' : 'aus'),
          trailing: CupertinoSwitch(value: enabled, onChanged: (v)=> setState(()=> enabled=v))),
        RowItem(title: const Text('Intervall'), subtitle: Text('$mins min'), trailing: SizedBox(
          width: 220,
          child: CupertinoSlider(min: 15, max: 1440, divisions: 95, value: mins.toDouble(), onChanged: (v)=> setState(()=> mins=v.round())),
        )),
        RowItem(title: const Text('Suchbegriff(e)'), subtitle: Text(qCtrl.text),
          onTap: () async {
            await showCupertinoDialog(context: context, builder: (ctx)=> CupertinoAlertDialog(
              title: const Text('Suche'),
              content: CupertinoTextField(controller: qCtrl, placeholder: 'lucid dream* ...'),
              actions: [
                CupertinoDialogAction(onPressed: ()=> Navigator.pop(ctx), child: const Text('Abbrechen')),
                CupertinoDialogAction(isDefaultAction: true, onPressed: ()=> Navigator.pop(ctx), child: const Text('OK')),
              ],
            ));
            setState((){});
          }),
      ]),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: CupertinoButton.filled(onPressed: _save, child: const Text('Speichern')),),
    ]);
  }
}
