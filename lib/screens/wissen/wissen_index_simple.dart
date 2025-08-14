import 'package:flutter/cupertino.dart';

class WissenIndexSimple extends StatelessWidget {
  const WissenIndexSimple({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Wissen')),
      child: SafeArea(child: ListView(
        children: [
          CupertinoListSection.insetGrouped(header: const Text('Grundlagen'), children: [
            CupertinoListTile.notched(
              title: const Text('Klartraum – Grundlagen'),
              subtitle: const Text('Techniken, Schlaf, Cues'),
              onTap: ()=> Navigator.pushNamed(context, '/wissen/article',
                arguments: 'assets/wissen/grundlagen_de.md'),
            ),
          ]),
        ],
      )),
    );
  }
}


