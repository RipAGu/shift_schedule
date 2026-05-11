import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../core/date_key.dart';
import '../../../core/shift.dart';
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
      await cycle.put(
        _cycleKey,
        const ['day', 'day', 'night', 'night', 'off', 'off'],
      );
    }
    if (cycle.get(_anchorKey) == null) {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      await cycle.put(_anchorKey, toDateKey(start));
    }
    if (notes.isEmpty) {
      final today = DateTime.now();
      DateTime relative(int days) =>
          DateTime(today.year, today.month, today.day + days);
      final samples = <int, Note>{
        -4: Note(emoji: '💪', memo: '인계 깔끔하게'),
        1: Note(emoji: '🎉', memo: '팀 회식 19시'),
        4: Note(emoji: '😴', memo: '병원 예약 14:30'),
        10: Note(emoji: '🏃', memo: '러닝 모임'),
        16: Note(emoji: '☕', memo: '카페에서 인계 받기'),
      };
      for (final entry in samples.entries) {
        await notes.put(toDateKey(relative(entry.key)), entry.value);
      }
    }
  }

  static const _defaultCycle = <ShiftKind>[
    ShiftKind.day,
    ShiftKind.day,
    ShiftKind.night,
    ShiftKind.night,
    ShiftKind.off,
    ShiftKind.off,
  ];

  List<ShiftKind> readCycle() {
    final raw = cycle.get(_cycleKey);
    if (raw is List) {
      final result = <ShiftKind>[];
      for (final e in raw) {
        final name = e?.toString();
        if (name == null) continue;
        for (final kind in ShiftKind.values) {
          if (kind.name == name) {
            result.add(kind);
            break;
          }
        }
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

  Map<DateKey, ShiftKind> readAllOverrides() {
    final map = <DateKey, ShiftKind>{};
    for (final key in overrides.keys) {
      final v = overrides.get(key);
      if (v == null) continue;
      final kind = ShiftKind.values.where((s) => s.name == v).firstOrNull;
      if (kind != null) map[key as DateKey] = kind;
    }
    return map;
  }
}
