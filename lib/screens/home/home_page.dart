import 'package:flutter/cupertino.dart';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(title: 'Home – Klar & fokussiert', child: Column(children: const [
      Section(header: 'Heute', children: [
        RowItem(title: Text('RC‑Reminder aktiv'), subtitle: Text('8–10x kontextbasiert')),
        RowItem(title: Text('Night Lite+ sanft bereit'), subtitle: Text('späte REM‑Fenster')),
      ]),
      Section(header: 'Schnellzugriff', children: [
        RowItem(title: Text('Trainer – RC planen')),
        RowItem(title: Text('Cue‑Tuning – Audio‑Lab')),
        RowItem(title: Text('Journal – Eintrag hinzufügen')),
      ]),
    ]));
  }
}
