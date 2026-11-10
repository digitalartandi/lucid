// lib/features/settings/settings_page.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/practice_store.dart';
import '../../services/journal_repo.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';
import '../shell/app_shell.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PracticeStore _store = PracticeStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _pickTime({required bool bed}) async {
    final Profile p = _store.profile;
    final int h = bed ? p.bedHour : p.wakeHour;
    final int m = bed ? p.bedMinute : p.wakeMinute;
    DateTime picked = DateTime(2024, 1, 1, h, m - m % 5);
    await showLSheet<void>(
      context,
      builder: (BuildContext ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(bed ? 'Schlafenszeit' : 'Aufstehen', style: LT.title),
          SizedBox(
            height: 180,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              minuteInterval: 5,
              initialDateTime: picked,
              onDateTimeChanged: (DateTime d) => picked = d,
            ),
          ),
          const SizedBox(height: LS.md),
          LButton(label: 'Übernehmen', onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    );
    if (bed) {
      p.bedHour = picked.hour;
      p.bedMinute = picked.minute;
    } else {
      p.wakeHour = picked.hour;
      p.wakeMinute = picked.minute;
    }
    await _store.saveProfile();
  }

  Future<void> _export({required bool csv}) async {
    final JournalRepo repo = JournalRepo.instance;
    final String data = csv ? await repo.exportCsv() : await repo.exportJson();
    try {
      await Share.shareXFiles(
        <XFile>[
          XFile.fromData(
            Uint8List.fromList(utf8.encode(data)),
            name: csv ? 'lucid_journal.csv' : 'lucid_journal.json',
            mimeType: csv ? 'text/csv' : 'application/json',
          ),
        ],
        subject: 'Lucid Journal',
      );
    } catch (_) {
      if (!mounted) return;
      await showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext ctx) => CupertinoAlertDialog(
          title: const Text('Export nicht möglich'),
          content: const Text('Dieses Gerät oder dieser Browser unterstützt das Teilen von Dateien nicht.'),
          actions: <Widget>[
            CupertinoDialogAction(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> _reset() async {
    final bool ok = await confirmL(
      context,
      title: 'Übungsstand zurücksetzen?',
      message: 'Profil, Programm und Tagesprotokoll werden gelöscht. Das Journal bleibt erhalten. Danach beginnt die Einführung neu.',
      confirmLabel: 'Zurücksetzen',
      destructive: true,
    );
    if (!ok) return;
    if (mounted) Navigator.of(context, rootNavigator: true).popUntil((Route<dynamic> r) => r.isFirst);
    await _store.resetAll();
  }

  @override
  Widget build(BuildContext context) {
    final Profile p = _store.profile;
    final int mins = p.sleepMinutes;
    return LPage(
      title: 'Einstellungen',
      child: LScroll(
        children: <Widget>[
          const LSection('Schlaf'),
          LGroup(
            children: <Widget>[
              LRow(
                icon: CupertinoIcons.moon,
                title: 'Schlafenszeit',
                trailing: Text(hhmm(p.bedHour, p.bedMinute), style: LT.heading.copyWith(color: LC.iris)),
                onTap: () => _pickTime(bed: true),
              ),
              LRow(
                icon: CupertinoIcons.sunrise,
                iconColor: LC.moon,
                title: 'Aufstehen',
                trailing: Text(hhmm(p.wakeHour, p.wakeMinute), style: LT.heading.copyWith(color: LC.iris)),
                onTap: () => _pickTime(bed: false),
              ),
              LRow(
                icon: CupertinoIcons.bed_double,
                title: 'Leichter Schlaf',
                subtitle: 'Keine Wecker-Nächte im Programm',
                trailing: LSwitch(
                  value: p.lightSleeper,
                  onChanged: (bool v) {
                    p.lightSleeper = v;
                    _store.saveProfile();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: LS.sm),
          Text(
            'Geplante Schlafdauer: ${mins ~/ 60} h ${(mins % 60).toString().padLeft(2, '0')} min',
            style: LT.caption,
          ),
          const LSection('Üben'),
          LGroup(
            children: <Widget>[
              LRow(
                icon: CupertinoIcons.calendar,
                title: 'Programm',
                subtitle: 'Verlauf ansehen oder neu beginnen',
                onTap: () => openRoute(context, '/program'),
              ),
              LRow(
                icon: CupertinoIcons.text_alignleft,
                title: 'Absichtssatz',
                onTap: () => openRoute(context, '/practice/intention'),
              ),
              LRow(
                icon: CupertinoIcons.tag,
                title: 'Traumzeichen',
                onTap: () => openRoute(context, '/practice/signs'),
              ),
              LRow(
                icon: CupertinoIcons.music_note_2,
                title: 'Ton für Wecksignal und Klangsignale',
                onTap: () => openRoute(context, '/cues'),
              ),
              LRow(
                icon: CupertinoIcons.bell,
                title: 'Reality-Check-Erinnerungen',
                onTap: () => openRoute(context, '/rc'),
              ),
            ],
          ),
          const LSection('Deine Daten'),
          LGroup(
            children: <Widget>[
              LRow(
                icon: CupertinoIcons.share,
                title: 'Journal exportieren (JSON)',
                onTap: () => _export(csv: false),
              ),
              LRow(
                icon: CupertinoIcons.share,
                title: 'Journal exportieren (CSV)',
                onTap: () => _export(csv: true),
              ),
              LRow(
                icon: CupertinoIcons.trash,
                iconColor: LC.rose,
                title: 'Übungsstand zurücksetzen',
                onTap: _reset,
              ),
            ],
          ),
          const SizedBox(height: LS.sm),
          Text(
            'Alle Daten liegen nur auf diesem Gerät. Im Browser gehen sie verloren, wenn du die Website-Daten löschst. Exportiere dein Journal gelegentlich.',
            style: LT.caption,
          ),
          const LSection('Hinweise'),
          LGroup(
            children: <Widget>[
              LRow(
                icon: CupertinoIcons.shield,
                title: 'Sicherheit und Grenzen',
                onTap: () => openRoute(context, '/wissen/article', arg: 'assets/wissen/ethik_risiken_de.md'),
              ),
              LRow(
                icon: CupertinoIcons.link,
                title: 'Quellen',
                onTap: () => openRoute(context, '/wissen/article', arg: 'assets/wissen/quellen_zitate_de.md'),
              ),
            ],
          ),
          const SizedBox(height: LS.lg),
          const LNote(
            text: 'Lucid gibt Orientierung auf Basis veröffentlichter Studien und ersetzt keine medizinische oder therapeutische Beratung.',
          ),
        ],
      ),
    );
  }
}
