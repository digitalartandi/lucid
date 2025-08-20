import 'package:flutter/cupertino.dart';
import '../../design/a11y_contrast.dart';

class NightLitePage extends StatelessWidget {
  const NightLitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: kA11yBg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: kA11yBg,
        middle: Text('Night Lite+', style: TextStyle(color: kA11yText)),
        border: Border(bottom: BorderSide(color: kA11yDivider, width: .5)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: const [
            _ChosenCueCard(),
            SizedBox(height: 12),
            _ProbeCard(),
            SizedBox(height: 12),
            _PlaybackCard(),
            SizedBox(height: 16),
            _SlidersCard(),
            SizedBox(height: 16),
            _HintCard(),
          ],
        ),
      ),
    );
  }
}

// — Karten — //

class _ChosenCueCard extends StatelessWidget {
  const _ChosenCueCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: panelBox(),
      child: CupertinoListSection.insetGrouped(
        backgroundColor: const Color(0x00000000),
        dividerMargin: 16,
        additionalDividerMargin: 16,
        children: [
          CupertinoListTile(
            title: const Text('Gewählter Cue', style: kLabel),
            subtitle: const Text('Kein Cue gewählt', style: kSub),
            trailing: const Text('Auswählen', style: TextStyle(color: kA11yText, fontWeight: FontWeight.w700)),
            onTap: () => Navigator.of(context).pushNamed('/cue_library'),
          ),
        ],
      ),
    );
  }
}

class _ProbeCard extends StatelessWidget {
  const _ProbeCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: panelBox(),
      child: CupertinoListSection.insetGrouped(
        backgroundColor: const Color(0x00000000),
        children: [
          CupertinoListTile(
            title: const Text('Probe abspielen', style: kLabel),
            subtitle: const Text('5 Sekunden mit aktueller Lautstärke', style: kSub),
            trailing: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: kA11yPanelHi,
              borderRadius: BorderRadius.circular(12),
              onPressed: () => Navigator.of(context).pushNamed('/cue_probe'),
              child: const Text('Probe-Cue', style: TextStyle(color: kA11yText)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybackCard extends StatelessWidget {
  const _PlaybackCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: panelBox(),
      child: CupertinoListSection.insetGrouped(
        backgroundColor: const Color(0x00000000),
        children: [
          CupertinoListTile(
            title: const Text('Wiedergabe', style: kLabel),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: kA11yPanelHi,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => Navigator.of(context).pushNamed('/cue_play'),
                  child: const Text('Play', style: TextStyle(color: kA11yText)),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: kA11yPanelHi,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => Navigator.of(context).pushNamed('/cue_stop'),
                  child: const Text('Stop', style: TextStyle(color: kA11yText)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidersCard extends StatefulWidget {
  const _SlidersCard();
  @override
  State<_SlidersCard> createState() => _SlidersCardState();
}

class _SlidersCardState extends State<_SlidersCard> {
  double volume = .8;
  double interval = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: panelBox(),
      child: CupertinoListSection.insetGrouped(
        backgroundColor: const Color(0x00000000),
        children: [
          CupertinoListTile(
            title: const Text('Lautstärke', style: kLabel),
            trailing: SizedBox(
              width: 220,
              child: CupertinoSlider(
                value: volume,
                onChanged: (v) => setState(() => volume = v),
                activeColor: kA11yAccent,
                thumbColor: kA11yPanelHi,
                min: 0, max: 1,
              ),
            ),
          ),
          CupertinoListTile(
            title: Text('Intervall: ${interval.toStringAsFixed(0)} min', style: kLabel),
            subtitle: const Text('Zeit zwischen zwei Cues', style: kSub),
            trailing: SizedBox(
              width: 220,
              child: CupertinoSlider(
                value: interval,
                onChanged: (v) => setState(() => interval = v),
                activeColor: kA11yAccent,
                thumbColor: kA11yPanelHi,
                min: 5, max: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: panelBox(),
      child: const Text(
        'Die Auswahl und Einstellungen werden automatisch gespeichert und in RC-Reminder / Night Lite+ verwendet.',
        style: kSub,
      ),
    );
  }
}
