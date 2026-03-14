class MbtiQuestion {
  final String text;

  /// 'pq' | 'bl' | 'n' | 'h' | 'u' | 's' | 'v' | 'a' | 'r'
  final String category;

  /// true이면 반대 방향 질문 → 채점 시 6-score로 역산
  final bool reversed;

  const MbtiQuestion({
    required this.text,
    required this.category,
    this.reversed = false,
  });
}

class TravelMbtiResult {
  final bool isP; // true=핫한(P), false=조용한(Q)
  final bool isB; // true=배낭(B), false=럭셔리(L)
  final String style1; // 1등: N·H·U·S  (자연·유적·도시·소도시)
  final String style2; // 1등: V·A·R    (휴양·액티비티·맛집)
  final String style3; // N·H·U·S·V·A·R 중 선택되지 않은 항목의 최고점

  const TravelMbtiResult({
    required this.isP,
    required this.isB,
    required this.style1,
    required this.style2,
    required this.style3,
  });

  /// 예: PBNA-S, QLHV-N
  String get typeCode =>
      '${isP ? 'P' : 'Q'}${isB ? 'B' : 'L'}$style1$style2-$style3';

  String get qpLabel => isP ? '핫한 명소' : '조용한 여행';
  String get blLabel => isB ? '배낭여행' : '럭셔리 여행';

  String style1Label(String s) => switch (s) {
    'N' => '자연',
    'H' => '유적·문화',
    'U' => '도시',
    'S' => '소도시',
    _ => s,
  };

  String style2Label(String s) => switch (s) {
    'V' => '휴양',
    'A' => '액티비티',
    'R' => '맛집 탐방',
    _ => s,
  };

  String style3Label(String s) => switch (s) {
    'N' => '자연',
    'H' => '유적·문화',
    'U' => '도시',
    'S' => '소도시',
    'V' => '휴양',
    'A' => '액티비티',
    'R' => '맛집 탐방',
    _ => s,
  };

  String style3Desc(String s) => switch (s) {
    'N' => '산·바다·숲 같은 자연 속에서 진짜 힐링을 찾습니다. 멋진 자연 경관이 최고의 보상입니다.',
    'H' => '오래된 유적지와 역사적 건물에서 가슴이 뜁니다. 도시의 역사와 문화를 깊이 탐구합니다.',
    'U' => '활기찬 도심 속 스카이라인, 거리 풍경, 쇼핑·카페 탐방이 여행의 즐거움입니다.',
    'S' => '작고 아담한 소도시 골목길에서 진짜 현지 분위기를 찾습니다. 관광지화되지 않은 소박함이 매력입니다.',
    'V' => '수영장과 해변에서 온전히 몸을 쉬게 하는 것이 여행의 목적. 리조트 라이프를 즐깁니다.',
    'A' => '하이킹·서핑·번지점프 등 몸으로 즐기는 체험이 여행의 핵심. 도전과 스릴을 추구합니다.',
    'R' => '현지 맛집과 길거리 음식 탐방으로 그 도시의 진짜 맛을 찾습니다. 먹는 것이 곧 여행입니다.',
    _ => '',
  };

  String get qpDesc => isP
      ? '활기차고 유명한 장소를 즐기는 스타일. 핫플레이스에서 살아있는 에너지를 느낍니다.'
      : '한적하고 조용한 곳에서 더 큰 여유를 찾는 스타일. 사람이 적은 곳이 더 편합니다.';

  String get blDesc => isB
      ? '저렴한 숙소에 경험 투자. 즉흥적이고 자유로운 이동을 즐기는 실속파 여행자입니다.'
      : '좋은 숙소와 편안한 이동에 투자. 프리미엄 경험으로 여행의 질을 높이는 스타일입니다.';

  String style1Desc(String s) => switch (s) {
    'N' => '산·바다·숲 같은 자연 속에서 진짜 힐링을 찾습니다. 멋진 자연 경관이 최고의 보상입니다.',
    'H' => '오래된 유적지와 역사적 건물에서 가슴이 뜁니다. 도시의 역사와 문화를 깊이 탐구합니다.',
    'U' => '활기찬 도심 속 스카이라인, 거리 풍경, 쇼핑·카페 탐방이 여행의 즐거움입니다.',
    'S' => '작고 아담한 소도시 골목길에서 진짜 현지 분위기를 찾습니다. 관광지화되지 않은 소박함이 매력입니다.',
    _ => '',
  };

  String style2Desc(String s) => switch (s) {
    'V' => '수영장과 해변에서 온전히 몸을 쉬게 하는 것이 여행의 목적. 리조트 라이프를 즐깁니다.',
    'A' => '하이킹·서핑·번지점프 등 몸으로 즐기는 체험이 여행의 핵심. 도전과 스릴을 추구합니다.',
    'R' => '현지 맛집과 길거리 음식 탐방으로 그 도시의 진짜 맛을 찾습니다. 먹는 것이 곧 여행입니다.',
    _ => '',
  };

  String get nickname => switch ('$style1$style2') {
    'NV' => '자연 속 힐링러',
    'NA' => '야생 자연 탐험가',
    'NR' => '자연 속 미식가',
    'HV' => '유유자적 역사가',
    'HA' => '열정적 역사 탐험가',
    'HR' => '역사 미식 기행가',
    'UV' => '도시 릴렉서',
    'UA' => '도시 어드벤처러',
    'UR' => '도시 미식가',
    'SV' => '소도시 힐링러',
    'SA' => '소도시 모험가',
    'SR' => '소도시 미식가',
    _ => '자유로운 여행자',
  };
}

/// [questions]와 [answers]는 동일 순서의 쌍 (셔플된 순서 포함).
TravelMbtiResult scoreMbti(List<MbtiQuestion> questions, List<int> answers) {
  assert(questions.length == answers.length);

  int pScore = 0, bScore = 0;
  int nScore = 0, hScore = 0, uScore = 0, sScore = 0;
  int vScore = 0, aScore = 0, rScore = 0;

  for (var i = 0; i < questions.length; i++) {
    final q = questions[i];
    final v = q.reversed ? 6 - answers[i] : answers[i];
    switch (q.category) {
      case 'pq':
        pScore += v;
      case 'bl':
        bScore += v;
      case 'n':
        nScore += v;
      case 'h':
        hScore += v;
      case 'u':
        uScore += v;
      case 's':
        sScore += v;
      case 'v':
        vScore += v;
      case 'a':
        aScore += v;
      case 'r':
        rScore += v;
    }
  }

  // pq / bl: 4문항(정방향2 + 역방향2) → 범위 4~20, mid=12
  // style 그룹: 각 3문항 → 범위 3~15
  final group1 = [
    MapEntry('N', nScore),
    MapEntry('H', hScore),
    MapEntry('U', uScore),
    MapEntry('S', sScore),
  ]..sort((a, b) => b.value.compareTo(a.value));

  final group2 = [
    MapEntry('V', vScore),
    MapEntry('A', aScore),
    MapEntry('R', rScore),
  ]..sort((a, b) => b.value.compareTo(a.value));

  // 선택되지 않은 N·H·U·S·V·A·R 중 최고점 항목 → 5번째 글자
  final chosen1 = group1[0].key;
  final chosen2 = group2[0].key;
  final unchosen =
      [
          MapEntry('N', nScore),
          MapEntry('H', hScore),
          MapEntry('U', uScore),
          MapEntry('S', sScore),
          MapEntry('V', vScore),
          MapEntry('A', aScore),
          MapEntry('R', rScore),
        ].where((e) => e.key != chosen1 && e.key != chosen2).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  return TravelMbtiResult(
    isP: pScore >= 12,
    isB: bScore >= 12,
    style1: chosen1,
    style2: chosen2,
    style3: unchosen[0].key,
  );
}

const List<MbtiQuestion> mbtiQuestions = [
  // ── P/Q 4문항 ────────────────────────────────────────────────────────────
  MbtiQuestion(category: 'pq', text: 'SNS에서 유명한 핫플레이스는 여행 중 꼭 방문하고 싶다.'),
  MbtiQuestion(
    category: 'pq',
    text: '사람이 많은 관광지라도 좋은 장소에서 충분히 즐거운 여행을 할 수 있다.',
  ),
  MbtiQuestion(
    category: 'pq',
    reversed: true,
    text: '관광객이 적고 한적한 곳에서 오히려 더 깊은 여유와 만족을 느낀다.',
  ),
  MbtiQuestion(
    category: 'pq',
    reversed: true,
    text: '아무리 좋은 명소라도 사람이 많으면 여행하고 싶지 않다.',
  ),

  // ── B/L 4문항 ────────────────────────────────────────────────────────────
  MbtiQuestion(
    category: 'bl',
    text: '저렴한 숙소와 로컬 교통으로 다니며 절약한 돈으로 더 많은 경험을 쌓는 것이 좋다.',
  ),
  MbtiQuestion(category: 'bl', text: '가는 교통이 조금 힘들더라도 멋진 장소를 방문하는 것은 즐겁다.'),
  MbtiQuestion(
    category: 'bl',
    reversed: true,
    text: '여행 중 좋은 숙소와 편안한 이동 수단은 여행의 질을 결정하는 중요한 요소다.',
  ),
  MbtiQuestion(
    category: 'bl',
    reversed: true,
    text: '여행 비용이 더 들더라도 프리미엄 서비스와 경험에 투자하는 것이 가치 있다.',
  ),

  // ── 자연(N) 3문항 ─────────────────────────────────────────────────────────
  MbtiQuestion(category: 'n', text: '산, 바다, 숲 같은 자연 속에 있을 때 가장 큰 힐링을 느낀다.'),
  MbtiQuestion(category: 'n', text: '압도적인 자연 경관 앞에 서는 것이 여행에서 가장 기억에 남는 순간이다.'),
  MbtiQuestion(category: 'n', text: '일출이나 일몰을 보기 위해 일부러 일정을 조정하는 편이다.'),

  // ── 유적·문화(H) 3문항 ───────────────────────────────────────────────────
  MbtiQuestion(category: 'h', text: '오래된 유적지나 역사적 건물을 방문하면 가슴이 설렌다.'),
  MbtiQuestion(category: 'h', text: '여행지의 역사와 문화를 깊이 이해하고 싶어 박물관·유적지를 자주 찾는다.'),
  MbtiQuestion(category: 'h', text: '무너져서 얼마 남지 않은 유적지에서도 큰 감명을 받는다.'),

  // ── 도시(U) 3문항 ─────────────────────────────────────────────────────────
  MbtiQuestion(category: 'u', text: '고층 빌딩과 현대적 스카이라인이 있는 도시 풍경을 보면 설렌다.'),
  MbtiQuestion(category: 'u', text: '활기찬 도심에서 쇼핑하고 즐기는 것이 여행에서 중요한 요소이다.'),
  MbtiQuestion(category: 'u', text: '잘 정비된 도시의 거리와 건축물을 걸으며 탐방하는 것을 즐긴다.'),

  // ── 소도시(S) 3문항 ───────────────────────────────────────────────────────
  MbtiQuestion(
    category: 's',
    text: '작고 아담한 소도시의 골목길을 천천히 걸으며 현지 분위기를 느끼는 것이 좋다.',
  ),
  MbtiQuestion(category: 's', text: '아기자기한 도심에서 사진을 찍는 재미를 즐긴다.'),
  MbtiQuestion(category: 's', text: '관광지화되지 않은 소박한 마을을 발견하는 것이 여행의 묘미다.'),

  // ── 휴양(V) 3문항 ─────────────────────────────────────────────────────────
  MbtiQuestion(category: 'v', text: '수영장이나 해변에서 하루 종일 느긋하게 쉬는 것이 여행의 핵심이다.'),
  MbtiQuestion(category: 'v', text: '좋은 숙소에서 충분히 쉬며 피로를 푸는 것이 여행의 중요한 부분이다.'),
  MbtiQuestion(category: 'v', text: '스파나 마사지 등 몸 관리를 여행 일정에 꼭 포함시키고 싶다.'),

  // ── 액티비티(A) 3문항 ─────────────────────────────────────────────────────
  MbtiQuestion(category: 'a', text: '번지점프, 스카이다이빙, 래프팅 같은 스릴 있는 활동에 끌린다.'),
  MbtiQuestion(
    category: 'a',
    text: '하이킹, 스쿠버다이빙, 서핑 등 몸으로 직접 즐기는 체험을 빠뜨릴 수 없다.',
  ),
  MbtiQuestion(category: 'a', text: '여행지에서 현지인들이 즐기는 스포츠나 레저를 직접 체험하고 싶다.'),

  // ── 맛집(R) 3문항 ─────────────────────────────────────────────────────────
  MbtiQuestion(category: 'r', text: '현지 유명 맛집 탐방과 길거리 음식 체험이 여행의 가장 큰 즐거움이다.'),
  MbtiQuestion(
    category: 'r',
    text: '처음 먹어보는 현지 음식을 도전하는 것이 여행에서 절대 빠질 수 없는 일이다.',
  ),
  MbtiQuestion(category: 'r', text: '여행 전 그 도시의 유명 음식을 미리 조사하고 방문 맛집 목록을 만든다.'),
];
