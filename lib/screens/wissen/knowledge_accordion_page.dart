// lib/screens/wissen/knowledge_accordion_page.dart
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

/// Zeigt alle Markdown-Dateien aus `assets/wissen/` (und optional `assets/wissen_en/`)
/// als Accordion. Inhalte werden lazy beim Aufklappen geladen.
class KnowledgeAccordionPage extends StatefulWidget {
  const KnowledgeAccordionPage({super.key});

  @override
  State<KnowledgeAccordionPage> createState() => _KnowledgeAccordionPageState();
}

class _KnowledgeAccordionPageState extends State<KnowledgeAccordionPage> {
  final List<_Doc> _docs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestJson) as Map<String, dynamic>;

      // Alle .md unter assets/wissen/ (und wissen_en/) einsammeln:
      final paths = manifest.keys
          .where((p) =>
              (p.startsWith('assets/wissen/') || p.startsWith('assets/wissen_en/')) &&
              p.toLowerCase().endsWith('.md'))
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      setState(() {
        _docs
          ..clear()
          ..addAll(paths.map((p) => _Doc(path: p, title: _prettyTitleFromPath(p))));
        _loading = false;
      });
    } catch (e) {
      _loading = false;
      debugPrint('KnowledgeAccordionPage: AssetManifest konnte nicht gelesen werden: $e');
      setState(() {});
    }
  }

  String _prettyTitleFromPath(String path) {
    final file = path.split('/').last.replaceAll('.md', '');
    String title = file.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    if (title.isEmpty) title = file;
    return title
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> _toggle(int index) async {
    final doc = _docs[index];
    setState(() => doc.isOpen = !doc.isOpen);
    if (doc.isOpen && doc.content == null) {
      try {
        final txt = await rootBundle.loadString(doc.path);
        final heading = _extractFirstHeading(txt);
        setState(() {
          doc.content = txt;
          if (heading != null && heading.isNotEmpty) doc.title = heading;
        });
      } catch (e) {
        setState(() => doc.content = '_Fehler beim Laden: $e');
      }
    }
  }

  String? _extractFirstHeading(String md) {
    for (final line in const LineSplitter().convert(md)) {
      final m = RegExp(r'^\s{0,3}#{1,3}\s+(.+?)\s*$').firstMatch(line);
      if (m != null) return m.group(1);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Wissen'),
        backgroundColor: Color(0x33000000),
        border: null,
      ),
      child: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : _docs.isEmpty
                ? const Center(child: Text('Keine Inhalte gefunden.\nErwarte Dateien unter assets/wissen/*.md'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _docs.length,
                    itemBuilder: (context, i) => _AccordionTile(
                      title: _docs[i].title,
                      isOpen: _docs[i].isOpen,
                      onToggle: () => _toggle(i),
                      child: _docs[i].isOpen
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: MarkdownBody(
                                data: _docs[i].content ?? 'Lade...',
                                selectable: false,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
      ),
    );
  }
}

class _Doc {
  _Doc({required this.path, required this.title});
  final String path;
  String title;
  String? content;
  bool isOpen = false;
}

class _AccordionTile extends StatelessWidget {
  const _AccordionTile({
    required this.title,
    required this.child,
    required this.isOpen,
    required this.onToggle,
  });

  final String title;
  final Widget child;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final bg = CupertinoTheme.of(context).scaffoldBackgroundColor;
    final card = bg.withOpacity(0.6);
    final textColor = CupertinoTheme.of(context).textTheme.textStyle.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Column(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              onPressed: onToggle,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 180),
                    turns: isOpen ? 0.5 : 0.0,
                    child: Icon(CupertinoIcons.chevron_down, size: 18, color: textColor),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              firstChild: const SizedBox.shrink(),
              secondChild: child,
              crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }
}
