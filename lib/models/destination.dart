import 'cost_of_living.dart';
import 'monthly_climate.dart';

enum DestinationTheme {
  general, // 일반 — 도시 관광 등
  summer, // 여름 — 해변·물놀이 (최고기온 28~33°C 만점)
  winter, // 겨울 — 스키·눈 (최고기온 0~5°C, 강수 역전)
  aurora, // 오로라 — 극지 오로라 관측 (오로라 지수 70% 반영)
  uyuni, // 우유니 - 1~3월 고정
}

extension DestinationThemeLabel on DestinationTheme {
  String get label {
    switch (this) {
      case DestinationTheme.general:
        return '일반';
      case DestinationTheme.summer:
        return '여름';
      case DestinationTheme.winter:
        return '겨울';
      case DestinationTheme.aurora:
        return '오로라';
      case DestinationTheme.uyuni:
        return '일반';
    }
  }

  String get emoji {
    switch (this) {
      case DestinationTheme.general:
        return '🏙️';
      case DestinationTheme.summer:
        return '🏖️';
      case DestinationTheme.winter:
        return '⛷️';
      case DestinationTheme.aurora:
        return '🌌';
      case DestinationTheme.uyuni:
        return '🏙️';
    }
  }
}

class Destination {
  final String id;
  final String name;
  final String country;
  final String region;
  final String flag;
  final DestinationTheme theme;
  final CostOfLiving? costOfLiving;
  final int minDays; // 평균 여행 일수 최솟값 (0 = 정보 없음)
  final int maxDays; // 평균 여행 일수 최댓값 (0 = 정보 없음)
  final int? flightPriceLow;  // 항공권 예상 최저가 (KRW, null = 정보 없음)
  final int? flightPriceHigh; // 항공권 예상 최고가 (KRW, null = 정보 없음)
  final List<MonthlyClimate> climates; // 12개월 순서대로 (1월~12월)
  final String description; // 도시 특징·주요 관광 포인트 한줄 요약

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.region,
    required this.flag,
    this.theme = DestinationTheme.general,
    this.costOfLiving,
    this.minDays = 0,
    this.maxDays = 0,
    this.flightPriceLow,
    this.flightPriceHigh,
    required this.climates,
    this.description = '',
  });

  // DB 직렬화 (climates 제외 — 별도 테이블)
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'country': country,
    'region': region,
    'flag': flag,
    'theme': theme.name,
    if (costOfLiving != null)
      ...costOfLiving!.toMap()
    else ...{
      'col_coffee': null,
      'col_meal': null,
      'col_beer': null,
      'col_transport': null,
      'col_hotel': null,
    },
    'min_days': minDays,
    'max_days': maxDays,
    'flight_price_low': flightPriceLow,
    'flight_price_high': flightPriceHigh,
    'description': description,
  };

  static Destination fromMap(
    Map<String, dynamic> m,
    List<MonthlyClimate> climates,
  ) => Destination(
    id: m['id'] as String,
    name: m['name'] as String,
    country: m['country'] as String,
    region: m['region'] as String,
    flag: m['flag'] as String,
    theme: DestinationTheme.values.byName((m['theme'] as String?) ?? 'general'),
    costOfLiving: CostOfLiving.fromMap(m),
    minDays: (m['min_days'] as int?) ?? 0,
    maxDays: (m['max_days'] as int?) ?? 0,
    flightPriceLow: m['flight_price_low'] as int?,
    flightPriceHigh: m['flight_price_high'] as int?,
    climates: climates,
    description: (m['description'] as String?) ?? '',
  );
}
