import 'package:flutter/cupertino.dart';
import '../../design/app_theme.dart';
import '../../design/widgets/glass_card.dart';
import '../../design/bank_theme_compat.dart';


/// Minimaler Startscreen wie Bild 3: Claim + CTA
class OnboardingStart extends StatelessWidget {
  const OnboardingStart({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BankTheme.bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lucid',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: BankTheme.ink)),
                const SizedBox(height: 8),
                const Text('Vom Traumtagebuch zum Klartraum –\nStartklar in 2 Wochen.',
                    style: TextStyle(color: BankTheme.subInk)),
                const SizedBox(height: 16),
                CupertinoButton.filled(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/trainer'),
                  child: const Text('Jetzt starten'),
                ),
                const SizedBox(height: 8),
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                  child: const Text('Später'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
