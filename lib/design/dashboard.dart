import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'lucid_tokens.dart';
import 'glass.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: Lc.bgGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              SvgPicture.asset(
                'assets/logo/logo-signet.svg',
                width: 28, height: 28,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                semanticsLabel: 'Lucid',
              ),
              const SizedBox(width: 10),
              Text('Lucid', style: Theme.of(context)
                  .textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Einstellungen',
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // Hero
              Glass(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gute Nacht 🌙', style: Theme.of(context)
                              .textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text('Dein 2-Wochen-Trainer wartet. Heute: Reality-Checks & Journal.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Lc.textMed)),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () => Navigator.pushNamed(context, '/trainer'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Fortsetzen'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Primäre Aktionen – 2 Spalten, große Kacheln
              LayoutBuilder(builder: (context, _) {
                final w = (size.width - 16*2 - 12) / 2;
                return Wrap(
                  spacing: 12, runSpacing: 12,
                  children: [
                    SizedBox(width: w, child: GradientCard(
                      title: 'Trainer', subtitle: '2-Wochen-Plan',
                      icon: Icons.flag_rounded,
                      onTap: () => Navigator.pushNamed(context, '/trainer'),
                    )),
                    SizedBox(width: w, child: GradientCard(
                      title: 'RC-Reminder', subtitle: 'Check-Routine',
                      icon: Icons.notifications_active_rounded,
                      onTap: () => Navigator.pushNamed(context, '/rc'),
                    )),
                    SizedBox(width: w, child: GradientCard(
                      title: 'Night Lite+', subtitle: 'REM-Cues & Audio',
                      icon: Icons.nightlight_round,
                      onTap: () => Navigator.pushNamed(context, '/nightlite'),
                    )),
                    SizedBox(width: w, child: GradientCard(
                      title: 'Journal', subtitle: 'Schnell notieren',
                      icon: Icons.edit_note_rounded,
                      onTap: () => Navigator.pushNamed(context, '/journal'),
                    )),
                    SizedBox(width: w, child: GradientCard(
                      title: 'Cue-Tuning', subtitle: 'Feinabstimmung',
                      icon: Icons.tune_rounded,
                      onTap: () => Navigator.pushNamed(context, '/cue'),
                    )),
                    SizedBox(width: w, child: GradientCard(
                      title: 'Wissen', subtitle: 'Studien & Guides',
                      icon: Icons.auto_stories_rounded,
                      onTap: () => Navigator.pushNamed(context, '/research'),
                    )),
                  ],
                );
              }),

              const SizedBox(height: 20),

              // Fortschritt + Streak
              Row(children: [
                Expanded(child: Glass(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fortschritt',
                        style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      _ProgressPill(value: 0.42, label: 'Woche 1 / 2'),
                    ],
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: Glass(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Streak',
                        style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text('3 Tage', style: Theme.of(context)
                        .textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      Text('letzte Klarheit: gestern',
                        style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Lc.textMed)),
                    ],
                  ),
                )),
              ]),

              const SizedBox(height: 20),

              // Journal Kurzbereich
              Glass(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('Journal', style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/journal'),
                        child: const Text('Alle ansehen'),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/journal/new'),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Neuen Eintrag'),
                    ),
                    const SizedBox(height: 12),
                    const _JournalItem(title: '„Traumstadt am Meer“', time: 'Heute, 07:10'),
                    const _JournalItem(title: 'RC-Reminder aktiviert', time: 'Gestern, 19:42'),
                    const _JournalItem(title: 'Cue Tuning – sanfte Glocke', time: 'Gestern, 18:11'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Wissen Teaser
              Glass(
                child: ListTile(
                  leading: const Icon(Icons.science_rounded),
                  title: const Text('Neue Studie: REM-Cues & Klarträume'),
                  subtitle: Text('Kurzfassung lesen'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(context, '/research'),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Glass(
              padding: const EdgeInsets.symmetric(vertical: 6),
              radius: 18,
              child: NavigationBar(
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.flag_rounded), label: 'Trainer'),
                  NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Wissen'),
                  NavigationDestination(icon: Icon(Icons.more_horiz_rounded), label: 'Mehr'),
                ],
                selectedIndex: 0,
                onDestinationSelected: (i) {
                  switch (i) {
                    case 1: Navigator.pushNamed(context, '/trainer'); break;
                    case 2: Navigator.pushNamed(context, '/research'); break;
                    case 3: Navigator.pushNamed(context, '/more'); break;
                    default: break;
                  }
                },
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final double value;
  final String label;
  const _ProgressPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Stack(
        children: [
          Container(height: 14, color: Colors.white.withOpacity(.06)),
          FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: Container(
              height: 14,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Lc.violet, Lc.magenta, Lc.sky]),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalItem extends StatelessWidget {
  final String title;
  final String time;
  const _JournalItem({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.radio_button_checked_rounded,
          size: 18, color: Lc.textLo),
      title: Text(title, overflow: TextOverflow.ellipsis),
      subtitle: Text(time, style: Theme.of(context)
          .textTheme.bodySmall?.copyWith(color: Lc.textMed)),
      onTap: () => Navigator.pushNamed(context, '/journal'),
    );
  }
}
