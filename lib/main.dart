import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show rootBundle; // für Asset-Diagnose
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/app_routes.dart' as app;
import 'routes/research_named_routes.dart' as research;
import 'screens/home/home_page.dart';
import 'screens/wissen/studien_feed_page_with_save.dart';

// --- AAA Night Palette / Tokens ---
const _bg0 = Color(0xFF0D0F16);
const _bg1 = Color(0xFF101323);
const _bg2 = Color(0xFF13172B);

const _violet    = Color(0xFF7A6CFF); // Primary (auch: Back-Label etc.)
const _textMed   = Color(0xFFB8C0E8); // Inactive / Secondary
const _glassBar  = Color(0x1AFFFFFF); // 10% Weiß für "Glass"-Bar
const _glassLine = Color(0x33FFFFFF); // 20% Weiß für Hairline

// --- Mini-Diagnose: prüft, ob die vier SVG-Icons aus den Assets geladen werden können
Future<void> _debugCheckIconAssets() async {
  const paths = [
    'assets/icons/home.svg',
    'assets/icons/wissen.svg',
    'assets/icons/research.svg',
    'assets/icons/feed.svg',
  ];
  for (final p in paths) {
    try {
      await rootBundle.loadString(p);
      // ignore: avoid_print
      print('OK: $p geladen');
    } catch (e) {
      // ignore: avoid_print
      print('FEHLT: $p  ->  $e');
    }
  }
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  WidgetsFlutterBinding.ensureInitialized();
  _debugCheckIconAssets(); // einmalige Diagnoseausgabe
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // Aus pubspec eingebettete Schrift
    const fam = 'DM Sans';
    const fallback = <String>['SF Pro Text', 'Roboto', 'Arial'];

    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: _violet,            // Back-Label, interaktive Akzente
        scaffoldBackgroundColor: _bg1,
        barBackgroundColor: _glassBar,
        // 👇 Navigationstitel hell & gut lesbar, Action-Text ebenfalls hell
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            inherit: false, fontFamily: fam, fontFamilyFallback: fallback, fontSize: 15),
          navTitleTextStyle: TextStyle(
            inherit: false, fontFamily: fam, fontFamilyFallback: fallback,
            fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFFE9EAFF)),
          navLargeTitleTextStyle: TextStyle(
            inherit: false, fontFamily: fam, fontFamilyFallback: fallback,
            fontSize: 34, fontWeight: FontWeight.w700, color: Color(0xFFE9EAFF)),
          tabLabelTextStyle: TextStyle(
            inherit: false, fontFamily: fam, fontFamilyFallback: fallback,
            fontSize: 12, fontWeight: FontWeight.w600),
          actionTextStyle: TextStyle(
            inherit: false, fontFamily: fam, fontFamilyFallback: fallback,
            fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFFE9EAFF)),
        ),
      ),
      onGenerateRoute: app.onGenerateRoute,
      home: _StartupRouter(),          // ⬅️ entscheidet Intro vs. Dashboard
    );
  }
}

/// Entscheidet einmalig: Intro (Landing + Stepper) oder direkt Dashboard.
/// Intro-Route ist '/intro' (in app_routes registriert).
class _StartupRouter extends StatefulWidget {
  const _StartupRouter();

  @override
  State<_StartupRouter> createState() => _StartupRouterState();
}

class _StartupRouterState extends State<_StartupRouter> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarded') ?? false;

    if (!mounted) return;

    if (seen) {
      // Direkt ins Dashboard (Tabs)
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => const RootTabs()),
      );
    } else {
      // Erstes Mal -> Intro zeigen
      Navigator.of(context).pushReplacementNamed('/intro');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kleiner Splash, bis entschieden wurde
    return const CupertinoPageScaffold(
      child: Center(child: CupertinoActivityIndicator()),
    );
  }
}

class RootTabs extends StatelessWidget {
  const RootTabs({super.key});

  @override
  Widget build(BuildContext context) {
    // Globaler Night-Gradient hinter allen Tabs
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [_bg0, _bg1, _bg2],
        ),
      ),
      child: CupertinoTabScaffold(
        backgroundColor: const Color(0x00000000), // transparent, damit Verlauf bleibt
        tabBar: CupertinoTabBar(
          activeColor: _violet,       // Label aktiv
          inactiveColor: _textMed,    // Label inaktiv
          backgroundColor: _glassBar,
          border: const Border(top: BorderSide(color: _glassLine, width: 0.5)),
          items: const [
            BottomNavigationBarItem(
              icon: _NavIcon('assets/icons/home.svg', active: false, semantics: 'Home'),
              activeIcon: _NavIcon('assets/icons/home.svg', active: true, semantics: 'Home'),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon('assets/icons/wissen.svg', active: false, semantics: 'Wissen'),
              activeIcon: _NavIcon('assets/icons/wissen.svg', active: true, semantics: 'Wissen'),
              label: 'Wissen',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon('assets/icons/research.svg', active: false, semantics: 'Research'),
              activeIcon: _NavIcon('assets/icons/research.svg', active: true, semantics: 'Research'),
              label: 'Research',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon('assets/icons/feed.svg', active: false, semantics: 'Feed'),
              activeIcon: _NavIcon('assets/icons/feed.svg', active: true, semantics: 'Feed'),
              label: 'Feed',
            ),
          ],
        ),
        tabBuilder: (ctx, idx) {
          switch (idx) {
            case 0:
              return const HomePage();
            case 1:
              return const _LucidTabShell(
                initialRoute: '/wissen',
                useResearchRoutes: false,
              );
            case 2:
              return const _LucidTabShell(
                initialRoute: '/research/study_builder',
                useResearchRoutes: true,
              );
            case 3:
              return const _LucidPageWrap(child: StudienFeedPage());
            default:
              return const HomePage();
          }
        },
      ),
    );
  }
}

/// Transparente Wrapper-Page für einfache Inhalte.
class _LucidPageWrap extends StatelessWidget {
  final Widget child;
  const _LucidPageWrap({required this.child});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      backgroundColor: Color(0x00000000),
      child: SizedBox.expand(child: ColoredBox(color: Color(0x00000000))),
    ).copyWith(child: child); // kleiner Trick, um consts zu erhalten
  }
}

/// Transparente Navigator-Hülle für Tabs 1/2 (Wissen/Research).
class _LucidTabShell extends StatelessWidget {
  final String initialRoute;
  final bool useResearchRoutes;
  const _LucidTabShell({
    required this.initialRoute,
    required this.useResearchRoutes,
  });

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      backgroundColor: Color(0x00000000),
      child: SizedBox.shrink(),
    ).copyWith(
      child: Navigator(
        onGenerateRoute:
            useResearchRoutes ? research.onGenerateResearch : app.onGenerateRoute,
        initialRoute: initialRoute,
      ),
    );
  }
}

/// SVG-Icon für die Bottom-Nav (aktiv = Primary, inaktiv = Secondary)
class _NavIcon extends StatelessWidget {
  final String asset;
  final bool active;
  final String semantics;
  const _NavIcon(this.asset, {required this.active, required this.semantics});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final Color color = active
        ? theme.primaryColor
        : (theme.textTheme.tabLabelTextStyle.color ?? _textMed);

    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      // 1) Erzwingt Färbung für „normale“ SVGs:
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      // 2) Greift bei SVGs, die „currentColor“ nutzen:
      theme: SvgTheme(currentColor: color),
      semanticsLabel: semantics,
      // 3) Debug-Helfer – wenn Pfad/Manifest nicht passt:
      placeholderBuilder: (_) =>
          Icon(CupertinoIcons.exclamationmark_triangle, color: color, size: 22),
    );
  }
}

extension on CupertinoPageScaffold {
  /// Convenience-Helper, um `child:` zu ersetzen (für die const-Tricks oben).
  CupertinoPageScaffold copyWith({Widget? child}) =>
      CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        navigationBar: navigationBar,
        child: child ?? this.child,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      );
}
