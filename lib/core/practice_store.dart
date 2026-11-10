// lib/core/practice_store.dart
//
// Persönlicher Übungsstand: Profil, Tagesprotokoll, Programmfortschritt.
// Alles bleibt auf dem Gerät (SharedPreferences).
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Datumsschlüssel "2026-11-10".
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Was an einem Tag geübt und beobachtet wurde.
class DayLog {
  DayLog({
    this.recall = -1,
    this.realityChecks = 0,
    Set<String>? doneTasks,
    Set<String>? techniques,
    this.lucid = false,
  })  : doneTasks = doneTasks ?? <String>{},
        techniques = techniques ?? <String>{};

  /// Traumerinnerung am Morgen: -1 offen, 0 nichts, 1 Bruchstücke, 2 ganzer Traum.
  int recall;
  int realityChecks;
  final Set<String> doneTasks;

  /// Verwendete Techniken (ids aus techniques.dart), z. B. "mild", "wbtb".
  final Set<String> techniques;
  bool lucid;

  bool get hasActivity =>
      recall >= 0 || realityChecks > 0 || doneTasks.isNotEmpty || techniques.isNotEmpty || lucid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'recall': recall,
        'rc': realityChecks,
        'done': doneTasks.toList(),
        'tech': techniques.toList(),
        'lucid': lucid,
      };

  factory DayLog.fromJson(Map<String, dynamic> j) => DayLog(
        recall: (j['recall'] as num?)?.toInt() ?? -1,
        realityChecks: (j['rc'] as num?)?.toInt() ?? 0,
        doneTasks: ((j['done'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) => e.toString())
            .toSet(),
        techniques: ((j['tech'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) => e.toString())
            .toSet(),
        lucid: (j['lucid'] as bool?) ?? false,
      );
}

/// Angaben aus dem Einstieg.
class Profile {
  Profile({
    this.experience = 0,
    this.goal = 'explore',
    this.bedHour = 23,
    this.bedMinute = 0,
    this.wakeHour = 7,
    this.wakeMinute = 0,
    this.lightSleeper = false,
    this.intention = defaultIntention,
    List<String>? dreamSigns,
    this.programStart,
  }) : dreamSigns = dreamSigns ?? <String>[];

  static const String defaultIntention =
      'Wenn ich das nächste Mal träume, erkenne ich, dass ich träume.';

  /// 0 noch nie, 1 vereinzelt, 2 regelmäßig.
  int experience;

  /// explore, nightmares, creativity, skills
  String goal;
  int bedHour;
  int bedMinute;
  int wakeHour;
  int wakeMinute;

  /// Empfindlicher Schlaf: weniger Schlafunterbrechung empfehlen.
  bool lightSleeper;
  String intention;
  final List<String> dreamSigns;
  DateTime? programStart;

  /// Geplante Schlafdauer in Minuten.
  int get sleepMinutes {
    int bed = bedHour * 60 + bedMinute;
    int wake = wakeHour * 60 + wakeMinute;
    if (wake <= bed) wake += 24 * 60;
    return wake - bed;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'experience': experience,
        'goal': goal,
        'bedHour': bedHour,
        'bedMinute': bedMinute,
        'wakeHour': wakeHour,
        'wakeMinute': wakeMinute,
        'lightSleeper': lightSleeper,
        'intention': intention,
        'dreamSigns': dreamSigns,
        'programStart': programStart?.toIso8601String(),
      };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        experience: (j['experience'] as num?)?.toInt() ?? 0,
        goal: (j['goal'] as String?) ?? 'explore',
        bedHour: (j['bedHour'] as num?)?.toInt() ?? 23,
        bedMinute: (j['bedMinute'] as num?)?.toInt() ?? 0,
        wakeHour: (j['wakeHour'] as num?)?.toInt() ?? 7,
        wakeMinute: (j['wakeMinute'] as num?)?.toInt() ?? 0,
        lightSleeper: (j['lightSleeper'] as bool?) ?? false,
        intention: (j['intention'] as String?) ?? defaultIntention,
        dreamSigns: ((j['dreamSigns'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(),
        programStart: j['programStart'] == null
            ? null
            : DateTime.tryParse(j['programStart'] as String),
      );
}

/// Zentrale Quelle für den Übungsstand. UI hört über [ChangeNotifier] zu.
class PracticeStore extends ChangeNotifier {
  PracticeStore._();
  static final PracticeStore instance = PracticeStore._();

  static const String _key = 'practice.v1';
  static const String introKey = 'intro_done';

  Profile profile = Profile();
  final Map<String, DayLog> _days = <String, DayLog>{};
  bool _loaded = false;
  bool onboarded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final SharedPreferences sp = await SharedPreferences.getInstance();
    onboarded = sp.getBool(introKey) ?? false;
    final String? raw = sp.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        restoreFromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        // Beschädigter Stand: mit leerem Profil weiterarbeiten.
      }
    }
    _loaded = true;
    notifyListeners();
  }

  /// Nur für Tests und Import: Zustand aus JSON setzen.
  @visibleForTesting
  void restoreFromJson(Map<String, dynamic> j) {
    profile = Profile.fromJson((j['profile'] as Map<String, dynamic>?) ?? <String, dynamic>{});
    _days.clear();
    final Map<String, dynamic> d = (j['days'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    d.forEach((String k, dynamic v) {
      _days[k] = DayLog.fromJson(v as Map<String, dynamic>);
    });
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'profile': profile.toJson(),
        'days': _days.map((String k, DayLog v) => MapEntry<String, dynamic>(k, v.toJson())),
      };

  Future<void> _save() async {
    notifyListeners();
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(toJson()));
  }

  Future<void> completeOnboarding() async {
    onboarded = true;
    profile.programStart ??= dateOnly(DateTime.now());
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool(introKey, true);
    await _save();
  }

  Future<void> saveProfile() => _save();

  Future<void> restartProgram() async {
    profile.programStart = dateOnly(DateTime.now());
    await _save();
  }

  /// Löscht Übungsstand und Profil (Journal bleibt unberührt).
  Future<void> resetAll() async {
    profile = Profile();
    _days.clear();
    onboarded = false;
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
    await sp.setBool(introKey, false);
    notifyListeners();
  }

  // ---------------------------------------------------------------- Tage

  DayLog logFor(DateTime d) => _days[dayKey(d)] ?? DayLog();

  DayLog get today => logFor(DateTime.now());

  DayLog _edit(DateTime d) => _days.putIfAbsent(dayKey(d), () => DayLog());

  Future<void> setRecall(int level, {DateTime? on}) async {
    _edit(on ?? DateTime.now()).recall = level;
    await _save();
  }

  Future<void> addRealityCheck({DateTime? on}) async {
    _edit(on ?? DateTime.now()).realityChecks += 1;
    await _save();
  }

  Future<void> setTaskDone(String taskId, bool done, {DateTime? on}) async {
    final DayLog l = _edit(on ?? DateTime.now());
    if (done) {
      l.doneTasks.add(taskId);
    } else {
      l.doneTasks.remove(taskId);
    }
    await _save();
  }

  Future<void> addTechnique(String id, {DateTime? on}) async {
    _edit(on ?? DateTime.now()).techniques.add(id);
    await _save();
  }

  Future<void> setLucid(bool v, {DateTime? on}) async {
    _edit(on ?? DateTime.now()).lucid = v;
    await _save();
  }

  // ------------------------------------------------------------ Kennzahlen

  /// Programmtag (1-basiert) oder 0, wenn nicht gestartet.
  int programDay({DateTime? now}) {
    final DateTime? s = profile.programStart;
    if (s == null) return 0;
    final int d = dateOnly(now ?? DateTime.now()).difference(dateOnly(s)).inDays + 1;
    return d < 1 ? 1 : d;
  }

  /// Aufeinanderfolgende Tage mit Aktivität, endend heute oder gestern.
  int streak({DateTime? now}) {
    DateTime d = dateOnly(now ?? DateTime.now());
    if (!logFor(d).hasActivity) {
      d = d.subtract(const Duration(days: 1));
    }
    int n = 0;
    while (logFor(d).hasActivity) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// Die letzten [count] Tage, ältester zuerst.
  List<MapEntry<DateTime, DayLog>> lastDays(int count, {DateTime? now}) {
    final DateTime end = dateOnly(now ?? DateTime.now());
    return <MapEntry<DateTime, DayLog>>[
      for (int i = count - 1; i >= 0; i--)
        MapEntry<DateTime, DayLog>(
          end.subtract(Duration(days: i)),
          logFor(end.subtract(Duration(days: i))),
        ),
    ];
  }

  /// Anteil der Morgen mit Traumerinnerung (0..1) über [count] Tage;
  /// nur Tage mit Angabe zählen. null, wenn keine Angaben.
  double? recallRate(int count, {DateTime? now}) {
    int answered = 0;
    int recalled = 0;
    for (final MapEntry<DateTime, DayLog> e in lastDays(count, now: now)) {
      if (e.value.recall >= 0) {
        answered++;
        if (e.value.recall > 0) recalled++;
      }
    }
    if (answered == 0) return null;
    return recalled / answered;
  }

  int realityChecksInLast(int count, {DateTime? now}) {
    int n = 0;
    for (final MapEntry<DateTime, DayLog> e in lastDays(count, now: now)) {
      n += e.value.realityChecks;
    }
    return n;
  }

  /// Nächte (Tage) mit Schlafunterbrechung in den letzten [count] Tagen.
  int wbtbNightsInLast(int count, {DateTime? now}) {
    int n = 0;
    for (final MapEntry<DateTime, DayLog> e in lastDays(count, now: now)) {
      if (e.value.techniques.contains('wbtb')) n++;
    }
    return n;
  }
}
