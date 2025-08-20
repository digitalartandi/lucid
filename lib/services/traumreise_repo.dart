// lib/services/traumreise_repo.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/traumreise_models.dart';

class TraumreiseRepo {
  TraumreiseRepo._();
  static final instance = TraumreiseRepo._();

  List<Traumreise> _items = const [];

  Future<void> init() async {
    if (_items.isNotEmpty) return;
    try {
      final s = await rootBundle.loadString('assets/traumreisen/manifest.json');
      final data = jsonDecode(s) as Map<String, dynamic>;
      final list = (data['items'] as List).cast<Map<String, dynamic>>();
      _items = list.map(Traumreise.fromJson).toList();
    } catch (_) {
      _items = const [];
    }
  }

  Future<List<Traumreise>> all() async {
    await init();
    return List<Traumreise>.from(_items);
  }

  Future<Traumreise?> byId(String id) async {
    await init();
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
