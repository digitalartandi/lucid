// lib/features/practice/technique_page.dart
import 'package:flutter/cupertino.dart';

import '../../core/techniques.dart';
import '../../ui/links.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';
import '../shell/app_shell.dart';
import 'practice_page.dart';

class TechniquePage extends StatelessWidget {
  const TechniquePage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final Technique? t = techniqueById(id);
    if (t == null) {
      return const LPage(
        title: 'Technik',
        child: LEmpty(
          icon: CupertinoIcons.question_circle,
          title: 'Nicht gefunden',
          text: 'Diese Technik gibt es in der App nicht.',
        ),
      );
    }
    return LPage(
      title: t.name,
      child: LScroll(
        children: <Widget>[
          Row(
            children: <Widget>[
              LIconDot(techniqueIcon(t.id), size: 48),
              const SizedBox(width: LS.md),
              Expanded(child: Text(t.longName, style: LT.labelMuted)),
            ],
          ),
          const SizedBox(height: LS.lg),
          Text(t.summary, style: LT.title),
          const SizedBox(height: LS.lg),
          Wrap(
            spacing: LS.sm,
            runSpacing: LS.sm,
            children: <Widget>[
              EvidenceBadge(t.evidence),
              LBadge('${t.minutes} Min.', color: LC.muted, background: LC.surface),
              if (t.disturbsSleep)
                const LBadge('Unterbricht den Schlaf', color: LC.rose, background: LC.roseSoft),
            ],
          ),
          const SizedBox(height: LS.lg),
          LRow(
            icon: CupertinoIcons.clock,
            iconColor: LC.muted,
            title: 'Wann',
            subtitle: t.when,
            chevron: false,
          ),
          if (t.sessionId != null) ...<Widget>[
            const SizedBox(height: LS.md),
            LButton(
              label: 'Geführt üben',
              icon: CupertinoIcons.play_fill,
              onPressed: () => openRoute(context, '/practice/session', arg: t.sessionId, root: true),
            ),
          ],
          if (t.id == 'wbtb' || t.id == 'tlr') ...<Widget>[
            const SizedBox(height: LS.md),
            LButton(
              label: 'Im Nachtmodus anwenden',
              icon: CupertinoIcons.moon_zzz,
              onPressed: () => openRoute(context, '/night', root: true),
            ),
          ],
          const LSection('So geht es'),
          LCard(
            child: Column(
              children: <Widget>[
                for (int i = 0; i < t.steps.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == t.steps.length - 1 ? 0 : LS.lg),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: LC.irisSoft, shape: BoxShape.circle),
                          child: Text('${i + 1}', style: LT.caption.copyWith(color: LC.iris)),
                        ),
                        const SizedBox(width: LS.md),
                        Expanded(child: Text(t.steps[i], style: LT.body.copyWith(fontSize: 15.5))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const LSection('Was die Forschung sagt'),
          LCard(child: Text(t.evidenceNote, style: LT.body.copyWith(fontSize: 15.5))),
          if (t.tips.isNotEmpty) ...<Widget>[
            const LSection('Hinweise aus der Praxis'),
            for (final String tip in t.tips) _Bullet(tip),
          ],
          if (t.cautions.isNotEmpty) ...<Widget>[
            const SizedBox(height: LS.lg),
            for (final String c in t.cautions)
              Padding(
                padding: const EdgeInsets.only(bottom: LS.sm),
                child: LNote(text: c, tone: LC.rose, icon: CupertinoIcons.exclamationmark_triangle),
              ),
          ],
          const LSection('Quellen'),
          LGroup(
            children: <Widget>[
              for (final SourceRef s in t.sources)
                LRow(
                  title: s.label,
                  subtitle: s.url.replaceFirst('https://', ''),
                  trailing: const Icon(CupertinoIcons.link, size: 16, color: LC.faint),
                  onTap: () => openExternal(s.url),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LS.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 9, right: LS.md),
            child: SizedBox(
              width: 6,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(color: LC.iris, shape: BoxShape.circle),
              ),
            ),
          ),
          Expanded(child: Text(text, style: LT.body.copyWith(fontSize: 15.5))),
        ],
      ),
    );
  }
}
