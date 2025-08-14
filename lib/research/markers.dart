import 'storage.dart';

class Markers {
  static Future<void> log(String label, {Map<String, dynamic>? meta}) async {
    final ts = DateTime.now().toIso8601String();
    await ResearchStorage.appendMarker({'ts_iso': ts, 'label': label, 'meta': meta ?? {}});
  }
}
