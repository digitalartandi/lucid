import 'package:flutter/cupertino.dart';

class LargeSliverScaffold extends StatelessWidget {
  final String title;
  final List<Widget> slivers;
  final Widget? trailing;

  const LargeSliverScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(title),
            trailing: trailing,
          ),
          ...slivers,
        ],
      ),
    );
  }
}






