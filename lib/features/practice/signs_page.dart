// lib/features/practice/signs_page.dart
//
// Traumzeichen und Absichtssatz: zwei kleine Seiten, die MILD persönlich machen.
import 'package:flutter/cupertino.dart';

import '../../core/practice_store.dart';
import '../../models/journal_models.dart';
import '../../services/journal_repo.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';

class DreamSignsPage extends StatefulWidget {
  const DreamSignsPage({super.key});

  @override
  State<DreamSignsPage> createState() => _DreamSignsPageState();
}

class _DreamSignsPageState extends State<DreamSignsPage> {
  final PracticeStore _store = PracticeStore.instance;
  final TextEditingController _input = TextEditingController();

  static const List<String> _examples = <String>[
    'Ich bin wieder in der Schule',
    'Verstorbene Personen',
    'Ich kann fliegen oder schweben',
    'Zähne fallen aus',
    'Unbekannte Räume im eigenen Haus',
    'Ich komme zu spät',
    'Technik funktioniert nicht',
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _add(String raw) async {
    final String s = raw.trim();
    if (s.isEmpty) return;
    final List<String> list = _store.profile.dreamSigns;
    if (!list.any((String e) => e.toLowerCase() == s.toLowerCase())) {
      list.add(s);
      await _store.saveProfile();
    }
    _input.clear();
    if (mounted) setState(() {});
  }

  Future<void> _remove(String s) async {
    _store.profile.dreamSigns.remove(s);
    await _store.saveProfile();
    if (mounted) setState(() {});
  }

  /// Häufigste Stichworte aus dem Journal, die noch kein Traumzeichen sind.
  List<String> _fromJournal() {
    final Map<String, int> count = <String, int>{};
    for (final JournalIndexItem e in JournalRepo.instance.snapshot) {
      for (final String t in e.tags) {
        count[t] = (count[t] ?? 0) + 1;
      }
    }
    final Set<String> have = _store.profile.dreamSigns.map((String e) => e.toLowerCase()).toSet();
    final List<MapEntry<String, int>> sorted = count.entries
        .where((MapEntry<String, int> e) => !have.contains(e.key.toLowerCase()))
        .toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value));
    return sorted.take(8).map((MapEntry<String, int> e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> signs = _store.profile.dreamSigns;
    final List<String> journal = _fromJournal();
    final Set<String> have = signs.map((String e) => e.toLowerCase()).toSet();
    final List<String> examples =
        _examples.where((String e) => !have.contains(e.toLowerCase())).toList();
    return LPage(
      title: 'Traumzeichen',
      child: LScroll(
        children: <Widget>[
          Text('Woran erkennst du deine Träume?', style: LT.title),
          const SizedBox(height: LS.sm),
          Text(
            'Traumzeichen sind Dinge, die in deinen Träumen immer wieder vorkommen und im Wachleben nicht oder kaum. Bei MILD stellst du dir vor, genau daran klar zu werden.',
            style: LT.bodyMuted,
          ),
          const SizedBox(height: LS.lg),
          LField(
            controller: _input,
            placeholder: 'Neues Traumzeichen',
            textInputAction: TextInputAction.done,
            onSubmitted: _add,
          ),
          const SizedBox(height: LS.sm),
          LButton(
            label: 'Hinzufügen',
            kind: LButtonKind.secondary,
            onPressed: () => _add(_input.text),
          ),
          const LSection('Deine Traumzeichen'),
          if (signs.isEmpty)
            Text('Noch keine. Zwei oder drei reichen für den Anfang.', style: LT.labelMuted)
          else
            LGroup(
              children: <Widget>[
                for (final String s in signs)
                  LRow(
                    title: s,
                    trailing: LTap(
                      onTap: () => _remove(s),
                      semanticLabel: 'Entfernen',
                      child: const Padding(
                        padding: EdgeInsets.all(LS.xs),
                        child: Icon(CupertinoIcons.xmark, size: 18, color: LC.faint),
                      ),
                    ),
                  ),
              ],
            ),
          if (journal.isNotEmpty) ...<Widget>[
            const LSection('Häufig in deinem Journal'),
            Wrap(
              spacing: LS.sm,
              runSpacing: LS.sm,
              children: <Widget>[
                for (final String s in journal)
                  LChip(label: s, icon: CupertinoIcons.plus, onTap: () => _add(s)),
              ],
            ),
          ],
          if (examples.isNotEmpty) ...<Widget>[
            const LSection('Typische Beispiele'),
            Wrap(
              spacing: LS.sm,
              runSpacing: LS.sm,
              children: <Widget>[
                for (final String s in examples)
                  LChip(label: s, icon: CupertinoIcons.plus, onTap: () => _add(s)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class IntentionPage extends StatefulWidget {
  const IntentionPage({super.key});

  @override
  State<IntentionPage> createState() => _IntentionPageState();
}

class _IntentionPageState extends State<IntentionPage> {
  final PracticeStore _store = PracticeStore.instance;
  late final TextEditingController _text =
      TextEditingController(text: _store.profile.intention);

  static const List<String> _variants = <String>[
    Profile.defaultIntention,
    'Beim nächsten Traum weiß ich: Das ist ein Traum.',
    'Wenn etwas seltsam ist, prüfe ich, ob ich träume.',
    'Heute Nacht merke ich, dass ich träume.',
  ];

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String s = _text.text.trim();
    _store.profile.intention = s.isEmpty ? Profile.defaultIntention : s;
    await _store.saveProfile();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return LPage(
      title: 'Absichtssatz',
      child: LScroll(
        children: <Widget>[
          Text('Der Satz, den du beim MILD wiederholst', style: LT.title),
          const SizedBox(height: LS.sm),
          Text(
            'Er soll in der Zukunft liegen, konkret sein und in deinen Worten stehen. Die geführte MILD-Übung blendet ihn ein.',
            style: LT.bodyMuted,
          ),
          const SizedBox(height: LS.lg),
          LField(controller: _text, maxLines: 3, minLines: 2),
          const LSection('Vorschläge'),
          for (final String v in _variants)
            Padding(
              padding: const EdgeInsets.only(bottom: LS.sm),
              child: LCard(
                onTap: () => setState(() => _text.text = v),
                child: Text(v, style: LT.body.copyWith(fontSize: 15.5)),
              ),
            ),
          const SizedBox(height: LS.lg),
          LButton(label: 'Satz speichern', onPressed: _save),
        ],
      ),
    );
  }
}
