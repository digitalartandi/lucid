import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_dreams_aaa/core/night_plan.dart';

void main() {
  final DateTime start = DateTime(2026, 11, 10, 23, 0);

  test('Zeitpunkte ergeben sich aus dem Zubettgehen', () {
    final NightConfig c = NightConfig(start: start, cues: true);
    expect(c.wbtbAt, DateTime(2026, 11, 11, 4, 30));
    expect(c.cuesFrom, DateTime(2026, 11, 11, 5, 0));
    expect(c.cuesUntil, DateTime(2026, 11, 11, 6, 30));
  });

  test('ohne Klangsignale ist nie ein Ton fällig', () {
    final NightConfig c = NightConfig(start: start);
    expect(cueDue(config: c, now: DateTime(2026, 11, 11, 5, 30), lastCue: null), isFalse);
  });

  test('Töne nur im Fenster, mit Abstand, nach Pause und Wiedereinschlafen', () {
    final NightConfig c = NightConfig(start: start, cues: true, cueIntervalMinutes: 5);
    final DateTime inWindow = DateTime(2026, 11, 11, 5, 10);
    expect(cueDue(config: c, now: DateTime(2026, 11, 11, 4, 59), lastCue: null), isFalse);
    expect(cueDue(config: c, now: inWindow, lastCue: null), isTrue);
    expect(
      cueDue(config: c, now: inWindow, lastCue: inWindow.subtract(const Duration(minutes: 4))),
      isFalse,
    );
    expect(
      cueDue(config: c, now: inWindow, lastCue: inWindow.subtract(const Duration(minutes: 5))),
      isTrue,
    );
    expect(
      cueDue(config: c, now: inWindow, lastCue: null, pausedUntil: inWindow.add(const Duration(minutes: 1))),
      isFalse,
    );
    expect(
      cueDue(config: c, now: inWindow, lastCue: null, earliest: inWindow.add(const Duration(minutes: 10))),
      isFalse,
    );
    expect(cueDue(config: c, now: DateTime(2026, 11, 11, 6, 31), lastCue: null), isFalse);
  });

  test('Klangsignale bleiben leise', () {
    expect(cueVolumeAt(0, 0.15), closeTo(0.15, 1e-9));
    for (int n = 0; n < 200; n++) {
      expect(cueVolumeAt(n, 0.15) <= 0.30 + 1e-9, isTrue);
      expect(cueVolumeAt(n, 0.5) <= 0.6 + 1e-9, isTrue);
    }
  });

  test('Wecksignal steigt sanft an und erreicht die Ziel-Lautstärke', () {
    expect(alarmVolumeAt(0, 0.5), closeTo(0.08, 1e-9));
    expect(alarmVolumeAt(30, 0.5), closeTo(0.29, 1e-9));
    expect(alarmVolumeAt(60, 0.5), closeTo(0.5, 1e-9));
    expect(alarmVolumeAt(600, 0.5), closeTo(0.5, 1e-9));
    expect(alarmVolumeAt(0, 0.05), closeTo(0.05, 1e-9));
  });
}
