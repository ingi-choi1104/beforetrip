class CostOfLiving {
  final double coffee;     // 커피 가격 지수 (서울=1.0)
  final double meal;       // 레스토랑 식사 지수 (서울=1.0)
  final double beer;       // 맥주 가격 지수 (서울=1.0)
  final double transport;  // 대중교통 1회 지수 (서울=1.0)
  final double hotel;      // 중급 호텔 1박 지수 (서울=1.0)

  const CostOfLiving({
    required this.coffee,
    required this.meal,
    required this.beer,
    required this.transport,
    required this.hotel,
  });

  static const CostOfLiving seoul = CostOfLiving(
    coffee: 1.0,
    meal: 1.0,
    beer: 1.0,
    transport: 1.0,
    hotel: 1.0,
  );

  double get overall => (coffee + meal + beer + transport + hotel) / 5;

  /// 모든 인덱스가 1.0이면 데이터 없음으로 간주
  bool get hasData =>
      !(coffee == 1.0 &&
          meal == 1.0 &&
          beer == 1.0 &&
          transport == 1.0 &&
          hotel == 1.0);

  /// 서울 기준 하루 예상 경비 (원, 만원 단위 반올림)
  /// 커피 5,000 + 식사 2끼 35,000 + 맥주 6,000 + 교통 3,000 + 호텔 130,000 + 잡비 10%
  int get estimatedDailyCostKRW {
    final raw =
        (5000 * coffee +
            35000 * meal +
            6000 * beer +
            3000 * transport +
            130000 * hotel) *
        1.1;
    return ((raw / 10000).round()) * 10000;
  }

  Map<String, dynamic> toMap() => {
    'col_coffee': coffee,
    'col_meal': meal,
    'col_beer': beer,
    'col_transport': transport,
    'col_hotel': hotel,
  };

  static CostOfLiving? fromMap(Map<String, dynamic> m) {
    if (m['col_coffee'] == null) return null;
    return CostOfLiving(
      coffee: (m['col_coffee'] as num).toDouble(),
      meal: (m['col_meal'] as num).toDouble(),
      beer: (m['col_beer'] as num).toDouble(),
      transport: (m['col_transport'] as num).toDouble(),
      hotel: (m['col_hotel'] as num).toDouble(),
    );
  }
}
