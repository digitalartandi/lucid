import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';
import '../../journal/journal_repo.dart';
import '../../research/storage.dart';

class ExportJsonPage extends StatefulWidget {
  const ExportJsonPage({super.key});
  @override State<ExportJsonPage> createState()=> _ExportJsonState();
}
class _ExportJsonState extends State<ExportJsonPage> {
  String? path;
  Future<void> _export() async {
    final dir = await getApplicationSupportDirectory();
    final f = File('${dir.path}/export.json');
    final study = await ResearchStorage.loadStudy();
    final journal = await JournalRepoFactory.get().listEntries();
    final markers = await ResearchStorage.readMarkersTail(lines: 100000);
    final payload = {
      'study': study?.toJson(),
      'journal': journal,
      'markers_csv': markers,
      'ts_export': DateTime.now().toIso8601String(),
    };
    await f.writeAsString(jsonEncode(payload));
    setState(()=> path = f.path);
  }
  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(title: 'Study Pack Export (JSON)', child: Column(children: [
      Section(children: [
        RowItem(title: const Text('Exportieren'), subtitle: const Text('Studie + Journal + Marker'), onTap: _export),
        if (path!=null) RowItem(title: const Text('Gespeichert unter'), subtitle: Text(path!)),
      ]),
    ]));
  }
}

class ExportCsvPage extends StatefulWidget {
  const ExportCsvPage({super.key});
  @override State<ExportCsvPage> createState()=> _ExportCsvState();
}
class _ExportCsvState extends State<ExportCsvPage> {
  String? journalPath;
  String? markersPath;
  Future<void> _exportJournal() async {
    final dir = await getApplicationSupportDirectory();
    final f = File('${dir.path}/journal_export.csv');
    final rows = await JournalRepoFactory.get().listEntries();
    final buf = StringBuffer('ts_iso,clarity,text\n');
    for (final r in rows) {
      buf.writeln('${r['ts'] ?? ''},${r['clarity'] ?? ''},"${(r['text'] ?? '').toString().replaceAll('"','""')}"');
    }
    await f.writeAsString(buf.toString());
    setState(()=> journalPath = f.path);
  }
  Future<void> _exportMarkers() async {
    final dir = await getApplicationSupportDirectory();
    final f = File('${dir.path}/markers_export.csv');
    final lines = await ResearchStorage.readMarkersTail(lines: 100000);
    await f.writeAsString(lines.join('\n'));
    setState(()=> markersPath = f.path);
  }
  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(title: 'CSV Export', child: Column(children: [
      Section(children: [
        RowItem(title: const Text('Journal exportieren'), subtitle: const Text('CSV'), onTap: _exportJournal),
        if (journalPath!=null) RowItem(title: const Text('Gespeichert unter'), subtitle: Text(journalPath!)),
      ]),
      Section(children: [
        RowItem(title: const Text('Marker exportieren'), subtitle: const Text('CSV'), onTap: _exportMarkers),
        if (markersPath!=null) RowItem(title: const Text('Gespeichert unter'), subtitle: Text(markersPath!)),
      ]),
    ]));
  }
}






