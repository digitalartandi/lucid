import 'package:flutter/cupertino.dart';
import '../app_theme.dart';
import '../bank_theme_compat.dart';

/// Kleine Pillen-Badges (z. B. "Neu"), wie in Bild 1/2
class PillChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const PillChip(this.label, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4FF),
        borderRadius: BankTheme.radiusL,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: BankTheme.subInk),
            const SizedBox(width: 6),
          ],
          Text(label, style: const TextStyle(fontSize: 13, color: BankTheme.subInk)),
        ],
      ),
    );
  }
}
