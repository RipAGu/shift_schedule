import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/calendar_repository.dart';
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
}
