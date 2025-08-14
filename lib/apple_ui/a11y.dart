import 'package:flutter/cupertino.dart';

class A11y {
  static Future<void> announce(String text) async {
    // Stub: could integrate with SemanticsService.announce if needed.
    debugPrint('A11y announce: $text');
  }
}

class A11yFocusGroup extends StatelessWidget {
  final Widget child;
  const A11yFocusGroup({super.key, required this.child});
  @override
  Widget build(BuildContext context) => child;
}
