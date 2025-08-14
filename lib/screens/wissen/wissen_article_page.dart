import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class WissenArticlePage extends StatelessWidget {
  final String assetPath;
  const WissenArticlePage({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Techniken & Details')),
      child: FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(assetPath),
        builder: (_, snap){
          if (!snap.hasData) return const Center(child: CupertinoActivityIndicator());
          return SafeArea(child: Markdown(data: snap.data!));
        },
      ),
    );
  }
}


