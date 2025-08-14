import 'package:flutter/cupertino.dart';

class Section extends StatelessWidget {
  final String? header;
  final List<Widget> children;
  const Section({super.key, this.header, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(header!, style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGroupedBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1A000000)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class RowItem extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const RowItem({super.key, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0x14000000), width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              DefaultTextStyle(style: const TextStyle(fontSize: 16, color: CupertinoColors.label), child: title),
              if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 2), child: DefaultTextStyle(style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey), child: subtitle!)),
            ])),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
