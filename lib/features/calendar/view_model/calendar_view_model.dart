import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/date_key.dart';
import '../data/calendar_repository.dart';
import '../domain/note.dart';
import '../domain/shift_calculator.dart';
import 'calendar_state.dart';

part 'calendar_view_model.g.dart';

@riverpod
class CalendarViewModel extends _$CalendarViewModel {
  @override
  CalendarState build() {
    final repo = ref.watch(calendarRepositoryProvider);
    final now = DateTime.now();
    return CalendarState(
      focusedMonth: DateTime(now.year, now.month),
      cycle: repo.getCycle(),
      anchorDate: repo.getAnchorDate(),
      notes: repo.getAllNotes(),
      overrides: repo.getAllOverrides(),
    );
  }

  void changeMonth(int delta) {
    final m = state.focusedMonth;
    state = state.copyWith(
      focusedMonth: DateTime(m.year, m.month + delta),
    );
  }

  void goToCurrentMonth() {
    final now = DateTime.now();
    state = state.copyWith(
      focusedMonth: DateTime(now.year, now.month),
      selectedDay: DateTime(now.year, now.month, now.day),
    );
  }

  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  Future<void> savePattern(List<String> cycle) async {
    if (cycle.isEmpty) return;
    final repo = ref.read(calendarRepositoryProvider);
    await repo.putCycle(cycle);
    state = state.copyWith(cycle: List.unmodifiable(cycle));
  }

  Future<void> saveAnchorDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final repo = ref.read(calendarRepositoryProvider);
    await repo.putAnchorDate(normalized);
    state = state.copyWith(anchorDate: normalized);
  }

  Future<void> saveShiftOverride({
    required DateTime day,
    required String shiftKey,
  }) async {
    final key = toDateKey(day);
    final repo = ref.read(calendarRepositoryProvider);
    final patternKey = shiftKeyFor(
      date: day,
      cycle: state.cycle,
      anchorDate: state.anchorDate,
    );
    if (shiftKey == patternKey) {
      await repo.deleteOverride(key);
    } else {
      await repo.putOverride(key, shiftKey);
    }
    state = state.copyWith(overrides: repo.getAllOverrides());
  }

  Future<void> saveDayDetail({
    required DateTime day,
    String? emoji,
    required String memo,
    required String shiftKey,
  }) async {
    final key = toDateKey(day);
    final repo = ref.read(calendarRepositoryProvider);

    final hasNote = (emoji != null && emoji.isNotEmpty) || memo.isNotEmpty;
    if (hasNote) {
      await repo.putNote(key, Note(emoji: emoji, memo: memo));
    } else {
      await repo.deleteNote(key);
    }

    final patternKey = shiftKeyFor(
      date: day,
      cycle: state.cycle,
      anchorDate: state.anchorDate,
    );
    if (shiftKey == patternKey) {
      await repo.deleteOverride(key);
    } else {
      await repo.putOverride(key, shiftKey);
    }

    state = state.copyWith(
      notes: repo.getAllNotes(),
      overrides: repo.getAllOverrides(),
    );
  }
}
