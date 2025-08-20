import 'dart:convert' show jsonDecode;
import 'package:flutter/services.dart' show rootBundle;
import '../models/meditation_models.dart';

class MeditationRepo {
  MeditationRepo._();
  static final instance = MeditationRepo._();

  List<MeditationTrack> _all = const [];

  Future<void> init() async {
    if (_all.isNotEmpty) return;
    final s = await rootBundle.loadString('assets/meditations/manifest.json');
    final data = jsonDecode(s) as Map<String, dynamic>;
    final list = (data['items'] as List).cast<Map<String, dynamic>>();
    _all = list.map(MeditationTrack.fromJson).toList(growable: false);
  }

  Future<List<MeditationTrack>> all() async {
    await init();
    return _all;
  }

  Future<MeditationTrack?> byId(String id) async {
    await init();
    try { return _all.firstWhere((e) => e.id == id); } catch (_) { return null; }
  }

  // einfache Kategorien (aus manifest.category)
  Future<Map<String, List<MeditationTrack>>> byCategory() async {
    await init();
    final map = <String, List<MeditationTrack>>{};
    for (final t in _all) {
      map.putIfAbsent(t.category, () => []).add(t);
    }
    return map;
  }
}
