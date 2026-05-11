import '../../../core/date_key.dart';
import '../../../core/shift.dart';

ShiftKind shiftFor({
  required DateTime date,
  required List<ShiftKind> cycle,
  required DateTime anchorDate,
}) {
  if (cycle.isEmpty) return ShiftKind.off;
  final diff = daysBetween(anchorDate, date);
  final len = cycle.length;
  final idx = ((diff % len) + len) % len;
  return cycle[idx];
}

Map<ShiftKind, int> monthStats({
  required int year,
  required int month,
  required List<ShiftKind> cycle,
  required DateTime anchorDate,
  required Map<DateKey, ShiftKind> overrides,
}) {
  final counts = <ShiftKind, int>{for (final k in ShiftKind.values) k: 0};
  final last = DateTime(year, month + 1, 0).day;
  for (var i = 1; i <= last; i++) {
    final d = DateTime(year, month, i);
    final eff =
        overrides[toDateKey(d)] ??
        shiftFor(date: d, cycle: cycle, anchorDate: anchorDate);
    counts[eff] = (counts[eff] ?? 0) + 1;
  }
  return counts;
}
