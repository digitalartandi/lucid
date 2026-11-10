// lib/core/techniques.dart
//
// Technik-Katalog. Jede Aussage zur Wirksamkeit ist einer Quelle zugeordnet
// (siehe assets/wissen/quellen_zitate_de.md). Stand der Recherche: November 2026.

/// Wie gut eine Technik durch Studien gestützt ist.
enum Evidence {
  /// Mehrere Studien, konsistente Ergebnisse.
  good,

  /// Erste kontrollierte Studien, Wiederholung steht noch aus.
  promising,

  /// Wenig oder widersprüchliche Daten.
  limited,

  /// Als alleinige Methode in Studien ohne Wirkung.
  weakAlone,
}

String evidenceLabel(Evidence e) {
  switch (e) {
    case Evidence.good:
      return 'Gut belegt';
    case Evidence.promising:
      return 'Vielversprechend';
    case Evidence.limited:
      return 'Wenig Daten';
    case Evidence.weakAlone:
      return 'Allein zu schwach';
  }
}

class SourceRef {
  const SourceRef(this.label, this.url);
  final String label;
  final String url;
}

class Technique {
  const Technique({
    required this.id,
    required this.name,
    required this.longName,
    required this.summary,
    required this.evidence,
    required this.evidenceNote,
    required this.when,
    required this.minutes,
    required this.steps,
    required this.tips,
    required this.cautions,
    required this.sources,
    this.sessionId,
    this.disturbsSleep = false,
  });

  final String id;
  final String name;
  final String longName;
  final String summary;
  final Evidence evidence;
  final String evidenceNote;
  final String when;
  final int minutes;
  final List<String> steps;
  final List<String> tips;
  final List<String> cautions;
  final List<SourceRef> sources;

  /// Geführte Übung (siehe sessions.dart), falls vorhanden.
  final String? sessionId;

  /// Unterbricht den Nachtschlaf.
  final bool disturbsSleep;
}

const SourceRef _aspy2020 = SourceRef(
  'Aspy (Adventure-Heart) 2020, Frontiers in Psychology',
  'https://doi.org/10.3389/fpsyg.2020.01746',
);
const SourceRef _tan2023 = SourceRef(
  'Tan & Fan 2023, Journal of Sleep Research',
  'https://doi.org/10.1111/jsr.13786',
);
const SourceRef _stumbrys2012 = SourceRef(
  'Stumbrys et al. 2012, Consciousness and Cognition',
  'https://doi.org/10.1016/j.concog.2012.07.003',
);
const SourceRef _erlacher2020 = SourceRef(
  'Erlacher & Stumbrys 2020, Frontiers in Psychology',
  'https://doi.org/10.3389/fpsyg.2020.01383',
);
const SourceRef _erlacher2022 = SourceRef(
  'Erlacher et al. 2022, Clocks & Sleep',
  'https://doi.org/10.3390/clockssleep4020021',
);
const SourceRef _konkoly2024 = SourceRef(
  'Konkoly et al. 2024, Consciousness and Cognition',
  'https://doi.org/10.1016/j.concog.2024.103759',
);
const SourceRef _carr2023 = SourceRef(
  'Carr et al. 2023, Psychology of Consciousness',
  'https://doi.org/10.1037/cns0000227',
);
const SourceRef _multicenter2026 = SourceRef(
  'Esfahani, Salvesen, Picard-Deland et al., Multi-Center-Studie (Preprint/2026)',
  'https://doi.org/10.1101/2024.06.21.600133',
);
const SourceRef _signorelli2026 = SourceRef(
  'Signorelli et al. 2026, Frontiers in Psychology',
  'https://doi.org/10.3389/fpsyg.2026.1924370',
);
const SourceRef _laberge2018 = SourceRef(
  'LaBerge, LaMarca & Baird 2018, PLOS ONE',
  'https://doi.org/10.1371/journal.pone.0201246',
);

const List<Technique> techniques = <Technique>[
  Technique(
    id: 'journal',
    name: 'Traumtagebuch',
    longName: 'Träume direkt nach dem Aufwachen festhalten',
    summary:
        'Die Grundlage. Wer sich an Träume erinnert, hat mit jeder anderen Technik bessere Chancen.',
    evidence: Evidence.good,
    evidenceNote:
        'Gute Traumerinnerung sagte in zwei großen Feldstudien (169 und 355 Teilnehmende) den Erfolg der Induktion voraus. Das Tagebuch allein löst selten Klarträume aus, es trägt alles Weitere.',
    when: 'Jeden Morgen, noch bevor du aufstehst',
    minutes: 3,
    steps: <String>[
      'Bleib nach dem Aufwachen einen Moment still liegen und lass die Augen zu.',
      'Frag dich: Was war gerade eben? Geh von der letzten Szene rückwärts.',
      'Schreib Stichworte auf: Ort, Personen, Gefühl, Seltsames. Ganze Sätze sind nicht nötig.',
      'Markiere, was im Wachleben nicht möglich wäre. Das sind deine Traumzeichen.',
      'Auch „nichts erinnert“ ist ein Eintrag. Er hält die Gewohnheit am Leben.',
    ],
    tips: <String>[
      'Leg das Handy so, dass du es ohne Aufstehen erreichst.',
      'Nimm dir abends kurz vor, dich an deine Träume zu erinnern.',
      'Wach nachts kurz auf? Zwei Stichworte reichen als Anker für den Morgen.',
    ],
    cautions: <String>[],
    sources: <SourceRef>[_aspy2020, _tan2023],
    sessionId: 'recall',
  ),
  Technique(
    id: 'mild',
    name: 'MILD',
    longName: 'Mnemonic Induction of Lucid Dreams',
    summary:
        'Du nimmst dir beim Wiedereinschlafen fest vor, im nächsten Traum zu erkennen, dass du träumst.',
    evidence: Evidence.good,
    evidenceNote:
        'Im systematischen Review von 2023 die wirksamste untersuchte Technik. Entscheidend: nach etwa fünf Stunden Schlaf anwenden und danach rasch wieder einschlafen. Wer innerhalb von fünf Minuten einschlief, berichtete in knapp 46 % der Versuche einen Klartraum.',
    when: 'Nach etwa 5 Stunden Schlaf, beim Wiedereinschlafen',
    minutes: 5,
    steps: <String>[
      'Stell den Wecker auf etwa fünf Stunden nach dem Einschlafen.',
      'Erinnere dich nach dem Aufwachen an den letzten Traum. Hast du keinen, nimm einen früheren.',
      'Such darin ein Traumzeichen: etwas, das im Wachleben nicht passieren würde.',
      'Leg dich hin und sag dir innerlich: „Wenn ich das nächste Mal träume, erkenne ich, dass ich träume.“ Mein es so.',
      'Stell dir vor, du bist wieder im Traum, bemerkst das Traumzeichen und wirst klar.',
      'Wiederhole Satz und Bild, bis die Absicht steht. Dann lass los und schlaf ein.',
    ],
    tips: <String>[
      'Es zählt die Absicht, nicht die Zahl der Wiederholungen.',
      'Wirst du zu wach, brich ab und schlaf einfach. Schnelles Einschlafen ist wichtiger als Perfektion.',
      'MILD funktioniert auch bei natürlichem Aufwachen in der zweiten Nachthälfte.',
    ],
    cautions: <String>[
      'In Verbindung mit einem Wecker unterbricht MILD den Schlaf. Zwei bis drei Nächte pro Woche genügen.',
    ],
    sources: <SourceRef>[_tan2023, _aspy2020, _erlacher2020],
    sessionId: 'mild',
  ),
  Technique(
    id: 'wbtb',
    name: 'WBTB',
    longName: 'Wake Back To Bed: aufwachen, kurz wach bleiben, weiterschlafen',
    summary:
        'Eine kurze Wachphase in der zweiten Nachthälfte. Sie ist der Rahmen, in dem MILD und SSILD wirken.',
    evidence: Evidence.good,
    evidenceNote:
        'Im Schlaflabor führte Wecken nach sechs Stunden mit einer Stunde Traumarbeit und MILD bei 36 bis 54 % ungeübter Personen zu einem Klartraum im Morgenschlaf. Mit Lesen statt MILD waren es 9 %. Die Unterbrechung allein reicht also nicht.',
    when: 'Nach 5 bis 6 Stunden Schlaf, an zwei bis drei Nächten pro Woche',
    minutes: 20,
    steps: <String>[
      'Plane eine Nacht, nach der du ausschlafen kannst.',
      'Lass dich nach fünf bis sechs Stunden wecken.',
      'Steh kurz auf. Gedimmtes, warmes Licht, kein Scrollen, keine Nachrichten.',
      'Notiere, was du geträumt hast, und lies deine Absicht.',
      'Bleib 10 bis 30 Minuten wach. Wenn du schwer wieder einschläfst, eher kürzer.',
      'Geh zurück ins Bett und mach MILD oder SSILD.',
    ],
    tips: <String>[
      'Die Studien nutzten 30 bis 60 Minuten Wachzeit. Zu Hause ist oft weniger sinnvoll, wenn du danach lange wach liegst.',
      'Nicht zu früh: Bei Wecken nach etwa viereinhalb Stunden sank die Erfolgsrate im Labor deutlich.',
      'Die Lucid-App führt dich im Nachtmodus durch Wecken, Notiz und Technik.',
    ],
    cautions: <String>[
      'WBTB kostet Schlaf. Nicht vor wichtigen Tagen, nicht bei Schlafproblemen und nicht jede Nacht.',
      'Fühlst du dich tagsüber müder, reduziere auf eine Nacht pro Woche oder pausiere.',
    ],
    sources: <SourceRef>[_erlacher2020, _erlacher2022, _aspy2020],
    disturbsSleep: true,
  ),
  Technique(
    id: 'ssild',
    name: 'SSILD',
    longName: 'Senses Initiated Lucid Dream',
    summary:
        'Du wechselst beim Wiedereinschlafen die Aufmerksamkeit zwischen Sehen, Hören und Körpergefühl.',
    evidence: Evidence.promising,
    evidenceNote:
        'In der internationalen Studie von 2020 ähnlich wirksam wie MILD. Eine vorregistrierte Multi-Center-Studie fand 2026 mit SSILD plus Sinnesreizen hohe Klartraumraten, auch bei Ungeübten. Weitere unabhängige Wiederholungen fehlen noch.',
    when: 'Nach etwa 5 Stunden Schlaf, beim Wiedereinschlafen',
    minutes: 6,
    steps: <String>[
      'Wach nach etwa fünf Stunden auf und leg dich bequem hin.',
      'Sehen: Augen geschlossen, schau ins Dunkel hinter den Lidern. Nichts erzwingen.',
      'Hören: Lausche auf Geräusche im Raum oder das Rauschen in den Ohren.',
      'Fühlen: Spür Gewicht, Wärme, Kontakt zur Matratze.',
      'Vier schnelle Durchgänge, jeder Sinn nur wenige Sekunden.',
      'Dann vier langsame Durchgänge, jeder Sinn etwa 20 Sekunden.',
      'Leg dich in deine Schlafposition und schlaf ein, ohne weiter zu üben.',
    ],
    tips: <String>[
      'Abschweifen ist normal. Kehr einfach zum nächsten Sinn zurück.',
      'Achte nach dem Aufwachen auf falsches Erwachen: Mach direkt einen Reality-Check.',
    ],
    cautions: <String>[
      'Wie MILD mit Wecker: höchstens zwei bis drei Nächte pro Woche.',
    ],
    sources: <SourceRef>[_aspy2020, _tan2023, _multicenter2026],
    sessionId: 'ssild',
  ),
  Technique(
    id: 'rc',
    name: 'Reality-Check',
    longName: 'Kritische Prüfung: Träume ich gerade?',
    summary:
        'Du prüfst tagsüber ernsthaft, ob du träumst, damit die Frage auch im Traum auftaucht.',
    evidence: Evidence.weakAlone,
    evidenceNote:
        'Als einzige Technik über ein bis zwei Wochen in mehreren Studien ohne messbaren Effekt. Sinnvoll als Begleiter: Er schult die kritische Haltung, die MILD und SSILD brauchen, und fängt falsches Erwachen ab. Eine kleine Studie von 2026 fand mehr Wirkung, wenn in traumähnlichen VR-Szenen geübt wurde.',
    when: 'Tagsüber bei allem, was seltsam wirkt, und nach jedem Aufwachen',
    minutes: 1,
    steps: <String>[
      'Halte inne und frag dich ernsthaft: Träume ich gerade?',
      'Schau dich um: Passt etwas nicht? Wie bin ich hierhergekommen?',
      'Prüfe: Halte die Nase zu und versuch zu atmen. Im Traum geht das.',
      'Lies einen Text, schau weg, lies noch einmal. Im Traum verändert er sich oft.',
      'Stell dir kurz vor, was du tun würdest, wenn es ein Traum wäre.',
    ],
    tips: <String>[
      'Lieber fünf echte Prüfungen am Tag als fünfzig mechanische.',
      'Knüpf den Check an deine persönlichen Traumzeichen.',
    ],
    cautions: <String>[],
    sources: <SourceRef>[_aspy2020, _stumbrys2012, _signorelli2026],
    sessionId: 'rc',
  ),
  Technique(
    id: 'tlr',
    name: 'Klangsignale',
    longName: 'Targeted Lucidity Reactivation (TLR)',
    summary:
        'Du verknüpfst vor dem Schlafen einen Ton mit wacher Aufmerksamkeit. Derselbe Ton erklingt leise in den Morgenstunden.',
    evidence: Evidence.promising,
    evidenceNote:
        'Im Labor mit Schlafmessung wurden 50 % der Teilnehmenden in einem Morgenschlaf klar (ohne Töne 17 %). Per Smartphone zu Hause stieg die Zahl in einer ersten Studie von 0,74 auf 2,11 Klarträume pro Woche; im kontrollierten Teil war der Vorteil nur teilweise nachweisbar, und Töne weckten häufig auf. Eine Multi-Center-Studie fand 2026 keinen klaren Zusatznutzen der Töne gegenüber dem Training allein.',
    when: 'Training vor dem Einschlafen, Signale ab etwa 6 Stunden danach',
    minutes: 12,
    steps: <String>[
      'Wähle einen kurzen, sanften Ton.',
      'Training vor dem Schlafen: Bei jedem Ton richtest du die Aufmerksamkeit auf Gedanken, Körper und Atem und fragst dich, ob du träumst.',
      'Die ersten Töne sind angeleitet, danach folgen sie in größeren Abständen. Einschlafen ist erlaubt.',
      'Etwa sechs Stunden später spielt die App denselben Ton sehr leise.',
      'Hörst du ihn im Traum, ist das dein Zeichen: prüfen, klar werden.',
      'Weckt dich der Ton, tippe auf den Bildschirm. Die App pausiert und wird leiser.',
    ],
    tips: <String>[
      'Stell die Lautstärke so ein, dass du den Ton im stillen Raum gerade noch hörst.',
      'Ohne Schlafmessung trifft die App die Traumphasen nur ungefähr. Sieh es als Experiment.',
    ],
    cautions: <String>[
      'Töne können den Schlaf stören. Brich ab, wenn du dich morgens gerädert fühlst.',
      'Im Browser muss die App nachts geöffnet bleiben.',
    ],
    sources: <SourceRef>[_carr2023, _konkoly2024, _multicenter2026],
    disturbsSleep: true,
  ),
  Technique(
    id: 'wild',
    name: 'WILD',
    longName: 'Wake Initiated Lucid Dream',
    summary:
        'Du gleitest bewusst vom Wachsein direkt in den Traum. Anspruchsvoll, eher etwas für später.',
    evidence: Evidence.limited,
    evidenceNote:
        'Kaum kontrollierte Studien. Erfahrungsberichte sind zahlreich, verlässliche Erfolgsraten fehlen.',
    when: 'Nach einer Wachphase am frühen Morgen oder beim Mittagsschlaf',
    minutes: 20,
    steps: <String>[
      'Leg dich nach einer WBTB-Wachphase entspannt hin.',
      'Halte die Aufmerksamkeit locker bei einem Anker: Atem, Zählen oder ein inneres Bild.',
      'Beobachte Bilder, Geräusche und Körperempfindungen des Einschlafens, ohne einzugreifen.',
      'Wird eine Szene stabil, mach einen Reality-Check.',
    ],
    tips: <String>[
      'Beginne mit MILD oder SSILD. WILD gelingt leichter, wenn Traumerinnerung und Absicht schon stehen.',
    ],
    cautions: <String>[
      'Beim Übergang kann Schlafparalyse auftreten: Du bist wach, der Körper noch gelähmt. Das ist ungefährlich und geht vorbei, kann aber beängstigend sein.',
    ],
    sources: <SourceRef>[_stumbrys2012],
    disturbsSleep: true,
  ),
  Technique(
    id: 'stabilize',
    name: 'Stabilisieren',
    longName: 'Im Klartraum bleiben',
    summary:
        'Was du in den ersten Sekunden eines Klartraums tust, entscheidet, ob er hält.',
    evidence: Evidence.limited,
    evidenceNote:
        'Empfehlungen stammen überwiegend aus Befragungen erfahrener Klarträumender, nicht aus kontrollierten Studien.',
    when: 'Sobald du merkst, dass du träumst',
    minutes: 1,
    steps: <String>[
      'Bleib ruhig. Starke Aufregung weckt dich auf.',
      'Reib die Hände aneinander und spür die Reibung.',
      'Schau dir etwas in der Nähe genau an: Boden, Hände, eine Oberfläche.',
      'Sag dir: „Ich träume. Der Traum bleibt stabil.“',
      'Erst dann wende dich dem zu, was du vorhattest.',
    ],
    tips: <String>[
      'Leg dir vorher ein kleines Ziel zurecht. Ohne Plan verpufft die Klarheit oft.',
      'Verblasst die Szene, bleib liegen und halte die Augen zu: Häufig kehrst du in den Traum zurück.',
    ],
    cautions: <String>[],
    sources: <SourceRef>[_stumbrys2012],
  ),
];

/// Nicht empfohlene Abkürzungen, die in der App erklärt, aber nicht angeleitet werden.
class NotRecommended {
  const NotRecommended(this.name, this.text, this.sources);
  final String name;
  final String text;
  final List<SourceRef> sources;
}

const List<NotRecommended> notRecommended = <NotRecommended>[
  NotRecommended(
    'Galantamin',
    'In einer placebokontrollierten Studie mit 121 Geübten stieg die Klartraumrate mit 4 mg auf 27 % und mit 8 mg auf 42 % (Placebo 14 %), jeweils zusammen mit WBTB und MILD. Galantamin ist ein verschreibungspflichtiges Alzheimer-Medikament mit Nebenwirkungen. Die App rät von Selbstversuchen ab.',
    <SourceRef>[_laberge2018, _tan2023],
  ),
  NotRecommended(
    'Hirnstimulation (tACS)',
    'Eine vielzitierte Studie von 2014 berichtete mehr Klarheit nach Stimulation mit 40 Hz. Ein Wiederholungsversuch 2020 fand den Effekt nicht. Geräte für zu Hause sind nicht belegt.',
    <SourceRef>[
      SourceRef('Voss et al. 2014, Nature Neuroscience', 'https://doi.org/10.1038/nn.3719'),
    ],
  ),
];

Technique? techniqueById(String id) {
  for (final Technique t in techniques) {
    if (t.id == id) return t;
  }
  return null;
}
