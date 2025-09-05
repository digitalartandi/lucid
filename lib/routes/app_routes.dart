// lib/routes/app_routes.dart
import 'package:flutter/cupertino.dart';

// Intro
import '../screens/onboarding/intro_landing_page.dart';
import '../screens/onboarding/intro_stepper_page.dart';

// Traumreisen
import '../screens/traumreisen/traumreisen_hub_page.dart';
import '../screens/traumreisen/traumreise_player_page.dart';

// Module
import '../screens/modules/rc_reminder_page.dart';
import '../screens/modules/night_lite_page.dart';
import '../screens/modules/trainer_page.dart';
import '../screens/modules/cue_tuning_page.dart';

// Hilfe
import '../screens/help/help_center_page.dart';

// Wissen
import '../screens/wissen/wissen_hub_page.dart';
import '../screens/wissen/wissen_article_page.dart';
import '../screens/wissen/faq_basics_page.dart';
import '../screens/wissen/reading_list_page.dart';
import '../screens/wissen/knowledge_accordion_page.dart'; // ← NEU: Accordion-Seite importieren

// Studien-Feed
import '../screens/wissen/studien_feed_page_with_save.dart';

// Journal
import '../screens/journal/journal_list_page.dart';
import '../screens/journal/journal_entry_page.dart';
import '../services/journal_repo.dart';
import '../models/journal_models.dart';

// Account
import '../screens/account/account_settings_page.dart';

// Cues
import '../screens/cues/cue_library_page.dart';

// Meditation
import '../screens/meditation/meditation_hub_page.dart';
import '../screens/meditation/meditation_player_page.dart';

// Affirmationen
import '../screens/affirmations/affirmation_hub_page.dart';
import '../screens/affirmations/affirmation_player_page.dart';


CupertinoPageRoute<T> _c<T>(Widget w) => CupertinoPageRoute<T>(builder: (_) => w);
String _argString(Object? a, [String fallback = '']) => a is String ? a : fallback;

Route<dynamic> onGenerateRoute(RouteSettings s) {
  switch (s.name) {
    // --- sichere Defaults / Einstieg ---
    case '/':
      return _c(const WissenHubPage()); // unverändert: Root kann weiter auf den Hub zeigen
    case '/wissen':
      return _c(const KnowledgeAccordionPage()); // ← GEÄNDERT: Wissen-Tab zeigt jetzt das Accordion

    // --- Module ---
    case '/rc':
      return _c(const RcReminderPage());
    case '/nightlite':
      return _c(const NightLitePage());
    case '/trainer':
      return _c(const TrainerPage());
    case '/cuetuning':
      return _c(const CueTuningPage());

    // --- Traumreisen ---
    case '/traumreisen':
      return _c(const TraumreisenHubPage());
    case '/traumreisen/play': {
      final id = _argString(s.arguments, '');
      if (id.isEmpty) {
        return _c(const _UnknownRouteScreen(name: '/traumreisen/play (ohne ID)'));
      }
      return _c(TraumreisePlayerPage(id: id));
    }

    // --- Journal ---
    case '/journal':
      return _c(const JournalListPage());
    case '/journal/new':
      return _c(const _JournalNewEntryLauncher());
    case '/journal/edit': {
      final id = _argString(s.arguments, '');
      if (id.isEmpty) {
        return _c(const _UnknownRouteScreen(name: '/journal/edit (ohne ID)'));
      }
      return _c(JournalEntryPage(id: id));
    }

    // --- Affirmationen ---
    case '/affirmations':
      return _c(const AffirmationHubPage());
    case '/affirmations/play': {
      final id = s.arguments is String ? s.arguments as String : '';
      if (id.isEmpty) return _c(const _UnknownRouteScreen(name: '/affirmations/play (ohne ID)'));
      return _c(AffirmationPlayerPage(id: id));
    }

    // --- Hilfe / Onboarding ---
    case '/help':
      return _c(const HelpCenterPage());
    case '/onboarding':
      return _c(const IntroStepperPage());

    // --- Wissen: Artikel & FAQ ---
    case '/wissen/article': {
      final path = _argString(s.arguments, 'assets/wissen/grundlagen_de.md');
      return _c(WissenArticlePage(assetPath: path));
    }
    case '/wissen/faq_basics':
      return _c(const FaqBasicsPage());

    // --- Leseliste ---
    case '/reading_list':
      return _c(const ReadingListPage());

    // --- Cues Bibliothek ---
    case '/cues':
      return _c(const CueLibraryPage());

    // --- Studien-Feed (Aliase) ---
    case '/studien':
    case '/wissen/studies':
      return _c(const StudienFeedPage());

    // --- Account ---
    case '/account':
      return _c(const AccountSettingsPage());

    // --- Intro ---
    case '/intro':
      return _c(const IntroLandingPage());
    case '/intro/stepper':
      return _c(const IntroStepperPage());

    // --- Meditations / Soundscapes ---
    case '/meditations':
      return _c(const MeditationHubPage());
    case '/meditations/play': {
      final id = _argString(s.arguments, '');
      if (id.isEmpty) {
        return _c(const _UnknownRouteScreen(name: '/meditations/play (ohne ID)'));
      }
      return _c(MeditationPlayerPage(id: id));
    }

    // --- Fallback: unbekannte Route ---
    default:
      return _c(_UnknownRouteScreen(name: s.name));
  }
}

/// Launcher, der sofort einen neuen Journal-Draft anlegt
/// und den Editor öffnet. Danach kehrt er zur Liste zurück.
class _JournalNewEntryLauncher extends StatefulWidget {
  const _JournalNewEntryLauncher();

  @override
  State<_JournalNewEntryLauncher> createState() => _JournalNewEntryLauncherState();
}

class _JournalNewEntryLauncherState extends State<_JournalNewEntryLauncher> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await JournalRepo.instance.init();
    final draft = JournalEntry.newDraft();
    await JournalRepo.instance.upsert(draft);

    if (!mounted) return;
    await Navigator.of(context).pushReplacementNamed('/journal/edit', arguments: draft.id);
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Journal')),
      child: Center(child: CupertinoActivityIndicator()),
    );
  }
}

/// Einfacher, dunkler Fallback-Screen mit heller Typo.
class _UnknownRouteScreen extends StatelessWidget {
  final String? name;
  const _UnknownRouteScreen({this.name});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0E0D18);
    const title = Color(0xFFE9EAFF);
    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: const CupertinoNavigationBar(middle: Text('Seite')),
      child: Center(
        child: Text(
          'Unbekannte Route: ${name ?? ''}',
          style: const TextStyle(color: title),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
