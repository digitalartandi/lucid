// lib/core/night_plan.dart
//
// Zeitplan einer Übungsnacht. Reine Logik, damit sie testbar bleibt.

class NightConfig {
  const NightConfig({
    required this.start,
    this.wbtb = true,
    this.wbtbAfterMinutes = 330,
    this.technique = 'mild',
    this.cues = false,
    this.cuesAfterMinutes = 360,
    this.cueIntervalMinutes = 5,
    this.cueWindowMinutes = 90,
    this.alarmVolume = 0.5,
    this.cueVolume = 0.15,
    this.cueAsset = defaultCueAsset,
  });

  static const String defaultCueAsset = 'assets/audio/cues/soft-chim.mp3';

  /// Zeitpunkt des Zubettgehens.
  final DateTime start;

  /// Kurze Wachphase einplanen.
  final bool wbtb;
  final int wbtbAfterMinutes;

  /// 'mild' oder 'ssild'.
  final String technique;

  /// Klangsignale (TLR) in den Morgenstunden.
  final bool cues;
  final int cuesAfterMinutes;
  final int cueIntervalMinutes;
  final int cueWindowMinutes;

  final double alarmVolume;
  final double cueVolume;
  final String cueAsset;

  DateTime? get wbtbAt => wbtb ? start.add(Duration(minutes: wbtbAfterMinutes)) : null;

  DateTime? get cuesFrom => cues ? start.add(Duration(minutes: cuesAfterMinutes)) : null;

  DateTime? get cuesUntil =>
      cues ? start.add(Duration(minutes: cuesAfterMinutes + cueWindowMinutes)) : null;
}

/// Lautstärke des n-ten Klangsignals (0-basiert): beginnt leise und steigt
/// in kleinen Schritten, höchstens auf das Doppelte des Startwerts und nie über 0.6.
double cueVolumeAt(int n, double base) {
  final double v = base * (1 + 0.08 * n);
  final double cap = base * 2 < 0.6 ? base * 2 : 0.6;
  return v > cap ? cap : v;
}

/// Lautstärke des Wecksignals nach [seconds] Sekunden: sanfter Anstieg über eine Minute.
double alarmVolumeAt(int seconds, double target) {
  const double floor = 0.08;
  if (target <= floor) return target;
  final double t = seconds >= 60 ? 1 : seconds / 60;
  return floor + (target - floor) * t;
}

/// Ob zum Zeitpunkt [now] ein Klangsignal fällig ist.
///
/// [earliest] verschiebt den Beginn (z. B. 20 Minuten nach der Wachphase),
/// [pausedUntil] setzt nach einem Aufwachen aus.
bool cueDue({
  required NightConfig config,
  required DateTime now,
  required DateTime? lastCue,
  DateTime? earliest,
  DateTime? pausedUntil,
}) {
  final DateTime? from = config.cuesFrom;
  final DateTime? until = config.cuesUntil;
  if (from == null || until == null) return false;
  DateTime begin = from;
  if (earliest != null && earliest.isAfter(begin)) begin = earliest;
  if (now.isBefore(begin) || now.isAfter(until)) return false;
  if (pausedUntil != null && now.isBefore(pausedUntil)) return false;
  if (lastCue == null) return true;
  return now.difference(lastCue).inSeconds >= config.cueIntervalMinutes * 60;
}
