import 'package:flutter/cupertino.dart';

class CueTuningPage extends StatefulWidget {
  const CueTuningPage({super.key});
  @override State<CueTuningPage> createState()=> _CueTuningPageState();
}

class _CueTuningPageState extends State<CueTuningPage> {
  double volume = 0.5;
  double interval = 10;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Cue-Tuning')),
      child: SafeArea(child: ListView(
        children: [
          CupertinoListSection.insetGrouped(children: [
            CupertinoListTile(
              title: const Text('LautstÃ¤rke'),
              trailing: SizedBox(width: 200,
                child: CupertinoSlider(value: volume, onChanged: (v)=> setState(()=> volume=v))),
            ),
            CupertinoListTile(
              title: Text('Intervall: ${interval.toStringAsFixed(0)} min'),
              trailing: SizedBox(width: 200,
                child: CupertinoSlider(min: 5, max: 30, value: interval, onChanged: (v)=> setState(()=> interval=v))),
            ),
            CupertinoButton.filled(onPressed: (){
              showCupertinoDialog(context: context, builder: (_)=> CupertinoAlertDialog(
                title: const Text('Probe-Cue'),
                content: Text('LautstÃ¤rke ${(volume*100).toStringAsFixed(0)}% â€“ Intervall ${interval.toStringAsFixed(0)} min'),
                actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: ()=> Navigator.of(context).pop())],
              ));
            }, child: const Text('Probe-Cue')),
          ]),
        ],
      )),
    );
  }
}


