// lib/screens/affirmations/affirmation_hub_page.dart
import 'package:flutter/cupertino.dart';
import '../../models/affirmation_models.dart';
import '../../services/affirmation_repo.dart';

const _bg     = Color(0xFF0D0F16);
const _white  = Color(0xFFE9EAFF);
const _card   = Color(0xFF0A0A23);
const _line   = Color(0x22FFFFFF);

class AffirmationHubPage extends StatefulWidget {
  const AffirmationHubPage({super.key});
  @override
  State<AffirmationHubPage> createState() => _AffirmationHubPageState();
}

class _AffirmationHubPageState extends State<AffirmationHubPage> {
  List<AffirmationTrack> _all = [];
  String _q = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AffirmationRepo.instance.list();
    if (!mounted) return;
    setState(() => _all = list);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _q.trim().isEmpty
        ? _all
        : _all.where((t) =>
            t.title.toLowerCase().contains(_q.toLowerCase()) ||
            t.asset.toLowerCase().contains(_q.toLowerCase())).toList();

    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: Text('Affirmationen', style: TextStyle(color: _white)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: CupertinoSearchTextField(
                placeholder: 'Suchen…',
                style: const TextStyle(color: _white),
                placeholderStyle: const TextStyle(color: Color(0x66E9EAFF)),
                backgroundColor: const Color(0x1AFFFFFF),
                prefixIcon: const Icon(CupertinoIcons.search, color: _white, size: 18),
                suffixIcon: const Icon(CupertinoIcons.xmark_circle_fill, color: _white),
                onChanged: (q) => setState(() => _q = q),
              ),
            ),
            Expanded(
              child: _all.isEmpty
                  ? const Center(child: CupertinoActivityIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final t = filtered[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _line),
                          ),
                          child: CupertinoListTile.notched(
                            title: Text(t.title, style: const TextStyle(color: _white)),
                            subtitle: Text('Affirmation · ${t.asset.split('/').last}',
                                style: const TextStyle(color: _white)),
                            trailing: const Icon(CupertinoIcons.chevron_right, color: _white),
                            onTap: () {
                              Navigator.of(context).pushNamed('/affirmations/play', arguments: t.id);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
