import 'package:flutter/cupertino.dart';

class LargeNavScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? trailing;
  final VoidCallback? onTrailingTap;
  const LargeNavScaffold({super.key, required this.title, required this.child, this.trailing, this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        trailing: (trailing!=null && trailing!.isNotEmpty) ? GestureDetector(onTap: onTrailingTap, child: Row(mainAxisSize: MainAxisSize.min, children: trailing!)) : null,
      ),
      child: SafeArea(child: child),
    );
  }
}






