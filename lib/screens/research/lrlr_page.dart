import 'package:flutter/cupertino.dart';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';
import '../../research/markers.dart';
import '../../research/storage.dart';
import '../../audio/cue_profiles.dart';

class LrLrPage extends StatefulWidget {
  const LrLrPage({super.key});
  @override State<LrLrPage> createState()=> _LrLrState();
}

class _LrLrState extends State<LrLrPage> {
  List<String> tail = [];

  Future<void> _refresh() async {
    tail = await ResearchStorage.readMarkersTail(lines: 20);
    if (mounted) setState((){});
  }

  @override
  void initState() { super.initState(); _refresh(); }

  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(title: 'LRLR & Marker', child: Column(children: [
      Section(header: 'Marker', children: [
        RowItem(title: const Text('LRLR markieren'), subtitle: const Text('Zeitstempel + Label'),
          onTap: () async { await Markers.log('LRLR'); await _refresh(); }),
        RowItem(title: const Text('Customâ€‘Marker'), subtitle: const Text('â€žKlarheit 4/5â€œ'),
          onTap: () async { await Markers.log('clarity', meta: {'score': 4}); await _refresh(); }),
      ]),
      Section(header: 'Chirpâ€‘Cues (optional)', children: [
        RowItem(title: const Text('Chirp â€“ Sanft'), subtitle: const Text('CueProfiles.soft'),
          onTap: () async { await CueProfiles.play(CueProfiles.soft); }),
        RowItem(title: const Text('Chirp â€“ Federleicht'), subtitle: const Text('Sehr leise'),
          onTap: () async { await CueProfiles.play(CueProfiles.feather); }),
      ]),
      Section(header: 'Letzte Marker', children: [
        for (final line in tail) RowItem(title: Text(line)),
      ]),
    ]));
  }
}






