// lib/features/practice/program_page.dart
//
// Das ganze Programm auf einen Blick, mit der Begründung je Woche.
import 'package:flutter/cupertino.dart';

import '../../core/practice_store.dart';
import '../../core/program.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';

class ProgramPage extends StatelessWidget {
  const ProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PracticeStore store = PracticeStore.instance;
    return LPage(
      title: 'Programm',
      child: AnimatedBuilder(
        animation: store,
        builder: (BuildContext context, Widget? _) {
          final int today = store.programDay();
          final bool light = store.profile.lightSleeper;
          return LScroll(
            children: <Widget>[
              LHero(
                image: LImg.door,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 96),
                    Text('Vier Wochen, ein Schritt nach dem anderen',
                        style: LT.display.copyWith(fontSize: 32)),
                    const SizedBox(height: LS.sm),
                    Text(
                      today > programLength
                          ? 'Du hast das Programm durchlaufen und bist im freien Üben.'
                          : 'Du bist an Tag $today von $programLength.',
                      style: LT.body.copyWith(color: const Color(0xFFD5D8F5)),
                    ),
                  ],
                ),
              ),
              for (final ProgramWeek w in programWeeks) ...<Widget>[
                LSection('Woche ${w.number}: ${w.title}'),
                Text(w.goal, style: LT.body),
                const SizedBox(height: LS.sm),
                LNote(text: w.why, icon: CupertinoIcons.lab_flask),
                const SizedBox(height: LS.md),
                LGroup(
                  children: <Widget>[
                    for (int d = (w.number - 1) * 7 + 1; d <= w.number * 7; d++)
                      _DayRow(
                        plan: programDayFor(d, lightSleeper: light),
                        state: d < today ? 0 : (d == today ? 1 : 2),
                      ),
                  ],
                ),
              ],
              const LSection('Danach: freies Üben'),
              Text(maintenanceWeek.goal, style: LT.body),
              const SizedBox(height: LS.xl),
              LButton(
                label: 'Programm neu beginnen',
                kind: LButtonKind.quiet,
                onPressed: () async {
                  final bool ok = await confirmL(
                    context,
                    title: 'Programm neu beginnen?',
                    message: 'Der Plan startet wieder bei Tag 1. Journal und Auswertung bleiben erhalten.',
                    confirmLabel: 'Neu beginnen',
                  );
                  if (ok) await store.restartProgram();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.plan, required this.state});
  final ProgramDay plan;

  /// 0 vorbei, 1 heute, 2 kommt noch.
  final int state;

  @override
  Widget build(BuildContext context) {
    final Color c = state == 1 ? LC.iris : (state == 0 ? LC.faint : LC.muted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LS.md),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 34,
            child: Text('${plan.day}', style: LT.heading.copyWith(color: c)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  plan.focusTitle,
                  style: LT.heading.copyWith(fontSize: 16, color: state == 0 ? LC.muted : LC.text),
                ),
                const SizedBox(height: 2),
                Text('${plan.minutes} Min.', style: LT.caption),
              ],
            ),
          ),
          if (plan.wbtbNight) const LBadge('Übungsnacht', color: LC.moon, background: LC.moonSoft),
          if (state == 1) ...<Widget>[
            const SizedBox(width: LS.sm),
            const LBadge('Heute'),
          ],
        ],
      ),
    );
  }
}
