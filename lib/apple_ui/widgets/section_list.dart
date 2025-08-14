import 'package:flutter/cupertino.dart';

class Section extends StatelessWidget {
  final String? header;
  final List<Widget> children;

  const Section({super.key, this.header, required this.children});

  @override
  Widget build(BuildContext context) {
    final list = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: _withDividers(children),
      ),
    );

    if ((header ?? '').isEmpty) return list;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
            child: Text(
              header!,
              style: const TextStyle(
                fontSize: 13,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          list,
        ],
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i < items.length - 1) {
        out.add(const DividerInset());
      }
    }
    return out;
  }
}

class RowItem extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const RowItem({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.label,
                    fontWeight: FontWeight.w600,
                  ),
                  child: title,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w400,
                    ),
                    child: subtitle!,
                  ),
                ]
              ],
            ),
          ),
        ),
        if (trailing != null) trailing!,
        if (onTap != null)
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(CupertinoIcons.chevron_right, size: 16, color: CupertinoColors.systemGrey2),
          ),
      ],
    );

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: row,
    );

    if (onTap == null) {
      return content;
    }
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Align(alignment: Alignment.centerLeft, child: content),
    );
  }
}

class DividerInset extends StatelessWidget {
  const DividerInset({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      height: 0.6,
      color: CupertinoColors.separator,
    );
  }
}






