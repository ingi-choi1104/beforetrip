import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../services/database_service.dart';
import 'destination_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Destination> _all = [];
  bool _loading = true;
  String _searchQuery = '';

  static const _regionOrder = [
    '동아시아',
    '동남아시아',
    '유럽',
    '북아메리카',
    '남아메리카',
    '오세아니아',
    '중동',
    '아프리카',
    '인도양',
  ];

  @override
  void initState() {
    super.initState();
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    final dests = await DatabaseService.instance.getAllDestinations();
    if (!mounted) return;
    setState(() {
      _all = dests;
      _loading = false;
    });
  }

  List<Destination> get _filtered {
    if (_searchQuery.isEmpty) return _all;
    final q = _searchQuery;
    return _all
        .where((d) => d.name.contains(q) || d.country.contains(q))
        .toList();
  }

  // region → country → destinations
  Map<String, Map<String, List<Destination>>> get _grouped {
    final map = <String, Map<String, List<Destination>>>{};
    for (final dest in _filtered) {
      map
          .putIfAbsent(dest.region, () => {})
          .putIfAbsent(dest.country, () => [])
          .add(dest);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '여행지 정보를 불러오는 중…',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final grouped = _grouped;
    final regions = _regionOrder.where(grouped.containsKey).toList();

    // 대륙 > 나라 > 도시 플랫 리스트로 변환 (SliverList용)
    // item: (type: 'region'|'country'|'dest', data)
    final items = <({String type, Object data})>[];
    for (final region in regions) {
      items.add((type: 'region', data: region));
      final countries = grouped[region]!;
      for (final country in countries.keys) {
        items.add((
          type: 'country',
          data: (country, countries[country]!.first.flag),
        ));
        for (final dest in countries[country]!) {
          items.add((type: 'dest', data: dest));
        }
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 헤더 + 고정 검색바
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '여행 가기 전',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.tertiary],
                  ),
                ),
                child: const Align(
                  alignment: Alignment(0.9, -0.3),
                  child: Text('✈️', style: TextStyle(fontSize: 72)),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: ColoredBox(
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: SearchBar(
                    hintText: '여행지 또는 나라 검색',
                    leading: const Icon(Icons.search),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ),
            ),
          ),

          // 여행지 목록 (대륙 > 나라 > 도시)
          if (items.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('검색 결과가 없습니다.')),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                if (item.type == 'region') {
                  final region = item.data as String;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 6),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          region,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  );
                }
                if (item.type == 'country') {
                  final (country, flag) = item.data as (String, String);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 10, 16, 2),
                    child: Row(
                      children: [
                        Text(flag, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          country,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: colorScheme.outline,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  );
                }
                // dest
                final dest = item.data as Destination;
                return _DestinationTile(
                  destination: dest,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DestinationScreen(destination: dest),
                    ),
                  ),
                );
              }, childCount: items.length),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _DestinationTile extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const _DestinationTile({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = destination.theme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(destination.flag, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          destination.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (theme != DestinationTheme.general) ...[
                          const SizedBox(width: 6),
                          _ThemeChip(theme: theme),
                        ],
                      ],
                    ),
                    Text(
                      destination.country,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final DestinationTheme theme;

  const _ThemeChip({required this.theme});

  @override
  Widget build(BuildContext context) {
    final (color, textColor) = switch (theme) {
      DestinationTheme.summer => (
        Colors.orange.shade100,
        Colors.orange.shade800,
      ),
      DestinationTheme.winter => (Colors.blue.shade100, Colors.blue.shade800),
      DestinationTheme.aurora => (
        Colors.purple.shade100,
        Colors.purple.shade800,
      ),
      DestinationTheme.general => (Colors.grey.shade100, Colors.grey.shade700),
      DestinationTheme.uyuni => (Colors.grey.shade100, Colors.grey.shade700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${theme.emoji} ${theme.label}',
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
