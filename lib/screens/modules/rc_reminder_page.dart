import 'package:flutter/cupertino.dart';

class RcReminderPage extends StatefulWidget {
  const RcReminderPage({super.key});
  @override State<RcReminderPage> createState()=> _RcReminderPageState();
}

class _RcReminderPageState extends State<RcReminderPage> {
  bool enabled = true;
  int perDay = 8;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Reality-Checks')),
      child: SafeArea(child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Kontextbasierte Erinnerungen helfen, tagsÃ¼ber â€žbin ich im Traum?â€œ zu prÃ¼fen.'),
          ),
          CupertinoListSection.insetGrouped(children: [
            CupertinoListTile(
              title: const Text('RC-Erinnerungen'),
              trailing: CupertinoSwitch(value: enabled, onChanged: (v)=> setState(()=> enabled=v)),
            ),
            CupertinoListTile(
              title: Text('HÃ¤ufigkeit: $perDayÃ—/Tag'),
              additionalInfo: const Text('empfohlen 8â€“10'),
              trailing: CupertinoSlidingSegmentedControl<int>(
                groupValue: perDay,
                children: const {6: Text('6'),8: Text('8'),10: Text('10')},
                onValueChanged: (v)=> setState(()=> perDay=v??perDay),
              ),
            ),
          ]),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Tipp: verknÃ¼pfe RC mit Alltagstriggern (TÃ¼ren, Uhrzeit, Wasser trinken).'),
          ),
        ],
      )),
    );
  }
}


