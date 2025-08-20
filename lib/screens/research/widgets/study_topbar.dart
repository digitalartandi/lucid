import 'package:flutter/cupertino.dart';
import '../../../design/a11y_contrast.dart';

enum StudyTab { overview, participants, data, export }

class StudyTopBar extends StatelessWidget {
  const StudyTopBar({
    super.key,
    required this.title,
    required this.tab,
    required this.onChanged,
    this.onEdit,
    this.status,
  });

  final String title;
  final StudyTab tab;
  final ValueChanged<StudyTab> onChanged;
  final VoidCallback? onEdit;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Titelzeile + Edit
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kA11yText, fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minSize: 32,
                onPressed: onEdit,
                child: const Text('Bearbeiten', style: TextStyle(color: kA11yText)),
              ),
            ],
          ),
        ),

        // Segmented control mit sehr guter Lesbarkeit
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: kA11yPanel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kA11yDivider, width: .8),
          ),
          child: CupertinoSlidingSegmentedControl<StudyTab>(
            backgroundColor: kA11yPanel,
            thumbColor: kA11yPanelHi,
            groupValue: tab,
            onValueChanged: (v) { if (v != null) onChanged(v); },
            children: {
              StudyTab.overview: _seg('Übersicht', selected: tab == StudyTab.overview),
              StudyTab.participants: _seg('Teilnehmer', selected: tab == StudyTab.participants),
              StudyTab.data: _seg('Datenerhebung', selected: tab == StudyTab.data),
              StudyTab.export: _seg('Export', selected: tab == StudyTab.export),
            },
          ),
        ),

        // Status-Badge
        if (status != null)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: panelBox(),
            alignment: Alignment.centerLeft,
            child: Text('Status: $status', style: kSub),
          ),
      ],
    );
  }

  Widget _seg(String label, {required bool selected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? kA11yText : kA11yTextMute,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: .2,
        ),
      ),
    );
  }
}
