import 'package:flutter/cupertino.dart';

class NightLitePage extends StatefulWidget {
  const NightLitePage({super.key});
  @override State<NightLitePage> createState()=> _NightLitePageState();
}

class _NightLitePageState extends State<NightLitePage> {
  double intensity = 0.4;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Night Lite+')),
      child: SafeArea(child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Sanfte Hinweise in spÃ¤ten REM-Fenstern. Teste die IntensitÃ¤t:'),
          ),
          CupertinoListSection.insetGrouped(children: [
            CupertinoListTile(
              title: const Text('IntensitÃ¤t'),
              trailing: SizedBox(
                width: 200,
                child: CupertinoSlider(value: intensity, onChanged: (v)=> setState(()=> intensity=v)),
              ),
            ),
            CupertinoButton.filled(
              child: const Text('Test-Cue abspielen'),
              onPressed: () async {
                // Demo: kurzer System-Beep via Dialog (plattformneutral)
                await showCupertinoDialog(context: context, builder: (_)=> const CupertinoAlertDialog(
                  title: Text('Cue'),
                  content: Text('Hinweis getriggert.'),
                ));
                if (mounted) Navigator.of(context).pop();
              },
            ),
          ]),
        ],
      )),
    );
  }
}


