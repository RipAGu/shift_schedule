import 'package:flutter_test/flutter_test.dart';
import 'package:sample/core/date_key.dart';
import 'package:sample/features/calendar/domain/shift_calculator.dart';

void main() {
  group('shiftKeyFor', () {
    test('cycles correctly from anchor', () {
      final anchor = DateTime(2026, 4, 27);
      const cycle = ['day', 'day', 'night', 'night', 'off', 'off'];

      expect(shiftKeyFor(date: anchor, cycle: cycle, anchorDate: anchor),
          'day');
      expect(
          shiftKeyFor(
              date: anchor.add(const Duration(days: 2)),
              cycle: cycle,
              anchorDate: anchor),
          'night');
      expect(
          shiftKeyFor(
              date: anchor.add(const Duration(days: 6)),
              cycle: cycle,
              anchorDate: anchor),
          'day');
    });

    test('handles dates before the anchor', () {
      final anchor = DateTime(2026, 4, 27);
      const cycle = ['day', 'day', 'night', 'night', 'off', 'off'];
      // 1 day before anchor = index 5 (last of cycle) = off
      expect(
          shiftKeyFor(
              date: anchor.subtract(const Duration(days: 1)),
              cycle: cycle,
              anchorDate: anchor),
          'off');
    });
  });

  group('monthStatsByKey', () {
    test('counts every day of the month', () {
      final anchor = DateTime(2026, 4, 27);
      const cycle = ['day', 'day', 'night', 'night', 'off', 'off'];

      final stats = monthStatsByKey(
        year: 2026,
        month: 5,
        cycle: cycle,
        anchorDate: anchor,
        overrides: {},
      );

      final total = stats.values.fold<int>(0, (a, b) => a + b);
      expect(total, 31);
    });

    test('overrides take precedence', () {
      final anchor = DateTime(2026, 4, 27);
      const cycle = ['day', 'day', 'night'];

      final stats = monthStatsByKey(
        year: 2026,
        month: 5,
        cycle: cycle,
        anchorDate: anchor,
        overrides: {toDateKey(DateTime(2026, 5, 1)): 'holiday'},
      );

      expect(stats['holiday'], 1);
    });
  });

  test('toDateKey/fromDateKey roundtrip', () {
    final d = DateTime(2026, 5, 11);
    expect(fromDateKey(toDateKey(d)), d);
  });
}
