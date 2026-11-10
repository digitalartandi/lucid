// lib/features/wissen/article_page.dart
//
// Artikelansicht: ruhiger Lesesatz, Links zu den Quellen.
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../ui/links.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';

class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key, required this.assetPath});
  final String assetPath;

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  String? _title;
  String? _body;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      String md = await rootBundle.loadString(widget.assetPath);
      md = md.replaceAll('\r\n', '\n');
      // Titel = erste H1; der Rest ist der Artikel.
      final RegExpMatch? h1 = RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(md);
      String title = 'Artikel';
      if (h1 != null) {
        title = h1.group(1)!.trim();
        md = md.replaceRange(h1.start, h1.end, '').trimLeft();
      }
      if (!mounted) return;
      setState(() {
        _title = title;
        _body = md;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  MarkdownStyleSheet _style() {
    final TextStyle p = LT.body.copyWith(fontSize: 16.5, height: 1.6);
    return MarkdownStyleSheet(
      p: p,
      a: p.copyWith(color: LC.iris),
      strong: p.copyWith(fontWeight: FontWeight.w700),
      em: p.copyWith(fontStyle: FontStyle.italic),
      h1: LT.display,
      h2: LT.title,
      h3: LT.heading,
      h2Padding: const EdgeInsets.only(top: LS.xl),
      h3Padding: const EdgeInsets.only(top: LS.md),
      listBullet: p.copyWith(color: LC.iris),
      listIndent: 22,
      blockSpacing: 14,
      blockquote: p.copyWith(color: LC.text),
      blockquotePadding: const EdgeInsets.all(LS.lg),
      blockquoteDecoration: const BoxDecoration(color: LC.glass, borderRadius: LRad.md),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(top: BorderSide(color: LC.line)),
      ),
      tableHead: LT.caption.copyWith(color: LC.text, fontWeight: FontWeight.w700, fontSize: 13),
      tableBody: LT.caption.copyWith(color: LC.text, fontSize: 13),
      tableBorder: TableBorder.all(color: LC.glassLine),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: LS.sm),
      tableCellsDecoration: const BoxDecoration(color: LC.glass),
      tableColumnWidth: const FlexColumnWidth(),
      code: p.copyWith(fontSize: 15, backgroundColor: LC.surface),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const LPage(
        title: 'Artikel',
        child: LEmpty(
          icon: CupertinoIcons.doc_text,
          title: 'Artikel nicht gefunden',
          text: 'Dieser Inhalt konnte nicht geladen werden.',
        ),
      );
    }
    final String? body = _body;
    if (body == null) {
      return const LPage(title: '', child: Center(child: CupertinoActivityIndicator()));
    }
    final int words = body.split(RegExp(r'\s+')).length;
    final int minutes = (words / 200).ceil();
    return LPage(
      title: '',
      child: LScroll(
        top: 0,
        children: <Widget>[
          Text(_title ?? '', style: LT.display),
          const SizedBox(height: LS.sm),
          Text('Lesezeit etwa $minutes Min.', style: LT.caption),
          const SizedBox(height: LS.lg),
          MarkdownBody(
            data: body,
            styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
            styleSheet: _style(),
            onTapLink: (String text, String? href, String title) {
              if (href != null) openExternal(href);
            },
          ),
        ],
      ),
    );
  }
}
