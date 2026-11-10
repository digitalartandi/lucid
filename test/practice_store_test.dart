import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_dreams_aaa/core/practice_store.dart';

void main() {
  final PracticeStore store = PracticeStore.instance;
  final DateTime now = DateTime(2026, 11, 10, 9);

  setUp(() {
    store.restoreFromJson(<String, dynamic>{
      'profile': <String, dynamic>{
        'programStart': DateTime(2026, 11, 3).toIso8601String(),
        'bedHour': 23,
        'bedMinute': 30,
        'wakeHour': 7,
        'wakeMinute': 0,
      },
      'days': <String, dynamic>{
        '2026-11-10': <String, dynamic>{'recall': 2, 'rc': 3, 'tech': <String>['mild']},
        '2026-11-09': <String, dynamic>{'recall': 0},
        '2026-11-08': <String, dynamic>{'recall': 1, 'tech': <String>['wbtb', 'mild'], 'lucid': true},
        '2026-11-06': <String, dynamic>{'rc': 1},
      },
    });
  });

  test('Programmtag zählt ab dem Startdatum', () {
    expect(store.programDay(now: now), 8);
    expect(store.programDay(now: DateTime(2026, 11, 3, 23, 59)), 1);
  });

  test('Schlafdauer über Mitternacht', () {
    expect(store.profile.sleepMinutes, 7 * 60 + 30);
  });

  test('Serie endet an der ersten Lücke', () {
    expect(store.streak(now: now), 3);
    // Heute noch nichts: die Serie von gestern zählt weiter.
    expect(store.streak(now: DateTime(2026, 11, 11, 7)), 3);
    expect(store.streak(now: DateTime(2026, 11, 13)), 0);
  });

  test('Traumerinnerung zählt nur Tage mit Angabe', () {
    expect(store.recallRate(7, now: now), closeTo(2 / 3, 1e-9));
    expect(store.recallRate(7, now: DateTime(2026, 12, 24)), isNull);
  });

  test('Wochenzahlen', () {
    expect(store.realityChecksInLast(7, now: now), 4);
    expect(store.wbtbNightsInLast(7, now: now), 1);
  });

  test('Tagesprotokoll übersteht Speichern und Laden', () {
    final Map<String, dynamic> json = store.toJson();
    store.restoreFromJson(json);
    final DayLog d = store.logFor(DateTime(2026, 11, 8));
    expect(d.lucid, isTrue);
    expect(d.techniques, containsAll(<String>['wbtb', 'mild']));
    expect(dayKey(DateTime(2026, 1, 5)), '2026-01-05');
  });
}
