import 'package:hive_ce_flutter/hive_flutter.dart';

import '../domain/year_holidays.dart';

class HolidayStorage {
  HolidayStorage(this._box);

  final Box<YearHolidaysCache> _box;

  static Future<HolidayStorage> open() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(YearHolidaysCacheAdapter());
    }
    final box = await Hive.openBox<YearHolidaysCache>('holidays');
    return HolidayStorage(box);
  }

  YearHolidaysCache? read(int year) => _box.get(year);

  Future<void> write(YearHolidaysCache cache) =>
      _box.put(cache.year, cache);
}
