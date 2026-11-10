// lib/features/onboarding/onboarding_page.dart
//
// Einstieg in fünf kurzen Schritten: worum es geht, wo du stehst,
// wann du schläfst, was zu beachten ist, wie der Plan aussieht.
import 'package:flutter/cupertino.dart';

import '../../core/practice_store.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const int _steps = 5;
  final PageController _pages = PageController();
  final Profile _draft = Profile();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() => _index = i);
    _pages.animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    final PracticeStore store = PracticeStore.instance;
    store.profile
      ..experience = _draft.experience
      ..goal = _draft.goal
      ..bedHour = _draft.bedHour
      ..bedMinute = _draft.bedMinute
      ..wakeHour = _draft.wakeHour
      ..wakeMinute = _draft.wakeMinute
      ..lightSleeper = _draft.lightSleeper;
    await store.completeOnboarding();
  }

  Future<void> _pickTime({required bool bed}) async {
    final DateTime initial = DateTime(
      2024,
      1,
      1,
      bed ? _draft.bedHour : _draft.wakeHour,
      bed ? _draft.bedMinute : _draft.wakeMinute,
    );
    DateTime picked = initial;
    await showLSheet<void>(
      context,
      builder: (BuildContext ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(bed ? 'Wann gehst du meist schlafen?' : 'Wann stehst du meist auf?',
              style: LT.title),
          SizedBox(
            height: 180,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              minuteInterval: 5,
              initialDateTime: initial.subtract(Duration(minutes: initial.minute % 5)),
              onDateTimeChanged: (DateTime d) => picked = d,
            ),
          ),
          const SizedBox(height: LS.md),
          LButton(label: 'Übernehmen', onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    );
    setState(() {
      if (bed) {
        _draft.bedHour = picked.hour;
        _draft.bedMinute = picked.minute - picked.minute % 5;
      } else {
        _draft.wakeHour = picked.hour;
        _draft.wakeMinute = picked.minute - picked.minute % 5;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool last = _index == _steps - 1;
    return LPage(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(LS.page, LS.lg, LS.page, 0),
            child: Row(
              children: <Widget>[
                if (_index > 0)
                  LTap(
                    onTap: () => _go(_index - 1),
                    semanticLabel: 'Zurück',
                    child: const Padding(
                      padding: EdgeInsets.only(right: LS.md),
                      child: Icon(CupertinoIcons.chevron_left, color: LC.muted, size: 22),
                    ),
                  ),
                Expanded(child: _Progress(index: _index, count: _steps)),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pages,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                _stepWelcome(),
                _stepExperience(),
                _stepSleep(),
                _stepSafety(),
                _stepPlan(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              LS.page,
              LS.md,
              LS.page,
              LS.xl + MediaQuery.of(context).padding.bottom,
            ),
            child: LButton(
              label: last ? 'Programm starten' : 'Weiter',
              onPressed: last ? _finish : () => _go(_index + 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _frame({required String title, required String lead, required List<Widget> children}) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(LS.page, LS.xxl, LS.page, LS.xl),
      children: <Widget>[
        Text(title, style: LT.display),
        const SizedBox(height: LS.md),
        Text(lead, style: LT.bodyMuted),
        const SizedBox(height: LS.xl),
        ...children,
      ],
    );
  }

  Widget _stepWelcome() {
    return _frame(
      title: 'Wach werden, während du träumst.',
      lead:
          'In einem Klartraum weißt du, dass du träumst. Etwa jeder Zweite erlebt das mindestens einmal im Leben. Es lässt sich üben.',
      children: const <Widget>[
        _Point(
          icon: CupertinoIcons.book,
          title: 'Erinnern',
          text: 'Du hältst morgens deine Träume fest. Das ist die Grundlage für alles Weitere.',
        ),
        _Point(
          icon: CupertinoIcons.sparkles,
          title: 'Absicht setzen',
          text: 'Du lernst MILD, die in Studien wirksamste Technik, und später SSILD.',
        ),
        _Point(
          icon: CupertinoIcons.moon_stars,
          title: 'Die Morgenstunden nutzen',
          text: 'An wenigen Nächten führt dich die App durch eine kurze Wachphase.',
        ),
      ],
    );
  }

  Widget _stepExperience() {
    const List<String> exp = <String>['Noch nie', 'Ein paar Mal', 'Regelmäßig'];
    const Map<String, String> goals = <String, String>{
      'explore': 'Neugier und Erleben',
      'nightmares': 'Albträume verändern',
      'creativity': 'Ideen und Kreativität',
      'skills': 'Fähigkeiten üben',
    };
    return _frame(
      title: 'Wo stehst du?',
      lead: 'Das Programm passt Ton und Tempo daran an.',
      children: <Widget>[
        Text('Hattest du schon einen Klartraum?', style: LT.heading),
        const SizedBox(height: LS.md),
        Wrap(
          spacing: LS.sm,
          runSpacing: LS.sm,
          children: <Widget>[
            for (int i = 0; i < exp.length; i++)
              LChip(
                label: exp[i],
                selected: _draft.experience == i,
                onTap: () => setState(() => _draft.experience = i),
              ),
          ],
        ),
        const SizedBox(height: LS.xl),
        Text('Was reizt dich am meisten?', style: LT.heading),
        const SizedBox(height: LS.md),
        Wrap(
          spacing: LS.sm,
          runSpacing: LS.sm,
          children: <Widget>[
            for (final MapEntry<String, String> g in goals.entries)
              LChip(
                label: g.value,
                selected: _draft.goal == g.key,
                onTap: () => setState(() => _draft.goal = g.key),
              ),
          ],
        ),
        if (_draft.goal == 'nightmares') ...<Widget>[
          const SizedBox(height: LS.lg),
          const LNote(
            text:
                'Bei häufigen oder belastenden Albträumen ist die Imagery-Rehearsal-Therapie die empfohlene Behandlung. Klarträumen kann ergänzen, ersetzt aber keine Therapie.',
          ),
        ],
      ],
    );
  }

  Widget _stepSleep() {
    final int mins = _draft.sleepMinutes;
    final String dur = '${mins ~/ 60} h ${(mins % 60).toString().padLeft(2, '0')} min';
    return _frame(
      title: 'Dein Schlaf',
      lead:
          'Klarträume entstehen vor allem in den langen Traumphasen am Morgen. Die App plant Wachphasen passend zu deinen Zeiten.',
      children: <Widget>[
        LGroup(
          children: <Widget>[
            LRow(
              icon: CupertinoIcons.moon,
              title: 'Schlafenszeit',
              trailing: Text(hhmm(_draft.bedHour, _draft.bedMinute),
                  style: LT.heading.copyWith(color: LC.iris)),
              onTap: () => _pickTime(bed: true),
            ),
            LRow(
              icon: CupertinoIcons.sunrise,
              iconColor: LC.moon,
              title: 'Aufstehen',
              trailing: Text(hhmm(_draft.wakeHour, _draft.wakeMinute),
                  style: LT.heading.copyWith(color: LC.iris)),
              onTap: () => _pickTime(bed: false),
            ),
          ],
        ),
        const SizedBox(height: LS.md),
        Text('Geplante Schlafdauer: $dur', style: LT.labelMuted),
        if (mins < 7 * 60) ...<Widget>[
          const SizedBox(height: LS.md),
          const LNote(
            tone: LC.rose,
            icon: CupertinoIcons.exclamationmark_triangle,
            text:
                'Unter sieben Stunden bleibt wenig Raum für die Traumphasen am Morgen. Wenn möglich, plane an Übungsnächten mehr Schlaf ein.',
          ),
        ],
        const SizedBox(height: LS.xl),
        LCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Ich schlafe leicht oder schlecht wieder ein', style: LT.heading.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('Dann plant die App keine Wecker-Nächte.', style: LT.labelMuted),
                  ],
                ),
              ),
              const SizedBox(width: LS.md),
              LSwitch(
                value: _draft.lightSleeper,
                onChanged: (bool v) => setState(() => _draft.lightSleeper = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepSafety() {
    return _frame(
      title: 'Bevor du anfängst',
      lead:
          'Für die meisten gesunden Erwachsenen gilt Klarträumen als unbedenklich. Drei Dinge solltest du wissen.',
      children: const <Widget>[
        _Point(
          icon: CupertinoIcons.bed_double,
          title: 'Schlaf geht vor',
          text:
              'Techniken mit Wecker kosten Schlaf. Die App begrenzt sie auf zwei bis drei Nächte pro Woche. Bei Schlafproblemen lass sie weg.',
        ),
        _Point(
          icon: CupertinoIcons.shield,
          title: 'Wann du vorher fragen solltest',
          text:
              'Bei Psychosen, Schizophrenie, bipolarer Störung, dissoziativen Störungen, Narkolepsie oder einer Traumafolgestörung: bitte erst mit deiner Ärztin oder deinem Therapeuten sprechen.',
        ),
        _Point(
          icon: CupertinoIcons.eye,
          title: 'Ungewohntes kann vorkommen',
          text:
              'Schlafparalyse oder falsches Erwachen sind ungefährlich, können aber erschrecken. Im Bereich Wissen steht, wie du damit umgehst.',
        ),
        SizedBox(height: LS.sm),
        LNote(text: 'Lucid gibt Orientierung auf Basis veröffentlichter Studien. Es ist keine medizinische Beratung.'),
      ],
    );
  }

  Widget _stepPlan() {
    final bool light = _draft.lightSleeper;
    return _frame(
      title: 'Dein Plan für vier Wochen',
      lead: 'Fünf bis zehn Minuten am Tag. Du kannst jederzeit pausieren.',
      children: <Widget>[
        const _Week(n: 1, title: 'Träume erinnern', text: 'Tagebuch, erste Reality-Checks'),
        const _Week(n: 2, title: 'Absicht setzen', text: 'MILD beim Einschlafen, Traumzeichen'),
        _Week(
          n: 3,
          title: 'Die Morgenstunden nutzen',
          text: light ? 'MILD beim natürlichen Aufwachen' : 'Zwei Nächte mit kurzer Wachphase',
        ),
        const _Week(n: 4, title: 'Verfeinern', text: 'SSILD, optional Klangsignale'),
        const SizedBox(height: LS.md),
        Text(
          'Wie schnell es klappt, ist sehr verschieden. In Feldstudien wurden manche schon in der ersten Trainingswoche klar, andere brauchen deutlich länger. Beides ist normal.',
          style: LT.labelMuted,
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.index, required this.count});
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Schritt ${index + 1} von $count',
      child: Row(
        children: <Widget>[
          for (int i = 0; i < count; i++)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i <= index ? LC.iris : LC.line,
                  borderRadius: LRad.pill,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LS.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LIconDot(icon, size: 44),
          const SizedBox(width: LS.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: LT.heading),
                const SizedBox(height: 4),
                Text(text, style: LT.bodyMuted.copyWith(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Week extends StatelessWidget {
  const _Week({required this.n, required this.title, required this.text});
  final int n;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LS.md),
      child: LCard(
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: LC.irisSoft, shape: BoxShape.circle),
              child: Text('$n', style: LT.heading.copyWith(color: LC.iris)),
            ),
            const SizedBox(width: LS.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: LT.heading.copyWith(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(text, style: LT.labelMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
