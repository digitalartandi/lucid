// lib/core/program.dart
//
// Vier-Wochen-Programm. Reihenfolge und Dosierung folgen der Studienlage:
// erst Traumerinnerung (stärkster Prädiktor), dann MILD, dann die kurze
// Wachphase am Morgen (WBTB) an wenigen Nächten, zuletzt SSILD und Klangsignale.

enum Slot { morning, day, evening, night }

String slotLabel(Slot s) {
  switch (s) {
    case Slot.morning:
      return 'Morgens';
    case Slot.day:
      return 'Tagsüber';
    case Slot.evening:
      return 'Abends';
    case Slot.night:
      return 'Nachts';
  }
}

class ProgramTask {
  const ProgramTask({
    required this.id,
    required this.title,
    required this.detail,
    required this.slot,
    required this.minutes,
    this.route,
    this.arg,
    this.rootNavigator = false,
  });

  final String id;
  final String title;
  final String detail;
  final Slot slot;
  final int minutes;
  final String? route;
  final Object? arg;

  /// Vollbild-Abläufe (Nachtmodus, geführte Übung) liegen über den Tabs.
  final bool rootNavigator;
}

class ProgramWeek {
  const ProgramWeek({
    required this.number,
    required this.title,
    required this.goal,
    required this.why,
  });

  final int number;
  final String title;
  final String goal;

  /// Begründung aus der Forschung, in einem Satz.
  final String why;
}

class ProgramDay {
  const ProgramDay({
    required this.day,
    required this.week,
    required this.focusTitle,
    required this.focusText,
    required this.tasks,
    this.wbtbNight = false,
  });

  final int day;
  final ProgramWeek week;
  final String focusTitle;
  final String focusText;
  final List<ProgramTask> tasks;
  final bool wbtbNight;

  int get minutes {
    int m = 0;
    for (final ProgramTask t in tasks) {
      m += t.minutes;
    }
    return m;
  }
}

const int programLength = 28;

const List<ProgramWeek> programWeeks = <ProgramWeek>[
  ProgramWeek(
    number: 1,
    title: 'Träume erinnern',
    goal: 'Jeden Morgen etwas festhalten, auch wenn es nur ein Gefühl ist.',
    why: 'Gute Traumerinnerung war in den großen Feldstudien der verlässlichste Hinweis darauf, wem die Induktion gelingt.',
  ),
  ProgramWeek(
    number: 2,
    title: 'Absicht setzen',
    goal: 'MILD lernen und Traumzeichen sammeln.',
    why: 'MILD ist laut systematischem Review von 2023 die wirksamste untersuchte Technik.',
  ),
  ProgramWeek(
    number: 3,
    title: 'Die Morgenstunden nutzen',
    goal: 'An zwei Nächten kurz aufwachen und MILD dort anwenden, wo es am besten wirkt.',
    why: 'Nach fünf bis sechs Stunden Schlaf sind die Traumphasen lang. Im Schlaflabor wurde so etwa jede zweite ungeübte Person in einer Nacht klar.',
  ),
  ProgramWeek(
    number: 4,
    title: 'Verfeinern',
    goal: 'SSILD ausprobieren, optional Klangsignale testen, den eigenen Weg finden.',
    why: 'SSILD war in der internationalen Studie von 2020 ähnlich wirksam wie MILD. Manche kommen damit besser zurecht.',
  ),
];

const String _articleBasics = 'assets/wissen/grundlagen_de.md';
const String _articleJournal = 'assets/wissen/journal_guide_de.md';
const String _articleSleep = 'assets/wissen/neuro_sleep_de.md';
const String _articleSafety = 'assets/wissen/ethik_risiken_de.md';
const String _articleTrouble = 'assets/wissen/troubleshooting_de.md';
const String _articleNightmares = 'assets/wissen/albtraeume_irt_de.md';
const String _articleTech = 'assets/wissen/wearables_erkennung_de.md';

class _Focus {
  const _Focus(this.title, this.text, {this.extra, this.wbtb = false});
  final String title;
  final String text;
  final ProgramTask Function(String id)? extra;
  final bool wbtb;
}

ProgramTask _read(String id, String title, String asset, {int minutes = 4}) => ProgramTask(
      id: id,
      title: title,
      detail: 'Kurz lesen',
      slot: Slot.day,
      minutes: minutes,
      route: '/wissen/article',
      arg: asset,
    );

ProgramTask _technique(String id, String title, String techniqueId) => ProgramTask(
      id: id,
      title: title,
      detail: 'Anleitung ansehen',
      slot: Slot.day,
      minutes: 3,
      route: '/practice/technique',
      arg: techniqueId,
    );

final List<_Focus> _focus = <_Focus>[
  // Woche 1
  _Focus(
    'Was ein Klartraum ist',
    'Du weißt im Traum, dass du träumst. Mehr braucht es nicht. Kontrolle kommt, wenn überhaupt, danach.',
    extra: (String id) => _read(id, 'Grundlagen lesen', _articleBasics),
  ),
  _Focus(
    'Still liegen bleiben',
    'Erinnerung hängt am Aufwachmoment. Wer sich sofort bewegt oder aufs Handy schaut, verliert den Traum in Sekunden.',
    extra: (String id) => _read(id, 'So führst du das Traumtagebuch', _articleJournal),
  ),
  _Focus(
    'Richtig prüfen',
    'Ein Reality-Check ist eine ernst gemeinte Frage, kein Ritual. Heute lernst du ihn einmal sauber.',
    extra: (String id) => ProgramTask(
      id: id,
      title: 'Reality-Check geführt üben',
      detail: 'Fünf Schritte, eine Minute',
      slot: Slot.day,
      minutes: 1,
      route: '/practice/session',
      arg: 'rc',
      rootNavigator: true,
    ),
  ),
  _Focus(
    'Deine Traumzeichen',
    'Schau in deine ersten Einträge: Was kommt wieder? Orte, Menschen, Unmögliches. Daran wirst du dich im Traum erkennen.',
    extra: (String id) => ProgramTask(
      id: id,
      title: 'Erste Traumzeichen notieren',
      detail: 'Zwei oder drei genügen',
      slot: Slot.day,
      minutes: 3,
      route: '/practice/signs',
    ),
  ),
  _Focus(
    'Schlaf zuerst',
    'Klarträume entstehen in den langen Traumphasen am Morgen. Wer zu kurz schläft, schneidet genau die ab.',
    extra: (String id) => _read(id, 'Schlaf und Traumphasen', _articleSleep),
  ),
  _Focus(
    'Erwartungen und Grenzen',
    'Manche werden in der ersten Woche klar, viele brauchen länger. Lies heute, für wen Zurückhaltung sinnvoll ist.',
    extra: (String id) => _read(id, 'Sicherheit und Grenzen', _articleSafety),
  ),
  _Focus(
    'Rückblick Woche 1',
    'Wie oft hast du dich erinnert? Die Zahl ist dein Ausgangswert. Sie steigt meist in den ersten zwei Wochen.',
    extra: (String id) => ProgramTask(
      id: id,
      title: 'Auswertung ansehen',
      detail: 'Erinnerung, Checks, Verlauf',
      slot: Slot.day,
      minutes: 2,
      route: '/insights',
    ),
  ),
  // Woche 2
  _Focus(
    'MILD kennenlernen',
    'Du setzt eine Absicht für die Zukunft, wie „Brief einwerfen, wenn ich am Kasten vorbeikomme“. Nur dass der Briefkasten ein Traum ist.',
    extra: (String id) => _technique(id, 'MILD-Anleitung lesen', 'mild'),
  ),
  _Focus(
    'Dein Satz',
    'Die Absicht wirkt, wenn sie deine ist. Formuliere den Satz so, dass du ihn meinst.',
    extra: (String id) => ProgramTask(
      id: id,
      title: 'Absichtssatz anpassen',
      detail: 'Eigene Worte',
      slot: Slot.day,
      minutes: 2,
      route: '/practice/intention',
    ),
  ),
  const _Focus(
    'Der Traum als Probebühne',
    'Beim MILD gehst du in einen echten Traum zurück und spielst durch, wie du darin klar wirst. Je konkreter, desto besser.',
  ),
  const _Focus(
    'Natürliches Aufwachen nutzen',
    'Fast jeder wacht nachts kurz auf. Wenn es in der zweiten Nachthälfte passiert: einmal MILD, dann weiterschlafen. Kein Wecker nötig.',
  ),
  const _Focus(
    'Schnell wieder einschlafen',
    'Der stärkste Einzelbefund zu MILD: Wer danach innerhalb von fünf Minuten einschlief, wurde in knapp der Hälfte der Versuche klar. Lieber kurz und entspannt als lang und wach.',
  ),
  _Focus(
    'Wenn es klappt: stabil bleiben',
    'Die ersten Sekunden entscheiden. Ruhig bleiben, Hände reiben, etwas genau ansehen.',
    extra: (String id) => _technique(id, 'Stabilisieren lesen', 'stabilize'),
  ),
  _Focus(
    'Rückblick Woche 2',
    'Vergleiche deine Traumerinnerung mit Woche 1. Welche Traumzeichen sind dazugekommen?',
    extra: (String id) => ProgramTask(
      id: id,
      title: 'Auswertung ansehen',
      detail: 'Zwei Wochen im Vergleich',
      slot: Slot.day,
      minutes: 2,
      route: '/insights',
    ),
  ),
  // Woche 3
  _Focus(
    'Die Wachphase verstehen',
    'WBTB heißt: nach fünf bis sechs Stunden kurz aufstehen, Traum notieren, Absicht setzen, weiterschlafen. Heute nur lesen und eine passende Nacht aussuchen.',
    extra: (String id) => _technique(id, 'WBTB-Anleitung lesen', 'wbtb'),
  ),
  const _Focus(
    'Erste Nacht mit Wachphase',
    'Heute Nacht führt dich der Nachtmodus: wecken, Traum notieren, MILD, weiterschlafen. Such dir eine Nacht, nach der du ausschlafen kannst.',
    wbtb: true,
  ),
  _Focus(
    'Nach der Nacht',
    'Wie war der Schlaf danach? Wenn du lange wach lagst, verkürze die Wachphase beim nächsten Mal.',
    extra: (String id) => _read(id, 'Wenn es hakt', _articleTrouble),
  ),
  const _Focus(
    'Falsches Erwachen',
    'Nach Wachphasen träumt man oft, aufzuwachen. Gewöhn dir an: Nach jedem Aufwachen ein Reality-Check.',
  ),
  const _Focus(
    'Zweite Nacht mit Wachphase',
    'Gleicher Ablauf wie vor drei Tagen. Ändere höchstens eine Sache, damit du merkst, was wirkt.',
    wbtb: true,
  ),
  _Focus(
    'Ein Ziel für den Klartraum',
    'Was möchtest du tun, wenn du klar wirst? Ein kleines, konkretes Vorhaben hält die Klarheit länger.',
    extra: (String id) => _read(id, 'Albträume verändern', _articleNightmares),
  ),
  _Focus(
    'Rückblick Woche 3',
    'Zwei Nächte mit Wachphase: Hat sich die Traumerinnerung an diesen Morgen verändert? Wie müde warst du tagsüber?',
    extra: (String id) => ProgramTask(
      id: id,
      title: 'Auswertung ansehen',
      detail: 'Nächte mit Wachphase im Blick',
      slot: Slot.day,
      minutes: 2,
      route: '/insights',
    ),
  ),
  // Woche 4
  _Focus(
    'SSILD kennenlernen',
    'Statt eines Satzes wanderst du mit der Aufmerksamkeit durch Sehen, Hören und Fühlen. Probier die geführte Übung einmal am Tag aus, damit sie nachts sitzt.',
    extra: (String id) => _technique(id, 'SSILD-Anleitung lesen', 'ssild'),
  ),
  const _Focus(
    'Nacht mit SSILD',
    'Heute Nacht: Wachphase wie gewohnt, danach SSILD statt MILD. Der Nachtmodus bietet beides an.',
    wbtb: true,
  ),
  _Focus(
    'Klangsignale: was die Forschung sagt',
    'Töne im Schlaf können an die Absicht erinnern. Im Labor klappt das gut, zu Hause ohne Schlafmessung nur manchmal. Lies, bevor du es testest.',
    extra: (String id) => _technique(id, 'Klangsignale verstehen', 'tlr'),
  ),
  _Focus(
    'Technik und Geräte einordnen',
    'Uhren und Ringe schätzen Schlafphasen nur ungefähr. Stirnbänder mit Hirnstrommessung sind genauer, aber noch Forschungswerkzeug.',
    extra: (String id) => _read(id, 'Geräte und Schlafmessung', _articleTech),
  ),
  const _Focus(
    'Deine beste Kombination',
    'Wähle für heute Nacht, was bisher am besten ging: MILD oder SSILD, mit oder ohne Wachphase.',
    wbtb: true,
  ),
  const _Focus(
    'Dranbleiben ohne Druck',
    'Klarträumen ist eine Fähigkeit mit guten und schlechten Wochen. Feste Pausentage schützen deinen Schlaf.',
  ),
  _Focus(
    'Abschluss',
    'Vier Wochen Daten: Du siehst jetzt, was bei dir wirkt. Ab morgen schlägt die App einen Erhaltungsrhythmus vor.',
    extra: (String id) => ProgramTask(
      id: id,
      title: 'Auswertung ansehen',
      detail: 'Dein Monat',
      slot: Slot.day,
      minutes: 3,
      route: '/insights',
    ),
  ),
];

ProgramWeek weekFor(int day) {
  final int idx = ((day - 1) ~/ 7).clamp(0, programWeeks.length - 1).toInt();
  return programWeeks[idx];
}

/// Aufgaben für einen Programmtag (1-basiert).
///
/// Nach Tag 28 läuft ein Erhaltungsrhythmus im Wochentakt weiter.
/// [lightSleeper] ersetzt Wecker-Nächte durch MILD beim natürlichen Aufwachen.
ProgramDay programDayFor(int day, {bool lightSleeper = false}) {
  if (day < 1) day = 1;
  if (day > programLength) return _maintenanceDay(day, lightSleeper: lightSleeper);

  final ProgramWeek week = weekFor(day);
  final _Focus f = _focus[day - 1];
  final String p = 'd$day';
  final List<ProgramTask> tasks = <ProgramTask>[
    ProgramTask(
      id: '$p-journal',
      title: 'Traum notieren',
      detail: 'Direkt nach dem Aufwachen, Stichworte genügen',
      slot: Slot.morning,
      minutes: 3,
      route: '/journal/new',
    ),
  ];

  if (f.extra != null) tasks.add(f.extra!('$p-focus'));

  if (week.number == 1) {
    tasks.add(ProgramTask(
      id: '$p-rc',
      title: day < 3 ? 'Zweimal innehalten: Träume ich?' : 'Zwei echte Reality-Checks',
      detail: 'Bei etwas Seltsamem oder nach dem Aufwachen',
      slot: Slot.day,
      minutes: 2,
      route: '/practice/rc',
    ));
    tasks.add(ProgramTask(
      id: '$p-recall',
      title: 'Abend-Absicht',
      detail: 'Eine Minute vor dem Einschlafen',
      slot: Slot.evening,
      minutes: 1,
      route: '/practice/session',
      arg: 'recall',
      rootNavigator: true,
    ));
  } else {
    tasks.add(ProgramTask(
      id: '$p-rc',
      title: 'Reality-Check bei einem Traumzeichen',
      detail: 'Mindestens einmal, ernst gemeint',
      slot: Slot.day,
      minutes: 1,
      route: '/practice/rc',
    ));
    final bool wbtb = f.wbtb && !lightSleeper;
    if (wbtb) {
      tasks.add(ProgramTask(
        id: '$p-night',
        title: week.number == 4 && day == 23
            ? 'Nachtmodus: Wachphase mit SSILD'
            : 'Nachtmodus: Wachphase mit ${week.number == 4 ? 'MILD oder SSILD' : 'MILD'}',
        detail: 'Wecken nach 5 bis 6 Stunden, geführt',
        slot: Slot.night,
        minutes: 20,
        route: '/night',
        rootNavigator: true,
      ));
    } else {
      final bool ssild = week.number == 4 && (day == 22 || day == 23);
      tasks.add(ProgramTask(
        id: '$p-evening',
        title: ssild ? 'SSILD geführt üben' : 'MILD beim Einschlafen',
        detail: f.wbtb
            ? 'Ohne Wecker: wenn du nachts von selbst aufwachst, wiederholen'
            : (ssild ? 'Sechs Minuten, Augen zu' : 'Fünf Minuten, dann loslassen'),
        slot: Slot.evening,
        minutes: ssild ? 6 : 5,
        route: '/practice/session',
        arg: ssild ? 'ssild' : 'mild',
        rootNavigator: true,
      ));
    }
  }

  return ProgramDay(
    day: day,
    week: week,
    focusTitle: f.title,
    focusText: f.text,
    tasks: tasks,
    wbtbNight: f.wbtb && !lightSleeper,
  );
}

const ProgramWeek maintenanceWeek = ProgramWeek(
  number: 5,
  title: 'Freies Üben',
  goal: 'Täglich notieren, zwei Nächte pro Woche gezielt üben, der Rest ist Schlaf.',
  why: 'In der internationalen Studie von 2020 beeinträchtigte erfolgreiche Induktion die Schlafqualität nicht. Wenige, geplante Übungsnächte sollen das so halten.',
);

ProgramDay _maintenanceDay(int day, {required bool lightSleeper}) {
  // Wochentakt ab Tag 29: Tag 2 und 5 der Woche sind Übungsnächte.
  final int dow = (day - programLength - 1) % 7; // 0..6
  final bool practiceNight = dow == 1 || dow == 4;
  final bool rest = dow == 6;
  final String p = 'm$day';
  final List<ProgramTask> tasks = <ProgramTask>[
    ProgramTask(
      id: '$p-journal',
      title: 'Traum notieren',
      detail: 'Direkt nach dem Aufwachen',
      slot: Slot.morning,
      minutes: 3,
      route: '/journal/new',
    ),
    if (!rest)
      ProgramTask(
        id: '$p-rc',
        title: 'Reality-Check bei einem Traumzeichen',
        detail: 'Einmal, ernst gemeint',
        slot: Slot.day,
        minutes: 1,
        route: '/practice/rc',
      ),
    if (practiceNight && !lightSleeper)
      ProgramTask(
        id: '$p-night',
        title: 'Nachtmodus: Wachphase mit deiner Technik',
        detail: 'Nur wenn du morgen ausschlafen kannst',
        slot: Slot.night,
        minutes: 20,
        route: '/night',
        rootNavigator: true,
      ),
    if (!rest && !(practiceNight && !lightSleeper))
      ProgramTask(
        id: '$p-evening',
        title: 'MILD beim Einschlafen',
        detail: 'Fünf Minuten, dann loslassen',
        slot: Slot.evening,
        minutes: 5,
        route: '/practice/session',
        arg: 'mild',
        rootNavigator: true,
      ),
  ];
  return ProgramDay(
    day: day,
    week: maintenanceWeek,
    focusTitle: rest ? 'Pausentag' : (practiceNight ? 'Übungsnacht' : 'Leichter Tag'),
    focusText: rest
        ? 'Heute nur das Tagebuch. Eine Nacht ganz ohne Technik gehört zum Training.'
        : (practiceNight
            ? 'Eine von zwei Übungsnächten dieser Woche. Wenn du müde bist, verschiebe sie.'
            : 'Tagebuch, ein ehrlicher Reality-Check, abends kurz die Absicht.'),
    tasks: tasks,
    wbtbNight: practiceNight && !lightSleeper,
  );
}
