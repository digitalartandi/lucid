// lib/screens/journal/widgets/journal_recent_widget.dart
import 'package:flutter/cupertino.dart';
import '../../../services/journal_repo.dart';
import '../../../models/journal_models.dart';

class JournalRecentWidget extends StatefulWidget {
  const JournalRecentWidget({super.key});

  @override
  State<JournalRecentWidget> createState() => _JournalRecentWidgetState();
}

class _JournalRecentWidgetState extends State<JournalRecentWidget> {
  final _repo = JournalRepo.instance;
  List<JournalIndexItem> _recent = [];
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _init();
    _repo.revision.addListener(_refresh);
  }

  @override
  void dispose() {
    _repo.revision.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _init() async {
    await _repo.init();
    await _refresh();
  }

  Future<void> _refresh() async {
    final c = await _repo.count();
    final r = await _repo.latest(count: 3);
    if (!mounted) return;
    setState(() { _count = c; _recent = r; });
  }

  @override
  Widget build(BuildContext context) {
    final title = const Color(0xFFE9EAFF);
    final hairline = const Color(0x22FFFFFF);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF141321), Color(0xFF0E0D18)],
        ),
        border: Border.all(color: hairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Journal – $_count Einträge', style: TextStyle(color: title, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (_recent.isEmpty)
            Text('Noch keine Einträge', style: TextStyle(color: title.withOpacity(0.7), fontSize: 14))
          else
            ..._recent.map((it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      it.title.isEmpty ? 'Ohne Titel' : it.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: title, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(_fmt(it.date), style: TextStyle(color: title.withOpacity(0.7), fontSize: 13)),
                ],
              ),
            )),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year} ${_two(d.hour)}:${_two(d.minute)}';
  String _two(int x) => x < 10 ? '0$x' : '$x';
}
