// lib/screens/modules/rc_reminder_store.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cue_models.dart';
import '../../services/cue_player.dart';

enum RcMode { once, daily }

class RcReminder {
  final String id;
  final bool enabled;
  final RcMode mode;
  final DateTime? dateTime; // bei once
  final int? hour;          // bei daily
  final int? minute;        // bei daily
  final String? label;

  RcReminder({
    required this.id,
    required this.enabled,
    required this.mode,
    this.dateTime,
    this.hour,
    this.minute,
    this.label,
  });

  factory RcReminder.create() => RcReminder(
        id: UniqueKey().toString(),
        enabled: true,
        mode: RcMode.once,
        dateTime: DateTime.now().add(const Duration(minutes: 5)),
      );

  RcReminder copyWith({
    String? id,
    bool? enabled,
    RcMode? mode,
    DateTime? dateTime,
    int? hour,
    int? minute,
    String? label,
  }) =>
      RcReminder(
        id: id ?? this.id,
        enabled: enabled ?? this.enabled,
        mode: mode ?? this.mode,
        dateTime: dateTime ?? this.dateTime,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        label: label ?? this.label,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'enabled': enabled,
        'mode': mode.name,
        'dateTime': dateTime?.toIso8601String(),
        'hour': hour,
        'minute': minute,
        'label': label,
      };

  factory RcReminder.fromJson(Map<String, dynamic> m) => RcReminder(
        id: m['id'] as String,
        enabled: (m['enabled'] ?? true) as bool,
        mode: (m['mode'] == 'daily') ? RcMode.daily : RcMode.once,
        dateTime: m['dateTime'] == null ? null : DateTime.parse(m['dateTime'] as String),
        hour: m['hour'] as int?,
        minute: m['minute'] as int?,
        label: m['label'] as String?,
      );

  /// Nächster Auslösezeitpunkt nach [now] (null, wenn keiner)
  DateTime? nextFireAfter(DateTime now) {
    if (!enabled) return null;
    if (mode == RcMode.once) {
      if (dateTime == null) return null;
      return dateTime!.isAfter(now) ? dateTime : null;
    }
    if (hour == null || minute == null) return null;
    final today = DateTime(now.year, now.month, now.day, hour!, minute!);
    return today.isAfter(now) ? today : today.add(const Duration(days: 1));
  }
}

class RcReminderStore {
  RcReminderStore._();
  static final instance = RcReminderStore._();

  static const _kList = 'rc.reminders.v1';
  static const _kLastFire = 'rc.lastfire.v1'; // Map<id, iso>

  final _player = CueLoopPlayer.instance;

  final _items = <RcReminder>[];
  List<RcReminder> get items =>
      List<RcReminder>.from(_items)
        ..sort((a, b) => (a.nextFireAfter(DateTime.now()) ?? DateTime(2100))
            .compareTo(b.nextFireAfter(DateTime.now()) ?? DateTime(2100)));

  // UI-Notifier
  final revision = StreamController<int>.broadcast();
  void _bump() => revision.add(DateTime.now().millisecondsSinceEpoch);

  Timer? _timer;

  Future<void> init() async {
    await _load();
    _startScheduler();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kList);
    _items.clear();
    if (s == null) return;
    final list = (jsonDecode(s) as List).cast<Map<String, dynamic>>();
    _items.addAll(list.map(RcReminder.fromJson));
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    final data = jsonEncode(_items.map((e) => e.toJson()).toList());
    await sp.setString(_kList, data);
    _bump();
  }

  Future<void> add(RcReminder r) async { _items.add(r); await _save(); }
  Future<void> update(RcReminder r) async {
    final i = _items.indexWhere((x) => x.id == r.id);
    if (i >= 0) _items[i] = r;
    await _save();
  }
  Future<void> remove(String id) async { _items.removeWhere((e) => e.id == id); await _save(); }

  // --------- Scheduler (In-App) ----------

  void _startScheduler() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _tick());
    Future.delayed(const Duration(seconds: 1), _tick);
  }

  Future<void> _tick() async {
    if (_items.isEmpty) return;

    final now = DateTime.now();
    final sp = await SharedPreferences.getInstance();
    final lastMap = Map<String, String>.from(
      jsonDecode(sp.getString(_kLastFire) ?? '{}') as Map<String, dynamic>,
    );

    for (final r in _items.where((e) => e.enabled)) {
      final next = r.nextFireAfter(now);
      if (next == null) continue;

      final lastStr = lastMap[r.id];
      final last = lastStr == null ? null : DateTime.tryParse(lastStr);

      final due = next.isBefore(now.add(const Duration(seconds: 1))) &&
          (last == null || now.difference(last).inMinutes >= 1);

      if (due) {
        await _fire();
        lastMap[r.id] = now.toIso8601String();
        if (r.mode == RcMode.once) {
          await update(r.copyWith(enabled: false));
        }
      }
    }

    await sp.setString(_kLastFire, jsonEncode(lastMap));
  }

  Future<void> _fire() async {
    // Cue laden
    final sp = await SharedPreferences.getInstance();
    final json = sp.getString('cue.selected.v1');
    CueSound? cue;
    if (json != null) {
      final m = jsonDecode(json) as Map<String, dynamic>;
      cue = CueSound(
        id: (m['id'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        category: (m['category'] ?? '') as String,
        asset: (m['asset'] ?? '') as String,
      );
    }
    final vol = sp.getDouble('rc.volume.v1') ?? .8;

    try {
      if (cue != null) {
        await _player.playOnce(cue, seconds: 3, volume: vol);
      } else {
        await (_player as dynamic)
            .playOnce('assets/audio/cues/soft-chim.mp3', seconds: 3, volume: vol);
      }
    } catch (_) {
      try {
        await (_player as dynamic)
            .playOnce(cue == null ? 'assets/audio/cues/soft-chim.mp3' : (cue as dynamic).asset as String,
                      seconds: 3, volume: vol);
      } catch (_) {}
    }
  }
}
