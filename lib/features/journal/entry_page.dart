// lib/features/journal/entry_page.dart
//
// Traum-Eintrag: erst schreiben, dann einordnen. Speichert automatisch.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/practice_store.dart';
import '../../core/techniques.dart';
import '../../models/journal_models.dart';
import '../../services/journal_repo.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';
import 'journal_page.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key, this.id});

  /// null: neuer Eintrag.
  final String? id;

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final JournalRepo _repo = JournalRepo.instance;
  final PracticeStore _store = PracticeStore.instance;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();
  final TextEditingController _tag = TextEditingController();

  JournalEntry? _entry;
  bool _isNew = false;
  bool _dirty = false;
  bool _saved = false;
  Timer? _debounce;

  static const List<String> _moodLabels = <String>['Unangenehm', 'Neutral', 'Angenehm'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    JournalEntry? e;
    if (widget.id != null) e = await _repo.getById(widget.id!);
    if (e == null) {
      e = JournalEntry.newDraft();
      _isNew = true;
    }
    if (!mounted) return;
    final JournalEntry entry = e;
    setState(() {
      _entry = entry;
      _title.text = entry.title;
      _body.text = entry.body;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _flush();
    _title.dispose();
    _body.dispose();
    _tag.dispose();
    super.dispose();
  }

  bool get _hasContent {
    final JournalEntry? e = _entry;
    if (e == null) return false;
    return _title.text.trim().isNotEmpty || _body.text.trim().isNotEmpty || e.tags.isNotEmpty || e.lucid;
  }

  void _touch() {
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), _flush);
  }

  /// Schreibt den aktuellen Stand, sofern es etwas zu speichern gibt.
  Future<void> _flush() async {
    final JournalEntry? e = _entry;
    if (e == null || !_dirty || !_hasContent) return;
    _dirty = false;
    e.title = _title.text.trim();
    e.body = _body.text.trim();
    if (e.title.isEmpty && e.body.isNotEmpty) {
      // Titel aus den ersten Worten ableiten, damit die Liste lesbar bleibt.
      final List<String> words = e.body.split(RegExp(r'\s+'));
      e.title = words.take(6).join(' ');
    }
    await _repo.upsert(e);
    final bool first = !_saved;
    _saved = true;
    if (first && _isNew) {
      // Ein neuer Eintrag heißt: An diesem Morgen wurde etwas erinnert.
      final int level = e.body.length > 200 ? 2 : 1;
      if (_store.logFor(e.date).recall < level) {
        await _store.setRecall(level, on: e.date);
      }
    }
    if (e.lucid) await _store.setLucid(true, on: e.date);
    if (mounted) setState(() {});
  }

  void _addTag(String raw) {
    final String t = raw.trim().replaceAll('#', '');
    if (t.isEmpty || _entry == null) return;
    if (!_entry!.tags.any((String x) => x.toLowerCase() == t.toLowerCase())) {
      setState(() => _entry!.tags.add(t));
      _touch();
    }
    _tag.clear();
  }

  Future<void> _pickDate() async {
    final JournalEntry e = _entry!;
    DateTime picked = e.date;
    await showLSheet<void>(
      context,
      builder: (BuildContext ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Wann war der Traum?', style: LT.title),
          SizedBox(
            height: 180,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: e.date,
              maximumDate: DateTime.now().add(const Duration(minutes: 1)),
              onDateTimeChanged: (DateTime d) => picked = d,
            ),
          ),
          const SizedBox(height: LS.md),
          LButton(label: 'Übernehmen', onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    );
    setState(() {
      e.date = DateTime(picked.year, picked.month, picked.day, e.date.hour, e.date.minute);
    });
    _touch();
  }

  Future<void> _delete() async {
    final bool ok = await confirmL(
      context,
      title: 'Eintrag löschen?',
      message: 'Der Traum wird endgültig entfernt.',
      confirmLabel: 'Löschen',
      destructive: true,
    );
    if (!ok) return;
    _debounce?.cancel();
    _dirty = false;
    final String id = _entry!.id;
    _entry = null;
    await _repo.delete(id);
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _share() async {
    await _flush();
    final JournalEntry e = _entry!;
    final StringBuffer b = StringBuffer()
      ..writeln(e.title.isEmpty ? 'Traum' : e.title)
      ..writeln(journalDate(e.date))
      ..writeln()
      ..writeln(e.body);
    if (e.tags.isNotEmpty) {
      b
        ..writeln()
        ..writeln('Traumzeichen: ${e.tags.join(', ')}');
    }
    if (e.lucid) b.writeln('Klartraum');
    try {
      await Share.shareXFiles(
        <XFile>[
          XFile.fromData(
            Uint8List.fromList(utf8.encode(b.toString())),
            name: 'traum_${e.id}.txt',
            mimeType: 'text/plain',
          ),
        ],
        text: e.title.isEmpty ? 'Traum' : e.title,
      );
    } catch (_) {
      // Teilen wurde abgebrochen oder ist hier nicht verfügbar.
    }
  }

  @override
  Widget build(BuildContext context) {
    final JournalEntry? e = _entry;
    if (e == null) {
      return const LPage(title: 'Traum', child: Center(child: CupertinoActivityIndicator()));
    }
    final List<String> suggestions = _store.profile.dreamSigns
        .where((String s) => !e.tags.any((String t) => t.toLowerCase() == s.toLowerCase()))
        .take(6)
        .toList();

    return LPage(
      title: _isNew ? 'Neuer Traum' : 'Traum',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LTap(
            onTap: _share,
            semanticLabel: 'Teilen',
            child: const Padding(
              padding: EdgeInsets.all(LS.sm),
              child: Icon(CupertinoIcons.share, size: 20, color: LC.muted),
            ),
          ),
          if (!_isNew || _saved)
            LTap(
              onTap: _delete,
              semanticLabel: 'Löschen',
              child: const Padding(
                padding: EdgeInsets.all(LS.sm),
                child: Icon(CupertinoIcons.trash, size: 20, color: LC.muted),
              ),
            ),
        ],
      ),
      child: LScroll(
        children: <Widget>[
          Row(
            children: <Widget>[
              LTap(
                onTap: _pickDate,
                child: Row(
                  children: <Widget>[
                    const Icon(CupertinoIcons.calendar, size: 16, color: LC.muted),
                    const SizedBox(width: 6),
                    Text(journalDate(e.date), style: LT.labelMuted),
                  ],
                ),
              ),
              const Spacer(),
              Text(_saved && !_dirty ? 'Gespeichert' : (_hasContent ? 'Speichert automatisch' : ''),
                  style: LT.caption),
            ],
          ),
          const SizedBox(height: LS.md),
          LField(
            controller: _body,
            placeholder: 'Was ist passiert? Ort, Personen, Gefühl, Seltsames. Stichworte genügen.',
            maxLines: null,
            minLines: 7,
            autofocus: _isNew,
            onChanged: (_) => _touch(),
          ),
          const SizedBox(height: LS.md),
          LField(
            controller: _title,
            placeholder: 'Titel (optional)',
            style: LT.heading,
            onChanged: (_) => _touch(),
          ),
          const LSection('War es ein Klartraum?'),
          LCard(
            borderColor: e.lucid ? const Color(0x59F2C879) : null,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const LIconDot(CupertinoIcons.sparkles, color: LC.moon),
                    const SizedBox(width: LS.md),
                    Expanded(
                      child: Text('Ich wusste, dass ich träume', style: LT.heading.copyWith(fontSize: 16)),
                    ),
                    LSwitch(
                      value: e.lucid,
                      tone: LC.moon,
                      onChanged: (bool v) {
                        setState(() {
                          e.lucid = v;
                          if (!v) e.control = false;
                        });
                        _touch();
                      },
                    ),
                  ],
                ),
                if (e.lucid) ...<Widget>[
                  const SizedBox(height: LS.md),
                  Container(height: 1, color: LC.line),
                  const SizedBox(height: LS.md),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Ich konnte den Traum beeinflussen', style: LT.label),
                      ),
                      LSwitch(
                        value: e.control,
                        tone: LC.moon,
                        onChanged: (bool v) {
                          setState(() => e.control = v);
                          _touch();
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const LSection('Traumzeichen und Themen'),
          if (e.tags.isNotEmpty) ...<Widget>[
            Wrap(
              spacing: LS.sm,
              runSpacing: LS.sm,
              children: <Widget>[
                for (final String t in e.tags)
                  LChip(
                    label: t,
                    selected: true,
                    icon: CupertinoIcons.xmark,
                    onTap: () {
                      setState(() => e.tags.remove(t));
                      _touch();
                    },
                  ),
              ],
            ),
            const SizedBox(height: LS.md),
          ],
          LField(
            controller: _tag,
            placeholder: 'Hinzufügen, z. B. Schule, Fliegen',
            textInputAction: TextInputAction.done,
            onSubmitted: _addTag,
          ),
          if (suggestions.isNotEmpty) ...<Widget>[
            const SizedBox(height: LS.md),
            Wrap(
              spacing: LS.sm,
              runSpacing: LS.sm,
              children: <Widget>[
                for (final String s in suggestions)
                  LChip(label: s, icon: CupertinoIcons.plus, onTap: () => _addTag(s)),
              ],
            ),
          ],
          const LSection('Stimmung im Traum'),
          Wrap(
            spacing: LS.sm,
            runSpacing: LS.sm,
            children: <Widget>[
              for (int i = 0; i < 3; i++)
                LChip(
                  label: _moodLabels[i],
                  selected: e.mood == i - 1,
                  onTap: () {
                    setState(() => e.mood = i - 1);
                    _touch();
                  },
                ),
            ],
          ),
          const LSection('Technik in dieser Nacht'),
          Wrap(
            spacing: LS.sm,
            runSpacing: LS.sm,
            children: <Widget>[
              LChip(
                label: 'Keine',
                selected: e.technique.isEmpty,
                onTap: () {
                  setState(() => e.technique = '');
                  _touch();
                },
              ),
              for (final Technique t in techniques)
                if (t.id != 'journal' && t.id != 'stabilize' && t.id != 'rc')
                  LChip(
                    label: t.name,
                    selected: e.technique == t.id,
                    onTap: () {
                      setState(() => e.technique = t.id);
                      _touch();
                    },
                  ),
            ],
          ),
          const SizedBox(height: LS.xl),
          LButton(
            label: 'Fertig',
            onPressed: () async {
              _debounce?.cancel();
              await _flush();
              if (context.mounted) Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }
}
