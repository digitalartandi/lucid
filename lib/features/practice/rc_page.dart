// lib/features/practice/rc_page.dart
//
// Reality-Check: zählt echte Prüfungen und erklärt, wie sie gelingen.
import 'package:flutter/cupertino.dart';

import '../../core/practice_store.dart';
import '../../core/techniques.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';
import '../shell/app_shell.dart';
import 'practice_page.dart';

class RealityCheckPage extends StatelessWidget {
  const RealityCheckPage({super.key});

  static const List<String> _dow = <String>['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    final PracticeStore store = PracticeStore.instance;
    final Technique t = techniqueById('rc')!;
    return LPage(
      title: 'Reality-Check',
      child: AnimatedBuilder(
        animation: store,
        builder: (BuildContext context, Widget? _) {
          final List<MapEntry<DateTime, DayLog>> days = store.lastDays(7);
          int maxRc = 1;
          for (final MapEntry<DateTime, DayLog> d in days) {
            if (d.value.realityChecks > maxRc) maxRc = d.value.realityChecks;
          }
          final List<String> signs = store.profile.dreamSigns;
          return LScroll(
            children: <Widget>[
              Text('Träume ich gerade?', style: LT.display),
              const SizedBox(height: LS.sm),
              Text(
                'Stell die Frage so, als könnte die Antwort Ja sein. Die App führt dich in fünf Schritten durch eine saubere Prüfung.',
                style: LT.bodyMuted,
              ),
              const SizedBox(height: LS.xl),
              LButton(
                label: 'Geführten Check starten',
                icon: CupertinoIcons.hand_raised,
                onPressed: () => openRoute(context, '/practice/session', arg: 'rc', root: true),
              ),
              const SizedBox(height: LS.sm),
              LButton(
                label: 'Ich habe gerade selbst geprüft',
                kind: LButtonKind.quiet,
                onPressed: store.addRealityCheck,
              ),
              const LSection('Letzte 7 Tage'),
              LCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text('${store.today.realityChecks}', style: LT.number),
                        const SizedBox(width: LS.sm),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text('heute', style: LT.labelMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: LS.lg),
                    LBars(
                      values: <double>[for (final MapEntry<DateTime, DayLog> d in days) d.value.realityChecks / maxRc],
                      labels: <String>[for (final MapEntry<DateTime, DayLog> d in days) _dow[d.key.weekday - 1]],
                    ),
                  ],
                ),
              ),
              const LSection('Gute Anlässe'),
              if (signs.isEmpty)
                LCard(
                  onTap: () => openRoute(context, '/practice/signs'),
                  child: Row(
                    children: <Widget>[
                      const LIconDot(CupertinoIcons.tag),
                      const SizedBox(width: LS.md),
                      Expanded(
                        child: Text(
                          'Leg deine Traumzeichen an. Dann prüfst du genau dort, wo es im Traum zählt.',
                          style: LT.label.copyWith(height: 1.4),
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_right, size: 16, color: LC.faint),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: LS.sm,
                  runSpacing: LS.sm,
                  children: <Widget>[
                    for (final String s in signs) LChip(label: s),
                    const LChip(label: 'Nach dem Aufwachen'),
                    const LChip(label: 'Etwas wirkt seltsam'),
                  ],
                ),
              const SizedBox(height: LS.lg),
              LGroup(
                children: <Widget>[
                  LRow(
                    icon: CupertinoIcons.bell,
                    title: 'Erinnerungen',
                    subtitle: 'Leiser Ton zu festen Zeiten, solange die App offen ist',
                    onTap: () => openRoute(context, '/rc'),
                  ),
                  LRow(
                    icon: CupertinoIcons.doc_text,
                    title: 'Anleitung und Studienlage',
                    onTap: () => openRoute(context, '/practice/technique', arg: 'rc'),
                  ),
                ],
              ),
              const SizedBox(height: LS.lg),
              Row(
                children: <Widget>[
                  EvidenceBadge(t.evidence),
                  const SizedBox(width: LS.sm),
                  Expanded(
                    child: Text('Wirkt als Begleiter von MILD und SSILD, nicht allein.', style: LT.caption),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
