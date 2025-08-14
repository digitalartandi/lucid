import 'package:flutter/cupertino.dart';

class TrainerPage extends StatelessWidget {
  const TrainerPage({super.key});
  @override
  Widget build(BuildContext context) {
    final days = List.generate(14, (i)=> i+1);
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('2-Wochen-Trainer')),
      child: SafeArea(child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('TÃ¤gliche Mini-Aufgaben (RC, Journal, kurze Visualisierung).'),
          ),
          ...days.map((d)=> CupertinoListTile.notched(
            title: Text('Tag $d'),
            subtitle: const Text('RC + Journal + Intention (MILD)'),
            trailing: const Icon(CupertinoIcons.chevron_right),
            onTap: (){},
          )),
        ],
      )),
    );
  }
}


