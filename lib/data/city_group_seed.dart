import '../models/city_group.dart';

class CityGroupSeed {
  static const List<CityGroup> groups = [
    // ─── 동아시아 ──────────────────────────────────────────
    CityGroup(
      name: '오사카·교토·고베',
      region: '동아시아',
      minDays: 4,
      maxDays: 6,
      destIds: ['osaka', 'kyoto', 'kobe'],
    ),
    CityGroup(
      name: '도쿄·오사카·교토·고베',
      region: '동아시아',
      minDays: 7,
      maxDays: 10,
      destIds: ['tokyo', 'osaka', 'kyoto', 'kobe'],
    ),
    CityGroup(
      name: '후쿠오카·오사카·교토·고베',
      region: '동아시아',
      minDays: 5,
      maxDays: 7,
      destIds: ['fukuoka', 'osaka', 'kyoto', 'kobe'],
    ),
    CityGroup(
      name: '도쿄·교토·나고야',
      region: '동아시아',
      minDays: 6,
      maxDays: 9,
      destIds: ['tokyo', 'kyoto', 'nagoya'],
    ),
    CityGroup(
      name: '타이페이·가오슝·타이중',
      region: '동아시아',
      minDays: 5,
      maxDays: 7,
      destIds: ['taipei', 'kaohsiung', 'taichung'],
    ),
    CityGroup(
      name: '홍콩·마카오',
      region: '동아시아',
      minDays: 3,
      maxDays: 5,
      destIds: ['hongkong', 'macau'],
    ),

    // ─── 동남아시아 ─────────────────────────────────────────
    CityGroup(
      name: '방콕·치앙마이',
      region: '동남아시아',
      minDays: 5,
      maxDays: 8,
      destIds: ['bangkok', 'chiangmai'],
    ),
    CityGroup(
      name: '방콕·코사무이',
      region: '동남아시아',
      minDays: 5,
      maxDays: 7,
      destIds: ['bangkok', 'kohsamui'],
    ),
    CityGroup(
      name: '끄라비·푸켓',
      region: '동남아시아',
      minDays: 4,
      maxDays: 6,
      destIds: ['krabi', 'phuket'],
    ),
    CityGroup(
      name: '하노이·다낭',
      region: '동남아시아',
      minDays: 5,
      maxDays: 7,
      destIds: ['hanoi', 'danang'],
    ),
    CityGroup(
      name: '다낭·나트랑·호치민',
      region: '동남아시아',
      minDays: 6,
      maxDays: 9,
      destIds: ['danang', 'nhatrang', 'hochiminh'],
    ),
    CityGroup(
      name: '발리·족자카르타',
      region: '동남아시아',
      minDays: 5,
      maxDays: 8,
      destIds: ['bali', 'yogyakarta'],
    ),
    CityGroup(
      name: '쿠알라룸푸르·코타키나발루',
      region: '동남아시아',
      minDays: 5,
      maxDays: 7,
      destIds: ['kualalumpur', 'kotakinabalu'],
    ),

    // ─── 유럽 - 프랑스 ─────────────────────────────────────
    CityGroup(
      name: '파리·몽생미셸',
      region: '유럽',
      minDays: 5,
      maxDays: 7,
      destIds: ['paris', 'montsaintmichel'],
    ),
    CityGroup(
      name: '파리·몽생미셸·스트라스부르',
      region: '유럽',
      minDays: 7,
      maxDays: 10,
      destIds: ['paris', 'montsaintmichel', 'strasbourg'],
    ),
    CityGroup(
      name: '니스·마르세유',
      region: '유럽',
      minDays: 4,
      maxDays: 6,
      destIds: ['nice', 'marseille'],
    ),

    // ─── 유럽 - 스페인 ─────────────────────────────────────
    CityGroup(
      name: '바르셀로나·마드리드',
      region: '유럽',
      minDays: 5,
      maxDays: 7,
      destIds: ['barcelona', 'madrid'],
    ),
    CityGroup(
      name: '세비야·그라나다·말라가',
      region: '유럽',
      minDays: 4,
      maxDays: 6,
      destIds: ['sevilla', 'granada', 'malaga'],
    ),
    CityGroup(
      name: '마드리드·세비야·그라나다·말라가',
      region: '유럽',
      minDays: 7,
      maxDays: 10,
      destIds: ['madrid', 'sevilla', 'granada', 'malaga'],
    ),

    // ─── 유럽 - 이탈리아 ───────────────────────────────────
    CityGroup(
      name: '로마·나폴리·아말피',
      region: '유럽',
      minDays: 5,
      maxDays: 7,
      destIds: ['rome', 'naples', 'amalfi'],
    ),
    CityGroup(
      name: '피렌체·베니스·밀라노',
      region: '유럽',
      minDays: 5,
      maxDays: 7,
      destIds: ['florence', 'venice', 'milan'],
    ),
    CityGroup(
      name: '로마·피렌체·베니스·밀라노',
      region: '유럽',
      minDays: 7,
      maxDays: 10,
      destIds: ['rome', 'florence', 'venice', 'milan'],
    ),
    CityGroup(
      name: '돌로미티·베니스·밀라노',
      region: '유럽',
      minDays: 7,
      maxDays: 12,
      destIds: ['dolomiti_ortisei', 'dolomiti_cortina', 'venice', 'milan'],
    ),
    CityGroup(
      name: '로마·나폴리·아말피·시칠리아',
      region: '유럽',
      minDays: 8,
      maxDays: 12,
      destIds: ['rome', 'naples', 'amalfi', 'sicilia'],
    ),
    CityGroup(
      name: '돌로미티·인스부르크·뮌헨',
      region: '유럽',
      minDays: 7,
      maxDays: 12,
      destIds: ['dolomiti_ortisei', 'dolomiti_cortina', 'venice', 'milan'],
    ),

    // ─── 유럽 - 오스트리아 ─────────────────────────────────
    CityGroup(
      name: '인스부르크·잘츠부르크·할슈타트',
      region: '유럽',
      minDays: 4,
      maxDays: 6,
      destIds: ['innsbruck', 'salzburg', 'hallstatt'],
    ),
    CityGroup(
      name: '비엔나·잘츠부르크·할슈타트',
      region: '유럽',
      minDays: 5,
      maxDays: 7,
      destIds: ['vienna', 'salzburg', 'hallstatt'],
    ),
    CityGroup(
      name: '뮌헨·비엔나·잘츠부르크·할슈타트',
      region: '유럽',
      minDays: 6,
      maxDays: 9,
      destIds: ['munich', 'vienna', 'salzburg', 'hallstatt'],
    ),

    // ─── 유럽 - 스위스 ─────────────────────────────────────
    CityGroup(
      name: '취리히·루체른',
      region: '유럽',
      minDays: 5,
      maxDays: 7,
      destIds: ['zurich', 'lucerne'],
    ),
    CityGroup(
      name: '루체른·인터라켄',
      region: '유럽',
      minDays: 5,
      maxDays: 7,
      destIds: ['lucerne', 'interlaken'],
    ),
    CityGroup(
      name: '인터라켄·체르마트',
      region: '유럽',
      minDays: 7,
      maxDays: 11,
      destIds: ['interlaken', 'zermatt'],
    ),
    CityGroup(
      name: '취리히·루체른·인터라켄',
      region: '유럽',
      minDays: 8,
      maxDays: 11,
      destIds: ['zurich', 'lucerne', 'interlaken'],
    ),
    CityGroup(
      name: '제네바·인터라켄·체르마트',
      region: '유럽',
      minDays: 10,
      maxDays: 15,
      destIds: ['geneva', 'interlaken', 'zermatt'],
    ),
    CityGroup(
      name: '취리히·루체른·인터라켄·체르마트',
      region: '유럽',
      minDays: 12,
      maxDays: 18,
      destIds: ['zurich', 'lucerne', 'interlaken', 'zermatt'],
    ),

    // ─── 유럽 - 그리스 ─────────────────────────────────────
    CityGroup(
      name: '산토리니·미코노스',
      region: '유럽',
      minDays: 4,
      maxDays: 6,
      destIds: ['santorini', 'mykonos'],
    ),
    CityGroup(
      name: '아테네·산토리니·미코노스',
      region: '유럽',
      minDays: 7,
      maxDays: 10,
      destIds: ['athens', 'santorini', 'mykonos'],
    ),

    // ─── 유럽 - 크로아티아 ─────────────────────────────────
    CityGroup(
      name: '두브로브니크·스플리트·자그레브',
      region: '유럽',
      minDays: 5,
      maxDays: 8,
      destIds: ['dubrovnik', 'split', 'zagreb'],
    ),

    // ─── 유럽 - 체코 ───────────────────────────────────────
    CityGroup(
      name: '프라하·체스키크룸로프',
      region: '유럽',
      minDays: 3,
      maxDays: 5,
      destIds: ['prague', 'ceskykrumlov'],
    ),

    // ─── 유럽 - 터키 ───────────────────────────────────────
    CityGroup(
      name: '이스탄불·카파도키아',
      region: '유럽',
      minDays: 5,
      maxDays: 7,
      destIds: ['istanbul', 'cappadocia'],
    ),
    CityGroup(
      name: '이스탄불·카파도키아·페티예·안탈리아',
      region: '유럽',
      minDays: 8,
      maxDays: 12,
      destIds: ['istanbul', 'cappadocia', 'fethiye', 'antalya'],
    ),

    // ─── 유럽 - 포르투갈 ───────────────────────────────────
    CityGroup(
      name: '리스본·포르투',
      region: '유럽',
      minDays: 4,
      maxDays: 6,
      destIds: ['lisbon', 'porto'],
    ),

    // ─── 유럽 - 영국 ───────────────────────────────────────
    CityGroup(
      name: '런던·에든버러',
      region: '유럽',
      minDays: 5,
      maxDays: 8,
      destIds: ['london', 'edinburgh'],
    ),

    // ─── 유럽 - 독일 ───────────────────────────────────────
    CityGroup(
      name: '뮌헨·베를린',
      region: '유럽',
      minDays: 5,
      maxDays: 7,
      destIds: ['munich', 'berlin'],
    ),

    // ─── 유럽 - 노르웨이 ───────────────────────────────────
    CityGroup(
      name: '오슬로·트롬쇠',
      region: '유럽',
      minDays: 5,
      maxDays: 7,
      destIds: ['oslo', 'tromso'],
    ),

    // ─── 북아메리카 ─────────────────────────────────────────
    CityGroup(
      name: '뉴욕·워싱턴DC',
      region: '북아메리카',
      minDays: 5,
      maxDays: 7,
      destIds: ['newyork', 'washington_dc'],
    ),
    CityGroup(
      name: '뉴욕·시카고',
      region: '북아메리카',
      minDays: 6,
      maxDays: 8,
      destIds: ['newyork', 'chicago'],
    ),
    CityGroup(
      name: '로스앤젤레스·샌프란시스코',
      region: '북아메리카',
      minDays: 5,
      maxDays: 7,
      destIds: ['losangeles', 'sanfrancisco'],
    ),

    // ─── 남아메리카 ─────────────────────────────────────────
    CityGroup(
      name: '라파스·우유니',
      region: '남아메리카',
      minDays: 3,
      maxDays: 5,
      destIds: ['lapaz', 'uyuni'],
    ),
    CityGroup(
      name: '부에노스아이레스·파타고니아',
      region: '남아메리카',
      minDays: 8,
      maxDays: 14,
      destIds: ['buenosaires', 'patagonia'],
    ),
    CityGroup(
      name: '리우·상파울루',
      region: '남아메리카',
      minDays: 5,
      maxDays: 7,
      destIds: ['rio', 'saopaulo'],
    ),

    // ─── 오세아니아 ─────────────────────────────────────────
    CityGroup(
      name: '시드니·멜버른',
      region: '오세아니아',
      minDays: 6,
      maxDays: 8,
      destIds: ['sydney', 'melbourne'],
    ),
    CityGroup(
      name: '퀸스타운·오클랜드',
      region: '오세아니아',
      minDays: 5,
      maxDays: 7,
      destIds: ['queenstown', 'auckland'],
    ),

    // ─── 아프리카/인도양 ────────────────────────────────────
    CityGroup(
      name: '카이로·룩소르',
      region: '아프리카/인도양',
      minDays: 5,
      maxDays: 7,
      destIds: ['cairo', 'luxor'],
    ),
    CityGroup(
      name: '나이로비·엠보젤리',
      region: '아프리카/인도양',
      minDays: 5,
      maxDays: 8,
      destIds: ['nairobi', 'amboseli'],
    ),
  ];
}
