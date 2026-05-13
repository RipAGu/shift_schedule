import '../../../core/date_key.dart';

String shiftKeyFor({
  required DateTime date,
  required List<String> cycle,
  required DateTime anchorDate,
}) {
  if (cycle.isEmpty) return 'off';
  final diff = daysBetween(anchorDate, date);
  final len = cycle.length;
  final idx = ((diff % len) + len) % len;
  return cycle[idx];
}

Map<String, int> monthStatsByKey({
  required int year,
  required int month,
  required List<String> cycle,
  required DateTime anchorDate,
  required Map<DateKey, String> overrides,
}) {
  final counts = <String, int>{};
  final last = DateTime(year, month + 1, 0).day;
  for (var i = 1; i <= last; i++) {
    final d = DateTime(year, month, i);
    final eff =
        overrides[toDateKey(d)] ??
        shiftKeyFor(date: d, cycle: cycle, anchorDate: anchorDate);
    counts[eff] = (counts[eff] ?? 0) + 1;
  }
  return counts;
}
