import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

const _bg = Color(0xFF080B23);
const _white = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);

class WissenArticlePage extends StatelessWidget {
  final String assetPath; // muss ein vollständiger Asset-Pfad sein, z. B. 'assets/wissen/grundlagen_de.md'
  const WissenArticlePage({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: Text('Artikel', style: TextStyle(color: _white)),
        border: Border(bottom: BorderSide(color: _stroke, width: .5)),
      ),
      child: SafeArea(
        child: FutureBuilder<String>(
          future: DefaultAssetBundle.of(context).loadString(assetPath),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (snap.hasError || !snap.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Der Artikel konnte nicht geladen werden.\nPfad: $assetPath',
                    style: const TextStyle(color: _white),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Nicht scrollende MarkdownBody in einen SingleChildScrollView packen:
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: MarkdownBody(
                data: snap.data!,
                styleSheet: MarkdownStyleSheet.fromCupertinoTheme(
                  const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      textStyle: TextStyle(color: _white, fontSize: 16),
                    ),
                  ),
                ).copyWith(
                  a: const TextStyle(color: Color(0xFF9FA9FF)),
                  p: const TextStyle(color: _white, height: 1.45),
                  h1: const TextStyle(color: _white, fontSize: 26, fontWeight: FontWeight.w800),
                  h2: const TextStyle(color: _white, fontSize: 22, fontWeight: FontWeight.w800),
                  h3: const TextStyle(color: _white, fontSize: 18, fontWeight: FontWeight.w700),
                  blockquote: const TextStyle(color: _white),
                  listBullet: const TextStyle(color: _white),
                  blockSpacing: 12,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
