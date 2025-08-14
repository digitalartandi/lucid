import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';
import '../../apple_ui/a11y.dart';
import '../../research/models.dart';
import '../../research/storage.dart';

class StudyBuilderPage extends StatefulWidget {
  const StudyBuilderPage({super.key});
  @override State<StudyBuilderPage> createState()=> _StudyBuilderPageState();
}

class _StudyBuilderPageState extends State<StudyBuilderPage> {
  final titleCtrl = TextEditingController(text: 'N‑of‑1 – Zwei Arme');
  final armA = TextEditingController(text: 'A: Cue sanft');
  final armB = TextEditingController(text: 'B: kein Cue');
  int days = 14;
  List<Assignment> schedule = [];

  @override
  void initState() { super.initState(); _generate(); }

  void _generate() {
    final rnd = Random();
    final arms = ['A','B'];
    schedule = List<Assignment>.generate(days, (i){
      final arm = arms[rnd.nextInt(arms.length)];
      return Assignment(dayIndex: i, armId: arm);
    });
    setState((){});
  }

  Future<void> _save() async {
    final s = Study(
      id: 'study_01',
      title: titleCtrl.text.trim(),
      arms: [StudyArm(id: 'A', name: armA.text.trim()), StudyArm(id: 'B', name: armB.text.trim())],
      schedule: schedule,
    );
    await ResearchStorage.saveStudy(s);
    if (mounted) {
      await A11y.announce('Studie gespeichert');
      showCupertinoDialog(context: context, builder: (_)=> const CupertinoAlertDialog(
        title: Text('Gespeichert'), content: Text('Studie gespeichert'), actions: [CupertinoDialogAction(child: Text('OK'))],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(title: 'Studien‑Builder', child: Column(children: [
      Section(children: [
        RowItem(title: const Text('Titel'), subtitle: const Text('Name der Studie'), onTap: () async {
          await showCupertinoDialog(context: context, builder: (ctx)=> CupertinoAlertDialog(
            title: const Text('Titel'),
            content: CupertinoTextField(controller: titleCtrl, placeholder: 'Titel'),
            actions: [
              CupertinoDialogAction(onPressed: ()=> Navigator.pop(ctx), child: const Text('Abbrechen')),
              CupertinoDialogAction(isDefaultAction: true, onPressed: ()=> Navigator.pop(ctx), child: const Text('OK')),
            ],
          ));
if (!mounted) return;
          setState((){});
        }),
        RowItem(title: const Text('Arm A'), subtitle: Text(armA.text), onTap: () async {
          await showCupertinoDialog(context: context, builder: (ctx)=> CupertinoAlertDialog(
            title: const Text('Arm A'),
            content: CupertinoTextField(controller: armA, placeholder: 'Arm A'),
            actions: [
              CupertinoDialogAction(onPressed: ()=> Navigator.pop(ctx), child: const Text('Abbrechen')),
              CupertinoDialogAction(isDefaultAction: true, onPressed: ()=> Navigator.pop(ctx), child: const Text('OK')),
            ],
          ));
          setState((){});
        }),
        RowItem(title: const Text('Arm B'), subtitle: Text(armB.text), onTap: () async {
          await showCupertinoDialog(context: context, builder: (ctx)=> CupertinoAlertDialog(
            title: const Text('Arm B'),
            content: CupertinoTextField(controller: armB, placeholder: 'Arm B'),
            actions: [
              CupertinoDialogAction(onPressed: ()=> Navigator.pop(ctx), child: const Text('Abbrechen')),
              CupertinoDialogAction(isDefaultAction: true, onPressed: ()=> Navigator.pop(ctx), child: const Text('OK')),
            ],
          ));
          setState((){});
        }),
        RowItem(title: const Text('Dauer (Tage)'), subtitle: Text('$days'),
          trailing: SizedBox(width: 220, child: CupertinoSlider(min: 7, max: 30, divisions: 23, value: days.toDouble(), onChanged: (v){ setState(()=> days=v.round()); _generate(); })),
        ),
      ]),
      Section(header: 'Randomisierte Reihenfolge', children: [
        for (final a in schedule) RowItem(title: Text('Tag ${a.dayIndex+1}'), subtitle: Text('Arm ${a.armId}')),
      ]),
      Padding(padding: const EdgeInsets.all(16), child: CupertinoButton.filled(onPressed: _save, child: const Text('Studie speichern'))),
    ]));
  }
}
