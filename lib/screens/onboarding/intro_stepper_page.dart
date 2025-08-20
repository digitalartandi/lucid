// lib/screens/onboarding/intro_stepper_page.dart
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../design/gradient_theme.dart';
import '../home/home_page.dart'; // nur für den Type im Route-Ziel (RootTabs liegt in main.dart)

const _bg = Color(0xFF0D0F16);
const _white = Color(0xFFFFFFFF);
const _hair = Color(0x22FFFFFF);

class IntroStepperPage extends StatefulWidget {
  const IntroStepperPage({super.key});
  @override
  State<IntroStepperPage> createState() => _IntroStepperPageState();
}

class _IntroStepperPageState extends State<IntroStepperPage> {
  final _page = PageController();
  int _i = 0;

  List<_Slide> get _slides => const [
        _Slide(CupertinoIcons.moon_stars, 'Night Lite+',
            'Sanfte REM-Cues im Schlaf — abgestimmt auf dich.'),
        _Slide(CupertinoIcons.bell, 'RC-Reminder',
            'Kontextbasierte Reality-Checks, damit Lucidität zur Gewohnheit wird.'),
        _Slide(CupertinoIcons.music_note, 'Cue Tuning',
            'Deine Cue-Sounds fein abstimmen und im Loop testen.'),
        _Slide(CupertinoIcons.airplane, 'Traumreisen',
            'Geführte Szenen, die sanft in Klarträume leiten.'),
        _Slide(CupertinoIcons.chart_bar, 'Trainer',
            'Ein klarer Einstieg mit Fortschritt & Routinen.'),
      ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_done', true);
    if (!mounted) return;
    // → direkt ins Dashboard, Stack leeren
    Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final g = GradientTheme.of(GradientTheme.style.value);

    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: const Text('Willkommen', style: TextStyle(color: _white)),
        trailing: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          onPressed: _finish,
          child: const Text('Überspringen', style: TextStyle(color: _white)),
        ),
        border: const Border(bottom: BorderSide(color: _hair, width: .5)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _page,
                onPageChanged: (i) => setState(() => _i = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideCard(slide: _slides[i]),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? _white : _white.withOpacity(.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () {
                    if (_i < _slides.length - 1) {
                      _page.nextPage(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                      );
                    } else {
                      _finish();
                    }
                  },
                  child: Text(_i == _slides.length - 1 ? 'Los geht’s' : 'Weiter'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  const _Slide(this.icon, this.title, this.body);
}

class _SlideCard extends StatelessWidget {
  final _Slide slide;
  const _SlideCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    final g = GradientTheme.of(GradientTheme.style.value);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: g.primary),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: Icon(slide.icon, size: 42, color: _white),
          ),
          const SizedBox(height: 22),
          Text(slide.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _white, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(slide.body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _white, fontSize: 16, height: 1.35)),
        ],
      ),
    );
  }
}
