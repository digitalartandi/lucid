// lib/core/sessions.dart
//
// Skripte der geführten Übungen. Reiner Inhalt, keine Oberfläche.

class SessionStep {
  const SessionStep(this.title, this.text, {this.seconds = 0, this.chime = false});

  final String title;

  /// Anleitung. "{intention}" wird durch den persönlichen Absichtssatz ersetzt.
  final String text;

  /// Dauer; 0 heißt: weiter per Tipp.
  final int seconds;

  /// Leiser Ton zu Beginn des Schritts (für Übungen mit geschlossenen Augen).
  final bool chime;
}

class SessionScript {
  const SessionScript({
    required this.id,
    required this.title,
    required this.intro,
    required this.steps,
    this.techniqueId,
    this.closing = 'Fertig.',
    this.eyesClosed = false,
  });

  final String id;
  final String title;
  final String intro;
  final List<SessionStep> steps;

  /// Wird nach Abschluss im Tagesprotokoll vermerkt.
  final String? techniqueId;
  final String closing;

  /// Übung läuft mit geschlossenen Augen; Schritte wechseln automatisch mit Ton.
  final bool eyesClosed;

  int get totalSeconds {
    int s = 0;
    for (final SessionStep st in steps) {
      s += st.seconds;
    }
    return s;
  }
}

List<SessionStep> _ssildCycle(int seconds, {required String round}) => <SessionStep>[
      SessionStep('Sehen', '$round\nAugen zu. Schau ins Dunkel hinter den Lidern.',
          seconds: seconds, chime: true),
      SessionStep('Hören', '$round\nLausche. Auf den Raum, auf die Stille.',
          seconds: seconds, chime: true),
      SessionStep('Fühlen', '$round\nSpür deinen Körper: Gewicht, Wärme, Kontakt.',
          seconds: seconds, chime: true),
    ];

final List<SessionScript> sessionScripts = <SessionScript>[
  const SessionScript(
    id: 'recall',
    title: 'Abend-Absicht',
    intro: 'Eine Minute vor dem Einschlafen. Du nimmst dir vor, dich an deine Träume zu erinnern.',
    techniqueId: 'journal',
    closing: 'Leg das Handy griffbereit. Morgen früh zuerst der Traum, dann der Tag.',
    steps: <SessionStep>[
      SessionStep('Ankommen', 'Leg dich bequem hin. Drei ruhige Atemzüge.', seconds: 15),
      SessionStep(
        'Vornehmen',
        'Sag dir innerlich: „Wenn ich aufwache, bleibe ich still liegen und erinnere mich an meinen Traum.“',
        seconds: 20,
      ),
      SessionStep(
        'Vorstellen',
        'Stell dir den Moment vor: Du wachst auf, bewegst dich nicht, und der Traum ist noch da.',
        seconds: 25,
      ),
    ],
  ),
  const SessionScript(
    id: 'mild',
    title: 'MILD',
    intro:
        'Am wirksamsten nach etwa fünf Stunden Schlaf. Danach direkt einschlafen: Je schneller, desto besser.',
    techniqueId: 'mild',
    closing: 'Lass jetzt los und schlaf ein. Die Absicht ist gesetzt.',
    steps: <SessionStep>[
      SessionStep(
        'Traum erinnern',
        'Hol dir den letzten Traum zurück. Ort, Personen, Stimmung. Kein Traum da? Nimm einen der letzten Tage.',
      ),
      SessionStep(
        'Traumzeichen finden',
        'Was daran wäre im Wachleben nicht möglich oder sehr unwahrscheinlich? Das ist dein Zeichen.',
      ),
      SessionStep(
        'Absicht setzen',
        'Sag dir innerlich und mein es so:\n\n„{intention}“',
        seconds: 40,
      ),
      SessionStep(
        'Klar werden, im Kopf',
        'Geh zurück in den Traum. Du siehst das Traumzeichen und erkennst: Ich träume. Was tust du dann?',
        seconds: 60,
      ),
      SessionStep(
        'Wiederholen',
        'Noch einmal Satz und Bild, ruhig und überzeugt.\n\n„{intention}“',
        seconds: 40,
      ),
    ],
  ),
  SessionScript(
    id: 'ssild',
    title: 'SSILD',
    intro:
        'Augen zu, das Handy neben dich. Ein leiser Ton zeigt jeden Wechsel an: Sehen, Hören, Fühlen. Erst vier schnelle, dann vier langsame Runden.',
    techniqueId: 'ssild',
    eyesClosed: true,
    closing: 'Dreh dich in deine Schlafposition und schlaf ein. Nicht weiter üben.',
    steps: <SessionStep>[
      for (int i = 1; i <= 4; i++) ..._ssildCycle(4, round: 'Schnelle Runde $i von 4'),
      for (int i = 1; i <= 4; i++) ..._ssildCycle(20, round: 'Langsame Runde $i von 4'),
    ],
  ),
  const SessionScript(
    id: 'rc',
    title: 'Reality-Check',
    intro: 'Eine echte Prüfung dauert unter einer Minute. Nimm die Frage ernst.',
    techniqueId: 'rc',
    closing: 'Diesmal wach. Die Frage nimmst du mit in den Traum.',
    steps: <SessionStep>[
      SessionStep('Innehalten', 'Stopp. Frag dich ernsthaft: Träume ich gerade?'),
      SessionStep(
        'Umsehen',
        'Schau dich um. Passt alles zusammen? Weißt du, wie du hierhergekommen bist und was davor war?',
      ),
      SessionStep(
        'Prüfen',
        'Halte dir die Nase zu und versuch, durch sie zu atmen. Geht es trotzdem, träumst du.',
      ),
      SessionStep(
        'Gegenprobe',
        'Lies einen Text oder eine Uhrzeit, schau kurz weg und lies noch einmal. Hat sich etwas verändert?',
      ),
      SessionStep(
        'Vorstellen',
        'Stell dir einen Moment lang vor, es wäre ein Traum gewesen. Was hättest du als Erstes getan?',
      ),
    ],
  ),
  const SessionScript(
    id: 'calm',
    title: 'Runterkommen',
    intro: 'Zwei Minuten ruhiges Atmen. Hilft beim Einschlafen und nach einer Wachphase.',
    closing: 'Gut. Lass den Atem jetzt von allein fließen.',
    steps: <SessionStep>[
      SessionStep('Einatmen 4, ausatmen 6', 'Atme durch die Nase ein und länger wieder aus. Folge dem Ring.',
          seconds: 120),
    ],
  ),
];

SessionScript? sessionById(String id) {
  for (final SessionScript s in sessionScripts) {
    if (s.id == id) return s;
  }
  return null;
}
