class CityGroup {
  final int? id;
  final String name;
  final String region;
  final int minDays;
  final int maxDays;
  final List<String> destIds; // ordered, first = primary

  const CityGroup({
    this.id,
    required this.name,
    required this.region,
    required this.minDays,
    required this.maxDays,
    required this.destIds,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'region': region,
    'min_days': minDays,
    'max_days': maxDays,
    'dest_ids': destIds.join(','),
  };

  static CityGroup fromMap(Map<String, dynamic> m) => CityGroup(
    id: m['id'] as int?,
    name: m['name'] as String,
    region: m['region'] as String,
    minDays: m['min_days'] as int,
    maxDays: m['max_days'] as int,
    destIds: (m['dest_ids'] as String).split(','),
  );
}
