import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../knowledge/bookmarks_repo.dart';
import '../../knowledge/progress.dart';
import '../../apple_ui/a11y.dart';

class WissenPageAnchors extends StatefulWidget {
  final String asset;
  final String title;
  const WissenPageAnchors({super.key, required this.asset, required this.title});

  @override
  State<WissenPageAnchors> createState() => _WissenPageAnchorsState();
}

class _WissenPageAnchorsState extends State<WissenPageAnchors> {
  String md = '';
  bool saved = false;
  final controller = ScrollController();
  final Map<String, GlobalKey> _headingKeys = {};
  final List<_Heading> _toc = [];

  @override
  void initState() { super.initState(); _load(); _checkSaved(); controller.addListener(_onScroll); }
  @override
  void dispose() { controller.removeListener(_onScroll); controller.dispose(); super.dispose(); }

  Future<void> _load() async {
    md = await rootBundle.loadString(widget.asset);
    _buildToc();
    if (mounted) setState((){});
  }

  void _buildToc() {
    _toc.clear();
    final lines = md.split('\n');
    for (final line in lines) {
      final m = RegExp(r'^(#{1,3})\s+(.*)').firstMatch(line);
      if (m != null) {
        final level = m.group(1)!.length;
        final text = m.group(2)!.trim();
        final slug = slugify(text);
        _toc.add(_Heading(level: level, text: text, slug: slug));
        _headingKeys.putIfAbsent(slug, () => GlobalKey());
      }
    }
  }

  Future<void> _checkSaved() async {
    saved = await KnowledgeBookmarksRepo.isSaved(widget.asset);
    if (mounted) setState((){});
  }

  Future<void> _toggleBookmarkArticle() async {
    final bm = KnowledgeBookmark(id: widget.asset, asset: widget.asset, title: widget.title);
    await KnowledgeBookmarksRepo.toggle(bm);
    saved = await KnowledgeBookmarksRepo.isSaved(widget.asset);
    if (saved) { await A11y.announce('Gespeichert'); } else { await A11y.announce('Entfernt'); }
    if (mounted) setState((){});
  }

  void _onScroll() {
    final max = controller.position.maxScrollExtent;
    if (max > 0) {
      final pct = controller.position.pixels / max;
      KnowledgeProgressRepo.setScroll(widget.asset, pct);
    }
  }

  Future<void> _jumpTo(String slug) async {
    final key = _headingKeys[slug];
    if (key == null) return;
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    KnowledgeProgressRepo.markVisited(widget.asset, slug);
  }

  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(
      title: widget.title,
      trailing: [Icon(saved ? CupertinoIcons.bookmark_solid : CupertinoIcons.bookmark)],
      onTrailingTap: _toggleBookmarkArticle,
      child: Column(children: [
        if (_toc.isNotEmpty) _TocBar(toc: _toc, onTap: _jumpTo),
        Expanded(child: Markdown(
          data: md,
          controller: controller,
          shrinkWrap: false,
          onTapLink: (text, href, title) async {
            if (href == null) return;
            final uri = Uri.parse(href);
            if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
          },
        )),
      ]),
    );
  }
}

class _Heading {
  final int level;
  final String text;
  final String slug;
  _Heading({required this.level, required this.text, required this.slug});
}

class _TocBar extends StatelessWidget {
  final List<_Heading> toc;
  final void Function(String slug) onTap;
  const _TocBar({required this.toc, required this.onTap, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x1F000000), width: 0.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final h in toc)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onPressed: () => onTap(h.slug),
                child: Text(h.text, style: TextStyle(fontSize: h.level==1? 16 : h.level==2? 15 : 14)),
              ),
            )
        ]),
      ),
    );
  }
}
