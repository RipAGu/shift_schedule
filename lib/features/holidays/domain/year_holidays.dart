import 'package:hive_ce/hive.dart';

part 'year_holidays.g.dart';

@HiveType(typeId: 1)
class YearHolidaysCache extends HiveObject {
  YearHolidaysCache({
    required this.year,
    required this.dates,
    required this.fetchedAt,
  });

  @HiveField(0)
  final int year;

  /// `Map<DateKey, holidayName>` — DateKey is "YYYY-MM-DD".
  @HiveField(1)
  final Map<String, String> dates;

  @HiveField(2)
  final DateTime fetchedAt;
}
