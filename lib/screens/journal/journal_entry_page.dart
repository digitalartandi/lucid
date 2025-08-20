// lib/screens/journal/journal_entry_page.dart
import 'dart:convert' show jsonEncode;
import 'dart:typed_data' show Uint8List;
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/journal_models.dart';
import '../../services/journal_repo.dart';

class JournalEntryPage extends StatefulWidget {
  final String id;
  const JournalEntryPage({super.key, required this.id});

  @override
  State<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  final _repo = JournalRepo.instance;
  JournalEntry? _entry;
  final _titleCtl = TextEditingController();
  final _bodyCtl = TextEditingController();
  final _tagCtl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await _repo.getById(widget.id);
    setState(() {
      _entry = e ?? JournalEntry.newDraft().copyWith();
      _titleCtl.text = _entry!.title;
      _bodyCtl.text = _entry!.body;
    });
  }

  Future<void> _save() async {
    if (_entry == null) return;
    setState(() => _saving = true);
    final e = _entry!.copyWith(
      title: _titleCtl.text.trim(),
      body: _bodyCtl.text.trim(),
    );
    await _repo.upsert(e);
    setState(() { _entry = e; _saving = false; });
    _toast('Gespeichert');
  }

  Future<void> _delete() async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (c) => CupertinoAlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text('Dieser Vorgang kann nicht rückgängig gemacht werden.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Löschen'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _repo.delete(widget.id);
      if (!mounted) return;
      Navigator.of(context).pop(); // zurück zur Liste
      // Banner in der Liste erscheint auch, aber sicherheitshalber:
      // (nur falls die Liste nicht sichtbar ist)
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _bodyCtl.dispose();
    _tagCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF0E0D18);
    final titleColor = const Color(0xFFE9EAFF);
    final violet = const Color(0xFF7A6CFF);
    final hairline = const Color(0x22FFFFFF);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: bg.withOpacity(0.9),
        middle: Text('Eintrag', style: TextStyle(color: titleColor, fontSize: 17)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_entry != null)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _exportEntry,
                child: Icon(CupertinoIcons.square_arrow_up, color: violet),
              ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _save,
              child: _saving
                  ? const CupertinoActivityIndicator(radius: 9)
                  : Icon(CupertinoIcons.check_mark_circled_solid, color: violet),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _delete,
              child: const Icon(CupertinoIcons.delete, color: Color(0xFFEF9A9A)),
            ),
          ],
        ),
        border: const Border(bottom: BorderSide(color: Color(0x22FFFFFF), width: 0.5)),
      ),
      child: _entry == null
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                children: [
                  _Card(
                    child: Semantics(
                      label: 'Titel des Eintrags',
                      child: CupertinoTextField(
                        controller: _titleCtl,
                        placeholder: 'Titel',
                        style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.w600),
                        placeholderStyle: TextStyle(color: titleColor.withOpacity(0.8)),
                        decoration: const BoxDecoration(color: Color(0x00000000)),
                      ),
                    ),
                  ),
                  _Card(
                    child: SizedBox(
                      height: 240,
                      child: Semantics(
                        label: 'Text des Eintrags',
                        child: CupertinoTextField(
                          controller: _bodyCtl,
                          placeholder: 'Ein bis drei Sätze Ablauf, Stichwörter, Dream-Signs…',
                          placeholderStyle: TextStyle(color: titleColor.withOpacity(0.8)),
                          style: TextStyle(color: titleColor, fontSize: 17, height: 1.38),
                          maxLines: null,
                          expands: true,
                          keyboardType: TextInputType.multiline,
                          decoration: const BoxDecoration(color: Color(0x00000000)),
                        ),
                      ),
                    ),
                  ),
                  _Card(
                    child: Row(
                      children: [
                        const Text('Stimmung ', style: TextStyle(color: Color(0xFFE9EAFF), fontSize: 16)),
                        const SizedBox(width: 8),
                        Semantics(
                          label: 'Stimmung auswählen',
                          child: CupertinoSlidingSegmentedControl<int>(
                            groupValue: _entry!.mood,
                            children: const {
                              -1: Padding(padding: EdgeInsets.all(8), child: Text('🙁', semanticsLabel: 'Traurig')),
                              0: Padding(padding: EdgeInsets.all(8), child: Text('😐', semanticsLabel: 'Neutral')),
                              1: Padding(padding: EdgeInsets.all(8), child: Text('🙂', semanticsLabel: 'Fröhlich')),
                            },
                            onValueChanged: (v) async {
                              if (v == null) return;
                              setState(() => _entry = _entry!.copyWith(mood: v));
                              await _repo.upsert(_entry!);
                              _toast('Stimmung gespeichert');
                            },
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Text('Lucid ', style: TextStyle(color: Color(0xFFE9EAFF), fontSize: 16)),
                            Semantics(
                              label: 'Lucid umschalten',
                              child: CupertinoSwitch(
                                value: _entry!.lucid,
                                onChanged: (v) async {
                                  setState(() => _entry = _entry!.copyWith(lucid: v));
                                  await _repo.upsert(_entry!);
                                  _toast(v ? 'Als Lucid markiert' : 'Lucid-Markierung entfernt');
                                },
                                activeColor: violet,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tags', style: TextStyle(color: Color(0xFFE9EAFF), fontSize: 16)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: -6,
                          children: _entry!.tags.map((t) {
                            return _TagChip(
                              label: t,
                              onRemove: () async {
                                final list = List<String>.from(_entry!.tags)..remove(t);
                                setState(() => _entry = _entry!.copyWith(tags: list));
                                await _repo.upsert(_entry!);
                                _toast('Tag entfernt');
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoTextField(
                                controller: _tagCtl,
                                placeholder: '#Tag hinzufügen',
                                decoration: const BoxDecoration(color: Color(0x00000000)),
                                style: const TextStyle(color: Color(0xFFE9EAFF), fontSize: 16),
                                onSubmitted: _addTag,
                              ),
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              onPressed: () => _addTag(_tagCtl.text),
                              child: const Icon(CupertinoIcons.add, color: Color(0xFF8FA2FF)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _Card(
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          onPressed: _insertUltraKurz,
                          child: const Text('Vorlage ultrakurz'),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          onPressed: _insertSkala,
                          child: const Text('Vorlage mit Skala'),
                        ),
                        const Spacer(),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          onPressed: _showTemplateHelp,
                          child: const Icon(CupertinoIcons.info, color: Color(0xFF8FA2FF)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _addTag(String raw) async {
    final t = raw.trim();
    if (t.isEmpty) return;
    final tag = t.startsWith('#') ? t : '#$t';
    if (_entry == null) return;
    if (_entry!.tags.contains(tag)) { _tagCtl.clear(); return; }
    final list = List<String>.from(_entry!.tags)..add(tag);
    setState(() => _entry = _entry!.copyWith(tags: list));
    _tagCtl.clear();
    await _repo.upsert(_entry!);
    _toast('Tag hinzugefügt');
  }

  void _insertUltraKurz() => _templateInsert(
    '''
Titel:
Stichwörter:
Ein bis drei Sätze:
Dream-Signs: #..., #...
RC-Anker:
'''.trim()
  );

  void _insertSkala() => _templateInsert(
    '''
Titel:
Stimmung:
Stichwörter:
Was passierte, drei bis sechs Sätze:
Dream-Signs: #...
RC-Anker für heute:
'''.trim()
  );

  void _templateInsert(String tpl) async {
    final choice = await showCupertinoModalPopup<int>(
      context: context,
      builder: (c) => CupertinoActionSheet(
        title: const Text('Vorlage einfügen'),
        message: const Text('Möchtest du die Vorlage ans Ende einfügen oder den bestehenden Text ersetzen?'),
        actions: [
          CupertinoActionSheetAction(onPressed: () => Navigator.of(c).pop(0), child: const Text('Einfügen')),
          CupertinoActionSheetAction(onPressed: () => Navigator.of(c).pop(1), child: const Text('Ersetzen')),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(c).pop(-1),
          child: const Text('Abbrechen'),
        ),
      ),
    );
    if (choice == null || choice == -1) return;

    if (choice == 1) {
      _bodyCtl.text = tpl;
    } else {
      _bodyCtl.text = _bodyCtl.text.isEmpty ? tpl : '${_bodyCtl.text.trim()}\n\n$tpl';
    }
    _toast('Vorlage eingefügt');
  }

void _showTemplateHelp() {
  showCupertinoModalPopup(
    context: context,
    builder: (c) => CupertinoActionSheet(
      title: const Text('Vorlagen – so nutzt du sie'),
      message: const Text(
        'Vorlagen helfen Einsteigern, schnell zu starten:\n\n'
        '• „Ultrakurz“: Titel, 3 Stichwörter, 1–3 Sätze.\n'
        '• „Mit Skala“: zusätzlich Stimmung und Fokus-RC.\n\n'
        'Profi-Tipp: Markiere wiederkehrende Dream-Signs als #Tags.\n'
        'Diese Tags nutzt die App später für Filter, Review und RC-Anker.',
      ),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(c).pop(),
        child: const Text('Schließen'),
        isDefaultAction: true,
      ),
    ),
  );
}


  Future<void> _exportEntry() async {
    if (_entry == null) return;
    final s = jsonEncode(_entry!.toJson());
    final name = 'lucid_journal_${_entry!.id}.json';
    await Share.shareXFiles(
      [XFile.fromData(Uint8List.fromList(s.codeUnits), name: name, mimeType: 'application/json')],
      text: _entry!.title.isEmpty ? 'Journal-Eintrag' : _entry!.title,
      subject: 'Journal-Export',
    );
  }

  void _toast(String msg) {
    final entry = OverlayEntry(builder: (_) => _TopBanner(message: msg));
    Overlay.of(context, rootOverlay: true).insert(entry);
    Future.delayed(const Duration(milliseconds: 1400), entry.remove);
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    final hairline = const Color(0x22FFFFFF);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF141321), Color(0xFF0E0D18)],
        ),
        border: Border.all(color: hairline, width: 0.5),
      ),
      child: child,
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _TagChip({required this.label, required this.onRemove});
  @override
  Widget build(BuildContext context) {
    final titleColor = const Color(0xFFE9EAFF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF202033),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: titleColor, fontSize: 14)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(CupertinoIcons.xmark_circle_fill, size: 16, color: Color(0xFF8FA2FF)),
          ),
        ],
      ),
    );
  }
}

class _TopBanner extends StatelessWidget {
  final String message;
  const _TopBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF202033),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 10)],
            ),
            child: Text(message, style: const TextStyle(color: Color(0xFFE9EAFF), fontSize: 14)),
          ),
        ),
      ),
    );
  }
}
