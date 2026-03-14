import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/city_group.dart';
import '../models/destination.dart';
import '../services/search_service.dart';
import '../widgets/banner_ad_widget.dart';
import 'destination_screen.dart';
import 'home_screen.dart' show ThemeChip;

class SearchScreen extends StatefulWidget {
  final List<Destination> destinations;
  final List<CityGroup> cityGroups;

  const SearchScreen({
    super.key,
    required this.destinations,
    required this.cityGroups,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int? _selectedMonth;
  int? _selectedDays;
  int _selectedParty = 2;
  int? _budgetWon;
  DestinationTheme? _selectedTheme;
  bool _monthLongStay = false;

  final _budgetController = TextEditingController();
  final _daysController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  bool get _filtersActive =>
      _selectedMonth != null ||
      _selectedDays != null ||
      _budgetWon != null ||
      _selectedTheme != null ||
      _monthLongStay;

  SearchFilters get _currentFilters => SearchFilters(
    month: _selectedMonth,
    travelDays: _monthLongStay ? null : _selectedDays,
    partySize: _selectedParty,
    budgetWon: _budgetWon,
    theme: _monthLongStay ? null : _selectedTheme,
    monthLongStay: _monthLongStay,
  );

  List<SearchResultItem> get _results => SearchService.filter(
    widget.destinations,
    widget.cityGroups,
    _currentFilters,
  );

  void _reset() {
    setState(() {
      _selectedMonth = null;
      _selectedDays = null;
      _selectedParty = 2;
      _budgetWon = null;
      _selectedTheme = null;
      _monthLongStay = false;
      _budgetController.clear();
      _daysController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final results = _filtersActive ? _results : <SearchResultItem>[];
    final singles = results.where((r) => !r.isGroup).toList();
    final groups = results.where((r) => r.isGroup).toList();

    final resultItems = <({String type, Object data})>[];
    if (singles.isNotEmpty) {
      resultItems.add((
        type: 'header',
        data: '단일 여행지 (${singles.length}개)',
      ));
      for (final r in singles) {
        resultItems.add((type: 'single', data: r));
      }
    }
    if (groups.isNotEmpty) {
      resultItems.add((
        type: 'header',
        data: '연계 여행 코스 (${groups.length}개)',
      ));
      for (final r in groups) {
        resultItems.add((type: 'group', data: r));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('조건 검색'),
        actions: [
          if (_filtersActive)
            TextButton(
              onPressed: _reset,
              child: const Text('초기화'),
            ),
        ],
      ),
      bottomNavigationBar: const BottomBannerAd(),
      body: CustomScrollView(
        slivers: [
          // 필터 패널
          SliverToBoxAdapter(
            child: _FilterPanel(
              selectedMonth: _selectedMonth,
              selectedDays: _selectedDays,
              selectedParty: _selectedParty,
              budgetController: _budgetController,
              daysController: _daysController,
              selectedTheme: _selectedTheme,
              monthLongStay: _monthLongStay,
              onMonthChanged: (m) => setState(() => _selectedMonth = m),
              onDaysChanged: (d) => setState(() => _selectedDays = d),
              onPartyChanged: (p) => setState(() => _selectedParty = p),
              onBudgetChanged: (v) {
                final parsed = int.tryParse(v);
                setState(
                  () => _budgetWon = parsed != null ? parsed * 10000 : null,
                );
              },
              onThemeChanged: (t) => setState(() => _selectedTheme = t),
              onMonthLongStayChanged: (v) => setState(() {
                _monthLongStay = v;
                if (v) {
                  _selectedDays = null;
                  _selectedTheme = null;
                  _daysController.clear();
                }
              }),
            ),
          ),

          // 구분선
          const SliverToBoxAdapter(child: Divider(height: 1)),

          // 결과 없음 안내
          if (_filtersActive && results.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '조건에 맞는 여행지가 없습니다.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            )

          // 필터 미설정 안내
          else if (!_filtersActive)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune,
                      size: 48,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '위의 조건을 선택하면\n적합한 여행지를 추천해 드립니다.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            )

          // 결과 목록
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = resultItems[index];
                if (item.type == 'header') {
                  return _SectionHeader(
                    title: item.data as String,
                    colorScheme: colorScheme,
                  );
                }
                if (item.type == 'single') {
                  final r = item.data as SearchResultItem;
                  return _SearchDestTile(
                    result: r,
                    selectedMonth: _selectedMonth,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DestinationScreen(destination: r.primaryDest),
                      ),
                    ),
                  );
                }
                final r = item.data as SearchResultItem;
                return _SearchGroupTile(
                  result: r,
                  selectedMonth: _selectedMonth,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DestinationScreen(destination: r.primaryDest),
                    ),
                  ),
                );
              }, childCount: resultItems.length),
            ),

          SliverSafeArea(
            top: false,
            sliver: const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 필터 패널
// ══════════════════════════════════════════════════════════

class _FilterPanel extends StatelessWidget {
  final int? selectedMonth;
  final int? selectedDays;
  final int selectedParty;
  final TextEditingController budgetController;
  final TextEditingController daysController;
  final DestinationTheme? selectedTheme;
  final bool monthLongStay;

  final ValueChanged<int?> onMonthChanged;
  final ValueChanged<int?> onDaysChanged;
  final ValueChanged<int> onPartyChanged;
  final ValueChanged<String> onBudgetChanged;
  final ValueChanged<DestinationTheme?> onThemeChanged;
  final ValueChanged<bool> onMonthLongStayChanged;

  const _FilterPanel({
    required this.selectedMonth,
    required this.selectedDays,
    required this.selectedParty,
    required this.budgetController,
    required this.daysController,
    required this.selectedTheme,
    required this.monthLongStay,
    required this.onMonthChanged,
    required this.onDaysChanged,
    required this.onPartyChanged,
    required this.onBudgetChanged,
    required this.onThemeChanged,
    required this.onMonthLongStayChanged,
  });

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 여행 희망 월 — 6개씩 2줄
          _FilterLabel(text: '여행 희망 월'),
          const SizedBox(height: 8),
          Column(
            children: [
              for (final rowStart in [1, 7])
                Padding(
                  padding: rowStart == 7
                      ? const EdgeInsets.only(top: 4)
                      : EdgeInsets.zero,
                  child: Row(
                    children: [
                      for (int m = rowStart; m < rowStart + 6; m++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ChoiceChip(
                              label: Center(child: Text('$m월')),
                              selected: selectedMonth == m,
                              onSelected: (_) => onMonthChanged(
                                selectedMonth == m ? null : m,
                              ),
                              visualDensity: VisualDensity.compact,
                              labelPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 여행 기간 + 한 달 살기
          _FilterLabel(text: '여행 기간'),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: daysController,
                  enabled: !monthLongStay,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: '일수',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (v) {
                    onDaysChanged(int.tryParse(v)?.clamp(1, 30));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '일 (최대 30일)',
                style: monthLongStay
                    ? TextStyle(color: outline)
                    : null,
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: monthLongStay,
                    onChanged: (v) => onMonthLongStayChanged(v ?? false),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Text('한 달 살기'),
                ],
              ),
            ],
          ),
          if (!monthLongStay && selectedDays != null && selectedDays! <= 5)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '5일 이하: 아시아 지역 여행지만 표시됩니다',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: outline,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // 여행 인원
          _FilterLabel(text: '여행 인원'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              for (int p = 1; p <= 4; p++)
                ChoiceChip(
                  label: Text('$p인'),
                  selected: selectedParty == p,
                  onSelected: (_) => onPartyChanged(p),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 예산
          _FilterLabel(text: '예산 (총 여행 경비)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: '예산 입력',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: onBudgetChanged,
                ),
              ),
              const SizedBox(width: 8),
              const Text('만원'),
            ],
          ),
          const SizedBox(height: 16),

          // 여행 목적 (한 달 살기 시 비활성)
          _FilterLabel(text: '여행 목적'),
          const SizedBox(height: 8),
          Opacity(
            opacity: monthLongStay ? 0.4 : 1.0,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text('🏙️ 일반여행'),
                  selected: !monthLongStay && selectedTheme == null,
                  onSelected: monthLongStay ? null : (_) => onThemeChanged(null),
                  visualDensity: VisualDensity.compact,
                ),
                ChoiceChip(
                  label: const Text('🏖️ 물놀이'),
                  selected:
                      !monthLongStay && selectedTheme == DestinationTheme.summer,
                  onSelected: monthLongStay
                      ? null
                      : (_) => onThemeChanged(DestinationTheme.summer),
                  visualDensity: VisualDensity.compact,
                ),
                ChoiceChip(
                  label: const Text('⛷️ 눈구경'),
                  selected:
                      !monthLongStay && selectedTheme == DestinationTheme.winter,
                  onSelected: monthLongStay
                      ? null
                      : (_) => onThemeChanged(DestinationTheme.winter),
                  visualDensity: VisualDensity.compact,
                ),
                ChoiceChip(
                  label: const Text('🌌 오로라'),
                  selected:
                      !monthLongStay && selectedTheme == DestinationTheme.aurora,
                  onSelected: monthLongStay
                      ? null
                      : (_) => onThemeChanged(DestinationTheme.aurora),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String text;
  const _FilterLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.outline,
    ),
  );
}

// ══════════════════════════════════════════════════════════
// 검색 결과 섹션 헤더
// ══════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme colorScheme;

  const _SectionHeader({required this.title, required this.colorScheme});

  @override
  Widget build(BuildContext context) => Padding(
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
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════
// 단일 도시 검색 결과 카드
// ══════════════════════════════════════════════════════════

class _SearchDestTile extends StatelessWidget {
  final SearchResultItem result;
  final int? selectedMonth;
  final VoidCallback onTap;

  const _SearchDestTile({
    required this.result,
    required this.selectedMonth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dest = result.primaryDest;
    final colorScheme = Theme.of(context).colorScheme;

    int? monthRank;
    if (selectedMonth != null) {
      final idx = result.topMonths.indexOf(selectedMonth!);
      if (idx >= 0) monthRank = idx + 1;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(dest.flag, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            dest.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (dest.theme != DestinationTheme.general)
                          ThemeChip(theme: dest.theme),
                        if (monthRank != null) ...[
                          const SizedBox(width: 4),
                          _RankBadge(rank: monthRank),
                        ],
                      ],
                    ),
                    Text(
                      '${dest.country} · ${dest.region}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    if (result.estimatedTotalWon != null) ...[
                      const SizedBox(height: 4),
                      _EstimateText(won: result.estimatedTotalWon!),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 연계 도시 검색 결과 카드
// ══════════════════════════════════════════════════════════

class _SearchGroupTile extends StatelessWidget {
  final SearchResultItem result;
  final int? selectedMonth;
  final VoidCallback onTap;

  const _SearchGroupTile({
    required this.result,
    required this.selectedMonth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final group = result.group!;
    final primary = result.primaryDest;
    final colorScheme = Theme.of(context).colorScheme;

    int? monthRank;
    if (selectedMonth != null) {
      final idx = result.topMonths.indexOf(selectedMonth!);
      if (idx >= 0) monthRank = idx + 1;
    }

    final totalMin = result.groupDests.fold(0, (s, d) => s + d.minDays);
    final totalMax = result.groupDests.fold(0, (s, d) => s + d.maxDays);
    final displayMin = totalMin > 0 ? totalMin : group.minDays;
    final displayMax = totalMax > 0 ? totalMax : group.maxDays;

    final flags = result.groupDests.map((d) => d.flag).take(4).join(' ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(flags, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (monthRank != null) _RankBadge(rank: monthRank),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.outline,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${primary.region} · $displayMin~$displayMax일',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  if (primary.theme != DestinationTheme.general) ...[
                    const SizedBox(width: 6),
                    ThemeChip(theme: primary.theme),
                  ],
                ],
              ),
              if (result.estimatedTotalWon != null) ...[
                const SizedBox(height: 4),
                _EstimateText(won: result.estimatedTotalWon!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 예상 경비 텍스트
// ══════════════════════════════════════════════════════════

class _EstimateText extends StatelessWidget {
  final int won;
  const _EstimateText({required this.won});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.flight_takeoff, size: 12, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          '예상 총 경비 약 ${won ~/ 10000}만원',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// 공통 뱃지
// ══════════════════════════════════════════════════════════

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    const emojis = ['', '🥇', '🥈', '🥉'];
    return Text(
      emojis[rank.clamp(1, 3)],
      style: const TextStyle(fontSize: 14),
    );
  }
}
