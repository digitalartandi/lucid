// lib/features/shell/splash.dart
//
// Kurzer Auftakt mit der Wortmarke, während Profil und Journal laden.
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../ui/tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Mindestdauer, damit die Wortmarke nicht nur aufblitzt.
  static const Duration minimum = Duration(milliseconds: 1800);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double logoWidth = (width * 0.56).clamp(170.0, 300.0).toDouble();
    final Animation<double> fade = CurvedAnimation(parent: _in, curve: Curves.easeOut);
    return CupertinoPageScaffold(
      backgroundColor: LC.skyTop,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            LImg.splash,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
                const ColoredBox(color: LC.skyMid),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0x990B0D1F), Color(0x330B0D1F), Color(0xCC0B0D1F)],
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(fade),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Semantics(
                      label: 'Lucid',
                      child: SvgPicture.asset(
                        LImg.wordmark,
                        width: logoWidth,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(LC.text, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(height: LS.lg),
                    Text(
                      'Klarträumen lernen',
                      style: LT.label.copyWith(
                        color: const Color(0xFFD5D8F5),
                        letterSpacing: 2.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
