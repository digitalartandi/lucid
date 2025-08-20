// lib/screens/modules/trainer_page.dart
import 'package:flutter/cupertino.dart';
import '../../design/gradient_theme.dart';
import '../../models/trainer_models.dart';
import '../../services/trainer_repo.dart';

const _bgDark = Color(0xFF080B23);
const _white  = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);
const _card   = Color(0xFF0A0A23);

class TrainerPage extends StatefulWidget {
  const TrainerPage({super.key});

  @override
  State<TrainerPage> createState() => _TrainerPageState();
}

class _TrainerPageState extends State<TrainerPage> {
  final _repo = TrainerRepo.instance;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _repo.init();
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const CupertinoPageScaffold(
        backgroundColor: _bgDark,
        navigationBar: CupertinoNavigationBar(middle: Text('2-Wochen-Trainer')),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    final plan = _repo.plan;

    return CupertinoPageScaffold(
      backgroundColor: _bgDark,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('2-Wochen-Trainer', style: TextStyle(color: _white)),
        backgroundColor: _bgDark,
      ),
      child: SafeArea(
        child: plan == null ? _StartCard(onStart: _startPlan) : _PlanView(plan: plan, onChanged: _onChanged),
      ),
    );
  }

  Future<void> _startPlan() async {
    await _repo.startNewPlan();
    setState(() {});
  }

  Future<void> _onChanged() async => setState(() {});
}

class _StartCard extends StatelessWidget {
  final VoidCallback onStart;
  const _StartCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final g = GradientTheme.of(GradientTheme.style.value);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _HeroGradient(
          title: 'Dein klarer Einstieg',
          subtitle: '14 Tage · kurze, praxistaugliche Schritte',
          colors: g.primary,
          child: CupertinoButton.filled(
            borderRadius: BorderRadius.circular(14),
            onPressed: onStart,
            child: const Text('Training starten'),
          ),
        ),
        const SizedBox(height: 16),
        _InfoTile('Täglich 2–10 Minuten', 'Mini-Aufgaben passen auch in volle Tage.'),
        _InfoTile('Sanfte REM-Cues', 'Night Lite+ und Cue-Tuning führen dich behutsam.'),
        _InfoTile('Traumreisen', 'Geführte Szenen als Lucidity-Anker.'),
      ],
    );
  }
}

class _PlanView extends StatelessWidget {
  final TrainerPlan plan;
  final VoidCallback onChanged;

  const _PlanView({required this.plan, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final g = GradientTheme.of(GradientTheme.style.value);

    final todayIndex = TrainerRepo.instance.currentDayIndex();
    final today = plan.days.firstWhere((d) => d.index == todayIndex);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _HeroGradient(
          title: 'Tag ${today.index} von ${plan.totalDays}',
          subtitle: '${plan.completedDays} Tage abgeschlossen',
          colors: g.primary,
          child: const SizedBox.shrink(),
        ),
        const SizedBox(height: 14),
        _DayCard(day: today, onChanged: onChanged),
        const SizedBox(height: 24),
        const Text('Übersicht', style: TextStyle(color: _white, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _DaysStrip(plan: plan),
        const SizedBox(height: 16),
        CupertinoButton(
          color: const Color(0xFF242742),
          borderRadius: BorderRadius.circular(14),
          onPressed: () async {
            await TrainerRepo.instance.startNewPlan();
            onChanged();
          },
          child: const Text('Plan neu starten', style: TextStyle(color: _white)),
        ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final TrainerDay day;
  final VoidCallback onChanged;

  const _DayCard({required this.day, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoListTile.notched(
            title: Text('Tag ${day.index}: ${day.title}', style: const TextStyle(color: _white, fontWeight: FontWeight.w700)),
            subtitle: Text(day.subtitle, style: const TextStyle(color: _white)),
          ),
          for (final t in day.tasks)
            _TaskTile(task: t, dayIndex: day.index, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TaskTile extends StatefulWidget {
  final TrainerTask task;
  final int dayIndex;
  final VoidCallback onChanged;

  const _TaskTile({required this.task, required this.dayIndex, required this.onChanged});

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.task;

    IconData icon;
    switch (t.type) {
      case TrainerTaskType.journal:  icon = CupertinoIcons.pencil; break;
      case TrainerTaskType.rc:       icon = CupertinoIcons.eye; break;
      case TrainerTaskType.nightlite:icon = CupertinoIcons.moon; break;
      case TrainerTaskType.cue:      icon = CupertinoIcons.music_note; break;
      case TrainerTaskType.lesen:    icon = CupertinoIcons.book; break;
      case TrainerTaskType.atem:     icon = CupertinoIcons.wind; break;
      case TrainerTaskType.traumreise: icon = CupertinoIcons.sparkles; break;
      case TrainerTaskType.reflekt:  icon = CupertinoIcons.bubble_left_bubble_right; break;
    }

    return CupertinoListTile(
      leading: Icon(icon, color: _white),
      title: Text(t.title, style: const TextStyle(color: _white)),
      subtitle: Text('${t.minutes} min${t.hint != null ? ' · ${t.hint}' : ''}',
          style: const TextStyle(color: _white)),
      trailing: _busy
          ? const CupertinoActivityIndicator()
          : CupertinoSwitch(
              value: t.done,
              onChanged: (v) async {
                setState(() => _busy = true);
                await TrainerRepo.instance.setTaskDone(widget.dayIndex, t.id, v);
                setState(() => _busy = false);
                widget.onChanged();
              },
            ),
      onTap: t.route == null
          ? null
          : () => Navigator.of(context).pushNamed(t.route!),
    );
  }
}

class _DaysStrip extends StatelessWidget {
  final TrainerPlan plan;
  const _DaysStrip({required this.plan});

  @override
  Widget build(BuildContext context) {
    final today = TrainerRepo.instance.currentDayIndex();
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: plan.totalDays,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = plan.days[i];
          final active = d.index == today;
          return Container(
            width: 64,
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: active ? const Color(0xFF7A6CFF) : _stroke, width: active ? 1.5 : 1),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${d.index}', style: const TextStyle(color: _white, fontWeight: FontWeight.w800)),
                Icon(d.completed ? CupertinoIcons.checkmark_alt_circle_fill : CupertinoIcons.circle,
                    color: _white, size: 18),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroGradient extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> colors;
  final Widget child;

  const _HeroGradient({required this.title, required this.subtitle, required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _stroke),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: _white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: _white)),
            ]),
          ),
          if (child is! SizedBox) child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _InfoTile(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _stroke),
      ),
      child: CupertinoListTile.notched(
        title: Text(title, style: const TextStyle(color: _white, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: _white)),
      ),
    );
  }
}
