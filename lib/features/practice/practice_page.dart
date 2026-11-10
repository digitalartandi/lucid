// lib/features/practice/practice_page.dart
//
// "Üben": Techniken nach Tageszeit, darunter Entspannung und Klänge.
import 'package:flutter/cupertino.dart';

import '../../core/practice_store.dart';
import '../../core/techniques.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';
import '../shell/app_shell.dart';

Color evidenceColor(Evidence e) {
  switch (e) {
    case Evidence.good:
      return LC.mint;
    case Evidence.promising:
      return LC.iris;
    case Evidence.limited:
      return LC.muted;
    case Evidence.weakAlone:
      return LC.rose;
  }
}

class EvidenceBadge extends StatelessWidget {
  const EvidenceBadge(this.evidence, {super.key});
  final Evidence evidence;

  @override
  Widget build(BuildContext context) {
    final Color c = evidenceColor(evidence);
    return LBadge(evidenceLabel(evidence), color: c, background: c.withValues(alpha: 0.15));
  }
}

IconData techniqueIcon(String id) {
  switch (id) {
    case 'journal':
      return CupertinoIcons.book;
    case 'mild':
      return CupertinoIcons.sparkles;
    case 'wbtb':
      return CupertinoIcons.alarm;
    case 'ssild':
      return CupertinoIcons.waveform;
    case 'rc':
      return CupertinoIcons.hand_raised;
    case 'tlr':
      return CupertinoIcons.bell;
    case 'wild':
      return CupertinoIcons.eye;
    case 'stabilize':
      return CupertinoIcons.scope;
    default:
      return CupertinoIcons.circle;
  }
}

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final PracticeStore store = PracticeStore.instance;
    return LPage(
      child: AnimatedBuilder(
        animation: store,
        builder: (BuildContext context, Widget? _) {
          final int wbtb = store.wbtbNightsInLast(7);
          return LScroll(
            children: <Widget>[
              const LHeader(
                title: 'Üben',
                subtitle: 'Wenige Techniken, richtig dosiert. Die Kennzeichnung zeigt, wie gut jede belegt ist.',
              ),
              _NightEntry(wbtbNights: wbtb),
              const LSection('Tagsüber'),
              LGroup(
                children: <Widget>[
                  _TechRow(id: 'rc', trailingText: '${store.today.realityChecks} heute', route: '/practice/rc'),
                  LRow(
                    icon: CupertinoIcons.tag,
                    title: 'Traumzeichen',
                    subtitle: store.profile.dreamSigns.isEmpty
                        ? 'Woran du dich im Traum erkennst'
                        : store.profile.dreamSigns.take(3).join(', '),
                    onTap: () => openRoute(context, '/practice/signs'),
                  ),
                  LRow(
                    icon: CupertinoIcons.text_alignleft,
                    title: 'Absichtssatz',
                    subtitle: store.profile.intention,
                    onTap: () => openRoute(context, '/practice/intention'),
                  ),
                ],
              ),
              const LSection('Beim Einschlafen und Wiedereinschlafen'),
              const LGroup(
                children: <Widget>[
                  _TechRow(id: 'mild'),
                  _TechRow(id: 'ssild'),
                  _TechRow(id: 'wbtb'),
                  _TechRow(id: 'tlr'),
                ],
              ),
              const LSection('Für später'),
              const LGroup(
                children: <Widget>[
                  _TechRow(id: 'stabilize'),
                  _TechRow(id: 'wild'),
                ],
              ),
              const LSection('Zur Ruhe kommen'),
              LGroup(
                children: <Widget>[
                  LRow(
                    icon: CupertinoIcons.circle,
                    iconColor: LC.mint,
                    title: 'Runterkommen',
                    subtitle: 'Zwei Minuten ruhiges Atmen',
                    onTap: () => openRoute(context, '/practice/session', arg: 'calm', root: true),
                  ),
                  LRow(
                    icon: CupertinoIcons.map,
                    iconColor: LC.mint,
                    title: 'Traumreisen',
                    subtitle: 'Geführte Reisen zum Einschlafen',
                    onTap: () => openRoute(context, '/traumreisen'),
                  ),
                  LRow(
                    icon: CupertinoIcons.headphones,
                    iconColor: LC.mint,
                    title: 'Klangwelten',
                    subtitle: 'Ruhige Musik und Atmosphären',
                    onTap: () => openRoute(context, '/meditations'),
                  ),
                  LRow(
                    icon: CupertinoIcons.heart,
                    iconColor: LC.mint,
                    title: 'Affirmationen',
                    subtitle: 'Kurze gesprochene Sätze',
                    onTap: () => openRoute(context, '/affirmations'),
                  ),
                ],
              ),
              const SizedBox(height: LS.xl),
              const LNote(
                text:
                    'Traumreisen, Klangwelten und Affirmationen dienen der Entspannung. Dass sie Klarträume auslösen, ist nicht belegt.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NightEntry extends StatelessWidget {
  const _NightEntry({required this.wbtbNights});
  final int wbtbNights;

  @override
  Widget build(BuildContext context) {
    final bool tooMany = wbtbNights >= 3;
    return LHero(
      image: LImg.night,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 110),
          const Align(
            alignment: Alignment.centerLeft,
            child: Icon(CupertinoIcons.moon_zzz, color: LC.iris, size: 28),
          ),
          const SizedBox(height: LS.md),
          Text('Nachtmodus', style: LT.display.copyWith(fontSize: 34)),
          const SizedBox(height: LS.sm),
          Text(
            'Weckt dich nach fünf bis sechs Stunden, führt durch Traumnotiz und MILD oder SSILD und spielt auf Wunsch leise Klangsignale.',
            style: LT.body.copyWith(color: const Color(0xFFD5D8F5)),
          ),
          const SizedBox(height: LS.md),
          Text(
            tooMany
                ? 'Diese Woche schon $wbtbNights Nächte mit Wachphase. Gönn dir heute ungestörten Schlaf.'
                : 'Diese Woche: $wbtbNights von höchstens 3 Nächten mit Wachphase.',
            style: LT.caption.copyWith(color: tooMany ? LC.rose : const Color(0xFFC3C7EA)),
          ),
          const SizedBox(height: LS.lg),
          LButton(
            label: 'Nacht einrichten',
            kind: tooMany ? LButtonKind.secondary : LButtonKind.primary,
            onPressed: () => openRoute(context, '/night', root: true),
          ),
        ],
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  const _TechRow({required this.id, this.trailingText, this.route});
  final String id;
  final String? trailingText;
  final String? route;

  @override
  Widget build(BuildContext context) {
    final Technique t = techniqueById(id)!;
    return LTap(
      onTap: () => openRoute(context, route ?? '/practice/technique', arg: route == null ? id : null),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LS.md),
        child: Row(
          children: <Widget>[
            LIconDot(techniqueIcon(id)),
            const SizedBox(width: LS.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(child: Text(t.name, style: LT.heading.copyWith(fontSize: 16))),
                      const SizedBox(width: LS.sm),
                      EvidenceBadge(t.evidence),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    trailingText ?? t.summary,
                    style: LT.labelMuted,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: LS.sm),
            const Icon(CupertinoIcons.chevron_right, size: 16, color: LC.faint),
          ],
        ),
      ),
    );
  }
}
