import 'package:flutter/cupertino.dart';

class QaItem {
  final String question;
  final Widget answer; // flexibel: Text, RichText, Column etc.
  final bool initiallyOpen;
  const QaItem({required this.question, required this.answer, this.initiallyOpen = false});
}

class AccordionList extends StatelessWidget {
  final List<QaItem> items;
  final EdgeInsets padding;
  const AccordionList({super.key, required this.items, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _AccordionTile(item: items[i]),
    );
  }
}

class _AccordionTile extends StatefulWidget {
  final QaItem item;
  const _AccordionTile({required this.item});

  @override
  State<_AccordionTile> createState() => _AccordionTileState();
}

class _AccordionTileState extends State<_AccordionTile> with TickerProviderStateMixin {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.item.initiallyOpen;
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
      color: Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w700,
    );
    final bodyStyle = const TextStyle(
      color: Color(0xFFE9EAFF), fontSize: 15, height: 1.45,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x26FFFFFF), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              onPressed: () => setState(() => _open = !_open),
              minSize: 48, // gute Tap-Fläche
              child: Row(
                children: [
                  Expanded(child: Text(widget.item.question, style: titleStyle)),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _open ? 0.25 : 0.0, // Pfeil drehen
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(CupertinoIcons.chevron_right, color: Color(0xFFE9EAFF)),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: DefaultTextStyle(style: bodyStyle, child: widget.item.answer),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
