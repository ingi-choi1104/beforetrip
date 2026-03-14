import 'package:flutter/material.dart';

import '../models/cost_of_living.dart';
import '../models/destination.dart';
import '../models/monthly_climate.dart';
import '../services/scoring_service.dart';
import '../widgets/banner_ad_widget.dart';

class DestinationScreen extends StatefulWidget {
  final Destination destination;

  const DestinationScreen({super.key, required this.destination});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  late final List<MonthScore> _scores;
  late final List<int> _topMonths;

  @override
  void initState() {
    super.initState();
    _scores = ScoringService.calculateScores(
      widget.destination.climates,
      widget.destination.name,
      widget.destination.theme, // 테마 전달
    );
    _topMonths = ScoringService.getTopMonths(
      _scores,
      3,
      widget.destination.theme,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dest = widget.destination;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: const BottomBannerAd(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '${dest.flag}  ${dest.name}',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (dest.theme != DestinationTheme.general &&
                      dest.theme != DestinationTheme.uyuni) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dest.theme.emoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
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
                  costOfLiving: dest.costOfLiving,
                  minDays: dest.minDays,
                  maxDays: dest.maxDays,
                  flightPriceLow: dest.flightPriceLow,
                  flightPriceHigh: dest.flightPriceHigh,
                ),
                _CostOfLivingSection(costOfLiving: dest.costOfLiving),
                _ClimateListSection(destination: dest, topMonths: _topMonths),
                SizedBox(height: 16 + MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 여행 종합 정보 섹션 ───────────────────────────────────────────

class _RecommendationSection extends StatelessWidget {
  final Destination destination;
  final List<int> topMonths;
  final CostOfLiving? costOfLiving;
  final int minDays;
  final int maxDays;
  final int? flightPriceLow;
  final int? flightPriceHigh;

  const _RecommendationSection({
    required this.destination,
    required this.topMonths,
    required this.costOfLiving,
    required this.minDays,
    required this.maxDays,
    this.flightPriceLow,
    this.flightPriceHigh,
  });

  static const _medals = ['🥇', '🥈', '🥉'];
  static const _rankLabels = ['1위', '2위', '3위'];
  static const _rankColors = [
    Color(0xFFFFF9C4),
    Color(0xFFF5F5F5),
    Color(0xFFFFE0B2),
  ];
  static const _borderColors = [Colors.amber, Colors.grey, Colors.orange];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasColData = costOfLiving != null && costOfLiving!.hasData;
    final hasDaysData = minDays > 0 && maxDays > 0;
    final hasFlightData = flightPriceLow != null && flightPriceHigh != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Row(
                children: [
                  Icon(Icons.travel_explore, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '여행 종합 정보',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (destination.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  destination.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // 추천 월 랭킹
              Text(
                '추천 여행 시기',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                destination.theme == DestinationTheme.aurora
                    ? '오로라 지수·강수량을 종합한 추천입니다'
                    : '기온·강수량·일조시간을 종합한 추천입니다',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(topMonths.length, (i) {
                  final month = topMonths[i];
                  final climate = destination.climates[month - 1];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                      child: _RankBadge(
                        medal: _medals[i],
                        rankLabel: _rankLabels[i],
                        climate: climate,
                        bgColor: _rankColors[i],
                        borderColor: _borderColors[i],
                      ),
                    ),
                  );
                }),
              ),
              // 요약 정보 박스들
              if (hasDaysData || hasColData || hasFlightData) ...[
                const SizedBox(height: 14),
                if (hasDaysData)
                  _SummaryBox(
                    icon: Icons.calendar_month_outlined,
                    label: '평균 여행 일수',
                    value: '$minDays~$maxDays일',
                    colorScheme: colorScheme,
                  ),
                if (hasDaysData && hasColData) const SizedBox(height: 8),
                if (hasColData)
                  _SummaryBox(
                    icon: Icons.payments_outlined,
                    label: '하루 예상 경비(2인)',
                    value:
                        '약 ${costOfLiving!.estimatedDailyCostKRW ~/ 10000}만원 / 일',
                    colorScheme: colorScheme,
                  ),
                if (hasFlightData) ...[
                  if (hasDaysData || hasColData) const SizedBox(height: 8),
                  _SummaryBox(
                    icon: Icons.flight_takeoff_outlined,
                    label: '항공권 예상 (왕복)',
                    value:
                        '${flightPriceLow! ~/ 10000}만 ~ ${flightPriceHigh! ~/ 10000}만원',
                    colorScheme: colorScheme,
                  ),
                ],
              ],
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
          Text(
            '체감 ${climate.feelsLikeMin.toInt()}~${climate.feelsLikeMax.toInt()}°C',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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
    final (idealLo, idealHi) = ScoringService.maxTempIdealRange(
      destination.theme,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Text(
              '월별 기후',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...destination.climates.map((climate) {
            final rank = topMonths.indexOf(climate.month) + 1;
            return _MonthRow(
              climate: climate,
              rank: rank > 0 ? rank : null,
              idealLo: idealLo,
              idealHi: idealHi,
            );
          }),
        ],
      ),
    );
  }
}

class _MonthRow extends StatelessWidget {
  final MonthlyClimate climate;
  final int? rank;
  final double idealLo;
  final double idealHi;

  const _MonthRow({
    required this.climate,
    required this.idealLo,
    required this.idealHi,
    this.rank,
  });

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
                        horizontal: 6,
                        vertical: 2,
                      ),
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
                    style: TextStyle(fontSize: 10, color: colorScheme.outline),
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
                  _TempBar(
                    minTemp: climate.feelsLikeMin,
                    maxTemp: climate.feelsLikeMax,
                    minColor: _tempColor(climate.feelsLikeMin),
                    maxColor: _tempColor(climate.feelsLikeMax),
                    idealLo: idealLo,
                    idealHi: idealHi,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.device_thermostat,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${climate.minTemp.toInt()}~${climate.maxTemp.toInt()}°C',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        ' (체감 ${climate.feelsLikeMin.toInt()}~${climate.feelsLikeMax.toInt()}°C)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.water_drop_outlined,
                        size: 14,
                        color: Colors.blue.shade400,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${climate.precipitation.toInt()}mm',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (climate.auroraIndex > 0) ...[
                        const SizedBox(width: 10),
                        const Text('🌌', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 3),
                        Text(
                          '${climate.auroraIndex.toInt()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ] else ...[
                        const SizedBox(width: 10),
                        Icon(
                          Icons.wb_sunny_outlined,
                          size: 14,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${climate.daylightHours.toStringAsFixed(1)}h',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
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
  final double idealLo; // 테마별 최고기온 이상 하한
  final double idealHi; // 테마별 최고기온 이상 상한

  const _TempBar({
    required this.minTemp,
    required this.maxTemp,
    required this.minColor,
    required this.maxColor,
    required this.idealLo,
    required this.idealHi,
  });

  @override
  Widget build(BuildContext context) {
    // 전체 표시 범위: -15°C ~ 45°C
    const rangeMin = -15.0;
    const rangeMax = 45.0;
    const totalRange = rangeMax - rangeMin;

    final leftFraction = ((minTemp - rangeMin) / totalRange).clamp(0.0, 1.0);
    final rightFraction = ((maxTemp - rangeMin) / totalRange).clamp(0.0, 1.0);

    // 이상 범위 위치 (테마별 최고기온 기준)
    final idealLeftFraction = ((idealLo - rangeMin) / totalRange).clamp(
      0.0,
      1.0,
    );
    final idealRightFraction = ((idealHi - rangeMin) / totalRange).clamp(
      0.0,
      1.0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        final barLeft = total * leftFraction;
        final barWidth = (total * rightFraction - barLeft).clamp(4.0, total);

        final idealLeft = total * idealLeftFraction;
        final idealWidth = (total * idealRightFraction - idealLeft).clamp(
          0.0,
          total - idealLeft,
        );

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
            // 이상 온도 영역 (테마별 최고기온 이상 범위)
            Positioned(
              left: idealLeft,
              width: idealWidth,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.25),
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
                  gradient: LinearGradient(colors: [minColor, maxColor]),
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

// ─── 물가 비교 섹션 ───────────────────────────────────────────────

class _CostOfLivingSection extends StatelessWidget {
  final CostOfLiving? costOfLiving;

  const _CostOfLivingSection({required this.costOfLiving});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget cardContent;
    if (costOfLiving == null || !costOfLiving!.hasData) {
      cardContent = Row(
        children: [
          Icon(Icons.wallet, color: colorScheme.outline),
          const SizedBox(width: 8),
          Text(
            '서울 대비 물가',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '정보 없음',
            style: TextStyle(fontSize: 13, color: colorScheme.outline),
          ),
        ],
      );
    } else {
      final col = costOfLiving!;
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wallet, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '서울 대비 물가',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _OverallBadge(overall: col.overall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '서울=1.0 기준  ·  중앙선이 서울 물가 수준',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
          ),
          const SizedBox(height: 16),
          _CostRow(icon: Icons.coffee, label: '커피', value: col.coffee),
          _CostRow(icon: Icons.restaurant, label: '식사(1인)', value: col.meal),
          _CostRow(icon: Icons.sports_bar, label: '맥주', value: col.beer),
          _CostRow(
            icon: Icons.directions_bus,
            label: '대중교통',
            value: col.transport,
          ),
          _CostRow(
            icon: Icons.hotel,
            label: '중급 호텔',
            value: col.hotel,
            isLast: true,
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        elevation: 2,
        child: Padding(padding: const EdgeInsets.all(20), child: cardContent),
      ),
    );
  }
}

class _OverallBadge extends StatelessWidget {
  final double overall;
  const _OverallBadge({required this.overall});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _levelInfo(overall);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label  ${overall.toStringAsFixed(2)}x',
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  static (Color, Color, String) _levelInfo(double v) {
    if (v < 0.7)
      return (const Color(0xFFE3F2FD), const Color(0xFF1565C0), '저렴');
    if (v < 0.95)
      return (const Color(0xFFE8F5E9), const Color(0xFF2E7D32), '보통');
    if (v < 1.3)
      return (const Color(0xFFFFF9C4), const Color(0xFFF57F17), '비슷');
    return (const Color(0xFFFFEBEE), const Color(0xFFC62828), '비쌈');
  }
}

class _CostRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final bool isLast;

  const _CostRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  // 표시 범위: 0.0 ~ 2.0, 1.0이 트랙 중앙(50%)
  static const _maxVal = 2.0;

  Color _barColor(double v) {
    if (v < 0.7) return Colors.blue.shade400;
    if (v < 0.95) return Colors.green.shade500;
    if (v < 1.3) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final fraction = (value / _maxVal).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.outline),
          const SizedBox(width: 6),
          SizedBox(
            width: 64,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final total = constraints.maxWidth;
                final barW = (total * fraction).clamp(4.0, total);
                final lineX = total * 0.5; // 1.0 기준선 위치 (50%)
                return SizedBox(
                  height: 12,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 배경 트랙
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      // 값 바
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: barW,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _barColor(value),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      // 1.0 기준선 (세로 선)
                      Positioned(
                        left: lineX - 1,
                        top: -3,
                        bottom: -3,
                        width: 2,
                        child: Container(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '${value.toStringAsFixed(1)}x',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _barColor(value),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _SummaryBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
