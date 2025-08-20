// lib/main.dart
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/app_routes.dart' as app;
import 'routes/research_named_routes.dart' as research;
import 'screens/home/home_page.dart';
import 'screens/wissen/studien_feed_page_with_save.dart';
import 'screens/onboarding/intro_landing_page.dart';

// --- AAA Night Palette / Tokens ---
const _bg0 = Color(0xFF0D0F16);
const _bg1 = Color(0xFF101323);
const _bg2 = Color(0xFF13172B);

const _violet    = Color(0xFF7A6CFF);
const _textMed   = Color(0xFFB8C0E8);
const _glassBar  = Color(0x1AFFFFFF);
const _glassLine = Color(0x33FFFFFF);

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
  _debugCheckIconAssets();
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    const fam = 'DM Sans';
    const fallback = <String>['SF Pro Text', 'Roboto', 'Arial'];

    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: _violet,
        scaffoldBackgroundColor: _bg1,
        barBackgroundColor: _glassBar,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(inherit: false, fontFamily: fam, fontFamilyFallback: fallback, fontSize: 15),
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
      home: const BootFlow(), // ← Boot-Flow entscheidet Landing vs. Tabs
    );
  }
}

/// Entscheidet: erstes Mal → Landing; danach → Tabs
class BootFlow extends StatefulWidget {
  const BootFlow({super.key});
  @override
  State<BootFlow> createState() => _BootFlowState();
}

class _BootFlowState extends State<BootFlow> {
  bool? _firstRun; // null = lädt

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('intro_done') ?? false;
    setState(() => _firstRun = !done);
  }

  @override
  Widget build(BuildContext context) {
    if (_firstRun == null) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    return _firstRun! ? const IntroLandingPage() : const RootTabs();
  }
}

class RootTabs extends StatelessWidget {
  const RootTabs({super.key});

  @override
  Widget build(BuildContext context) {
    // Globaler Night-Gradient hinter allen Tabs
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_bg0, _bg1, _bg2]),
      ),
      child: CupertinoTabScaffold(
        backgroundColor: const Color(0x00000000),
        tabBar: CupertinoTabBar(
          activeColor: _violet,
          inactiveColor: _textMed,
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
              return const _LucidTabShell(initialRoute: '/wissen', useResearchRoutes: false);
            case 2:
              return const _LucidTabShell(initialRoute: '/research/study_builder', useResearchRoutes: true);
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
  const _LucidTabShell({required this.initialRoute, required this.useResearchRoutes});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      backgroundColor: Color(0x00000000),
      child: SizedBox.shrink(),
    ).copyWith(
      child: Navigator(
        onGenerateRoute: useResearchRoutes ? research.onGenerateResearch : app.onGenerateRoute,
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
      width: 24, height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      theme: SvgTheme(currentColor: color),
      semanticsLabel: semantics,
      placeholderBuilder: (_) => Icon(CupertinoIcons.exclamationmark_triangle, color: color, size: 22),
    );
  }
}

extension on CupertinoPageScaffold {
  CupertinoPageScaffold copyWith({Widget? child}) =>
      CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        navigationBar: navigationBar,
        child: child ?? this.child,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      );
}
