import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../app/tokens.dart';
import '../../../core/date_key.dart';
import '../../../core/shift.dart';
import '../../holidays/data/holiday_repository.dart';
import '../../shift_types/view_model/shift_types_view_model.dart';
import '../domain/shift_calculator.dart';
import '../view_model/calendar_state.dart';
import '../view_model/calendar_view_model.dart';
import 'calendar_cell.dart';
import 'date_detail_sheet.dart';
import 'month_header.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarViewModelProvider);
    final vm = ref.read(calendarViewModelProvider.notifier);
    final customs = ref.watch(shiftTypesViewModelProvider);
    final today = DateTime.now();

    final year = state.focusedMonth.year;
    final holidays = <String, String>{
      ...ref.watch(yearHolidaysProvider(year - 1)).value ?? const {},
      ...ref.watch(yearHolidaysProvider(year)).value ?? const {},
      ...ref.watch(yearHolidaysProvider(year + 1)).value ?? const {},
    };

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          MonthHeader(
            month: state.focusedMonth,
            onPrev: () => vm.changeMonth(-1),
            onNext: () => vm.changeMonth(1),
            onToday: vm.goToCurrentMonth,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dowHeight = 22.0;
                final rowHeight = (constraints.maxHeight - dowHeight) / 6;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TableCalendar(
                    firstDay: DateTime(2020, 1, 1),
                    lastDay: DateTime(2035, 12, 31),
                    focusedDay: state.focusedMonth,
                    currentDay: today,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    sixWeekMonthsEnforced: true,
                    availableGestures: AvailableGestures.horizontalSwipe,
                    headerVisible: false,
                    daysOfWeekHeight: dowHeight,
                    rowHeight: rowHeight,
                    calendarStyle: const CalendarStyle(
                      cellMargin: EdgeInsets.zero,
                      cellPadding: EdgeInsets.zero,
                    ),
                    selectedDayPredicate: (d) =>
                        state.selectedDay != null &&
                        isSameDay(d, state.selectedDay),
                    onDaySelected: (selected, focused) {
                      vm.selectDay(selected);
                      showDateDetailSheet(context, selected);
                    },
                    onPageChanged: (focused) {
                      final cur = state.focusedMonth;
                      final delta =
                          (focused.year - cur.year) * 12 +
                          (focused.month - cur.month);
                      if (delta != 0) vm.changeMonth(delta);
                    },
                    calendarBuilders: CalendarBuilders(
                      dowBuilder: (context, day) => _DowLabel(day: day),
                      defaultBuilder: (ctx, day, _) =>
                          _buildCell(state, customs, holidays, day,
                              isOutside: false),
                      todayBuilder: (ctx, day, _) =>
                          _buildCell(state, customs, holidays, day,
                              isToday: true),
                      outsideBuilder: (ctx, day, _) =>
                          _buildCell(state, customs, holidays, day,
                              isOutside: true),
                      selectedBuilder: (ctx, day, _) =>
                          _buildCell(
                            state,
                            customs,
                            holidays,
                            day,
                            isSelected: true,
                            isToday: isSameDay(day, today),
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
          // HomeShell Scaffold (extendBody:true) 가 padding.bottom 에 탭바+시스템 nav
          // 인셋을 자동 주입 → 디바이스마다 정확한 높이로 공간 확보.
          SizedBox(height: MediaQuery
              .of(context)
              .padding
              .bottom),
        ],
      ),
    );
  }

  Widget _buildCell(
    CalendarState state,
      List<CustomShift> customs,
    Map<String, String> holidays,
    DateTime day, {
    bool isToday = false,
    bool isOutside = false,
    bool isSelected = false,
  }) {
    final key = toDateKey(day);
    final shiftKeyStr = state.overrides[key] ??
        shiftKeyFor(
          date: day,
          cycle: state.cycle,
          anchorDate: state.anchorDate,
        );
    final shift = shiftByKeyOrFallback(shiftKeyStr, customs);
    final note = state.notes[key];
    return CalendarCell(
      day: day,
      shift: shift,
      isToday: isToday,
      isOutside: isOutside,
      isSelected: isSelected,
      emoji: note?.emoji,
      memo: note?.memo,
      holiday: holidays[key],
      overridden: state.overrides.containsKey(key),
    );
  }
}

class _DowLabel extends StatelessWidget {
  const _DowLabel({required this.day});
  final DateTime day;

  static const _names = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final idx = day.weekday % 7;
    final color = idx == 0
        ? AppColors.red
        : idx == 6
            ? AppColors.blue
            : AppColors.text5;
    return Center(
      child: Text(
        _names[idx],
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: color,
        ),
      ),
    );
  }
}
