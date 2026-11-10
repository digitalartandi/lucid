# Changelog

## 0.2.0 — 2026-11-10

Grundlegende Überarbeitung von Inhalt, Benutzerführung und Design.

### Neu
- Navigation entlang des Lernwegs: Heute, Üben, Journal, Wissen.
- Einstieg in fünf Schritten mit Schlafzeiten, Erfahrung und Sicherheitshinweisen.
- Vier-Wochen-Programm nach Studienlage (Traumerinnerung, MILD, WBTB, SSILD), danach Erhaltungsrhythmus; Variante ohne Wecker für leichten Schlaf.
- Technik-Katalog mit Evidenzgrad, Schrittfolge, Hinweisen und verlinkten Quellen.
- Geführte Übungen: Abend-Absicht, MILD, SSILD (mit Tonwechsel), Reality-Check, Atemübung.
- Nachtmodus: Wachphase mit sanft ansteigendem Wecksignal, Traumnotiz, MILD oder SSILD im roten Nachtstil; optionale Klangsignale (TLR) mit Training, leisem Start, Pause nach Aufwachen.
- Journal mit automatischem Speichern, Klartraum-Kennzeichnung, Traumzeichen, Suche und Filtern.
- Auswertung: Traumerinnerung, Klarträume, Übungsnächte, häufigste Traumzeichen.
- Einheitliches Designsystem (`lib/ui`).
- Tests für Programm, Nachtlogik und Übungsstand; CI-Workflow.

### Inhalte
- Alle Wissensartikel neu geschrieben und gegen Primärquellen geprüft, mit DOI-Links.
- Studien-Feed neu aufgebaut: 20 Arbeiten und 6 Meldungen, alle Links geprüft. Erfundene Platzhalter-Einträge (`curated.json`) entfernt.
- Korrigiert: Reality-Checks sind als alleinige Technik nicht belegt; Klangsignale ohne Schlafmessung sind als experimentell gekennzeichnet; Traumreisen und Affirmationen sind als Entspannung eingeordnet.

### Entfernt
- 72 nicht mehr erreichbare oder ersetzte Dart-Dateien (alte Startseite, Trainer, Night Lite+, doppelte Repos und Themes, nie eingebundene LRLR-/Live-Stream-Seiten).
- Ungenutzte Abhängigkeiten: `flutter_svg`, `google_fonts`, `video_player`, `web_socket_channel`, `workmanager`, `background_fetch`, `dart_rss`.
- Englische Platzhalter-Artikel (je eine Zeile) und doppelte Glossar-/Grundlagen-Dateien.

## 0.1.0 — 2025-08-14
- Erster Stand.
