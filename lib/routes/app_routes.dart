import 'package:flutter/cupertino.dart';

// Module
import '../screens/modules/rc_reminder_page.dart';
import '../screens/modules/night_lite_page.dart';
import '../screens/modules/trainer_page.dart';
import '../screens/modules/cue_tuning_page.dart';
import '../screens/modules/journal_page.dart';

// Hilfe / Onboarding
import '../screens/help/help_center_page.dart';
import '../screens/onboarding/start_screen.dart';

// WISSEN
import '../screens/wissen/wissen_hub_page.dart';           // ← NEU: Hub
import '../screens/wissen/wissen_article_page.dart';
import '../screens/wissen/reading_list_page.dart';        // optional, falls vorhanden

// Studien-Feed
import '../screens/wissen/studien_feed_page_with_save.dart';

CupertinoPageRoute _c(Widget w) => CupertinoPageRoute(builder: (_) => w);

Route<dynamic> onGenerateRoute(RouteSettings s) {
  switch (s.name) {
    // Module
    case '/rc':         return _c(const RcReminderPage());
    case '/nightlite':  return _c(const NightLitePage());
    case '/trainer':    return _c(const TrainerPage());
    case '/cuetuning':  return _c(const CueTuningPage());
    case '/journal':    return _c(const JournalPage());

    // Hilfe / Onboarding
    case '/help':       return _c(const HelpCenterPage());
    case '/onboarding': return _c(const OnboardingStart());

    // Wissen (Hub + Artikel)
    case '/wissen':           return _c(const WissenHubPage()); // ← statt WissenIndexSimple
    case '/wissen/article':   return _c(WissenArticlePage(assetPath: s.arguments as String));

    // Leseliste (optional)
    case '/reading_list':     return _c(const ReadingListPage());

    // Studien-Feed (Aliase)
    case '/studien':
    case '/wissen/studies':
      return _c(const StudienFeedPage());

    // Fallback
    default:
      return _c(CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Seite')),
        child: Center(child: Text('Unbekannte Route: ${s.name}')),
      ));
  }
}
