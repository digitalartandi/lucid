import 'package:flutter/cupertino.dart';
import '../theme.dart';

class BrandChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const BrandChip({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: Brand.chipGradient),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: CupertinoColors.white),
          const SizedBox(width: 6),
          Text(label, style: T.chip.copyWith(color: CupertinoColors.white)),
        ],
      ),
    );
  }
}






