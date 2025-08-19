import 'package:flutter/cupertino.dart';

import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';

/// Klarer Wissens-Hub mit Themenbereichen.
/// Nutzt deine bestehenden Markdown-Artikel (assets/wissen/*.md)
class WissenHubPage extends StatelessWidget {
  const WissenHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(
      title: 'Wissen',
      child: ListView(
        children: [
          // — START HIER —
          Section(header: 'Start hier', children: [
            _article(
              context,
              'Was ist Klarträumen?',
              'Grundlagen, Nutzen, Sicherheit – der schnelle Überblick',
              'assets/wissen/grundlagen_de.md',
            ),
            _article(
              context,
              'Klartraum in 2 Wochen',
              'Geführter Einstieg: Tagesroutinen & Nachtroutinen',
              'assets/wissen/klartraum_grundlagen_de.md',
            ),
            _route(
              context,
              'Trainer starten',
              'Geführte Sessions – ideal für den Einstieg',
              '/trainer',
            ),
            _article(
              context,
              'Traumtagebuch',
              'Warum es wirkt & wie du es richtig führst',
              'assets/wissen/journal_guide_de.md',
            ),
          ]),

          // — TECHNIKEN —
          Section(header: 'Techniken', children: [
            _article(
              context,
              'Überblick: Techniken',
              'MILD, WILD, SSILD, WBTB – wann welche Methode?',
              'assets/wissen/techniken_de.md',
            ),
            _route(
              context,
              'Reality-Checks einrichten',
              'Kontextbasiert erinnern (RC-Reminder)',
              '/rc',
            ),
          ]),

          // — SCHLAF & NEURO —
          Section(header: 'Schlaf & Neuro', children: [
            _article(
              context,
              'Schlaf & Gehirn',
              'REM, Gedächtnis & was beim Klarträumen passiert',
              'assets/wissen/neuro_sleep_de.md',
            ),
          ]),

          // — TRAINING & TOOLS —
          Section(header: 'Training & Tools', children: [
            _route(
              context,
              'Night Lite+ (REM-Cues)',
              'Sanfte Signale in REM-Phasen',
              '/nightlite',
            ),
            _route(
              context,
              'Cue-Tuning',
              'Klang/Intensität fein einstellen',
              '/cuetuning',
            ),
            _article(
              context,
              'Wearables & Erkennung',
              'Was ist möglich – wo sind die Grenzen?',
              'assets/wissen/wearables_detection_de.md',
            ),
          ]),

          // — PROBLEME LÖSEN —
          Section(header: 'Probleme lösen', children: [
            _article(
              context,
              'Häufige Hürden',
              'Einschlafprobleme, Motivation, falsches Timing',
              'assets/wissen/troubleshooting_de.md',
            ),
            _article(
              context,
              'Albträume: IRT',
              'Imagery Rehearsal Therapy Schritt für Schritt',
              'assets/wissen/nightmare_irt_de.md',
            ),
            _article(
              context,
              'Ethik & Risiken',
              'Sicher trainieren, gesund bleiben',
              'assets/wissen/ethics_risks_de.md',
            ),
          ]),

          // — NACHSCHLAGEN —
          Section(header: 'Nachschlagen', children: [
            _article(
              context,
              'FAQ',
              'Schnelle Antworten auf häufige Fragen',
              'assets/wissen/faq_de.md',
            ),
            _article(
              context,
              'Glossar',
              'Begriffe von A–Z kurz erklärt',
              'assets/wissen/glossary_de.md',
            ),
            _article(
              context,
              'Quellen & Studien',
              'Weiterführende Literatur und Zitate',
              'assets/wissen/citations_de.md',
            ),
            _maybeRoute(
              context,
              title: 'Leseliste',
              subtitle: 'Gemerkte Studien & Artikel',
              routeName: '/reading_list', // optional, wenn vorhanden
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // — Helpers —

  RowItem _article(BuildContext context, String title, String subtitle, String assetPath) {
    return RowItem(
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () => Navigator.of(context).pushNamed('/wissen/article', arguments: assetPath),
    );
  }

  RowItem _route(BuildContext context, String title, String subtitle, String route) {
    return RowItem(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(CupertinoIcons.chevron_right),
      onTap: () => Navigator.of(context).pushNamed(route),
    );
  }

  /// Nutzt Route nur, wenn sie existiert – sonst wird der Eintrag ausgeblendet.
  /// (Verhindert Crashes, falls du die Leseliste gerade nicht registriert hast.)
  RowItem _maybeRoute(BuildContext context,
      {required String title, required String subtitle, required String routeName}) {
    return RowItem(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(CupertinoIcons.chevron_right),
      onTap: () {
        try {
          Navigator.of(context).pushNamed(routeName);
        } catch (_) {
          // Route nicht registriert: tu nichts
        }
      },
    );
  }
}
