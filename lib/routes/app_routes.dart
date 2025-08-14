import 'package:flutter/cupertino.dart';
import 'research_named_routes.dart' as research;
import 'wissen_routes_en_quiz_anchors.dart' as wissen;
import '../screens/wissen/studien_feed_page_with_save.dart';
import '../screens/wissen/reading_list_page.dart';

Route<dynamic> onGenerateRoute(RouteSettings s) {
  final name = s.name ?? '';
  if (name.startsWith('/research')) {
    return research.onGenerateResearch(s);
  }
  if (name.startsWith('/wissen')) {
    // special-cases for feed and reading list
    if (name == '/wissen/feed') return CupertinoPageRoute(builder: (_) => const StudienFeedPage(), settings: s);
    if (name == '/wissen/reading_list') return CupertinoPageRoute(builder: (_) => const ReadingListPage(), settings: s);
    return wissen.WissenRoutesEx.onGenerate(s);
  }
  // Unknown
  return CupertinoPageRoute(builder: (_) => const CupertinoPageScaffold(child: Center(child: Text('Unknown route'))), settings: s);
}
