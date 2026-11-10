// lib/main.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/practice_store.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/shell/app_shell.dart';
import 'features/shell/splash.dart';
import 'routes/app_routes.dart' as app;
import 'services/journal_repo.dart';
import 'ui/tokens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LucidApp());
}

class LucidApp extends StatelessWidget {
  const LucidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Lucid',
      debugShowCheckedModeBanner: false,
      theme: lucidTheme(),
      locale: const Locale('de'),
      supportedLocales: const <Locale>[Locale('de'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      onGenerateRoute: app.onGenerateRoute,
      home: const BootFlow(),
    );
  }
}

/// Lädt den Übungsstand und entscheidet: Einstieg oder App.
class BootFlow extends StatefulWidget {
  const BootFlow({super.key});

  @override
  State<BootFlow> createState() => _BootFlowState();
}

class _BootFlowState extends State<BootFlow> {
  final PracticeStore _store = PracticeStore.instance;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStore);
    _boot();
  }

  Future<void> _boot() async {
    final Future<void> minimum = Future<void>.delayed(SplashScreen.minimum);
    await _store.load();
    try {
      await JournalRepo.instance.init();
    } catch (_) {
      // Journal lädt beim ersten Zugriff erneut.
    }
    await minimum;
    if (mounted) setState(() => _ready = true);
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_onStore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget page = !_ready
        ? const SplashScreen(key: ValueKey<String>('splash'))
        : (_store.onboarded
            ? const AppShell(key: ValueKey<String>('app'))
            : const OnboardingPage(key: ValueKey<String>('onboarding')));
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      switchInCurve: Curves.easeOut,
      child: page,
    );
  }
}
