import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_dreams_aaa/core/program.dart';
import 'package:lucid_dreams_aaa/core/sessions.dart';
import 'package:lucid_dreams_aaa/core/techniques.dart';

const Set<String> _knownRoutes = <String>{
  '/journal/new',
  '/practice/rc',
  '/practice/session',
  '/practice/technique',
  '/practice/signs',
  '/practice/intention',
  '/night',
  '/wissen/article',
  '/insights',
};

void main() {
  group('Programm', () {
    test('jeder Tag hat Aufgaben mit eindeutigen ids und bekannten Zielen', () {
      for (int day = 1; day <= 70; day++) {
        for (final bool light in <bool>[false, true]) {
          final ProgramDay d = programDayFor(day, lightSleeper: light);
          expect(d.tasks, isNotEmpty, reason: 'Tag $day');
          final Set<String> ids = d.tasks.map((ProgramTask t) => t.id).toSet();
          expect(ids.length, d.tasks.length, reason: 'doppelte id an Tag $day');
          for (final ProgramTask t in d.tasks) {
            expect(_knownRoutes.contains(t.route), isTrue, reason: '${t.route} an Tag $day');
            if (t.route == '/practice/session') {
              expect(sessionById(t.arg! as String), isNotNull, reason: 'Übung ${t.arg}');
            }
            if (t.route == '/practice/technique') {
              expect(techniqueById(t.arg! as String), isNotNull, reason: 'Technik ${t.arg}');
            }
            if (t.route == '/wissen/article') {
              expect(File(t.arg! as String).existsSync(), isTrue, reason: 'Artikel ${t.arg}');
            }
          }
        }
      }
    });

    test('jeden Morgen steht das Traumtagebuch an erster Stelle', () {
      for (int day = 1; day <= 70; day++) {
        expect(programDayFor(day).tasks.first.route, '/journal/new');
      }
    });

    test('nie mehr als drei Nächte mit Wachphase in sieben Tagen', () {
      for (int start = 1; start <= 63; start++) {
        int nights = 0;
        for (int d = start; d < start + 7; d++) {
          if (programDayFor(d).wbtbNight) nights++;
        }
        expect(nights <= 3, isTrue, reason: 'Fenster ab Tag $start: $nights');
      }
    });

    test('keine Wachphase in den ersten zwei Wochen', () {
      for (int day = 1; day <= 14; day++) {
        expect(programDayFor(day).wbtbNight, isFalse);
      }
    });

    test('leichter Schlaf: keine Wecker-Nächte', () {
      for (int day = 1; day <= 70; day++) {
        final ProgramDay d = programDayFor(day, lightSleeper: true);
        expect(d.wbtbNight, isFalse);
        expect(d.tasks.any((ProgramTask t) => t.route == '/night'), isFalse);
      }
    });

    test('Wochen sind korrekt zugeordnet', () {
      expect(weekFor(1).number, 1);
      expect(weekFor(7).number, 1);
      expect(weekFor(8).number, 2);
      expect(weekFor(28).number, 4);
      expect(programDayFor(29).week.number, maintenanceWeek.number);
    });
  });

  group('Techniken und Übungen', () {
    test('geführte Übungen existieren und Quellen sind verlinkt', () {
      for (final Technique t in techniques) {
        if (t.sessionId != null) {
          expect(sessionById(t.sessionId!), isNotNull, reason: t.id);
        }
        expect(t.sources, isNotEmpty, reason: t.id);
        for (final SourceRef s in t.sources) {
          expect(s.url.startsWith('https://doi.org/'), isTrue, reason: s.url);
        }
      }
    });

    test('SSILD: vier schnelle und vier langsame Runden mit je drei Sinnen', () {
      final SessionScript s = sessionById('ssild')!;
      expect(s.steps.length, 24);
      expect(s.steps.take(12).every((SessionStep st) => st.seconds == 4), isTrue);
      expect(s.steps.skip(12).every((SessionStep st) => st.seconds == 20), isTrue);
      expect(s.totalSeconds, 12 * 4 + 12 * 20);
    });

    test('MILD blendet den Absichtssatz ein', () {
      final SessionScript s = sessionById('mild')!;
      expect(s.steps.any((SessionStep st) => st.text.contains('{intention}')), isTrue);
    });
  });
}
