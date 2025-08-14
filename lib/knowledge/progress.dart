import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

String slugify(String s) {
  final lower = s.trim().toLowerCase();
  final only = lower.replaceAll(RegExp(r'[^a-z0-9\s\-]'), '');
  return only.replaceAll(RegExp(r'\s+'), '-');
}

class KnowledgeProgress {
  final String asset;
  final Set<String> visitedSlugs;
  final double scrollPct;
  final DateTime updatedAt;
  KnowledgeProgress({required this.asset, required this.visitedSlugs, required this.scrollPct, DateTime? updatedAt})
    : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'asset': asset,
    'visited': visitedSlugs.toList(),
    'scrollPct': scrollPct,
    'updatedAt': updatedAt.toIso8601String(),
  };

  static KnowledgeProgress fromJson(Map<String, dynamic> j) => KnowledgeProgress(
    asset: j['asset'],
    visitedSlugs: ((j['visited'] ?? []) as List).map((e)=> e.toString()).toSet(),
    scrollPct: (j['scrollPct'] ?? 0.0) * 1.0,
    updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
  );
}

class KnowledgeProgressRepo {
  static Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/knowledge_progress.json');
  }

  static Future<Map<String, KnowledgeProgress>> _loadAll() async {
    final f = await _file();
    if (!await f.exists()) return {};
    try {
      final j = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      return j.map((k,v)=> MapEntry(k, KnowledgeProgress.fromJson(v)));
    } catch (_) { return {}; }
  }

  static Future<void> _saveAll(Map<String, KnowledgeProgress> m) async {
    final f = await _file();
    final j = m.map((k,v)=> MapEntry(k, v.toJson()));
    await f.writeAsString(jsonEncode(j));
  }

  static Future<KnowledgeProgress> get(String asset) async {
    final all = await _loadAll();
    return all[asset] ?? KnowledgeProgress(asset: asset, visitedSlugs: {}, scrollPct: 0.0);
  }

  static Future<void> markVisited(String asset, String slug) async {
    final all = await _loadAll();
    final cur = all[asset] ?? KnowledgeProgress(asset: asset, visitedSlugs: {}, scrollPct: 0.0);
    cur.visitedSlugs.add(slug);
    all[asset] = KnowledgeProgress(asset: asset, visitedSlugs: cur.visitedSlugs, scrollPct: cur.scrollPct, updatedAt: DateTime.now());
    await _saveAll(all);
  }

  static Future<void> setScroll(String asset, double pct) async {
    final all = await _loadAll();
    final cur = all[asset] ?? KnowledgeProgress(asset: asset, visitedSlugs: {}, scrollPct: 0.0);
    final npct = pct.clamp(0.0, 1.0);
    all[asset] = KnowledgeProgress(asset: asset, visitedSlugs: cur.visitedSlugs, scrollPct: npct, updatedAt: DateTime.now());
    await _saveAll(all);
  }
}
