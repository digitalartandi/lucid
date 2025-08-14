import 'package:flutter/cupertino.dart';
import '../screens/modules/rc_reminder_page.dart';
import '../screens/modules/night_lite_page.dart';
import '../screens/modules/trainer_page.dart';
import '../screens/modules/cue_tuning_page.dart';
import '../screens/modules/journal_page.dart';
import '../screens/help/help_center_page.dart';
import '../screens/wissen/wissen_index_simple.dart';
import '../screens/wissen/wissen_article_page.dart';

CupertinoPageRoute _c(Widget w) =>
  CupertinoPageRoute(builder: (_) => w);

Route<dynamic> onGenerateRoute(RouteSettings s) {
  switch (s.name) {
    case '/rc':         return _c(const RcReminderPage());
    case '/nightlite':  return _c(const NightLitePage());
    case '/trainer':    return _c(const TrainerPage());
    case '/cuetuning':  return _c(const CueTuningPage());
    case '/journal':    return _c(const JournalPage());
    case '/help':       return _c(const HelpCenterPage());
    case '/wissen':     return _c(const WissenIndexSimple());
    case '/wissen/article':
      return _c(WissenArticlePage(assetPath: s.arguments as String));
    default:
      return _c(CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Seite')),
        child: Center(child: Text('Unbekannte Route: ${s.name}')),
      ));
  }
}


