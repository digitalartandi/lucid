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

// Wissen
import '../screens/wissen/wissen_hub_page.dart';       // Hub / Übersichtsseite
import '../screens/wissen/wissen_article_page.dart';   // Markdown-Artikel
import '../screens/wissen/faq_basics_page.dart';       // FAQ-Einstieg
import '../screens/wissen/reading_list_page.dart';     // Leseliste

// Studien-Feed
import '../screens/wissen/studien_feed_page_with_save.dart';

CupertinoPageRoute<T> _c<T>(Widget w) =>
    CupertinoPageRoute<T>(builder: (_) => w);

String _argString(Object? a, [String fallback = '']) =>
    a is String ? a : fallback;

Route<dynamic> onGenerateRoute(RouteSettings s) {
  switch (s.name) {
    // --- sichere Defaults / Einstieg ins Wissen ---
    // Wichtig: Einige Navigatoren initialisieren mit '/'.
    // Wir leiten beides auf den Wissen-Hub um.
    case '/':
    case '/wissen':
      return _c(const WissenHubPage());

    // --- Module ---
    case '/rc':
      return _c(const RcReminderPage());
    case '/nightlite':
      return _c(const NightLitePage());
    case '/trainer':
      return _c(const TrainerPage());
    case '/cuetuning':
      return _c(const CueTuningPage());
    case '/journal':
      return _c(const JournalPage());

    // --- Hilfe / Onboarding ---
    case '/help':
      return _c(const HelpCenterPage());
    case '/onboarding':
      return _c(const OnboardingStart());

    // --- Wissen: Artikel & FAQ ---
    case '/wissen/article': {
      final path = _argString(
        s.arguments,
        // Fallback: zeigt Grundlagen, falls kein Pfad übergeben wurde.
        'assets/wissen/grundlagen_de.md',
      );
      return _c(WissenArticlePage(assetPath: path));
    }
    case '/wissen/faq_basics':
      return _c(const FaqBasicsPage());

    // --- Leseliste ---
    case '/reading_list':
      return _c(const ReadingListPage());

    // --- Studien-Feed (Aliase) ---
    case '/studien':
    case '/wissen/studies':
      return _c(const StudienFeedPage());

    // --- Fallback: unbekannte Route ---
    default:
      return _c(_UnknownRouteScreen(name: s.name));
  }
}

/// Einfacher, dunkler Fallback-Screen mit heller Typo.
class _UnknownRouteScreen extends StatelessWidget {
  final String? name;
  const _UnknownRouteScreen({this.name});

  @override
  Widget build(BuildContext context) {
    return const Color(0x00000000) == const Color(0x00000000)
        ? CupertinoPageScaffold(
            backgroundColor: const Color(0x00000000),
            navigationBar:
                const CupertinoNavigationBar(middle: Text('Seite')),
            child: Center(
              child: Text(
                'Unbekannte Route: ${''}',
                // Platzhalter wird gleich ersetzt
                style: const TextStyle(color: Color(0xFFE9EAFF)),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
