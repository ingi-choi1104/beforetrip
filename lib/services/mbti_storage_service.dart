import 'package:shared_preferences/shared_preferences.dart';

import '../models/travel_mbti.dart';

class MbtiStorageService {
  static const _key = 'saved_mbti';

  /// 저장: "P,B,N,V,S" 형식
  static Future<void> save(TravelMbtiResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final value =
        '${result.isP ? 'P' : 'Q'},${result.isB ? 'B' : 'L'},${result.style1},${result.style2},${result.style3}';
    await prefs.setString(_key, value);
  }

  /// 불러오기. 저장된 값 없으면 null 반환
  static Future<TravelMbtiResult?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == null) return null;
    final parts = value.split(',');
    if (parts.length != 5) return null;
    return TravelMbtiResult(
      isP: parts[0] == 'P',
      isB: parts[1] == 'B',
      style1: parts[2],
      style2: parts[3],
      style3: parts[4],
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
