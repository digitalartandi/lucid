import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cue_models.dart';
import '../../services/cue_sounds_repo.dart';
import '../../services/cue_player.dart';
import '../../services/cue_prefs.dart';

const _bg = Color(0xFF0B0F2A);
const _title = Color(0xFFF7F8FF);
const _muted = Color(0xCCFFFFFF);
const _tile = Color(0x191C2A66);
const _stroke = Color(0x33FFFFFF);
const _active = Color(0xFF7C83FF);
const _r = BorderRadius.all(Radius.circular(16));

class CueLibraryPage extends StatefulWidget {
  const CueLibraryPage({super.key, this.returnOnPick = false});
  final bool returnOnPick; // true = als reiner Picker (pop mit Auswahl)

  @override
  State<CueLibraryPage> createState() => _CueLibraryPageState();
}

class _CueLibraryPageState extends State<CueLibraryPage> {
  final _repo = CueSoundsRepo.instance;
  final _player = CueLoopPlayer.instance;

  List<CueCategoryGroup> _groups = const [];
  String? _previewId;
  String? _selectedId; // aus Prefs geladen

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groups = await _repo.groupedWithImages();
    final cfg = await CuePrefs.load();
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _selectedId = cfg.asset;
    });
  }

  Future<void> _togglePreview(CueSound s) async {
    if (_previewId == s.id) {
      await _player.stop();
    } else {
      await _player.playLoop(s.id, volume: 0.8);
    }
    if (!mounted) return;
    setState(() => _previewId = (_previewId == s.id) ? null : s.id);
  }

  Future<void> _selectCue(CueSound s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(CuePrefsKeys.asset, s.id);
    setState(() => _selectedId = s.id);

    // wenn Picker: direkt zurückgeben
    if (widget.returnOnPick) {
      Navigator.of(context).pop<CueSound>(s);
      return;
    }

    // Klareres Feedback
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Cue gespeichert'),
        content: Text('„${s.name}“ wird ab jetzt verwendet.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _player.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: const CupertinoNavigationBar(middle: Text('Cue-Bibliothek')),
      child: _groups.isEmpty
          ? const Center(child: CupertinoActivityIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: _groups.map((g) => _CategoryBlock(
                group: g,
                selectedId: _selectedId,
                previewId: _previewId,
                onPreview: _togglePreview,
                onSelect: _selectCue,
              )).toList(),
            ),
    );
  }
}

class _CategoryBlock extends StatelessWidget {
  final CueCategoryGroup group;
  final String? selectedId;
  final String? previewId;
  final void Function(CueSound) onPreview;
  final void Function(CueSound) onSelect;

  const _CategoryBlock({
    required this.group,
    required this.selectedId,
    required this.previewId,
    required this.onPreview,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headerbild + Titel
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: _r,
            border: Border.all(color: _stroke),
            color: _tile,
            image: group.imageAsset != null
                ? DecorationImage(
                    image: AssetImage(group.imageAsset!),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  )
                : null,
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xAA000000),
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Text(group.title,
                style: const TextStyle(
                  color: _title, fontWeight: FontWeight.w800, fontSize: 14,
                )),
          ),
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: group.items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final s = group.items[i];
              final active = selectedId == s.id;
              final preview = previewId == s.id;

              return GestureDetector(
                onTap: () => onPreview(s),
                onLongPress: () => onSelect(s), // Long-press: direkt setzen
                child: Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: _tile,
                    borderRadius: _r,
                    border: Border.all(color: active ? _active : _stroke, width: active ? 2 : 1),
                    boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 6))],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: active ? _active : _stroke, width: active ? 2 : 1),
                          color: active ? const Color(0x222244FF) : const Color(0x11223366),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          preview ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                          color: _title,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _title,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        onPressed: () => onSelect(s),
                        child: Text(active ? 'Ausgewählt' : 'Setzen',
                            style: TextStyle(color: active ? _active : _title)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
