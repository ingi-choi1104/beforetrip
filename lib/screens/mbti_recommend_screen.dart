import 'package:flutter/material.dart';

import '../models/travel_mbti.dart';
import '../services/database_service.dart';
import '../services/mbti_recommend_service.dart';
import '../widgets/banner_ad_widget.dart';
import 'destination_screen.dart';

class MbtiRecommendScreen extends StatefulWidget {
  final TravelMbtiResult result;

  const MbtiRecommendScreen({super.key, required this.result});

  @override
  State<MbtiRecommendScreen> createState() => _MbtiRecommendScreenState();
}

class _MbtiRecommendScreenState extends State<MbtiRecommendScreen> {
  List<MbtiRecommendItem>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dests = await DatabaseService.instance.getAllDestinations();
    if (!mounted) return;
    setState(() {
      _items = MbtiRecommendService.recommend(dests, widget.result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final result = widget.result;

    return Scaffold(
      appBar: AppBar(
        title: Text('${result.typeCode} 추천 여행지'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      bottomNavigationBar: const BottomBannerAd(),
      body: _items == null
          ? const Center(child: CircularProgressIndicator())
          : _items!.isEmpty
              ? const Center(child: Text('추천 여행지가 없습니다.'))
              : CustomScrollView(
                  slivers: [
                    // MBTI 요약 배너
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.tertiary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.typeCode,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    result.nickname,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          colorScheme.onPrimary.withAlpha(210),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${_items!.length}개',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 추천 목록
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = _items![index];
                            return _RecommendTile(
                              item: item,
                              rank: index + 1,
                              result: result,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DestinationScreen(
                                      destination: item.dest),
                                ),
                              ),
                            );
                          },
                          childCount: _items!.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _RecommendTile extends StatelessWidget {
  final MbtiRecommendItem item;
  final int rank;
  final TravelMbtiResult result;
  final VoidCallback onTap;

  const _RecommendTile({
    required this.item,
    required this.rank,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dest = item.dest;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // 순위
              SizedBox(
                width: 28,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: rank <= 3
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              // 국기
              Text(dest.flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              // 이름·점수 바
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            dest.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            dest.country,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: _ScorePill(
                            label: result.style1Label(result.style1),
                            color: colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: _ScorePill(
                            label: result.style2Label(result.style2),
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 총점
              _TotalScore(score: item.score),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final Color color;

  const _ScorePill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TotalScore extends StatelessWidget {
  final int score; // 최대 50

  const _TotalScore({required this.score});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ratio = score / 50.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$score',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 44,
          height: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: ratio >= 0.77
                  ? colorScheme.primary
                  : colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
