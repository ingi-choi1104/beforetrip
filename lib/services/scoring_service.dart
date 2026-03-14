import 'package:flutter/foundation.dart';

import '../models/destination.dart';
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
  // 일반·여름 가중치
  static const double _wTemp = 0.4;
  static const double _wPrecip = 0.4;
  static const double _wDay = 0.20;
  // 겨울 가중치 (일조 미포함: 기온 40% + 강수 60%)
  static const double _wTempWinter = 0.40;
  static const double _wPrecipWinter = 0.60;
  // 오로라 가중치 (오로라 50% + 강수 25% + 기온 25%)
  static const double _wAurora = 0.50;
  static const double _wPrecipAurora = 0.25;
  static const double _wTempAurora = 0.25;

  // 일조시간 기준 (공통)
  static const double _minDaylight = 8.0;
  static const double _maxDaylight = 16.0;

  // 기온 이상 범위 (테마별)
  // 일반: min 13~18, max 18~22
  static const _generalMinLo = 14.0, _generalMinHi = 19.0;
  static const _generalMaxLo = 19.0, _generalMaxHi = 24.0;
  // 여름: 최고기온 28~33만 채점 (최저기온은 관여 없음)
  static const _summerMinLo = 20.0, _summerMinHi = 25.0;
  static const _summerMaxLo = 28.0, _summerMaxHi = 33.0;
  // 겨울: min -10~-5, max -2~2
  static const _winterMinLo = -10.0, _winterMinHi = -5.0;
  static const _winterMaxLo = -4.0, _winterMaxHi = 1.0;

  static double _dev(double v, double lo, double hi) {
    if (v < lo) return lo - v;
    if (v > hi) return v - hi;
    return 0.0;
  }

  static double _calcTempScore(
    double minTemp,
    double maxTemp,
    DestinationTheme theme,
  ) {
    final double minDev, maxDev;

    switch (theme) {
      case DestinationTheme.general:
        minDev = _dev(minTemp, _generalMinLo, _generalMinHi);
        maxDev = _dev(maxTemp, _generalMaxLo, _generalMaxHi);
      case DestinationTheme.uyuni:
        minDev = _dev(minTemp, _generalMinLo, _generalMinHi);
        maxDev = _dev(maxTemp, _generalMaxLo, _generalMaxHi);
      case DestinationTheme.summer:
        // 여름 여행지는 최고기온만 채점 (해변 낮 날씨가 핵심, 최저기온 무관)
        minDev = _dev(minTemp, _summerMinLo, _summerMinHi);
        maxDev = _dev(maxTemp, _summerMaxLo, _summerMaxHi);
      case DestinationTheme.winter:
        minDev = _dev(minTemp, _winterMinLo, _winterMinHi);
        maxDev = _dev(maxTemp, _winterMaxLo, _winterMaxHi);
      case DestinationTheme.aurora:
        // 오로라: 일반 기온 범위로 채점 (20% 가중치)
        minDev = _dev(minTemp, _generalMinLo, _generalMinHi);
        maxDev = _dev(maxTemp, _generalMaxLo, _generalMaxHi);
    }

    return (100.0 - (minDev + maxDev) * 4.0).clamp(0.0, 100.0);
  }

  static double _calcPrecipScore(double precipitation, DestinationTheme theme) {
    if (theme == DestinationTheme.winter) {
      // 겨울: 강수(눈) 많을수록 좋음 (0mm→0점, 200mm→100점)
      return (precipitation / 200.0 * 100.0).clamp(0.0, 100.0);
    }
    // 일반·여름: 적을수록 좋음 (300mm 기준으로 0점 — 변화폭 극대화)
    return (100.0 - precipitation / 300.0 * 100.0).clamp(0.0, 100.0);
  }

  static double _calcDaylightScore(double daylightHours) {
    return ((daylightHours - _minDaylight) /
            (_maxDaylight - _minDaylight) *
            100.0)
        .clamp(0.0, 100.0);
  }

  /// 12개월 점수 계산 + 디버그 출력 (사용자에게는 미노출)
  /// [quiet] = true 이면 디버그 출력 생략 (검색 필터 등 대량 호출 시 사용)
  static List<MonthScore> calculateScores(
    List<MonthlyClimate> climates,
    String destinationName,
    DestinationTheme theme, {
    bool quiet = false,
  }) {
    final isAurora = theme == DestinationTheme.aurora;
    final isWinter = theme == DestinationTheme.winter;
    final tempWeight = isWinter ? _wTempWinter : _wTemp;
    final precipWeight = isWinter ? _wPrecipWinter : _wPrecip;
    final daylightWeight = isWinter ? 0.0 : _wDay;

    final scores = climates.map((c) {
      if (isAurora) {
        final a = c.auroraIndex;
        final p = _calcPrecipScore(c.precipitation, theme);
        final t = _calcTempScore(
          c.feelsLikeMin,
          c.feelsLikeMax,
          theme,
        ); // 체감 기온
        final total = a * _wAurora + p * _wPrecipAurora + t * _wTempAurora;
        return MonthScore(
          month: c.month,
          tempScore: a, // aurora 테마: tempScore 필드를 오로라 지수로 재사용
          precipScore: p,
          daylightScore: t,
          totalScore: total,
        );
      }
      final t = _calcTempScore(c.feelsLikeMin, c.feelsLikeMax, theme); // 체감 기온
      final p = _calcPrecipScore(c.precipitation, theme);
      final d = _calcDaylightScore(c.daylightHours);
      final total = t * tempWeight + p * precipWeight + d * daylightWeight;
      return MonthScore(
        month: c.month,
        tempScore: t,
        precipScore: p,
        daylightScore: d,
        totalScore: total,
      );
    }).toList();

    if (!quiet && kDebugMode) {
      final themeStr = theme.label;
      final sorted = [...scores]
        ..sort((a, b) => b.totalScore.compareTo(a.totalScore));

      debugPrint('');
      debugPrint('══════════════════════════════════════════');
      if (isAurora) {
        debugPrint(
          '📊 [$destinationName | $themeStr] [오로라(60%) + 강수(20%) + 기온(20%)]',
        );
        debugPrint('══════════════════════════════════════════');
        debugPrint(' 월   오로라(60%)  강수(20%)  기온(20%)   총점');
      } else {
        final precipNote = isWinter
            ? ' [강수: 많을수록↑, 가중치 ${(_wPrecipWinter * 100).toInt()}%]'
            : ' [강수: 적을수록↑, 가중치 ${(_wPrecip * 100).toInt()}%]';
        debugPrint('📊 [$destinationName | $themeStr]$precipNote');
        debugPrint('══════════════════════════════════════════');
        debugPrint(
          ' 월     기온(${(tempWeight * 100).toInt()}%)  강수(${(precipWeight * 100).toInt()}%)  일조(${(daylightWeight * 100).toInt()}%)   총점',
        );
      }
      debugPrint('──────────────────────────────────────────');
      for (final s in scores) {
        final rank = sorted.indexWhere((r) => r.month == s.month) + 1;
        final rankTag = rank <= 3 ? ' [$rank위]' : '     ';
        if (isAurora) {
          debugPrint(
            '${s.month.toString().padLeft(2)}월$rankTag'
            '   ${s.tempScore.toStringAsFixed(1).padLeft(5)}'
            '   ${s.precipScore.toStringAsFixed(1).padLeft(5)}'
            '   ${s.daylightScore.toStringAsFixed(1).padLeft(5)}'
            '   ${s.totalScore.toStringAsFixed(1).padLeft(5)}',
          );
        } else {
          debugPrint(
            '${s.month.toString().padLeft(2)}월$rankTag'
            '   ${s.tempScore.toStringAsFixed(1).padLeft(5)}'
            '   ${s.precipScore.toStringAsFixed(1).padLeft(5)}'
            '   ${s.daylightScore.toStringAsFixed(1).padLeft(5)}'
            '   ${s.totalScore.toStringAsFixed(1).padLeft(5)}',
          );
        }
      }
      debugPrint('══════════════════════════════════════════');
      debugPrint('');
    }

    return scores;
  }

  /// 점수 높은 순 상위 N개 월 번호 반환
  static List<int> getTopMonths(
    List<MonthScore> scores,
    int count,
    DestinationTheme theme,
  ) {
    // 우유니 테마일 경우 하드코딩된 값 반환
    if (theme == DestinationTheme.uyuni) {
      // 옵션 1: count와 무관하게 무조건 2, 1, 3 반환
      return [2, 1, 3];
    } else {
      final sorted = [...scores]
        ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
      return sorted.take(count).map((s) => s.month).toList();
    }
  }

  /// 테마별 기온 시각화 바에 사용할 최고기온 이상 범위 반환
  static (double lo, double hi) maxTempIdealRange(DestinationTheme theme) {
    switch (theme) {
      case DestinationTheme.general:
      case DestinationTheme.uyuni:
      case DestinationTheme.aurora:
        return (_generalMaxLo, _generalMaxHi);
      case DestinationTheme.summer:
        return (_summerMaxLo, _summerMaxHi);
      case DestinationTheme.winter:
        return (_winterMaxLo, _winterMaxHi);
    }
  }
}
