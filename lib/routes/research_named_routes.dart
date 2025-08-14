import 'package:flutter/cupertino.dart';
import '../screens/research/study_builder_page.dart';
import '../screens/research/lrlr_page.dart';
import '../screens/research/live_event_stream_page.dart';
import '../screens/research/exports_page.dart';

class R {
  static const studyBuilder = '/research/study_builder';
  static const lrLR = '/research/lr_lr';
  static const eventStream = '/research/event_stream';
  static const exportJson = '/research/export_json';
  static const exportCsv = '/research/export_csv';
  static const audioLab = '/audio/lab';
}

Route<dynamic> onGenerateResearch(RouteSettings settings) {
  Widget page;
  switch (settings.name) {
    case R.studyBuilder: page = const StudyBuilderPage(); break;
    case R.lrLR: page = const LrLrPage(); break;
    case R.eventStream: page = const LiveEventStreamPage(); break;
    case R.exportJson: page = const ExportJsonPage(); break;
    case R.exportCsv: page = const ExportCsvPage(); break;
    default: page = _Unknown(name: settings.name ?? ''); break;
  }
  return CupertinoPageRoute(builder: (_) => page, settings: settings);
}

class _Unknown extends StatelessWidget {
  final String name;
  const _Unknown({Key? key, required this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Unbekannte Route')),
      child: Center(child: Text('Keine Seite für: $name')),
    );
  }
}







