// lib/features/shell/app_shell.dart
//
// Vier Bereiche entlang des Lernwegs: Heute, Üben, Journal, Wissen.
import 'package:flutter/cupertino.dart';

import '../../routes/app_routes.dart' as app;
import '../../ui/tokens.dart';
import '../journal/journal_page.dart';
import '../practice/practice_page.dart';
import '../today/today_page.dart';
import '../wissen/wissen_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  /// Tab-Steuerung, damit Seiten gezielt den Bereich wechseln können.
  static final CupertinoTabController tabs = CupertinoTabController();

  static const int tabToday = 0;
  static const int tabPractice = 1;
  static const int tabJournal = 2;
  static const int tabWissen = 3;

  static void goTo(int index) => tabs.index = index;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final List<GlobalKey<NavigatorState>> _navKeys = <GlobalKey<NavigatorState>>[
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  int _last = 0;

  void _onTap(int index) {
    // Erneutes Tippen auf den aktiven Tab führt zurück zur Wurzel.
    if (index == _last) {
      _navKeys[index].currentState?.popUntil((Route<dynamic> r) => r.isFirst);
    }
    _last = index;
  }

  @override
  void initState() {
    super.initState();
    AppShell.tabs.addListener(_sync);
  }

  void _sync() => _last = AppShell.tabs.index;

  @override
  void dispose() {
    AppShell.tabs.removeListener(_sync);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: AppShell.tabs,
      backgroundColor: LC.night,
      tabBar: CupertinoTabBar(
        onTap: _onTap,
        backgroundColor: LC.night,
        activeColor: LC.iris,
        inactiveColor: LC.faint,
        iconSize: 24,
        height: 58,
        border: const Border(top: BorderSide(color: LC.line, width: 1)),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.moon_stars),
            activeIcon: Icon(CupertinoIcons.moon_stars_fill),
            label: 'Heute',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.sparkles),
            label: 'Üben',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            activeIcon: Icon(CupertinoIcons.book_fill),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.lightbulb),
            activeIcon: Icon(CupertinoIcons.lightbulb_fill),
            label: 'Wissen',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          navigatorKey: _navKeys[index],
          onGenerateRoute: app.onGenerateRoute,
          builder: (BuildContext context) {
            switch (index) {
              case AppShell.tabToday:
                return const TodayPage();
              case AppShell.tabPractice:
                return const PracticePage();
              case AppShell.tabJournal:
                return const JournalPage();
              default:
                return const WissenPage();
            }
          },
        );
      },
    );
  }
}

/// Öffnet eine benannte Route; Vollbild-Abläufe über den Tabs.
Future<Object?> openRoute(
  BuildContext context,
  String route, {
  Object? arg,
  bool root = false,
}) {
  return Navigator.of(context, rootNavigator: root).pushNamed<Object?>(route, arguments: arg);
}
