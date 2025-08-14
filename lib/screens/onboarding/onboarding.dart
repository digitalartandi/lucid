import 'package:flutter/cupertino.dart';
import '../../prefs/first_run_onboarding.dart';
import '../../design/theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override State<OnboardingPage> createState()=> _OnboardingState();
}

class _OnboardingState extends State<OnboardingPage> {
  final controller = PageController();
  int idx = 0;

  final pages = const [
    _Slide(
      icon: CupertinoIcons.book_solid,
      title: 'Journal â€“ die Basis',
      text: 'Kurz notieren, was du getrÃ¤umt hast. So trainierst du Erinnerung & Bewusstsein im Traum.',
    ),
    _Slide(
      icon: CupertinoIcons.eye_solid,
      title: 'Reality-Checks',
      text: 'TagsÃ¼ber erinnern, bewusst prÃ¼fen. So steigt die Chance, es im Traum zu merken.',
    ),
    _Slide(
      icon: CupertinoIcons.waveform_circle_fill,
      title: 'Night Lite+',
      text: 'Feine Cues in spÃ¤ten REM-Fenstern â€“ Hinweis statt Wecker.',
    ),
  ];

  void _finish() async {
    await FirstRunOnboarding.setSeen();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Brand.bg,
      navigationBar: const CupertinoNavigationBar(middle: Text('Willkommen')),
      child: SafeArea(child: Column(
        children: [
          Expanded(child: PageView(
            controller: controller,
            onPageChanged: (i)=> setState(()=> idx=i),
            children: pages,
          )),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(pages.length, (i){
            final active = i==idx;
            return Container(
              width: active? 10:8, height: active? 10:8, margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: active? Brand.primary: const Color(0xFFD1D5DB), shape: BoxShape.circle),
            );
          })),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(child: CupertinoButton(
                onPressed: _finish,
                color: Brand.primary,
                borderRadius: BorderRadius.circular(24),
                child: const Text('Los gehtâ€™s'),
              )),
            ]),
          ),
        ],
      )),
    );
  }
}

class _Slide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _Slide({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Brand.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(gradient: const LinearGradient(colors: Brand.chipGradient), shape: BoxShape.circle),
              padding: const EdgeInsets.all(18),
              child: Icon(icon, size: 42, color: CupertinoColors.white),
            ),
            const SizedBox(height: 16),
            Text(title, style: T.titleL, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(text, style: T.bodyMuted, textAlign: TextAlign.center),
          ],
        ),
      ),
    ));
  }
}






