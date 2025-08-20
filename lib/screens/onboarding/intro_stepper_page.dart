import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../design/gradient_theme.dart';

const _bg = Color(0xFF080B23);
const _white = Color(0xFFFFFFFF);
const _muted = Color(0xCCFFFFFF);

class IntroStepperPage extends StatefulWidget {
  const IntroStepperPage({super.key});

  @override
  State<IntroStepperPage> createState() => _IntroStepperPageState();
}

class _IntroStepperPageState extends State<IntroStepperPage> {
  final _c = PageController();
  int _index = 0;

  Future<void> _finish() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('onboarded', true);
    if (!mounted) return;
    // Nach Hause / Dashboard
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  void _skip() => _finish();

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
    } else {
      _c.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = GradientTheme.of(GradientTheme.style.value);

    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _skip,
          child: const Text('Überspringen', style: TextStyle(color: _white)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _c,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _StepPage(data: _pages[i]),
              ),
            ),

            // Dots + Button
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.of(context).viewPadding.bottom),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? _white : _white.withOpacity(.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _next,
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: _index == _pages.length - 1
                              ? g.primary
                              : [const Color(0xFF40435E), const Color(0xFF40435E)],
                        ),
                      ),
                      child: Text(
                        _index == _pages.length - 1 ? 'Los geht’s' : 'Weiter',
                        style: const TextStyle(color: _white, fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Seiteninhalte (Platzhalter-Icons, klarer Text) ---
class _StepData {
  final IconData icon;
  final String title;
  final String body;
  const _StepData(this.icon, this.title, this.body);
}

final _pages = <_StepData>[
  _StepData(CupertinoIcons.moon_stars_fill, 'Sanfte Cues',
      'Leise Erinnerungstöne triggern Realitätschecks und helfen dir, bewusst zu träumen.'),
  _StepData(CupertinoIcons.music_note_2, 'Traumreisen',
      'Geführte Szenen mit Musik & SFX – ideal zum Einschlafen oder für MILD.'),
  _StepData(CupertinoIcons.bell_circle_fill, 'RC-Reminder',
      'Kontextbasierte Erinnerungen zur Routine – flexibel und smart.'),
  _StepData(CupertinoIcons.lightbulb_fill, 'Night Lite+',
      'REM-freundliche Hinweise in der Nacht, fein einstellbar.'),
  _StepData(CupertinoIcons.chart_bar_alt_fill, 'Trainer',
      '2-Wochen-Plan mit klaren Schritten – damit du zuverlässig Fortschritte siehst.'),
];

class _StepPage extends StatelessWidget {
  const _StepPage({required this.data});
  final _StepData data;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final iconSize = w < 360 ? 110.0 : 140.0;
    final titleSize = w < 360 ? 22.0 : 24.0;
    final bodySize  = w < 360 ? 15.0 : 16.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon-Card
          Container(
            height: iconSize + 40,
            width: iconSize + 40,
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(data.icon, color: _white, size: iconSize),
          ),
          const SizedBox(height: 22),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(color: _white, fontSize: titleSize, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: bodySize, height: 1.35),
          ),
        ],
      ),
    );
  }
}
