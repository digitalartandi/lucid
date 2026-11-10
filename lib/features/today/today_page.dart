// lib/features/today/today_page.dart
//
// "Heute": eine Sache, die jetzt dran ist, darunter der Tagesplan.
import 'package:flutter/cupertino.dart';

import '../../core/practice_store.dart';
import '../../core/program.dart';
import '../../models/journal_models.dart';
import '../../services/journal_repo.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';
import '../shell/app_shell.dart';

enum _Phase { morning, day, evening }

_Phase _phaseFor(DateTime now) {
  final int h = now.hour;
  if (h >= 4 && h < 11) return _Phase.morning;
  if (h >= 11 && h < 18) return _Phase.day;
  return _Phase.evening;
}

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final PracticeStore _store = PracticeStore.instance;
  final JournalRepo _journal = JournalRepo.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);
    _journal.revision.addListener(_refresh);
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    _journal.revision.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  bool _journalToday() {
    final String key = dayKey(DateTime.now());
    for (final JournalIndexItem e in _journal.snapshot) {
      if (dayKey(e.date) == key) return true;
    }
    return false;
  }

  bool _isDone(ProgramTask t, DayLog log) {
    if (log.doneTasks.contains(t.id)) return true;
    if (t.route == '/journal/new') return _journalToday() || log.recall == 0;
    if (t.route == '/practice/rc') return log.realityChecks >= (t.minutes >= 2 ? 2 : 1);
    if (t.route == '/practice/session' && t.arg is String) {
      final String id = t.arg! as String;
      if (id == 'recall') return false;
      return log.techniques.contains(id);
    }
    if (t.route == '/night') return log.techniques.contains('wbtb');
    return false;
  }

  Future<void> _open(ProgramTask t) async {
    if (t.route == null) return;
    await openRoute(context, t.route!, arg: t.arg, root: t.rootNavigator);
    // Lese- und Ansichtsaufgaben gelten nach dem Öffnen als erledigt.
    if (t.route == '/wissen/article' ||
        t.route == '/practice/technique' ||
        t.route == '/insights' ||
        t.route == '/practice/signs' ||
        t.route == '/practice/intention' ||
        (t.route == '/practice/session' && t.arg == 'recall')) {
      await _store.setTaskDone(t.id, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final _Phase phase = _phaseFor(now);
    final int day = _store.programDay(now: now);
    final ProgramDay plan = programDayFor(day, lightSleeper: _store.profile.lightSleeper);
    final DayLog log = _store.today;

    final String greeting = switch (phase) {
      _Phase.morning => 'Guten Morgen',
      _Phase.day => 'Hallo',
      _Phase.evening => 'Guten Abend',
    };
    final String sub = day <= programLength
        ? 'Tag $day von $programLength, Woche ${plan.week.number}: ${plan.week.title}'
        : plan.week.title;

    final List<ProgramTask> tasks = List<ProgramTask>.from(plan.tasks)
      ..sort((ProgramTask a, ProgramTask b) => a.slot.index.compareTo(b.slot.index));
    final int done = tasks.where((ProgramTask t) => _isDone(t, log)).length;

    return LPage(
      child: LScroll(
        children: <Widget>[
          LHeader(
            title: greeting,
            subtitle: sub,
            trailing: LTap(
              onTap: () => openRoute(context, '/settings'),
              semanticLabel: 'Einstellungen',
              child: const LIconDot(CupertinoIcons.gear, color: LC.muted),
            ),
          ),
          _NowCard(
            phase: phase,
            log: log,
            plan: plan,
            journalToday: _journalToday(),
            onJournal: () => openRoute(context, '/journal/new'),
            onNoRecall: () => _store.setRecall(0),
            onRc: () => openRoute(context, '/practice/rc'),
            onNight: () => openRoute(context, '/night', root: true),
            onEveningSession: (String id) =>
                openRoute(context, '/practice/session', arg: id, root: true),
          ),
          LSection('Heute', actionLabel: 'Ganzes Programm', onAction: () => openRoute(context, '/program')),
          LCard(
            padding: const EdgeInsets.all(LS.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(plan.focusTitle, style: LT.heading),
                          const SizedBox(height: 4),
                          Text(plan.focusText, style: LT.label.copyWith(color: LC.muted, height: 1.45)),
                        ],
                      ),
                    ),
                    const SizedBox(width: LS.md),
                    LRing(
                      value: tasks.isEmpty ? 0 : done / tasks.length,
                      color: done == tasks.length && tasks.isNotEmpty ? LC.mint : LC.iris,
                      child: Text('$done/${tasks.length}', style: LT.caption.copyWith(color: LC.text)),
                    ),
                  ],
                ),
                const SizedBox(height: LS.md),
                Container(height: 1, color: LC.line),
                for (final ProgramTask t in tasks)
                  _TaskRow(
                    task: t,
                    done: _isDone(t, log),
                    onOpen: () => _open(t),
                    onToggle: () => _store.setTaskDone(t.id, !log.doneTasks.contains(t.id)),
                  ),
              ],
            ),
          ),
          const LSection('Deine Woche'),
          _WeekCard(store: _store, journal: _journal, onOpen: () => openRoute(context, '/insights')),
        ],
      ),
    );
  }
}

class _NowCard extends StatelessWidget {
  const _NowCard({
    required this.phase,
    required this.log,
    required this.plan,
    required this.journalToday,
    required this.onJournal,
    required this.onNoRecall,
    required this.onRc,
    required this.onNight,
    required this.onEveningSession,
  });

  final _Phase phase;
  final DayLog log;
  final ProgramDay plan;
  final bool journalToday;
  final VoidCallback onJournal;
  final VoidCallback onNoRecall;
  final VoidCallback onRc;
  final VoidCallback onNight;
  final ValueChanged<String> onEveningSession;

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final String title;
    late final String text;
    late final List<Widget> actions;
    Color tone = LC.iris;

    switch (phase) {
      case _Phase.morning:
        icon = CupertinoIcons.sunrise;
        tone = LC.moon;
        if (journalToday) {
          title = 'Traum festgehalten';
          text = 'Gut. Fällt dir später noch etwas ein, ergänze es im Journal.';
          actions = <Widget>[
            LButton(label: 'Noch einen Traum notieren', kind: LButtonKind.secondary, onPressed: onJournal),
          ];
        } else if (log.recall == 0) {
          title = 'Heute keine Erinnerung';
          text = 'Das gehört dazu. Bleib morgen nach dem Aufwachen einen Moment still liegen.';
          actions = <Widget>[
            LButton(label: 'Doch etwas eingefallen', kind: LButtonKind.secondary, onPressed: onJournal),
          ];
        } else {
          title = 'Was hast du geträumt?';
          text = 'Halte es fest, bevor der Tag es überschreibt. Stichworte genügen.';
          actions = <Widget>[
            LButton(label: 'Traum notieren', kind: LButtonKind.moon, icon: CupertinoIcons.pencil, onPressed: onJournal),
            const SizedBox(height: LS.sm),
            LButton(label: 'Nichts erinnert', kind: LButtonKind.quiet, onPressed: onNoRecall),
          ];
        }
        break;
      case _Phase.day:
        icon = CupertinoIcons.eye;
        title = 'Träumst du gerade?';
        text = log.realityChecks == 0
            ? 'Halte kurz inne und prüfe es ernsthaft. Eine echte Prüfung ist mehr wert als zehn nebenbei.'
            : 'Heute geprüft: ${log.realityChecks} Mal. Der nächste Anlass: etwas, das dir seltsam vorkommt.';
        actions = <Widget>[
          LButton(label: 'Reality-Check machen', icon: CupertinoIcons.hand_raised, onPressed: onRc),
        ];
        break;
      case _Phase.evening:
        icon = CupertinoIcons.moon_stars;
        if (plan.wbtbNight) {
          title = 'Heute ist eine Übungsnacht';
          text =
              'Der Nachtmodus weckt dich nach fünf bis sechs Stunden und führt dich durch Notiz und Technik. Nur, wenn du morgen ausschlafen kannst.';
          actions = <Widget>[
            LButton(label: 'Nachtmodus einrichten', icon: CupertinoIcons.moon_zzz, onPressed: onNight),
            const SizedBox(height: LS.sm),
            LButton(
              label: 'Heute lieber nur MILD',
              kind: LButtonKind.quiet,
              onPressed: () => onEveningSession('mild'),
            ),
          ];
        } else if (plan.week.number == 1) {
          title = 'Vor dem Einschlafen';
          text = 'Eine Minute: Du nimmst dir vor, dich morgen an deinen Traum zu erinnern.';
          actions = <Widget>[
            LButton(label: 'Abend-Absicht starten', onPressed: () => onEveningSession('recall')),
          ];
        } else {
          title = 'Vor dem Einschlafen';
          text = 'Fünf Minuten MILD: Traum erinnern, Absicht setzen, klar werden im Kopf. Dann loslassen.';
          actions = <Widget>[
            LButton(label: 'MILD starten', onPressed: () => onEveningSession('mild')),
            const SizedBox(height: LS.sm),
            LButton(label: 'Nachtmodus öffnen', kind: LButtonKind.quiet, onPressed: onNight),
          ];
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.all(LS.xl),
      decoration: BoxDecoration(
        borderRadius: LRad.lg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.alphaBlend(tone.withValues(alpha: 0.16), LC.surface),
            LC.surface,
          ],
        ),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(alignment: Alignment.centerLeft, child: Icon(icon, color: tone, size: 28)),
          const SizedBox(height: LS.md),
          Text(title, style: LT.title),
          const SizedBox(height: LS.sm),
          Text(text, style: LT.bodyMuted),
          const SizedBox(height: LS.xl),
          ...actions,
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.done,
    required this.onOpen,
    required this.onToggle,
  });

  final ProgramTask task;
  final bool done;
  final VoidCallback onOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: LS.md),
      child: Row(
        children: <Widget>[
          LTap(
            onTap: onToggle,
            semanticLabel: done ? 'Als offen markieren' : 'Als erledigt markieren',
            child: Padding(
              padding: const EdgeInsets.only(right: LS.md, top: 4, bottom: 4),
              child: Icon(
                done ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                color: done ? LC.mint : LC.faint,
                size: 26,
              ),
            ),
          ),
          Expanded(
            child: LTap(
              onTap: onOpen,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          task.title,
                          style: LT.heading.copyWith(
                            fontSize: 16,
                            color: done ? LC.muted : LC.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('${slotLabel(task.slot)}, ${task.minutes} Min. ${task.detail}',
                            style: LT.caption),
                      ],
                    ),
                  ),
                  const Icon(CupertinoIcons.chevron_right, size: 16, color: LC.faint),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.store, required this.journal, required this.onOpen});

  final PracticeStore store;
  final JournalRepo journal;
  final VoidCallback onOpen;

  static const List<String> _dow = <String>['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<DateTime, DayLog>> days = store.lastDays(7);
    final Set<String> lucidDays = <String>{};
    final Set<String> dreamDays = <String>{};
    int lucidTotal = 0;
    for (final JournalIndexItem e in journal.snapshot) {
      dreamDays.add(dayKey(e.date));
      if (e.lucid) {
        lucidTotal++;
        lucidDays.add(dayKey(e.date));
      }
    }
    final double? recall = store.recallRate(7);
    final int streak = store.streak();

    return LCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              for (final MapEntry<DateTime, DayLog> d in days)
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lucidDays.contains(dayKey(d.key))
                              ? LC.moon
                              : (d.value.hasActivity || dreamDays.contains(dayKey(d.key))
                                  ? LC.irisSoft
                                  : LC.transparent),
                          border: Border.all(
                            color: lucidDays.contains(dayKey(d.key))
                                ? LC.moon
                                : (d.value.hasActivity || dreamDays.contains(dayKey(d.key))
                                    ? LC.iris
                                    : LC.line),
                          ),
                        ),
                        child: lucidDays.contains(dayKey(d.key))
                            ? const Icon(CupertinoIcons.sparkles, size: 14, color: LC.night)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(_dow[d.key.weekday - 1], style: LT.caption),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: LS.lg),
          Row(
            children: <Widget>[
              _Stat(
                value: recall == null ? '–' : '${(recall * 100).round()} %',
                label: 'Traumerinnerung',
              ),
              _Stat(value: '$lucidTotal', label: 'Klarträume', color: LC.moon),
              _Stat(value: '$streak', label: streak == 1 ? 'Tag in Folge' : 'Tage in Folge'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.color = LC.text});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: LT.number.copyWith(color: color, fontSize: 24)),
          const SizedBox(height: 4),
          Text(label, style: LT.caption),
        ],
      ),
    );
  }
}
