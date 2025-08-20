// lib/screens/research/study_detail_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../models/research_models.dart';
import '../../services/research_repo.dart';

// ---- Farben / Tokens (kontrastreich) ----
const _bg       = Color(0xFF080B23);
const _white    = Color(0xFFFFFFFF);
const _muted    = Color(0xFFCCD4FF);   // Untertitel/Erklärtext
const _label    = Color(0xFF9FA9D6);   // Labels
const _stroke   = Color(0x33FFFFFF);   // Hairline
const _card     = Color(0xFF111631);   // Panel
const _cardHi   = Color(0xFF171C3F);   // Hervorhebung/Thumb
const _accent   = Color(0xFF7A6CFF);

// ---- TextStyles ----
const _tTitle = TextStyle(color: _white, fontWeight: FontWeight.w700, fontSize: 16, height: 1.2);
const _tBody  = TextStyle(color: _muted,  fontSize: 14, height: 1.25);
const _tLabel = TextStyle(color: _label,  fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: .2);

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
        border: const Border(bottom: BorderSide(color: _stroke, width: .5)),
        middle: Text(s.title, style: const TextStyle(color: _white)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pushNamed(
            '/research/study_builder',
            arguments: s.id,
          ),
          child: const Text('Bearbeiten', style: TextStyle(color: _white)),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Kontraststarker Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _stroke, width: .8),
                ),
                child: CupertinoSlidingSegmentedControl<int>(
                  backgroundColor: _card,
                  thumbColor: _cardHi,
                  groupValue: _tab,
                  onValueChanged: (v) => setState(() => _tab = v ?? 0),
                  children: {
                    0: _seg('Übersicht', selected: _tab == 0),
                    1: _seg('Teilnehmer', selected: _tab == 1),
                    2: _seg('Datenerhebung', selected: _tab == 2),
                    3: _seg('Export', selected: _tab == 3),
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Inhalte
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

  Widget _seg(String label, {required bool selected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? _white : _label,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: .2,
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
        _Card(child: Text('Status: ${st(s.status)}', style: _tBody)),
        const SizedBox(height: 10),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ziel', style: _tTitle),
              const SizedBox(height: 6),
              Text(s.goal.isEmpty ? '—' : s.goal, style: _tBody),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Einverständniserklärung', style: _tTitle),
              const SizedBox(height: 6),
              Text(s.consent.isEmpty ? '—' : s.consent, style: _tBody),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Aufgaben', style: _tTitle),
              const SizedBox(height: 6),
              Text(
                s.tasks.isEmpty ? '—' : s.tasks.map((e) => e.name).join(', '),
                style: _tBody,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (s.survey != null)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fragebogen', style: _tTitle),
                const SizedBox(height: 6),
                Text(
                  '${s.survey!.title} · ${s.survey!.questions.length} Fragen',
                  style: _tBody,
                ),
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
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: _cardHi,
          borderRadius: BorderRadius.circular(12),
          onPressed: () async {
            await ResearchRepo.instance.addParticipant(s.id);
          },
          child: const Text('Teilnehmer hinzufügen', style: TextStyle(color: _white)),
        ),
        const SizedBox(height: 12),
        ...s.participants.map(
          (p) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _stroke, width: .8),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))],
            ),
            child: CupertinoListTile(
              title: Text(p.code, style: const TextStyle(color: _white, fontWeight: FontWeight.w700)),
              subtitle: Text(p.note ?? '—', style: const TextStyle(color: _muted)),
              trailing: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: const Color(0xFF5A2C2C),
                borderRadius: BorderRadius.circular(10),
                onPressed: () => ResearchRepo.instance.removeParticipant(s.id, p.id),
                child: const Text('Entfernen', style: TextStyle(color: _white)),
              ),
            ),
          ),
        ),
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
          const _Card(child: Text('Kein Fragebogen definiert.', style: _tBody))
        else
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fragebogen: ${s.survey!.title}', style: _tTitle),
                const SizedBox(height: 10),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: _cardHi,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/research/run_survey',
                    arguments: {
                      'studyId': s.id,
                      'participantId': s.participants.isEmpty ? null : s.participants.first.id,
                    },
                  ),
                  child: const Text(
                    'Antwort erfassen (ohne Auswahl → anonym)',
                    style: TextStyle(color: _white),
                  ),
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
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      children: [
        _Card(child: Text('Antworten: ${s.responses.length}', style: _tBody)),
        const SizedBox(height: 12),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: _accent,
          borderRadius: BorderRadius.circular(12),
          onPressed: () => copy(csv),
          child: const Text('CSV kopieren', style: TextStyle(color: _white, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: _cardHi,
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
        border: Border.all(color: _stroke, width: .8),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: child,
    );
  }
}
