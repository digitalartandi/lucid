// lib/features/wissen/wissen_page.dart
//
// "Wissen": geprüfte Artikel, Nachschlagen, Forschung.
import 'package:flutter/cupertino.dart';

import '../../ui/tokens.dart';
import '../../ui/widgets.dart';
import '../shell/app_shell.dart';

class WissenArticle {
  const WissenArticle(this.title, this.subtitle, this.asset, this.icon);
  final String title;
  final String subtitle;
  final String asset;
  final IconData icon;
}

const List<WissenArticle> startArticles = <WissenArticle>[
  WissenArticle('Grundlagen', 'Was ein Klartraum ist und was nicht', 'assets/wissen/grundlagen_de.md', CupertinoIcons.moon_stars),
  WissenArticle('Techniken im Vergleich', 'Was wirkt, wie gut es belegt ist', 'assets/wissen/techniken_de.md', CupertinoIcons.sparkles),
  WissenArticle('Traumtagebuch', 'So wird Erinnerung zur Gewohnheit', 'assets/wissen/journal_guide_de.md', CupertinoIcons.book),
  WissenArticle('Häufige Fragen', 'Kurze Antworten', 'assets/wissen/faq_de.md', CupertinoIcons.question_circle),
];

const List<WissenArticle> backgroundArticles = <WissenArticle>[
  WissenArticle('Schlaf und Gehirn', 'Traumphasen, Timing, was im Kopf passiert', 'assets/wissen/neuro_sleep_de.md', CupertinoIcons.waveform_path),
  WissenArticle('Geräte und Schlafmessung', 'Uhren, Stirnbänder, Apps: was sie können', 'assets/wissen/wearables_erkennung_de.md', CupertinoIcons.graph_square),
];

const List<WissenArticle> safetyArticles = <WissenArticle>[
  WissenArticle('Sicherheit und Grenzen', 'Risiken, Gegenanzeigen, gesunde Dosierung', 'assets/wissen/ethik_risiken_de.md', CupertinoIcons.shield),
  WissenArticle('Albträume verändern', 'Imagery Rehearsal und Klartraum-Ansätze', 'assets/wissen/albtraeume_irt_de.md', CupertinoIcons.bolt),
  WissenArticle('Wenn es hakt', 'Typische Hürden und was hilft', 'assets/wissen/troubleshooting_de.md', CupertinoIcons.compass),
];

const List<WissenArticle> referenceArticles = <WissenArticle>[
  WissenArticle('Glossar', 'Begriffe kurz erklärt', 'assets/wissen/glossar_de.md', CupertinoIcons.text_alignleft),
  WissenArticle('Quellen', 'Alle zitierten Studien mit Link', 'assets/wissen/quellen_zitate_de.md', CupertinoIcons.link),
];

class WissenPage extends StatelessWidget {
  const WissenPage({super.key});

  Widget _group(BuildContext context, List<WissenArticle> items) {
    return LGroup(
      children: <Widget>[
        for (final WissenArticle a in items)
          LRow(
            icon: a.icon,
            title: a.title,
            subtitle: a.subtitle,
            onTap: () => openRoute(context, '/wissen/article', arg: a.asset),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LPage(
      child: LScroll(
        children: <Widget>[
          const LHeader(
            title: 'Wissen',
            subtitle: 'Geprüft gegen veröffentlichte Studien. Stand: November 2026.',
          ),
          _group(context, startArticles),
          const LSection('Hintergrund'),
          _group(context, backgroundArticles),
          const LSection('Sicher üben'),
          _group(context, safetyArticles),
          const LSection('Nachschlagen'),
          _group(context, referenceArticles),
          const LSection('Forschung'),
          LGroup(
            children: <Widget>[
              LRow(
                icon: CupertinoIcons.news,
                iconColor: LC.moon,
                title: 'Studien und Meldungen',
                subtitle: 'Kuratierte Arbeiten mit Kurzfassung',
                onTap: () => openRoute(context, '/studien'),
              ),
              LRow(
                icon: CupertinoIcons.rectangle_stack,
                iconColor: LC.moon,
                title: 'Leseliste',
                subtitle: 'Gespeicherte Arbeiten und Notizen',
                onTap: () => openRoute(context, '/reading_list'),
              ),
              LRow(
                icon: CupertinoIcons.lab_flask,
                iconColor: LC.moon,
                title: 'Eigene Studie',
                subtitle: 'Selbstversuche planen und auswerten',
                onTap: () => openRoute(context, '/research'),
              ),
            ],
          ),
          const SizedBox(height: LS.xl),
          const LNote(
            text: 'Die Inhalte geben Orientierung und ersetzen keine medizinische oder therapeutische Beratung.',
          ),
        ],
      ),
    );
  }
}
