import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class JournalRepo {
  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/journal.json');
  }

  Future<List<Map<String, dynamic>>> listEntries() async {
    final f = await _file();
    if (!await f.exists()) return <Map<String, dynamic>>[];
    try {
      final j = jsonDecode(await f.readAsString());
      return (j as List).cast<Map<String, dynamic>>();
    } catch (_) { return <Map<String, dynamic>>[]; }
  }

  Future<void> addEntry({required String text, int clarity = 3}) async {
    final f = await _file();
    final arr = await listEntries();
    arr.add({'ts': DateTime.now().toIso8601String(), 'text': text, 'clarity': clarity});
    await f.writeAsString(jsonEncode(arr));
  }
}

class JournalRepoFactory {
  static JournalRepo get() => JournalRepo();
}






