// lib/services/trainer_repo.dart
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trainer_models.dart';

class TrainerRepo {
  TrainerRepo._();
  static final TrainerRepo instance = TrainerRepo._();

  static const _key = 'trainer.plan.v1';

  TrainerPlan? _plan;

  TrainerPlan? get plan => _plan;

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      _plan = TrainerPlan.decode(raw);
    }
  }

  Future<void> _save() async {
    if (_plan == null) return;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, _plan!.encode());
  }

  /// Erstellt einen neuen 14-Tage-Plan (überschreibt bestehenden Plan).
  Future<void> startNewPlan() async {
    final days = _buildDefault14Days();
    _plan = TrainerPlan(started: DateTime.now(), days: days);
    await _save();
  }

  /// Plan komplett löschen (z. B. in Einstellungen).
  Future<void> reset() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
    _plan = null;
  }

  /// Toggle Task-Status und speichert.
  Future<void> setTaskDone(int dayIndex, String taskId, bool done) async {
    final p = _plan;
    if (p == null) return;
    final day = p.days.firstWhere((d) => d.index == dayIndex);
    final t = day.tasks.firstWhere((t) => t.id == taskId);
    t.done = done;
    await _save();
  }

  /// Der "heutige" Tag: min(heutiger Abstand, 14)
  int currentDayIndex() {
    final p = _plan;
    if (p == null) return 1;
    final delta = DateTime.now().difference(DateTime(p.started.year, p.started.month, p.started.day)).inDays + 1;
    return max(1, min(delta, p.totalDays));
  }

  // --------- Default-Inhalte für 14 Tage ----------

  List<TrainerDay> _buildDefault14Days() {
    int id = 0;
    String nid() => 't${++id}';

    return [
      TrainerDay(
        index: 1,
        title: 'Grundlagen & Setup',
        subtitle: 'Journal + RC + sanfte Cues',
        tasks: [
          TrainerTask(id: nid(), title: 'Ersten Journal-Eintrag anlegen', type: TrainerTaskType.journal, route: '/journal/new', minutes: 5, hint: 'Kurzer Tagesrückblick reicht.'),
          TrainerTask(id: nid(), title: '2 Reality-Checks üben', type: TrainerTaskType.rc, route: '/rc', minutes: 3, hint: 'Finger zählen, Uhr/Display doppelt prüfen.'),
          TrainerTask(id: nid(), title: 'Night Lite+ öffnen & leisen Cue testen', type: TrainerTaskType.nightlite, route: '/nightlite', minutes: 5),
        ],
      ),
      TrainerDay(
        index: 2,
        title: 'Atem & Fokus',
        subtitle: 'Vor dem Schlaf 2 Min. Atmen',
        tasks: [
          TrainerTask(id: nid(), title: '2 Minuten Atemfokus', type: TrainerTaskType.atem, minutes: 2, hint: '4s ein, 6s aus.'),
          TrainerTask(id: nid(), title: 'Cue-Lautstärke feinjustieren', type: TrainerTaskType.cue, route: '/cuetuning', minutes: 5),
          TrainerTask(id: nid(), title: 'Journal – kurzer Eintrag', type: TrainerTaskType.journal, route: '/journal/new', minutes: 3),
        ],
      ),
      TrainerDay(
        index: 3,
        title: 'Traumreisen',
        subtitle: 'Geführte Szene + RC-Anker',
        tasks: [
          TrainerTask(id: nid(), title: 'Eine Traumreise starten', type: TrainerTaskType.traumreise, route: '/traumreisen', minutes: 10, hint: 'Wähle ein Thema, z. B. „Highlands“.'),
          TrainerTask(id: nid(), title: 'RC nach der Reise', type: TrainerTaskType.rc, route: '/rc', minutes: 2),
        ],
      ),
      TrainerDay(
        index: 4,
        title: 'Lesen: Klarträumen Basics',
        subtitle: '3–5 Minuten',
        tasks: [
          TrainerTask(id: nid(), title: 'FAQ-Basics lesen', type: TrainerTaskType.lesen, route: '/wissen/faq_basics', minutes: 5),
          TrainerTask(id: nid(), title: 'Night Lite+ 1 Nacht aktivieren', type: TrainerTaskType.nightlite, route: '/nightlite', minutes: 3),
        ],
      ),
      TrainerDay(
        index: 5,
        title: 'Cue-Tuning',
        subtitle: 'Feine Lautstärke / Intervall',
        tasks: [
          TrainerTask(id: nid(), title: 'Intervall 10–15 Min. testen', type: TrainerTaskType.cue, route: '/cuetuning', minutes: 5),
          TrainerTask(id: nid(), title: 'Journal – kurzes Stichwort', type: TrainerTaskType.journal, route: '/journal/new', minutes: 2),
        ],
      ),
      TrainerDay(
        index: 6,
        title: 'RC-Routine festigen',
        subtitle: '3× am Tag',
        tasks: [
          TrainerTask(id: nid(), title: '3 Reality-Checks über den Tag', type: TrainerTaskType.rc, route: '/rc', minutes: 4),
          TrainerTask(id: nid(), title: 'Traumreise kurz (5–8 Min.)', type: TrainerTaskType.traumreise, route: '/traumreisen', minutes: 8),
        ],
      ),
      TrainerDay(
        index: 7,
        title: 'Woche 1 – Rückblick',
        subtitle: 'Reflexion & Anpassung',
        tasks: [
          TrainerTask(id: nid(), title: 'Reflexion: Was hat geholfen?', type: TrainerTaskType.reflekt, minutes: 5, hint: '2–3 Stichpunkte ins Journal.'),
          TrainerTask(id: nid(), title: 'Cue nochmals anpassen', type: TrainerTaskType.cue, route: '/cuetuning', minutes: 5),
        ],
      ),
      // Woche 2 – Aufbau
      TrainerDay(
        index: 8,
        title: 'Sanfte Vertiefung',
        subtitle: 'Traumreise + RC',
        tasks: [
          TrainerTask(id: nid(), title: 'Eine Traumreise starten', type: TrainerTaskType.traumreise, route: '/traumreisen', minutes: 10),
          TrainerTask(id: nid(), title: 'RC direkt danach', type: TrainerTaskType.rc, route: '/rc', minutes: 2),
        ],
      ),
      TrainerDay(
        index: 9,
        title: 'Night Lite+ Feintuning',
        subtitle: 'REM-Cues optimieren',
        tasks: [
          TrainerTask(id: nid(), title: 'Night Lite+ öffnen & testen', type: TrainerTaskType.nightlite, route: '/nightlite', minutes: 5),
        ],
      ),
      TrainerDay(
        index: 10,
        title: 'Lesen: Traumerinnerung',
        subtitle: '3–5 Minuten Wissen',
        tasks: [
          TrainerTask(id: nid(), title: 'Artikel lesen', type: TrainerTaskType.lesen, route: '/wissen/article', minutes: 5, hint: 'Leseliste in „Wissen“.'),
          TrainerTask(id: nid(), title: 'Journal – Stichworte', type: TrainerTaskType.journal, route: '/journal/new', minutes: 2),
        ],
      ),
      TrainerDay(
        index: 11,
        title: 'Atem + Cue',
        subtitle: 'Kurzer Abend-Anchor',
        tasks: [
          TrainerTask(id: nid(), title: '2 Minuten Atemfokus', type: TrainerTaskType.atem, minutes: 2),
          TrainerTask(id: nid(), title: 'Cue kurz probehören', type: TrainerTaskType.cue, route: '/cuetuning', minutes: 3),
        ],
      ),
      TrainerDay(
        index: 12,
        title: 'RC-Routine 2',
        subtitle: '3× über den Tag',
        tasks: [
          TrainerTask(id: nid(), title: '3 Reality-Checks', type: TrainerTaskType.rc, route: '/rc', minutes: 4),
          TrainerTask(id: nid(), title: 'Kurze Traumreise', type: TrainerTaskType.traumreise, route: '/traumreisen', minutes: 8),
        ],
      ),
      TrainerDay(
        index: 13,
        title: 'Vorbereitung Klarheit',
        subtitle: 'Alles auf grün',
        tasks: [
          TrainerTask(id: nid(), title: 'Night Lite+ aktiv (heute Nacht)', type: TrainerTaskType.nightlite, route: '/nightlite', minutes: 3),
          TrainerTask(id: nid(), title: 'Journal – Intent festhalten', type: TrainerTaskType.journal, route: '/journal/new', minutes: 3, hint: '„Heute Nacht werde ich mich erinnern …“'),
        ],
      ),
      TrainerDay(
        index: 14,
        title: 'Woche 2 – Abschluss',
        subtitle: 'Reflexion & nächste Schritte',
        tasks: [
          TrainerTask(id: nid(), title: 'Reflexion im Journal', type: TrainerTaskType.reflekt, minutes: 5),
          TrainerTask(id: nid(), title: 'Wiederhole Lieblings-Traumreise', type: TrainerTaskType.traumreise, route: '/traumreisen', minutes: 10),
        ],
      ),
    ];
  }
}
