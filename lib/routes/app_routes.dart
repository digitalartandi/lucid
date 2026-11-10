// lib/routes/app_routes.dart
//
// Alle benannten Routen der App. Wird vom Wurzel-Navigator und von den
// Navigatoren der vier Tabs gemeinsam verwendet.
import 'package:flutter/cupertino.dart';

import '../features/insights/insights_page.dart';
import '../features/journal/entry_page.dart';
import '../features/night/night_page.dart';
import '../features/practice/program_page.dart';
import '../features/practice/rc_page.dart';
import '../features/practice/session_page.dart';
import '../features/practice/signs_page.dart';
import '../features/practice/technique_page.dart';
import '../features/settings/settings_page.dart';
import '../features/wissen/article_page.dart';
import '../screens/affirmations/affirmation_hub_page.dart';
import '../screens/affirmations/affirmation_player_page.dart';
import '../screens/cues/cue_library_page.dart';
import '../screens/meditation/meditation_hub_page.dart';
import '../screens/meditation/meditation_player_page.dart';
import '../screens/modules/cue_tuning_page.dart';
import '../screens/modules/rc_reminder_page.dart';
import '../screens/traumreisen/traumreise_player_page.dart';
import '../screens/traumreisen/traumreisen_hub_page.dart';
import '../screens/wissen/reading_list_page.dart';
import '../screens/wissen/studien_feed_page_with_save.dart';
import '../ui/tokens.dart';
import '../ui/widgets.dart';
import 'research_named_routes.dart' as research;

String _argString(Object? a, [String fallback = '']) => a is String ? a : fallback;

Route<dynamic> onGenerateRoute(RouteSettings s) {
  // Die Einstellungen werden durchgereicht, damit Seiten ihre Argumente lesen können.
  CupertinoPageRoute<dynamic> page(Widget w, {bool fullscreen = false}) =>
      CupertinoPageRoute<dynamic>(
        builder: (_) => w,
        settings: s,
        fullscreenDialog: fullscreen,
      );

  final String name = s.name ?? '';
  if (name.startsWith('/research')) return research.onGenerateResearch(s);

  switch (name) {
    // --- Heute / Programm ---
    case '/program':
      return page(const ProgramPage());
    case '/insights':
      return page(const InsightsPage());
    case '/settings':
      return page(const SettingsPage());

    // --- Üben ---
    case '/practice/technique':
      return page(TechniquePage(id: _argString(s.arguments)));
    case '/practice/session':
      return page(SessionPage(id: _argString(s.arguments)), fullscreen: true);
    case '/practice/rc':
      return page(const RealityCheckPage());
    case '/practice/signs':
      return page(const DreamSignsPage());
    case '/practice/intention':
      return page(const IntentionPage());
    case '/night':
      return page(const NightSetupPage(), fullscreen: true);
    case '/rc':
      return page(const RcReminderPage());
    case '/cues':
      return page(const CueLibraryPage());
    case '/cuetuning':
      return page(const CueTuningPage());
    case '/cues/background':
    case '/cue/background':
      return page(const CueBackgroundPickerPage());

    // --- Journal ---
    case '/journal/new':
      return page(const EntryPage());
    case '/journal/edit':
      return page(EntryPage(id: _argString(s.arguments)));

    // --- Wissen ---
    case '/wissen/article':
      return page(ArticlePage(assetPath: _argString(s.arguments, 'assets/wissen/grundlagen_de.md')));
    case '/studien':
    case '/wissen/studies':
      return page(const StudienFeedPage());
    case '/reading_list':
      return page(const ReadingListPage());

    // --- Entspannung ---
    case '/traumreisen':
      return page(const TraumreisenHubPage());
    case '/traumreisen/play':
      return page(TraumreisePlayerPage(id: _argString(s.arguments)));
    case '/meditations':
      return page(const MeditationHubPage());
    case '/meditations/play':
      return page(MeditationPlayerPage(id: _argString(s.arguments)));
    case '/affirmations':
      return page(const AffirmationHubPage());
    case '/affirmations/play':
      return page(AffirmationPlayerPage(id: _argString(s.arguments)));

    default:
      return page(_UnknownRoute(name: name));
  }
}

class _UnknownRoute extends StatelessWidget {
  const _UnknownRoute({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return LPage(
      title: 'Nicht gefunden',
      child: Padding(
        padding: const EdgeInsets.all(LS.page),
        child: LEmpty(
          icon: CupertinoIcons.compass,
          title: 'Diese Seite gibt es nicht',
          text: name.isEmpty ? 'Geh zurück und versuch es noch einmal.' : 'Unbekanntes Ziel: $name',
        ),
      ),
    );
  }
}
