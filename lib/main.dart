import 'package:flutter/cupertino.dart';
import 'routes/app_routes.dart' as app;
import 'screens/home/home_page.dart';
import 'routes/wissen_routes_en_quiz_anchors.dart' as wissen;
import 'routes/research_named_routes.dart' as research;
import 'screens/wissen/studien_feed_page_with_save.dart'; // <— NEU

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // Kein const – onGenerateRoute ist keine Konstante
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: app.onGenerateRoute,
      home: const RootTabs(),
    );
  }
}

class RootTabs extends StatelessWidget {
  const RootTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      // Kein const beim TabBar-Widget (intern werden Längen geprüft)
      tabBar: CupertinoTabBar(items: const [
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.house), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.book), label: 'Wissen'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.lab_flask), label: 'Research'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_list), label: 'Feed'),
      ]),
      tabBuilder: (ctx, idx) {
        switch (idx) {
          case 0:
            return const HomePage();
          case 1:
            return CupertinoPageScaffold(
              child: Navigator(
                onGenerateRoute: wissen.WissenRoutesEx.onGenerate,
                initialRoute: wissen.WissenRoutesEx.index,
              ),
            );
          case 2:
            return CupertinoPageScaffold(
              child: Navigator(
                onGenerateRoute: research.onGenerateResearch,
                initialRoute: '/research/study_builder',
              ),
            );
          case 3:
            // Direkt die Seite zurückgeben (kein const Scaffold drumherum nötig)
            return const StudienFeedPage();
          default:
            return const HomePage();
        }
      },
    );
  }
}
