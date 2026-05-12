import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/date_key.dart';
import '../../../core/shift.dart';
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
    state = state.copyWith(focusedMonth: DateTime(now.year, now.month));
  }

  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  Future<void> saveDayDetail({
    required DateTime day,
    String? emoji,
    required String memo,
    required ShiftKind shift,
  }) async {
    final key = toDateKey(day);
    final repo = ref.read(calendarRepositoryProvider);

    final hasNote = (emoji != null && emoji.isNotEmpty) || memo.isNotEmpty;
    if (hasNote) {
      await repo.putNote(key, Note(emoji: emoji, memo: memo));
    } else {
      await repo.deleteNote(key);
    }

    final patternShift = shiftFor(
      date: day,
      cycle: state.cycle,
      anchorDate: state.anchorDate,
    );
    if (shift == patternShift) {
      await repo.deleteOverride(key);
    } else {
      await repo.putOverride(key, shift);
    }

    state = state.copyWith(
      notes: repo.getAllNotes(),
      overrides: repo.getAllOverrides(),
    );
  }
}
