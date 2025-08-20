// lib/screens/research/study_list_page.dart
import 'package:flutter/cupertino.dart';
import '../../design/gradient_theme.dart';
import '../../models/research_models.dart';
import '../../services/research_repo.dart';

const _bg = Color(0xFF080B23);
const _white = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);
const _card = Color(0xFF0A0A23);

class StudyListPage extends StatefulWidget {
  const StudyListPage({super.key});

  @override
  State<StudyListPage> createState() => _StudyListPageState();
}

class _StudyListPageState extends State<StudyListPage> {
  final _repo = ResearchRepo.instance;

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
    setState(() {});
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final g = GradientTheme.of(GradientTheme.style.value);

    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Studien', style: TextStyle(color: _white)),
        backgroundColor: _bg,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _Hero(colors: g.primary),
            const SizedBox(height: 14),
            ..._repo.studies.map((s) => _StudyTile(study: s)),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: () async {
                final s = await _repo.createStudy(title: 'Neue Studie');
                if (!mounted) return;
                Navigator.of(context).pushNamed('/research/study_builder', arguments: s.id);
              },
              child: const Text('Neue Studie'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyTile extends StatelessWidget {
  final Study study;
  const _StudyTile({required this.study});

  @override
  Widget build(BuildContext context) {
    String status(StudyStatus st) => switch (st) {
          StudyStatus.draft => 'Entwurf',
          StudyStatus.recruiting => 'Rekrutierung',
          StudyStatus.active => 'Aktiv',
          StudyStatus.closed => 'Abgeschlossen',
        };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _stroke),
      ),
      child: CupertinoListTile.notched(
        title: Text(study.title, style: const TextStyle(color: _white, fontWeight: FontWeight.w700)),
        subtitle: Text('${status(study.status)} – ${study.goal.isEmpty ? 'ohne Ziel' : study.goal}',
            style: const TextStyle(color: _white)),
        trailing: const Icon(CupertinoIcons.chevron_right, color: _white),
        onTap: () => Navigator.of(context).pushNamed('/research/study_detail', arguments: study.id),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final List<Color> colors;
  const _Hero({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _stroke),
      ),
      child: const Text(
        'Führe eigene Mini-Studien durch. Rekrutiere Teilnehmer, sammle Antworten und exportiere die Daten.',
        style: TextStyle(color: _white, fontWeight: FontWeight.w700),
      ),
    );
  }
}
