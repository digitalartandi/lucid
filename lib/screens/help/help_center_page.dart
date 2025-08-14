import 'package:flutter/cupertino.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Hilfe & Einführung'),
      ),
      child: Center(
        child: Text('Hier wird bald das Hilfe-Center erscheinen.'),
      ),
    );
  }
}
