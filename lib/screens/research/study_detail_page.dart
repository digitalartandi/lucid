// lib/screens/research/study_detail_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../models/research_models.dart';
import '../../services/research_repo.dart';

const _bg = Color(0xFF080B23);
const _white = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);
const _card = Color(0xFF0A0A23);

class StudyDetailPage extends StatefulWidget {
  final String studyId;
  const StudyDetailPage({super.key, required this.studyId});

  @override
  State<StudyDetailPage> createState() => _StudyDetailPageState();
}

class _StudyDetailPageState extends State<StudyDetailPage> {
  int _tab = 0;
  late Study s;

  @override
  void initState() {
    super.initState();
    s = ResearchRepo.instance.studies.firstWhere((e) => e.id == widget.studyId);
    ResearchRepo.instance.revision.addListener(_refresh);
  }

  @override
  void dispose() {
    ResearchRepo.instance.revision.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {
        s = ResearchRepo.instance.studies.firstWhere((e) => e.id == widget.studyId);
      });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: Text(s.title, style: const TextStyle(color: _white)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pushNamed('/research/study_builder', arguments: s.id),
          child: const Text('Bearbeiten', style: TextStyle(color: _white)),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _tab,
                children: const {
                  0: Text('Übersicht'),
                  1: Text('Teilnehmer'),
                  2: Text('Datenerhebung'),
                  3: Text('Export'),
                },
                onValueChanged: (v) => setState(() => _tab = v ?? 0),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _OverviewTab(s: s),
                  _ParticipantsTab(s: s),
                  _CollectTab(s: s),
                  _ExportTab(s: s),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Study s;
  const _OverviewTab({required this.s});

  @override
  Widget build(BuildContext context) {
    String st(StudyStatus ss) => switch (ss) {
          StudyStatus.draft => 'Entwurf',
          StudyStatus.recruiting => 'Rekrutierung',
          StudyStatus.active => 'Aktiv',
          StudyStatus.closed => 'Abgeschlossen',
        };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      children: [
        _Card(child: Text('Status: ${st(s.status)}', style: const TextStyle(color: _white))),
        const SizedBox(height: 10),
        _Card(child: Text('Ziel:\n${s.goal.isEmpty ? '—' : s.goal}', style: const TextStyle(color: _white))),
        const SizedBox(height: 10),
        _Card(child: Text('Einverständniserklärung:\n${s.consent.isEmpty ? '—' : s.consent}', style: const TextStyle(color: _white))),
        const SizedBox(height: 10),
        _Card(child: Text('Aufgaben: ${s.tasks.map((e) => e.name).join(', ')}', style: const TextStyle(color: _white))),
        const SizedBox(height: 10),
        if (s.survey != null)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fragebogen', style: TextStyle(color: _white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('${s.survey!.title} · ${s.survey!.questions.length} Fragen', style: const TextStyle(color: _white)),
              ],
            ),
          ),
      ],
    );
  }
}

class _ParticipantsTab extends StatefulWidget {
  final Study s;
  const _ParticipantsTab({required this.s});

  @override
  State<_ParticipantsTab> createState() => _ParticipantsTabState();
}

class _ParticipantsTabState extends State<_ParticipantsTab> {
  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      children: [
        CupertinoButton.filled(
          borderRadius: BorderRadius.circular(12),
          onPressed: () async {
            await ResearchRepo.instance.addParticipant(s.id);
          },
          child: const Text('Teilnehmer hinzufügen'),
        ),
        const SizedBox(height: 10),
        ...s.participants.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _stroke),
              ),
              child: CupertinoListTile(
                title: Text(p.code, style: const TextStyle(color: _white, fontWeight: FontWeight.w700)),
                subtitle: Text(p.note ?? '—', style: const TextStyle(color: _white)),
                trailing: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  color: const Color(0xFF402D2D),
                  borderRadius: BorderRadius.circular(10),
                  onPressed: () => ResearchRepo.instance.removeParticipant(s.id, p.id),
                  child: const Text('Entfernen', style: TextStyle(color: _white)),
                ),
              ),
            )),
      ],
    );
  }
}

class _CollectTab extends StatelessWidget {
  final Study s;
  const _CollectTab({required this.s});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      children: [
        if (s.survey == null)
          const _Card(child: Text('Kein Fragebogen definiert.', style: TextStyle(color: _white)))
        else
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fragebogen: ${s.survey!.title}', style: const TextStyle(color: _white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                CupertinoButton(
                  color: const Color(0xFF242742),
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => Navigator.of(context).pushNamed('/research/run_survey', arguments: {
                    'studyId': s.id,
                    'participantId': s.participants.isEmpty ? null : s.participants.first.id,
                  }),
                  child: const Text('Antwort erfassen (ohne Auswahl → anonym)', style: TextStyle(color: _white)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ExportTab extends StatelessWidget {
  final Study s;
  const _ExportTab({required this.s});

  @override
  Widget build(BuildContext context) {
    final csv = ResearchRepo.instance.toCsv(s);
    final json = s.encode();

    Future<void> copy(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      // ignore: use_build_context_synchronously
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Kopiert'),
          content: const Text('Inhalt in Zwischenablage kopiert.'),
          actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.of(context).pop())],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      children: [
        _Card(child: Text('Antworten: ${s.responses.length}', style: const TextStyle(color: _white))),
        const SizedBox(height: 10),
        CupertinoButton.filled(
          borderRadius: BorderRadius.circular(12),
          onPressed: () => copy(csv),
          child: const Text('CSV kopieren'),
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          color: const Color(0xFF242742),
          borderRadius: BorderRadius.circular(12),
          onPressed: () => copy(json),
          child: const Text('JSON kopieren', style: TextStyle(color: _white)),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _stroke),
      ),
      child: child,
    );
  }
}
