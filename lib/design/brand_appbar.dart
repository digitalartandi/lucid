import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'bank_theme_compat.dart'; // nutzt deine Lc-Tokens indirekt

class BrandAppBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  const BrandAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: CupertinoColors.systemBackground.withOpacity(0.0), // transparent
      border: const Border(bottom: BorderSide(color: Color(0x33FFFFFF), width: .5)),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/logo/logo-signet.svg',
              width: 24, height: 24,
              colorFilter: const ColorFilter.mode(
                CupertinoColors.white, BlendMode.srcIn),
              semanticsLabel: 'Lucid',
            ),
            const SizedBox(width: 8),
            const Text(
              'Lucid',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: CupertinoColors.white,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),
      trailing: const Padding(
        padding: EdgeInsets.only(right: 8),
        child: Icon(CupertinoIcons.bell, color: CupertinoColors.white),
      ),
      middle: null, // bewusst frei lassen für ruhige Optik
    );
  }
}
