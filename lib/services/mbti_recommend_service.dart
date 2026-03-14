import '../data/destination_mbti_scores.dart';
import '../models/destination.dart';
import '../models/travel_mbti.dart';

class MbtiRecommendItem {
  final Destination dest;
  final int score;        // 최대 55점
  final int style1Score;  // 해당 style1 원점수 (1~5)
  final int style2Score;  // 해당 style2 원점수 (1~5)
  final int style3Score;  // 해당 style3 원점수 (1~5)
  final int pqScore;      // P 또는 Q 원점수 (1~5)
  final int blScore;      // B 또는 L 원점수 (1~5)

  const MbtiRecommendItem({
    required this.dest,
    required this.score,
    required this.style1Score,
    required this.style2Score,
    required this.style3Score,
    required this.pqScore,
    required this.blScore,
  });
}

class MbtiRecommendService {
  /// MBTI 결과에 따라 여행지 추천 목록 반환 (점수 내림차순, 상위 20개)
  ///
  /// 가중치:
  ///   1순위 — 3번째(style1)×3, 4번째(style2)×3  → 최대 30
  ///   2순위 — 5번째(style3)×2                   → 최대 10
  ///   3순위 — 1번째(pq)×1,     2번째(bl)×1       → 최대 10
  ///                                          합계 최대 50
  static List<MbtiRecommendItem> recommend(
    List<Destination> allDests,
    TravelMbtiResult result, {
    int topN = 20,
  }) {
    final items = <MbtiRecommendItem>[];

    for (final dest in allDests) {
      final s = destinationMbtiScores[dest.id];
      if (s == null) continue;

      final pqScore    = s[result.isP ? 'P' : 'Q'] ?? 0;
      final blScore    = s[result.isB ? 'B' : 'L'] ?? 0;
      final style1Score = s[result.style1] ?? 0;
      final style2Score = s[result.style2] ?? 0;
      final style3Score = s[result.style3] ?? 0;

      final score =
          style1Score * 3 +
          style2Score * 3 +
          style3Score * 2 +
          pqScore     * 1 +
          blScore     * 1;

      items.add(MbtiRecommendItem(
        dest: dest,
        score: score,
        style1Score: style1Score,
        style2Score: style2Score,
        style3Score: style3Score,
        pqScore: pqScore,
        blScore: blScore,
      ));
    }

    items.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return a.dest.name.compareTo(b.dest.name);
    });

    return items.take(topN).toList();
  }

  static String dimLabel(String dim) => switch (dim) {
    'P' => '핫한 명소',
    'Q' => '조용한 여행',
    'N' => '자연',
    'H' => '유적·문화',
    'U' => '도시',
    'S' => '소도시',
    'V' => '휴양',
    'A' => '액티비티',
    'R' => '맛집',
    'B' => '배낭여행',
    'L' => '럭셔리',
    _ => dim,
  };
}
