import 'package:flutter/cupertino.dart';
import '../../prefs/first_run_prefs.dart';

class CoachBanner extends StatefulWidget {
  final String text;
  const CoachBanner({super.key, required this.text});
  @override State<CoachBanner> createState()=> _CoachBannerState();
}

class _CoachBannerState extends State<CoachBanner> {
  bool visible = false;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final seen = await FirstRunPrefs.isWissenCoachSeen();
    if (!seen && mounted) setState(()=> visible = true);
  }
  Future<void> _dismiss() async {
    await FirstRunPrefs.setWissenCoachSeen(true);
    if (mounted) setState(()=> visible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x1A000000)),
      ),
      child: Row(children: [
        const Icon(CupertinoIcons.lightbulb),
        const SizedBox(width: 10),
        Expanded(child: Text(widget.text)),
        CupertinoButton(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), onPressed: _dismiss, child: const Text('Okay')),
      ]),
    );
  }
}
