import 'package:flutter/material.dart';

import '../data/climate_data.dart';
import '../models/destination.dart';
import 'destination_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  List<Destination> get _filtered {
    if (_searchQuery.isEmpty) return ClimateData.allDestinations;
    final q = _searchQuery;
    return ClimateData.allDestinations.where((d) {
      return d.name.contains(q) || d.country.contains(q);
    }).toList();
  }

  Map<String, List<Destination>> get _grouped {
    final map = <String, List<Destination>>{};
    for (final dest in _filtered) {
      map.putIfAbsent(dest.region, () => []).add(dest);
    }
    return map;
  }

  static const _regionOrder = [
    '국내',
    '동아시아',
    '동남아시아',
    '유럽',
    '아메리카·오세아니아',
    '중동',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final grouped = _grouped;
    final regions = _regionOrder.where(grouped.containsKey).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 헤더
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
                    colors: [
                      colorScheme.primary,
                      colorScheme.tertiary,
                    ],
                  ),
                ),
                child: const Align(
                  alignment: Alignment(0.9, -0.3),
                  child: Text('✈️', style: TextStyle(fontSize: 72)),
                ),
              ),
            ),
          ),

          // 검색바
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

          // 여행지 목록 (지역별)
          if (regions.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('검색 결과가 없습니다.')),
            )
          else
            for (final region in regions) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 6),
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
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dest = grouped[region]![index];
                    return _DestinationTile(
                      destination: dest,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DestinationScreen(destination: dest),
                        ),
                      ),
                    );
                  },
                  childCount: grouped[region]!.length,
                ),
              ),
            ],

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
                    Text(
                      destination.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
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
