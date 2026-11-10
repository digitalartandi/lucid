# Lucid

Klarträumen lernen: geführtes Vier-Wochen-Programm, Nachtmodus, Traumtagebuch und geprüftes Wissen. Flutter-App (Web/PWA, nativ vorbereitet). Alle Daten bleiben auf dem Gerät.

## Aufbau

Vier Bereiche entlang des Lernwegs:

| Bereich | Inhalt |
|---|---|
| **Heute** | Was jetzt dran ist (morgens Traum notieren, tagsüber Reality-Check, abends Technik), Tagesplan, Wochenüberblick |
| **Üben** | Nachtmodus, Techniken mit Evidenzgrad und geführten Übungen, Traumzeichen, Entspannung |
| **Journal** | Träume festhalten, suchen, filtern; Auswertung |
| **Wissen** | Artikel mit Quellen, Glossar, Studien-Feed, Leseliste, eigene Studien |

```
lib/
  main.dart                 App-Start, Einstieg oder Shell
  ui/                       Designsystem: tokens.dart, widgets.dart
  core/                     Inhalt und Logik ohne Oberfläche
    techniques.dart         Technik-Katalog mit Evidenz und Quellen
    program.dart            Vier-Wochen-Programm und Erhaltungsrhythmus
    sessions.dart           Skripte der geführten Übungen
    night_plan.dart         Zeit- und Lautstärkelogik des Nachtmodus
    practice_store.dart     Profil, Tagesprotokoll, Kennzahlen
  features/                 Screens: today, practice, night, journal, insights, wissen, settings, onboarding, shell
  platform/                 Plattform-Brücken (Bildschirm wach halten)
  screens/, services/       Übernommene Module: Klangbibliothek, Traumreisen, Klangwelten, Affirmationen, Studien-Feed, Studien-Builder
assets/wissen/              Artikel (Markdown) mit Quellenangaben
assets/feed/                Kuratierter Studien- und Meldungs-Feed
```

## Inhalte und Evidenz

Jede Aussage zur Wirksamkeit ist einer veröffentlichten Arbeit zugeordnet (`assets/wissen/quellen_zitate_de.md`, Stand November 2026). Techniken tragen einen Evidenzgrad: gut belegt, vielversprechend, wenig Daten, allein zu schwach. Die App leitet weder Medikamente noch Hirnstimulation an.

## Entwickeln

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Entwickelt gegen Flutter 3.32.8. Der Workflow `.github/workflows/ci.yml` prüft jeden Branch außer `main` (analyze, test, Web-Build als Artefakt).

## Nachtmodus im Browser

Der Nachtmodus arbeitet mit Timern in der geöffneten App und hält den Bildschirm über die Screen-Wake-Lock-API wach. Er funktioniert nur, solange der Tab im Vordergrund bleibt. Für native Builds sind lokale Benachrichtigungen und Hintergrund-Audio der nächste Schritt; die Zeitlogik in `core/night_plan.dart` ist davon unabhängig.

## Hinweis

Lucid gibt Orientierung auf Basis veröffentlichter Studien und ersetzt keine medizinische oder therapeutische Beratung.
