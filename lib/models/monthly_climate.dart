import 'dart:math';

class MonthlyClimate {
  final int month;
  final double minTemp;
  final double maxTemp;
  final double precipitation; // mm
  final double daylightHours;
  final double auroraIndex;   // 0~100, 오로라 관측 확률 (aurora 테마 전용)
  final double humidity;      // %, 월평균 상대습도
  final double windSpeed;     // m/s, 월평균 풍속

  const MonthlyClimate({
    required this.month,
    required this.minTemp,
    required this.maxTemp,
    required this.precipitation,
    required this.daylightHours,
    this.auroraIndex = 0,
    this.humidity = 60,
    this.windSpeed = 3.0,
  });

  String get monthName {
    const names = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월',
    ];
    return names[month - 1];
  }

  String get seasonName {
    if (month >= 3 && month <= 5) return '봄';
    if (month >= 6 && month <= 8) return '여름';
    if (month >= 9 && month <= 11) return '가을';
    return '겨울';
  }

  /// 체감 기온 계산
  /// - 추울 때 (T ≤ 10°C, 풍속 ≥ 1.3 m/s): 풍속 냉각 지수 (KMA)
  /// - 더울 때 (T ≥ 27°C, 습도 ≥ 40%): 열 지수 (Steadman)
  /// - 그 외: 실제 기온
  static double feelsLike(double tempC, double windSpeedMs, double humidityPct) {
    final v = windSpeedMs * 3.6; // m/s → km/h
    if (tempC <= 10 && windSpeedMs >= 1.3) {
      return 13.12 +
          0.6215 * tempC -
          11.37 * pow(v, 0.16) +
          0.3965 * pow(v, 0.16) * tempC;
    }
    if (tempC >= 27 && humidityPct >= 40) {
      // Steadman AT: AT = T + 0.33e - 0.70ws - 4.00
      // e = 수증기압 (hPa)
      final e = humidityPct / 100 * 6.105 * exp(17.27 * tempC / (237.7 + tempC));
      return tempC + 0.33 * e - 0.70 * windSpeedMs - 4.00;
    }
    return tempC;
  }

  double get feelsLikeMin => feelsLike(minTemp, windSpeed, humidity);
  double get feelsLikeMax => feelsLike(maxTemp, windSpeed, humidity);

  // DB 직렬화
  Map<String, dynamic> toMap(String destinationId) => {
        'destination_id': destinationId,
        'month': month,
        'min_temp': minTemp,
        'max_temp': maxTemp,
        'precipitation': precipitation,
        'daylight_hours': daylightHours,
        'aurora_index': auroraIndex,
        'humidity': humidity,
        'wind_speed': windSpeed,
      };

  static MonthlyClimate fromMap(Map<String, dynamic> m) => MonthlyClimate(
        month: m['month'] as int,
        minTemp: (m['min_temp'] as num).toDouble(),
        maxTemp: (m['max_temp'] as num).toDouble(),
        precipitation: (m['precipitation'] as num).toDouble(),
        daylightHours: (m['daylight_hours'] as num).toDouble(),
        auroraIndex: (m['aurora_index'] as num? ?? 0).toDouble(),
        humidity: (m['humidity'] as num? ?? 60).toDouble(),
        windSpeed: (m['wind_speed'] as num? ?? 3.0).toDouble(),
      );
}
