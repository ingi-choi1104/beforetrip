import 'monthly_climate.dart';

class Destination {
  final String id;
  final String name;
  final String country;
  final String region;
  final String flag;
  final List<MonthlyClimate> climates; // 12개월 순서대로 (1월~12월)

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.region,
    required this.flag,
    required this.climates,
  });
}
