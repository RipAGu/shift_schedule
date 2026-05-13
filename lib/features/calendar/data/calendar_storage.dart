import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../core/date_key.dart';
import '../domain/note.dart';

class CalendarStorage {
  CalendarStorage({
    required this.notes,
    required this.overrides,
    required this.cycle,
  });

  final Box<Note> notes;
  final Box<String> overrides;
  final Box<dynamic> cycle;

  static const _cycleKey = 'current';
  static const _anchorKey = 'anchor';

  // 기본 패턴: 주-주-야-야-비-비 — 새 키 체계로 시드.
  static const _defaultCycle = <String>[
    'day',
    'day',
    'night',
    'night',
    'off',
    'off',
  ];

  static Future<CalendarStorage> open() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
    final notes = await Hive.openBox<Note>('notes');
    final overrides = await Hive.openBox<String>('overrides');
    final cycle = await Hive.openBox('cycle');

    final storage = CalendarStorage(
      notes: notes,
      overrides: overrides,
      cycle: cycle,
    );
    await storage._seedIfEmpty();
    return storage;
  }

  Future<void> _seedIfEmpty() async {
    if (cycle.get(_cycleKey) == null) {
      await cycle.put(_cycleKey, _defaultCycle);
    }
    if (cycle.get(_anchorKey) == null) {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      await cycle.put(_anchorKey, toDateKey(start));
    }
  }

  List<String> readCycle() {
    final raw = cycle.get(_cycleKey);
    if (raw is List) {
      final result = <String>[];
      for (final e in raw) {
        final s = e?.toString();
        if (s != null && s.isNotEmpty) result.add(s);
      }
      if (result.isNotEmpty) return result;
    }
    return _defaultCycle;
  }

  DateTime readAnchorDate() {
    final raw = cycle.get(_anchorKey);
    if (raw is String) {
      try {
        return fromDateKey(raw);
      } catch (_) {}
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Map<DateKey, Note> readAllNotes() {
    final map = <DateKey, Note>{};
    for (final key in notes.keys) {
      final v = notes.get(key);
      if (v != null) map[key as DateKey] = v;
    }
    return map;
  }

  Map<DateKey, String> readAllOverrides() {
    final map = <DateKey, String>{};
    for (final key in overrides.keys) {
      final v = overrides.get(key);
      if (v == null || v.isEmpty) continue;
      map[key as DateKey] = v;
    }
    return map;
  }

  Future<void> writeCycle(List<String> next) async {
    await cycle.put(_cycleKey, next);
  }

  Future<void> writeAnchorDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    await cycle.put(_anchorKey, toDateKey(start));
  }

  Future<void> writeOverride(DateKey key, String shiftKey) =>
      overrides.put(key, shiftKey);

  Future<void> deleteOverride(DateKey key) => overrides.delete(key);
}
