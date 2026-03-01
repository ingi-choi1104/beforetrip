import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../models/monthly_climate.dart';
import '../services/scoring_service.dart';

class DestinationScreen extends StatefulWidget {
  final Destination destination;

  const DestinationScreen({super.key, required this.destination});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  late final List<MonthScore> _scores;
  late final List<int> _topMonths; // 1위부터 3위까지의 월 번호

  @override
  void initState() {
    super.initState();
    _scores = ScoringService.calculateScores(
      widget.destination.climates,
      widget.destination.name,
    );
    _topMonths = ScoringService.getTopMonths(_scores, 3);
  }

  @override
  Widget build(BuildContext context) {
    final dest = widget.destination;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${dest.flag}  ${dest.name}',
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
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                _RecommendationSection(
                  destination: dest,
                  topMonths: _topMonths,
                ),
                _ClimateListSection(
                  destination: dest,
                  topMonths: _topMonths,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 추천 여행 시기 섹션 ─────────────────────────────────────────

class _RecommendationSection extends StatelessWidget {
  final Destination destination;
  final List<int> topMonths;

  const _RecommendationSection({
    required this.destination,
    required this.topMonths,
  });

  static const _medals = ['🥇', '🥈', '🥉'];
  static const _rankLabels = ['1위', '2위', '3위'];
  static const _rankColors = [
    Color(0xFFFFF9C4), // 금
    Color(0xFFF5F5F5), // 은
    Color(0xFFFFE0B2), // 동
  ];
  static const _borderColors = [
    Colors.amber,
    Colors.grey,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '추천 여행 시기',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '기온·강수량·일조시간을 종합한 추천입니다',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(
                  topMonths.length,
                  (i) {
                    final month = topMonths[i];
                    final climate = destination.climates[month - 1];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0 : 6,
                        ),
                        child: _RankBadge(
                          medal: _medals[i],
                          rankLabel: _rankLabels[i],
                          climate: climate,
                          bgColor: _rankColors[i],
                          borderColor: _borderColors[i],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final String medal;
  final String rankLabel;
  final MonthlyClimate climate;
  final Color bgColor;
  final Color borderColor;

  const _RankBadge({
    required this.medal,
    required this.rankLabel,
    required this.climate,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Text(medal, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 2),
          Text(
            rankLabel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            climate.monthName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            climate.seasonName,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${climate.minTemp.toInt()}~${climate.maxTemp.toInt()}°C',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─── 월별 기후 목록 섹션 ─────────────────────────────────────────

class _ClimateListSection extends StatelessWidget {
  final Destination destination;
  final List<int> topMonths;

  const _ClimateListSection({
    required this.destination,
    required this.topMonths,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Text(
              '월별 기후',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...destination.climates.map((climate) {
            final rank = topMonths.indexOf(climate.month) + 1;
            return _MonthRow(
              climate: climate,
              rank: rank > 0 ? rank : null,
            );
          }),
        ],
      ),
    );
  }
}

class _MonthRow extends StatelessWidget {
  final MonthlyClimate climate;
  final int? rank; // 1, 2, 3 또는 null

  const _MonthRow({required this.climate, this.rank});

  Color _tempColor(double temp) {
    if (temp < 0) return Colors.blue.shade900;
    if (temp < 10) return Colors.lightBlue;
    if (temp < 18) return Colors.green.shade400;
    if (temp <= 24) return Colors.green;
    if (temp < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isRecommended = rank != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      color: isRecommended ? colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // 월 + 순위 뱃지
            SizedBox(
              width: 52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$rank위',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    climate.monthName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    climate.seasonName,
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // 기후 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 기온 막대
                  _TempBar(
                    minTemp: climate.minTemp,
                    maxTemp: climate.maxTemp,
                    minColor: _tempColor(climate.minTemp),
                    maxColor: _tempColor(climate.maxTemp),
                  ),
                  const SizedBox(height: 6),
                  // 강수량 & 일조시간
                  Row(
                    children: [
                      Icon(Icons.water_drop_outlined,
                          size: 14, color: Colors.blue.shade400),
                      const SizedBox(width: 3),
                      Text(
                        '${climate.precipitation.toInt()}mm',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.wb_sunny_outlined,
                          size: 14, color: Colors.amber.shade600),
                      const SizedBox(width: 3),
                      Text(
                        '${climate.daylightHours.toStringAsFixed(1)}h',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempBar extends StatelessWidget {
  final double minTemp;
  final double maxTemp;
  final Color minColor;
  final Color maxColor;

  const _TempBar({
    required this.minTemp,
    required this.maxTemp,
    required this.minColor,
    required this.maxColor,
  });

  @override
  Widget build(BuildContext context) {
    // 전체 범위 기준: -15°C ~ 45°C (60도 범위)
    const rangeMin = -15.0;
    const rangeMax = 45.0;
    const totalRange = rangeMax - rangeMin;

    final leftFraction = ((minTemp - rangeMin) / totalRange).clamp(0.0, 1.0);
    final rightFraction = ((maxTemp - rangeMin) / totalRange).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        final barLeft = total * leftFraction;
        final barWidth = (total * rightFraction - barLeft).clamp(4.0, total);

        return Stack(
          children: [
            // 배경 트랙
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // 이상적 온도 영역 표시 (18~24°C)
            Positioned(
              left: total * ((18.0 - rangeMin) / totalRange),
              width:
                  total * ((24.0 - 18.0) / totalRange),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // 실제 기온 막대
            Positioned(
              left: barLeft,
              width: barWidth,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [minColor, maxColor],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
