import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'routes/app_routes.dart' as app;
import 'screens/home/home_page.dart';
import 'routes/research_named_routes.dart' as research;
import 'screens/wissen/studien_feed_page_with_save.dart'; // <— NEU

void main() {
  // Fonts nicht zur Laufzeit laden (alles aus Assets, schneller Start)
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: GoogleFonts.dmSans(), // Basis-Body-Text
          navTitleTextStyle: GoogleFonts.dmSans(
              fontSize: 17, fontWeight: FontWeight.w600),
          navLargeTitleTextStyle: GoogleFonts.dmSans(
              fontSize: 34, fontWeight: FontWeight.w700),
          tabLabelTextStyle: GoogleFonts.dmSans(
              fontSize: 12, fontWeight: FontWeight.w600),
          actionTextStyle: GoogleFonts.dmSans(
              fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
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
            // Statt wissen.WissenRoutesEx → zentrale App-Routen
            return CupertinoPageScaffold(
              child: Navigator(
                onGenerateRoute: app.onGenerateRoute,
                initialRoute: '/wissen',
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
            return const StudienFeedPage();
          default:
            return const HomePage();
        }
      },
    );
  }
}
