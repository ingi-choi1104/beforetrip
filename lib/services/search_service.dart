import '../models/city_group.dart';
import '../models/destination.dart';
import 'scoring_service.dart';

class SearchFilters {
  final int? month;
  final int? travelDays;
  final int partySize; // 1~4, 기본 2
  final int? budgetWon;
  final DestinationTheme? theme; // null = 전체(일반여행)
  final bool monthLongStay; // 한 달 살기 모드

  const SearchFilters({
    this.month,
    this.travelDays,
    this.partySize = 2,
    this.budgetWon,
    this.theme,
    this.monthLongStay = false,
  });

  bool get hasAnyFilter =>
      month != null ||
      travelDays != null ||
      budgetWon != null ||
      theme != null ||
      monthLongStay;

  SearchFilters copyWith({
    Object? month = _sentinel,
    Object? travelDays = _sentinel,
    int? partySize,
    Object? budgetWon = _sentinel,
    Object? theme = _sentinel,
    bool? monthLongStay,
  }) => SearchFilters(
    month: month == _sentinel ? this.month : month as int?,
    travelDays: travelDays == _sentinel ? this.travelDays : travelDays as int?,
    partySize: partySize ?? this.partySize,
    budgetWon: budgetWon == _sentinel ? this.budgetWon : budgetWon as int?,
    theme: theme == _sentinel ? this.theme : theme as DestinationTheme?,
    monthLongStay: monthLongStay ?? this.monthLongStay,
  );

  static const _sentinel = Object();
}

class SearchResultItem {
  final bool isGroup;
  final Destination? dest; // single
  final CityGroup? group; // multi
  final List<Destination> groupDests; // multi용 (비어있으면 single)
  final List<int> topMonths; // primary dest 기준 top3 월 목록
  final int? estimatedTotalWon; // null = 항공 정보 없음
  final bool hasFlight;

  const SearchResultItem({
    required this.isGroup,
    this.dest,
    this.group,
    this.groupDests = const [],
    required this.topMonths,
    this.estimatedTotalWon,
    required this.hasFlight,
  });

  Destination get primaryDest => isGroup ? groupDests.first : dest!;
}

class SearchService {
  static const _partyMultipliers = [0.0, 0.70, 1.00, 1.50, 2.00];

  static List<SearchResultItem> filter(
    List<Destination> allDests,
    List<CityGroup> allGroups,
    SearchFilters f,
  ) {
    final destMap = {for (final d in allDests) d.id: d};
    final results = <SearchResultItem>[];

    // 단일 도시 필터
    for (final dest in allDests) {
      final item = _filterSingle(dest, f);
      if (item != null) results.add(item);
    }

    // 연계 도시 필터 (한 달 살기·5일 이하면 그룹 제외)
    final days = f.travelDays;
    if (!f.monthLongStay && (days == null || days > 5)) {
      for (final group in allGroups) {
        final item = _filterGroup(group, destMap, f);
        if (item != null) results.add(item);
      }
    }

    return results;
  }

  static SearchResultItem? _filterSingle(Destination dest, SearchFilters f) {
    // 1. 테마 필터 (한 달 살기는 테마 무관)
    if (!f.monthLongStay && f.theme != null && dest.theme != f.theme) {
      return null;
    }

    // 2. 월 필터
    final scores = ScoringService.calculateScores(
      dest.climates,
      dest.name,
      dest.theme,
      quiet: true,
    );
    final topMonths = ScoringService.getTopMonths(scores, 3, dest.theme);
    if (f.month != null && !topMonths.contains(f.month)) return null;

    // 3. 여행 기간 필터 (한 달 살기는 스킵)
    if (!f.monthLongStay) {
      final days = f.travelDays;
      if (days != null) {
        // 5일 이하 → 아시아만
        if (days <= 5 && dest.region != '동아시아' && dest.region != '동남아시아') {
          return null;
        }
        // 추천 여행 기간 ±1일 이내만 허용
        if (dest.minDays > 0 || dest.maxDays > 0) {
          final lo = dest.minDays > 0 ? dest.minDays : dest.maxDays;
          final hi = dest.maxDays > 0 ? dest.maxDays : dest.minDays;
          if (days < lo - 1 || days > hi + 1) return null;
        }
      }
    }

    // 4. 예산 필터
    final (hasFlight, estimate) = f.monthLongStay
        ? _calcMonthLongEstimate(dest, f.partySize)
        : _calcEstimate(dest, f.travelDays, f.partySize);
    if (f.budgetWon != null && estimate != null) {
      final budget = f.budgetWon!;
      if (estimate < budget * 0.50 || estimate > budget * 1.00) return null;
    }

    return SearchResultItem(
      isGroup: false,
      dest: dest,
      topMonths: topMonths,
      estimatedTotalWon: estimate,
      hasFlight: hasFlight,
    );
  }

  static SearchResultItem? _filterGroup(
    CityGroup group,
    Map<String, Destination> destMap,
    SearchFilters f,
  ) {
    // 그룹 내 모든 도시 조회 (없는 ID는 스킵)
    final groupDests = group.destIds
        .map((id) => destMap[id])
        .whereType<Destination>()
        .toList();
    if (groupDests.isEmpty) return null;

    final primary = groupDests.first;

    // 1. 테마 필터 (primary 기준)
    if (f.theme != null && primary.theme != f.theme) return null;

    // 2. 월 필터 (primary 기준)
    final scores = ScoringService.calculateScores(
      primary.climates,
      primary.name,
      primary.theme,
      quiet: true,
    );
    final topMonths = ScoringService.getTopMonths(scores, 3, primary.theme);
    if (f.month != null && !topMonths.contains(f.month)) return null;

    // 3. 여행 기간 필터: 각 도시 minDays 합계 ~ maxDays 합계 범위 안에 입력값이 들어와야 함
    final days = f.travelDays;
    if (days != null) {
      final totalMin = groupDests.fold(0, (s, d) => s + d.minDays);
      final totalMax = groupDests.fold(0, (s, d) => s + d.maxDays);
      // 도시들에 기간 데이터가 있으면 합산 범위로 필터, 없으면 group 시드값 사용
      final lo = totalMin > 0 ? totalMin : group.minDays;
      final hi = totalMax > 0 ? totalMax : group.maxDays;
      if (days < lo || days > hi) return null;
    }

    // 4. 예산 필터 (primary 항공, 그룹 평균 일경비 사용)
    final totalMin = groupDests.fold(0, (s, d) => s + d.minDays);
    final totalMax = groupDests.fold(0, (s, d) => s + d.maxDays);
    final groupMid = totalMin > 0
        ? (totalMin + totalMax) ~/ 2
        : (group.minDays + group.maxDays) ~/ 2;
    final effectiveDays = days ?? groupMid;
    final (hasFlight, estimate) = _calcGroupEstimate(
      primary,
      groupDests,
      effectiveDays,
      f.partySize,
    );
    if (f.budgetWon != null && estimate != null) {
      final budget = f.budgetWon!;
      if (estimate < budget * 0.50 || estimate > budget * 1.00) return null;
    }

    return SearchResultItem(
      isGroup: true,
      group: group,
      groupDests: groupDests,
      topMonths: topMonths,
      estimatedTotalWon: estimate,
      hasFlight: hasFlight,
    );
  }

  /// 지역별 기본 항공료 (인당 왕복, 실제 데이터 없을 때 사용)
  static int _defaultFlightAvg(String region) => switch (region) {
    '동아시아' || '동남아시아' => 600000,
    '유럽' || '아프리카/인도양' || '북아메리카' => 1600000,
    '오세아니아' => 1200000,
    '남아메리카' => 2200000,
    _ => 1600000, // 중동 등 기타
  };

  /// 실제 항공 데이터 또는 지역 기본값 반환
  static double _flightAvg(Destination dest) {
    if (dest.flightPriceLow != null && dest.flightPriceHigh != null) {
      return (dest.flightPriceLow! + dest.flightPriceHigh!) / 2.0;
    }
    return _defaultFlightAvg(dest.region).toDouble();
  }

  /// (hasFlight, estimatedTotalWon) for a single destination
  static (bool, int?) _calcEstimate(
    Destination dest,
    int? days,
    int partySize,
  ) {
    final hasFlight =
        dest.flightPriceLow != null && dest.flightPriceHigh != null;
    if (dest.costOfLiving == null || days == null) return (hasFlight, null);
    final avgFlight = _flightAvg(dest);
    final dailyCost = dest.costOfLiving!.estimatedDailyCostKRW;
    // 2인 기준: 항공 왕복(인당) × 2 + 일수 × 2인 일경비
    final base2p = avgFlight * 2 + days * dailyCost;
    final mult = _partyMultipliers[partySize.clamp(1, 4)];
    return (hasFlight, (base2p * mult).round());
  }

  /// 한 달 살기: 30일, 일경비 70% 적용
  static (bool, int?) _calcMonthLongEstimate(Destination dest, int partySize) {
    final hasFlight =
        dest.flightPriceLow != null && dest.flightPriceHigh != null;
    if (dest.costOfLiving == null) return (hasFlight, null);
    final avgFlight = _flightAvg(dest);
    final dailyCost = (dest.costOfLiving!.estimatedDailyCostKRW * 0.70).round();
    final base2p = avgFlight * 2 + 30 * dailyCost;
    final mult = _partyMultipliers[partySize.clamp(1, 4)];
    return (hasFlight, (base2p * mult).round());
  }

  /// (hasFlight, estimatedTotalWon) for a city group
  static (bool, int?) _calcGroupEstimate(
    Destination primary,
    List<Destination> groupDests,
    int days,
    int partySize,
  ) {
    final hasFlight =
        primary.flightPriceLow != null && primary.flightPriceHigh != null;

    final costsWithData = groupDests
        .where((d) => d.costOfLiving != null)
        .map((d) => d.costOfLiving!.estimatedDailyCostKRW)
        .toList();
    if (costsWithData.isEmpty) return (hasFlight, null);

    final avgDailyCost =
        costsWithData.reduce((a, b) => a + b) ~/ costsWithData.length;
    final avgFlight = _flightAvg(primary);
    final base2p = avgFlight * 2 + days * avgDailyCost;
    final mult = _partyMultipliers[partySize.clamp(1, 4)];
    return (hasFlight, (base2p * mult).round());
  }
}
