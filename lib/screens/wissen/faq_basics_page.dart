// lib/screens/wissen/faq_basics_page.dart
import 'package:flutter/widgets.dart';
import 'wissen_article_page.dart';

class FaqBasicsPage extends StatelessWidget {
  const FaqBasicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lädt die FAQ aus Markdown und rendert sie als Accordion (weißer Text, dunkler Stil)
    return const WissenArticlePage(assetPath: 'assets/wissen/faq_de.md');
  }
}
