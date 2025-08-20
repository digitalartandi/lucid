import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cue_models.dart';

class CueSelection {
  final String id;
  final String name;
  final String asset;
  final String category;

  const CueSelection({
    required this.id,
    required this.name,
    required this.asset,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'asset': asset,
        'category': category,
      };

  factory CueSelection.fromJson(Map<String, dynamic> j) => CueSelection(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        asset: j['asset'] ?? '',
        category: j['category'] ?? '',
      );
}

class CuePrefs {
  static const _key = 'selected_cue_v2';
  static final ValueListenable<CueSelection?> selection = _selection;
  static final ValueNotifier<CueSelection?> _selection =
      ValueNotifier<CueSelection?>(null);

  static Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_key);
    if (s != null && s.isNotEmpty) {
      _selection.value = CueSelection.fromJson(jsonDecode(s));
    }
  }

  static Future<void> setFromCue(CueSound s) async {
    await set(CueSelection(
      id: s.id,
      name: s.name,
      asset: s.asset,
      category: s.category,
    ));
  }

  static Future<void> set(CueSelection sel) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(sel.toJson()));
    _selection.value = sel;
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
    _selection.value = null;
  }
}
