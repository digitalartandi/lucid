// lib/screens/onboarding/intro_landing_page.dart
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../design/gradient_theme.dart';

const _bgImage     = 'assets/slider/violetter-sonnenuntergang-ruhiger-see.webp';
const _logoLanding = 'assets/logo/logo-landingpage.svg';

const _white  = Color(0xFFFFFFFF);
const _shadow = Color(0x80000000);

// ---------- Feinjustage ----------
const kTopGapFactor   = 0.06;   // 6% der Bildschirmhöhe als Ziel
const kTopGapMin      = 50.0;  // nie kleiner als 50 px
const kTopGapMax      = 100.0;  // nie größer als 150 px

const kLogoPhoneMin   = 180.0;
const kLogoPhoneMax   = 250.0;
const kLogoTabletMax  = 320.0;
const kLogoDesktopMax = 360.0;

class IntroLandingPage extends StatelessWidget {
  const IntroLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    // Button-Gradient (bewusst Violett)
    final violet = GradientTheme.of(GradientStyle.aurora).primary;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0D0F16),
      child: Stack(
        children: [
          // Hintergrundbild (fullscreen)
          Positioned.fill(child: Image.asset(_bgImage, fit: BoxFit.cover)),

          // Inhalt: Logo + Text oben ausgerichtet mit flexiblem Top-Abstand
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final h = constraints.maxHeight;
                  // ~250px, aber flexibel über min/max
                  final topGap = (h * kTopGapFactor).clamp(kTopGapMin, kTopGapMax);

                  // Logo-Breite per Breakpoints
                  final double logoWidth = () {
                    if (w < 370) return (w - 48).clamp(kLogoPhoneMin, kLogoPhoneMax);
                    if (w < 600) return kLogoPhoneMax;
                    if (w < 900) return kLogoTabletMax;
                    return kLogoDesktopMax;
                  }();

                  // Intro-Textgröße – gedeckelt für Desktop
                  final bodySize = (w * 0.042).clamp(13.0, 20.0);

                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Align(
                      alignment: Alignment.topCenter, // WICHTIG: nicht zentrieren, sondern oben
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, topGap, 24, 140),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Kombiniertes Landing-Logo, hart in der Breite geklammert
                            _FadeInUp(
                              delayMs: 60,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: logoWidth),
                                child: SizedBox(
                                  width: logoWidth,
                                  child: SvgPicture.asset(
                                    _logoLanding,
                                    fit: BoxFit.contain,
                                    colorFilter: const ColorFilter.mode(_white, BlendMode.srcIn),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28), // mehr Abstand Logo → Text

                            // 2-Zeiler – Light, etwas kleiner, gut lesbar
                            _FadeInUp(
                              delayMs: 200,
                              child: Text(
                                'Schlafe tiefer. Träume klarer.\n'
                                'Dein ruhiger Begleiter in die Lucidität.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w300,
                                  fontSize: bodySize,
                                  height: 1.28,
                                  color: _white,
                                  shadows: const [
                                    Shadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Fixierter Button (immer sichtbar)
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _PrimaryGradientButton(
                label: 'Los geht’s',
                gradientColors: violet,
                height: 52,
                fontSize: 20,
                onPressed: () => Navigator.of(context).pushNamed('/onboarding'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Primär-Button mit Gradient
class _PrimaryGradientButton extends StatelessWidget {
  final List<Color> gradientColors;
  final String label;
  final VoidCallback onPressed;
  final double height;
  final double fontSize;

  const _PrimaryGradientButton({
    required this.label,
    required this.gradientColors,
    required this.onPressed,
    this.height = 52,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return _FadeInUp(
      delayMs: 320,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 8))],
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            borderRadius: BorderRadius.circular(18),
            minSize: height,
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize,
                    color: _white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kleiner Fade-in-Up Effekt
class _FadeInUp extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const _FadeInUp({required this.child, this.delayMs = 0});

  @override
  State<_FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<_FadeInUp> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _offset = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delayMs), () { if (mounted) _c.forward(); });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _opacity, child: SlideTransition(position: _offset, child: widget.child));
}
