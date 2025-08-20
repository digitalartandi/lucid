import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _bgDark = Color(0xFF080B23);
const _white  = Color(0xFFFFFFFF);
const _btnGrad = [Color(0xFF7A6CFF), Color(0xFFA179EF)];

class IntroLandingPage extends StatefulWidget {
  const IntroLandingPage({super.key});
  @override
  State<IntroLandingPage> createState() => _IntroLandingPageState();
}

class _IntroLandingPageState extends State<IntroLandingPage>
    with TickerProviderStateMixin {
  late final AnimationController _cLogos;
  late final AnimationController _cText;
  late final AnimationController _cBtn;

  @override
  void initState() {
    super.initState();
    _cLogos = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))..forward();
    _cText  = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _cBtn   = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    Future.delayed(const Duration(milliseconds: 300), () => _cText.forward());
    Future.delayed(const Duration(milliseconds: 650), () => _cBtn.forward());
  }

  @override
  void dispose() { _cLogos.dispose(); _cText.dispose(); _cBtn.dispose(); super.dispose(); }

  void _openStepper() => Navigator.of(context).pushReplacementNamed('/intro/stepper');

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgDark,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hintergrund
          Positioned.fill(
            child: Image.asset(
              'assets/slider/violetter-sonnenuntergang-ruhiger-see.webp',
              fit: BoxFit.cover,
            ),
          ),
          // Darken-Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [const Color(0x55000000), const Color(0x66000000), const Color(0xAA000000)],
                  stops: const [0.0, .55, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final h = c.maxHeight;
                final isShort = h < 620;

                // Größen – streng begrenzt, orientiert am Mock
                final signetSize = math.min(math.min(w * 0.16, h * 0.12), 96.0); // kleiner als zuvor
                final logoTextHeight = math.min(math.min(w * 0.12, h * 0.10), 84.0);
                final claimSize = (w * 0.06).clamp(16.0, isShort ? 20.0 : 26.0);

                final topGap = math.max(20.0, h * 0.08);   // Abstand oberhalb des Signets
                final afterLogoGap = isShort ? 18.0 : 24.0;

                final content = Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: topGap),

                    // Signet (weiß), weich einblenden
                    FadeTransition(
                      opacity: CurvedAnimation(parent: _cLogos, curve: Curves.easeOut),
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, .08), end: Offset.zero)
                            .animate(CurvedAnimation(parent: _cLogos, curve: Curves.easeOut)),
                        child: SizedBox(
                          height: signetSize,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SvgPicture.asset(
                              'assets/logo/logo-signet.svg',
                              colorFilter: const ColorFilter.mode(_white, BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isShort ? 12 : 18),

                    // Textlogo (weiß) – Höhe begrenzen statt Breite!
                    FadeTransition(
                      opacity: CurvedAnimation(parent: _cLogos, curve: const Interval(.3, 1, curve: Curves.easeOut)),
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, .06), end: Offset.zero)
                            .animate(CurvedAnimation(parent: _cLogos, curve: Curves.easeOut)),
                        child: SizedBox(
                          height: logoTextHeight,
                          // Breite folgt automatisch, Verhältnis bleibt korrekt
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SvgPicture.asset(
                              'assets/logo/logo-text.svg',
                              colorFilter: const ColorFilter.mode(_white, BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: afterLogoGap),

                    // Claim – zweizeilig
                    FadeTransition(
                      opacity: CurvedAnimation(parent: _cText, curve: Curves.easeOut),
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, .05), end: Offset.zero)
                            .animate(CurvedAnimation(parent: _cText, curve: Curves.easeOut)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: w * .92),
                            child: Text(
                              'Schlafe tiefer. Träume klarer.\nDein ruhiger Begleiter in die Lucidität.',
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: TextStyle(
                                color: _white.withOpacity(.95),
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w300, // Light
                                height: 1.25,
                                fontSize: claimSize,
                                letterSpacing: .1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Rest füllen → Button bleibt am unteren Rand
                    const Spacer(),

                    // CTA immer sichtbar + animiert
                    _AnimatedCTA(controller: _cBtn, onTap: _openStepper),

                    // Unterer Abstand inkl. Safe Insets
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 18),
                  ],
                );

                // Sicherheitsnetz: auf sehr kleinen Höhen scollbar statt overflow
                if (isShort) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: h),
                      child: content,
                    ),
                  );
                }
                return content;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCTA extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onTap;
  const _AnimatedCTA({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fade  = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final scale = Tween<double>(begin: .98, end: 1)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight, colors: _btnGrad),
                  boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 10))],
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: const Center(
                    child: Text(
                      'Los geht’s',
                      style: TextStyle(
                        color: _white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),
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
