class MonthlyClimate {
  final int month;
  final double minTemp;
  final double maxTemp;
  final double precipitation; // mm
  final double daylightHours;

  const MonthlyClimate({
    required this.month,
    required this.minTemp,
    required this.maxTemp,
    required this.precipitation,
    required this.daylightHours,
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
}
