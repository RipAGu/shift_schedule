import 'dart:developer' as dev;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/year_holidays.dart';
import 'holiday_service.dart';
import 'holiday_storage.dart';

part 'holiday_repository.g.dart';

@Riverpod(keepAlive: true)
HolidayService holidayService(Ref ref) => HolidayService();

@Riverpod(keepAlive: true)
HolidayStorage holidayStorage(Ref ref) {
  throw UnimplementedError('overridden in main()');
}

@Riverpod(keepAlive: true)
HolidayRepository holidayRepository(Ref ref) {
  return HolidayRepository(
    ref.watch(holidayServiceProvider),
    ref.watch(holidayStorageProvider),
  );
}

@Riverpod(keepAlive: true)
Future<Map<String, String>> yearHolidays(Ref ref, int year) {
  return ref.watch(holidayRepositoryProvider).getYear(year);
}

class HolidayRepository {
  HolidayRepository(this._service, this._storage);

  final HolidayService _service;
  final HolidayStorage _storage;

  Future<Map<String, String>> getYear(int year) async {
    final cached = _storage.read(year);

    if (cached != null && !_isStale(cached)) {
      final age = DateTime.now().difference(cached.fetchedAt).inHours;
      dev.log(
          'Cache hit $year — ${cached.dates.length} holidays, ${age}h old',
          name: 'holidays');
      return cached.dates;
    }

    if (cached != null) {
      dev.log('Cache stale $year — refreshing', name: 'holidays');
    } else {
      dev.log('No cache $year — fetching', name: 'holidays');
    }

    try {
      final fresh = await _service.fetchYear(year);
      if (fresh.isNotEmpty) {
        await _storage.write(YearHolidaysCache(
          year: year,
          dates: fresh,
          fetchedAt: DateTime.now(),
        ));
        dev.log('Cached $year — ${fresh.length} holidays', name: 'holidays');
        return fresh;
      }
      dev.log('Empty fetch result $year, falling back to '
          '${cached == null ? "empty" : "stale cache"}', name: 'holidays');
      return cached?.dates ?? const {};
    } catch (e) {
      dev.log('Fetch failed $year: $e — falling back to '
          '${cached == null ? "empty" : "stale cache"}', name: 'holidays');
      return cached?.dates ?? const {};
    }
  }

  bool _isStale(YearHolidaysCache cache) {
    final age = DateTime.now().difference(cache.fetchedAt).inDays;
    final currentYear = DateTime.now().year;
    // 현재 연도: 7일, 과거/미래 연도: 30일
    final threshold = cache.year == currentYear ? 7 : 30;
    return age > threshold;
  }
}
