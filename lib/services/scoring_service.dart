import 'package:flutter/foundation.dart';
import '../models/monthly_climate.dart';

class MonthScore {
  final int month;
  final double tempScore;
  final double precipScore;
  final double daylightScore;
  final double totalScore;

  const MonthScore({
    required this.month,
    required this.tempScore,
    required this.precipScore,
    required this.daylightScore,
    required this.totalScore,
  });
}

class ScoringService {
  // 가중치
  static const double _tempWeight = 0.4;
  static const double _precipWeight = 0.3;
  static const double _daylightWeight = 0.3;

  // 이상적인 기온 범위 (최저·최고 기준 분리)
  static const double _minTempIdealLow  = 15.0; // 최저 기온 이상 하한
  static const double _minTempIdealHigh = 20.0; // 최저 기온 이상 상한
  static const double _maxTempIdealLow  = 18.0; // 최고 기온 이상 하한
  static const double _maxTempIdealHigh = 24.0; // 최고 기온 이상 상한

  // 기준값
  static const double _maxPrecipRef = 400.0; // 400mm → 0점
  static const double _minDaylightRef = 8.0;  // 8시간 → 0점
  static const double _maxDaylightRef = 16.0; // 16시간 → 100점

  /// 기온 점수
  /// - 최저 기온 15~20°C = 만점, 벗어날수록 1도당 -5점
  /// - 최고 기온 18~24°C = 만점, 벗어날수록 1도당 -5점
  static double _calcTempScore(double minTemp, double maxTemp) {
    final minDev = (minTemp < _minTempIdealLow)
        ? _minTempIdealLow - minTemp
        : (minTemp > _minTempIdealHigh)
            ? minTemp - _minTempIdealHigh
            : 0.0;

    final maxDev = (maxTemp < _maxTempIdealLow)
        ? _maxTempIdealLow - maxTemp
        : (maxTemp > _maxTempIdealHigh)
            ? maxTemp - _maxTempIdealHigh
            : 0.0;

    return (100.0 - (minDev + maxDev) * 5.0).clamp(0.0, 100.0);
  }

  /// 강수량 점수: 적을수록 높음 (0mm=100점, 400mm=0점)
  static double _calcPrecipScore(double precipitation) {
    return (100.0 - (precipitation / _maxPrecipRef) * 100.0).clamp(0.0, 100.0);
  }

  /// 일조시간 점수: 길수록 높음 (8h=0점, 16h=100점)
  static double _calcDaylightScore(double daylightHours) {
    return ((daylightHours - _minDaylightRef) /
            (_maxDaylightRef - _minDaylightRef) *
            100.0)
        .clamp(0.0, 100.0);
  }

  /// 12개월 점수 계산 후 debugPrint로 출력 (사용자에게는 미노출)
  static List<MonthScore> calculateScores(
    List<MonthlyClimate> climates,
    String destinationName,
  ) {
    final scores = climates.map((c) {
      final t = _calcTempScore(c.minTemp, c.maxTemp);
      final p = _calcPrecipScore(c.precipitation);
      final d = _calcDaylightScore(c.daylightHours);
      final total = t * _tempWeight + p * _precipWeight + d * _daylightWeight;
      return MonthScore(
        month: c.month,
        tempScore: t,
        precipScore: p,
        daylightScore: d,
        totalScore: total,
      );
    }).toList();

    // 디버그 전용 출력 (debug 빌드에서만 표시)
    if (kDebugMode) {
      debugPrint('');
      debugPrint('══════════════════════════════════════');
      debugPrint('📊 [$destinationName] 월별 여행 점수');
      debugPrint('══════════════════════════════════════');
      debugPrint(
        '월    기온(40%)  강수(30%)  일조(30%)  총점',
      );
      debugPrint('──────────────────────────────────────');

      final sorted = [...scores]
        ..sort((a, b) => b.totalScore.compareTo(a.totalScore));

      for (final s in scores) {
        final rank = sorted.indexWhere((r) => r.month == s.month) + 1;
        final rankStr = rank <= 3 ? ' [$rank위]' : '     ';
        debugPrint(
          '${s.month.toString().padLeft(2)}월$rankStr  '
          '${s.tempScore.toStringAsFixed(1).padLeft(5)}  '
          '${s.precipScore.toStringAsFixed(1).padLeft(7)}  '
          '${s.daylightScore.toStringAsFixed(1).padLeft(7)}  '
          '${s.totalScore.toStringAsFixed(1).padLeft(5)}',
        );
      }
      debugPrint('══════════════════════════════════════');
      debugPrint('');
    }

    return scores;
  }

  /// 점수 순위 기준 상위 N개 월 반환 (1위부터)
  static List<int> getTopMonths(List<MonthScore> scores, int count) {
    final sorted = [...scores]
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return sorted.take(count).map((s) => s.month).toList();
  }
}
