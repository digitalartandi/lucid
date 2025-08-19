import 'package:flutter/cupertino.dart';
import '../../apple_ui/widgets/section_list.dart';

class FaqBasicsPage extends StatefulWidget {
  const FaqBasicsPage({super.key});
  @override
  State<FaqBasicsPage> createState() => _FaqBasicsPageState();
}

class _FaqBasicsPageState extends State<FaqBasicsPage> {
  final _scroll = ScrollController();

  // ————————————————————————————————————————————————————————————
  // 20 kompakte Q&As (Basics)
  // ————————————————————————————————————————————————————————————
  final List<_FaqItem> _items = const [
    _FaqItem(
      q: 'Was ist ein Klartraum?',
      a: 'Ein Klartraum ist ein Traum, in dem du weißt, dass du träumst, '
         'während der Traum weiterläuft. Je nach Person reicht das von leichter '
         'Einflussnahme bis zu klarer Handlungssteuerung.',
    ),
    _FaqItem(
      q: 'Wie häufig kommen Klarträume vor?',
      a: 'Etwa 50 % erleben mindestens einmal einen Klartraum; ca. 20 % berichten '
         'monatliche Klarträume. Häufigkeit steigt mit Interesse, Übung und guter Schlafqualität.',
    ),
    _FaqItem(
      q: 'In welcher Schlafphase entstehen Klarträume?',
      a: 'Überwiegend in der REM-Phase (bildhafte Träume, schnelle Augenbewegungen). '
         'Im Labor werden häufig Augensignale genutzt, um Klarheit im REM zu markieren.',
    ),
    _FaqItem(
      q: 'Woran erkenne ich, dass ich gerade klar träume?',
      a: 'Schlüsselsignal ist die Einsicht „Ich träume“. Farben und Details wirken oft '
         'intensiver; du erinnerst dich an dein Ziel und kannst Verhalten bewusster steuern.',
    ),
    _FaqItem(
      q: 'Ist Klarträumen gefährlich?',
      a: 'Für Gesunde gilt es als sicher. Vermeide jedoch chronische Schlafverkürzung. '
         'Bei psychischen Erkrankungen oder schweren Parasomnien vorab fachlich abklären.',
    ),
    _FaqItem(
      q: 'Hilft Klarträumen bei Albträumen?',
      a: 'Ja, teils: Klarheit ermöglicht Umdeutung oder aktive Konfrontation. '
         'Für klinische Anwendung (z. B. IRT) ist therapeutische Begleitung sinnvoll.',
    ),
    _FaqItem(
      q: 'Brauche ich besondere Begabung?',
      a: 'Nein. Traumtagebuch, Reality-Checks und gezielte Intentionen reichen, '
         'um die Wahrscheinlichkeit deutlich zu erhöhen.',
    ),
    _FaqItem(
      q: 'Wie lange dauert es bis zum ersten Klartraum?',
      a: 'Sehr unterschiedlich: von Tagen bis Wochen. Gute Start-Kombi: '
         'Schlafhygiene + Tagebuch + Reality-Checks + WBTB + MILD.',
    ),
    _FaqItem(
      q: 'Was ist ein Reality-Check?',
      a: 'Ein kurzer Test, ob du träumst (z. B. Text zweimal lesen, Nase zuhalten und atmen). '
         'Regelmäßig im Alltag trainieren, damit er im Traum automatisch ausgelöst wird.',
    ),
    _FaqItem(
      q: 'Welche Einsteiger-Techniken sind sinnvoll?',
      a: 'MILD (Intention), SSILD (Aufmerksamkeitszyklen), WBTB (Wecken & wieder Einschlafen), '
         'und DILD (Klarheit im Traum durch Checks).',
    ),
    _FaqItem(
      q: 'Was ist WILD?',
      a: 'Wake-Initiated Lucid Dream: Du gleitest wach in den Traum. Anspruchsvoller; '
         'besser, nachdem du mit DILD/MILD erste Erfolge hast.',
    ),
    _FaqItem(
      q: 'Wie führe ich ein Traumtagebuch richtig?',
      a: 'Direkt nach dem Aufwachen stichwortartig festhalten: Personen, Orte, Gefühle, '
         'Unstimmigkeiten. Täglich → bessere Erinnerung & mehr Klarträume.',
    ),
    _FaqItem(
      q: 'Welche Rolle spielt Schlafhygiene?',
      a: 'Groß. Konstanz bei Schlafzeiten, kühles dunkles Zimmer, Licht abends reduzieren, '
         'Koffein spät meiden – alles verbessert REM-Qualität.',
    ),
    _FaqItem(
      q: 'Was bringt der RC-Reminder?',
      a: 'Kontextbasierte Erinnerungen (z. B. Standort, Uhrzeit, Aktivität) helfen, '
         'Reality-Checks regelmäßig und sinnvoll im Alltag zu verankern.',
    ),
    _FaqItem(
      q: 'Was ist Night Lite+?',
      a: 'Sanfte akustische/visuelle Cues in wahrscheinlichen REM-Phasen, die du vor dem Schlafen '
         'mit einer Intention verknüpfst (Klarheit ohne Aufwecken).',
    ),
    _FaqItem(
      q: 'Wie vermeide ich Aufwachen, wenn ich klar bin?',
      a: 'Ruhe bewahren, Traum stabilisieren (Hände reiben, Details ansehen), Ziel fokussieren, '
         'starke Emotionen drosseln.',
    ),
    _FaqItem(
      q: 'Was mache ich bei Schlafparalyse?',
      a: 'Bleib ruhig, konzentriere dich auf Atmung und kleine Bewegungen (Finger/Zehen). '
         'Sie ist unangenehm, aber nicht gefährlich und vergeht nach Sekunden.',
    ),
    _FaqItem(
      q: 'Kann ich im Klartraum üben/lernen?',
      a: 'Ja, mentale Proben können Bewegungsabläufe und Selbstvertrauen verbessern. '
         'Erwartungen realistisch halten und regelmäßig reflektieren.',
    ),
    _FaqItem(
      q: 'Ist Technik/Wearable nötig?',
      a: 'Nicht nötig, aber hilfreich: Schlaf-Tracking, sanfte Cues, Journal-Erfassung. '
         'Die Basis bleibt Verhalten & Konsistenz.',
    ),
    _FaqItem(
      q: 'Worauf sollte ich bei Sicherheit achten?',
      a: 'Gesund schlafen (keine dauerhafte Verkürzung), Stress reduzieren, '
         'bei psychischen Problemen erst Rücksprache halten, realistische Ziele setzen.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFFFFFFFF);
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('FAQ – Start hier'),
      ),
      child: CupertinoScrollbar(
        controller: _scroll,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Section(
              header: 'Klarträumen – Grundlagen',
              children: [
                for (final it in _items)
                  _AccordionTile(
                    title: it.q,
                    body: it.a,
                    textColor: textColor,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}

class _AccordionTile extends StatefulWidget {
  final String title;
  final String body;
  final Color textColor;
  const _AccordionTile({
    super.key,
    required this.title,
    required this.body,
    required this.textColor,
  });

  @override
  State<_AccordionTile> createState() => _AccordionTileState();
}

class _AccordionTileState extends State<_AccordionTile>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _c = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 180),
  );
  late final Animation<double> _size = CurvedAnimation(
    parent: _c, curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _c.forward() : _c.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final chevron = _open
        ? CupertinoIcons.chevron_up
        : CupertinoIcons.chevron_down;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33FFFFFF), width: 0.5),
      ),
      child: Column(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            onPressed: _toggle,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(chevron, color: widget.textColor.withOpacity(.9), size: 18),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor: _size,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: Text(
                widget.body,
                style: TextStyle(
                  color: widget.textColor.withOpacity(.92),
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
