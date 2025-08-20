// lib/screens/research/study_builder_page.dart
import 'package:flutter/cupertino.dart';

class StudyBuilderPage extends StatefulWidget {
  final String studyId;
  const StudyBuilderPage({super.key, required this.studyId});

  @override
  State<StudyBuilderPage> createState() => _StudyBuilderPageState();
}

class _StudyBuilderPageState extends State<StudyBuilderPage> {
  final _titleCtrl = TextEditingController();
  final _goalCtrl  = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Studie einrichten'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Weiter zur Detailseite (du kannst auch Editor wählen)
            Navigator.of(context).pushNamed(
              '/research/study_detail',
              arguments: widget.studyId,
            );
          },
          child: const Text('Weiter'),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            const Text('Allgemein', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _Field(
              label: 'Titel',
              child: CupertinoTextField(
                controller: _titleCtrl,
                placeholder: 'z. B. Klartraum-Frequenz (2 Wochen)',
              ),
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Ziel',
              child: CupertinoTextField(
                controller: _goalCtrl,
                placeholder: 'Kurz das Studienziel beschreiben…',
                maxLines: 3,
              ),
            ),

            const SizedBox(height: 24),
            const Text('Module', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _NavTile(
              title: 'Fragebogen / Surveys',
              subtitle: 'Items, Skalen, Zeitpunkte festlegen',
              onTap: () => Navigator.of(context).pushNamed(
                '/research/survey_editor',
                arguments: widget.studyId,
              ),
            ),
            _NavTile(
              title: 'Teilnehmer & Einladungen',
              subtitle: 'Links, Codes, Tracking',
              onTap: () => Navigator.of(context).pushNamed(
                '/research/study_detail',
                arguments: widget.studyId,
              ),
            ),
            _NavTile(
              title: 'Pilot starten',
              subtitle: 'Testlauf durchführen',
              onTap: () => Navigator.of(context).pushNamed(
                '/research/run_survey',
                arguments: {
                  'studyId': widget.studyId,
                  'participantId': null,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: CupertinoColors.inactiveGray)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _NavTile({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: CupertinoListTile.notched(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(CupertinoIcons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
