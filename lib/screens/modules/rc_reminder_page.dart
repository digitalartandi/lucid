// lib/screens/modules/rc_reminder_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cue_models.dart';
import '../../services/cue_player.dart';
import 'rc_reminder_store.dart';

const _bg     = Color(0xFF0D0F16);
const _white  = Color(0xFFE9EAFF);
const _card   = Color(0xFF0A0A23);
const _line   = Color(0x22FFFFFF);
const _accent = Color(0xFF7A6CFF);

const _kCueSelectedJson = 'cue.selected.v1';
const _kRcVolume = 'rc.volume.v1';

class _CuePrefs {
  static Future<CueSound?> load() async {
    final sp = await SharedPreferences.getInstance();
    final s  = sp.getString(_kCueSelectedJson);
    if (s == null) return null;
    final m = jsonDecode(s) as Map<String, dynamic>;
    return CueSound(
      id:       (m['id'] ?? '') as String,
      name:     (m['name'] ?? '') as String,
      category: (m['category'] ?? '') as String,
      asset:    (m['asset'] ?? '') as String,
    );
  }
}

class RcReminderPage extends StatefulWidget {
  const RcReminderPage({super.key});
  @override
  State<RcReminderPage> createState() => _RcReminderPageState();
}

class _RcReminderPageState extends State<RcReminderPage> {
  final _player  = CueLoopPlayer.instance;
  final _store   = RcReminderStore.instance;

  CueSound? _cue;
  double _volume = .8;

  StreamSubscription<int>? _revSub;

  @override
  void initState() {
    super.initState();
    _load();
    _revSub = _store.revision.stream.listen((_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _revSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    await _store.init();
    final cue = await _CuePrefs.load();
    final sp  = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _cue = cue;
      _volume = sp.getDouble(_kRcVolume) ?? .8;
    });
  }

  Future<void> _pickCue() async {
    final res = await Navigator.of(context).pushNamed(
      '/cues',
      arguments: {'picker': true, 'selectedId': _cue?.id},
    );
    if (!mounted) return;
    if (res is CueSound) {
      setState(() => _cue = res);
    } else {
      final fromPrefs = await _CuePrefs.load();
      if (!mounted) return;
      setState(() => _cue = fromPrefs);
    }
  }

  Future<void> _probe() async {
    if (_cue == null) return;
    try {
      await _player.playOnce(_cue!, seconds: 3, volume: _volume);
    } catch (_) {
      try {
        await (_player as dynamic)
            .playOnce((_cue as dynamic).asset as String, seconds: 3, volume: _volume);
      } catch (_) {}
    }
  }

  Future<void> _saveVolume(double v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_kRcVolume, v);
  }

  @override
  Widget build(BuildContext context) {
    final items = _store.items;

    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: const Text('RC-Reminder', style: TextStyle(color: _white)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _openEditor(),
          child: const Icon(CupertinoIcons.add_circled_solid, color: _accent),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            // ---- Cue & Volume ----
            _Section(
              title: 'Cue',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_cue?.name ?? 'Kein Cue gewählt',
                    style: const TextStyle(color: _white)),
                const SizedBox(height: 10),
                Row(children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: const Color(0xFF2A2942),
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _pickCue,
                    child: const Text('Auswählen', style: TextStyle(color: _white)),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: const Color(0xFF2A2942),
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _cue == null ? null : _probe,
                    child: const Text('Probe', style: TextStyle(color: _white)),
                  ),
                ]),
                const SizedBox(height: 12),
                const Text('Lautstärke',
                    style: TextStyle(color: _white, fontWeight: FontWeight.w700)),
                Row(children: [
                  Expanded(
                    child: CupertinoSlider(
                      value: _volume,
                      onChanged: (v) { setState(() => _volume = v); _saveVolume(v); },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${(_volume * 100).round()}%',
                      style: const TextStyle(color: _white)),
                ]),
              ]),
            ),

            const SizedBox(height: 12),

            // ---- Reminder-Liste ----
            if (items.isEmpty)
              _EmptyHint(onAdd: _openEditor)
            else
              ...items.map((r) => _ReminderTile(
                    r: r,
                    onTap: () => _openEditor(r),
                    onToggle: (v) => _store.update(r.copyWith(enabled: v)),
                    onDelete: () => _store.remove(r.id),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor([RcReminder? r]) async {
    final result = await Navigator.of(context).push<RcReminder>(
      CupertinoPageRoute(builder: (_) => _EditReminderPage(reminder: r)),
    );
    if (result == null) return;
    if (r == null) {
      await _store.add(result);
    } else {
      await _store.update(result);
    }
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.r,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final RcReminder r;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitle = r.mode == RcMode.once
        ? _fmtDateTime(r.dateTime!)
        : 'Täglich · ${_two(r.hour!)}:${_two(r.minute!)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: CupertinoListTile(
        onTap: onTap,
        title: Text(r.label ?? 'Erinnerung',
            style: const TextStyle(color: _white, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: _white)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          CupertinoSwitch(value: r.enabled, onChanged: onToggle),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFF402D2D),
            borderRadius: BorderRadius.circular(10),
            onPressed: onDelete,
            child: const Icon(CupertinoIcons.delete, color: _white, size: 18),
          ),
        ]),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyHint({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(children: [
        const Icon(CupertinoIcons.bell, color: _white, size: 32),
        const SizedBox(height: 10),
        const Text(
          'Noch keine RC-Reminder.\nTippe rechts oben auf „+“, um einen anzulegen.',
          textAlign: TextAlign.center, style: TextStyle(color: _white)),
        const SizedBox(height: 10),
        CupertinoButton.filled(
          borderRadius: BorderRadius.circular(12),
          onPressed: onAdd,
          child: const Text('Reminder hinzufügen'),
        ),
      ]),
    );
  }
}

/// Editor-Screen
class _EditReminderPage extends StatefulWidget {
  final RcReminder? reminder;
  const _EditReminderPage({this.reminder});
  @override
  State<_EditReminderPage> createState() => _EditReminderPageState();
}

class _EditReminderPageState extends State<_EditReminderPage> {
  RcMode _mode = RcMode.once;
  DateTime _dt = DateTime.now().add(const Duration(minutes: 5));
  int _hour = 8, _minute = 0;
  String _label = 'RC-Reminder';
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    if (r != null) {
      _mode = r.mode;
      _dt = r.dateTime ?? _dt;
      _hour = r.hour ?? _hour;
      _minute = r.minute ?? _minute;
      _label = r.label ?? _label;
      _enabled = r.enabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: Text(widget.reminder == null ? 'Reminder anlegen' : 'Reminder bearbeiten',
            style: const TextStyle(color: _white)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _save,
          child: const Text('Speichern', style: TextStyle(color: _white)),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            _Section(
              title: 'Modus',
              child: CupertinoSlidingSegmentedControl<RcMode>(
                groupValue: _mode,
                children: const {
                  RcMode.once: Text('Einmalig'),
                  RcMode.daily: Text('Täglich'),
                },
                onValueChanged: (m) => setState(() => _mode = m ?? RcMode.once),
              ),
            ),
            if (_mode == RcMode.once)
              _Section(
                title: 'Datum & Uhrzeit',
                child: SizedBox(
                  height: 180,
                  child: CupertinoDatePicker(
                    initialDateTime: _dt,
                    mode: CupertinoDatePickerMode.dateAndTime,
                    use24hFormat: true,
                    onDateTimeChanged: (v) => _dt = v,
                  ),
                ),
              )
            else
              _Section(
                title: 'Uhrzeit (täglich)',
                child: Row(children: [
                  Expanded(
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hm,
                      initialTimerDuration: Duration(hours: _hour, minutes: _minute),
                      onTimerDurationChanged: (d) {
                        _hour = d.inHours; _minute = d.inMinutes % 60;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${_two(_hour)}:${_two(_minute)}', style: const TextStyle(color: _white)),
                ]),
              ),
            _Section(
              title: 'Name',
              child: CupertinoTextField(
                controller: TextEditingController(text: _label),
                onChanged: (v) => _label = v,
                placeholder: 'z. B. „Mittags-RC“',
              ),
            ),
            _Section(
              title: 'Aktiv',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Erinnerung ist aktiv', style: TextStyle(color: _white)),
                  CupertinoSwitch(value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final r = (widget.reminder ?? RcReminder.create()).copyWith(
      mode: _mode,
      dateTime: _mode == RcMode.once ? _dt : null,
      hour: _mode == RcMode.daily ? _hour : null,
      minute: _mode == RcMode.daily ? _minute : null,
      label: _label.trim().isEmpty ? null : _label.trim(),
      enabled: _enabled,
    );
    Navigator.of(context).pop(r);
  }
}

// ---- kleine UI-Helfer
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: _white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

String _two(int n) => n.toString().padLeft(2, '0');
String _fmtDateTime(DateTime d) =>
    '${_two(d.day)}.${_two(d.month)}.${d.year} · ${_two(d.hour)}:${_two(d.minute)}';
