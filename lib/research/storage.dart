import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'models.dart';

class ResearchStorage {
  static Future<File> _file(String name) async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$name');
  }

  static Future<void> saveStudy(Study study) async {
    final f = await _file('study.json');
    await f.writeAsString(jsonEncode(study.toJson()));
  }

  static Future<Study?> loadStudy() async {
    final f = await _file('study.json');
    if (!await f.exists()) return null;
    try { return Study.fromJson(jsonDecode(await f.readAsString())); } catch (_) { return null; }
  }

  static Future<void> appendMarker(Map<String, dynamic> row) async {
    final f = await _file('markers.csv');
    if (!await f.exists()) {
      await f.writeAsString('ts_iso,label,meta_json\n');
    }
    final meta = jsonEncode(row['meta'] ?? {});
    final line = '${row['ts_iso']},${row['label']},$meta\n';
    await f.writeAsString(line, mode: FileMode.append);
  }

  static Future<List<String>> readMarkersTail({int lines = 50}) async {
    final f = await _file('markers.csv');
    if (!await f.exists()) return <String>[];
    try {
      final txt = await f.readAsString();
      final rows = txt.trim().split('\n');
      return rows.reversed.take(lines).toList().reversed.toList();
    } catch (_) { return <String>[]; }
  }
}






