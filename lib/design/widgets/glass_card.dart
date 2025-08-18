import 'dart:ui';
import 'package:flutter/cupertino.dart';

// dünne, helle Hairline für Glas
const _glassStroke = Color(0x33FFFFFF);

class GlassCard extends StatelessWidget {
  final BorderRadius radius;
  final EdgeInsets padding;
  final Widget child;
  final GestureTapCallback? onTap;

  /// Blur der Glasschicht
  final double blur;

  /// Helligkeit der „Frost“-Schicht (weiße Grundaufhellung).
  /// Niedriger = mehr Farbsättigung. 0.06–0.10 sind gute Werte.
  final double frost;

  /// Optionale, **volle** Farb-Tönung über die gesamte Karte.
  final Gradient? tint;

  const GlassCard({
    super.key,
    this.radius = const BorderRadius.all(Radius.circular(20)),
    this.padding = const EdgeInsets.all(16),
    required this.child,
    this.onTap,
    this.blur = 18,
    this.frost = .08,     // vorher oft zu hoch → Farben wurden grau
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final core = Stack(
      children: [
        // Frost-Schicht (unter der Tönung)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              color: const Color(0xFFFFFFFF).withOpacity(frost),
            ),
          ),
        ),
        // Farbtönung (deckt die **ganze Karte** inkl. Rundungen ab)
        if (tint != null)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: tint,
              ),
            ),
          ),
        // dezente Hairline
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: const Border.fromBorderSide(BorderSide(color: _glassStroke)),
            ),
          ),
        ),
        // Inhalt
        Padding(padding: padding, child: child),
      ],
    );

    final clipped = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: core,
      ),
    );

    return onTap == null ? clipped : GestureDetector(onTap: onTap, child: clipped);
  }
}
