import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../app/tokens.dart';
import '../../../core/date_key.dart';
import '../../../core/shift.dart';
import '../domain/shift_calculator.dart';
import '../view_model/calendar_state.dart';
import '../view_model/calendar_view_model.dart';
import 'app_tab_bar.dart';
import 'calendar_cell.dart';
import 'date_detail_sheet.dart';
import 'month_header.dart';
import 'stats_strip.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarViewModelProvider);
    final vm = ref.read(calendarViewModelProvider.notifier);
    final today = DateTime.now();
    final stats = monthStats(
      year: state.focusedMonth.year,
      month: state.focusedMonth.month,
      cycle: state.cycle,
      anchorDate: state.anchorDate,
      overrides: state.overrides,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
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
                              _buildCell(state, day, isOutside: false),
                          todayBuilder: (ctx, day, _) =>
                              _buildCell(state, day, isToday: true),
                          outsideBuilder: (ctx, day, _) =>
                              _buildCell(state, day, isOutside: true),
                          selectedBuilder: (ctx, day, _) =>
                              _buildCell(state, day, isSelected: true),
                        ),
                      ),
                    );
                  },
                ),
              ),
              StatsStrip(stats: stats),
            ],
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: AppTabBar(active: AppTab.calendar),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(
    CalendarState state,
    DateTime day, {
    bool isToday = false,
    bool isOutside = false,
    bool isSelected = false,
  }) {
    final key = toDateKey(day);
    final ShiftKind shift = state.overrides[key] ??
        shiftFor(
          date: day,
          cycle: state.cycle,
          anchorDate: state.anchorDate,
        );
    final note = state.notes[key];
    return CalendarCell(
      day: day,
      shift: shift,
      isToday: isToday,
      isOutside: isOutside,
      isSelected: isSelected,
      emoji: note?.emoji,
      memo: note?.memo,
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
