import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tokens.dart';
import '../../../core/shift.dart';
import '../../shift_types/view_model/shift_types_view_model.dart';

const _weekdayShort = ['일', '월', '화', '수', '목', '금', '토'];

Future<DateTime?> showStartDatePicker(
  BuildContext context, {
  required DateTime initial,
      required List<String> cycle,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x610F172A),
    builder: (_) => _StartDatePicker(initial: initial, cycle: cycle),
  );
}

class _StartDatePicker extends StatefulWidget {
  const _StartDatePicker({required this.initial, required this.cycle});
  final DateTime initial;
  final List<String> cycle;

  @override
  State<_StartDatePicker> createState() => _StartDatePickerState();
}

class _StartDatePickerState extends State<_StartDatePicker> {
  late DateTime _selected;
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _selected = DateTime(
      widget.initial.year,
      widget.initial.month,
      widget.initial.day,
    );
    _viewMonth = DateTime(_selected.year, _selected.month);
  }

  void _prevMonth() => setState(() {
        _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1);
      });

  List<DateTime> _grid() {
    final first = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final startOffset = first.weekday % 7; // Sun=0
    final cells = <DateTime>[];
    for (var i = 0; i < 42; i++) {
      cells.add(first.add(Duration(days: i - startOffset)));
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final mq = MediaQuery.of(context);
    final maxHeight = (mq.size.height - mq.viewInsets.bottom) * 0.92;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: AppShadows.sheet,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dragHandle(),
              const SizedBox(height: 10),
              _Header(onClose: () => Navigator.of(context).pop()),
              const SizedBox(height: 16),
              _MonthNav(
                viewMonth: _viewMonth,
                onPrev: _prevMonth,
                onNext: _nextMonth,
              ),
              const SizedBox(height: 4),
              const _WeekdayRow(),
              const SizedBox(height: 2),
              _Grid(
                cells: _grid(),
                viewMonth: _viewMonth,
                selected: _selected,
                today: today,
                onTap: (d) => setState(() => _selected = d),
              ),
              const SizedBox(height: 14),
              _PreviewStrip(start: _selected, cycle: widget.cycle),
              const SizedBox(height: 16),
              _ConfirmButton(
                date: _selected,
                onTap: () => Navigator.of(context).pop(_selected),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dragHandle() => Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '시작일 선택',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text1,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '이 날짜부터 패턴이 적용돼요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text4,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close, size: 18, color: AppColors.text2),
          ),
        ),
      ],
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.viewMonth,
    required this.onPrev,
    required this.onNext,
  });
  final DateTime viewMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          _navBtn(Icons.chevron_left, onPrev),
          Expanded(
            child: Center(
              child: Text(
                '${viewMonth.year}년 ${viewMonth.month}월',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text1,
                  letterSpacing: -0.3,
                  fontFeatures: tabularNumbers,
                ),
              ),
            ),
          ),
          _navBtn(Icons.chevron_right, onNext),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 20, color: AppColors.text2),
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: Text(
                  _weekdayShort[i],
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: i == 0
                        ? AppColors.red
                        : i == 6
                            ? AppColors.blue
                            : AppColors.text5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.cells,
    required this.viewMonth,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final List<DateTime> cells;
  final DateTime viewMonth;
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onTap;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 6; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++) ...[
                  Expanded(
                    child: _Cell(
                      day: cells[row * 7 + col],
                      inMonth: cells[row * 7 + col].month == viewMonth.month,
                      isSelected: _sameDay(cells[row * 7 + col], selected),
                      isToday: _sameDay(cells[row * 7 + col], today),
                      onTap: () => onTap(cells[row * 7 + col]),
                    ),
                  ),
                  if (col != 6) const SizedBox(width: 2),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.day,
    required this.inMonth,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final bool inMonth;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dow = day.weekday % 7;
    final base = !inMonth
        ? AppColors.textDisabled
        : dow == 0
            ? AppColors.red
            : dow == 6
                ? AppColors.blue
                : AppColors.text1;

    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        height: 40,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.blue : Colors.transparent,
              shape: BoxShape.circle,
              border: !isSelected && isToday
                  ? Border.all(color: AppColors.blue, width: 1.5)
                  : null,
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: isSelected || isToday
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: isSelected ? Colors.white : base,
                letterSpacing: -0.2,
                fontFeatures: tabularNumbers,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewStrip extends ConsumerWidget {
  const _PreviewStrip({required this.start, required this.cycle});

  final DateTime start;
  final List<String> cycle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customs = ref.watch(shiftTypesViewModelProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '이 날짜부터 첫 7일',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.text5,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                Expanded(
                  child: _PreviewCell(
                    date: start.add(Duration(days: i)),
                    shift: cycle.isEmpty
                        ? Shift.off
                        : shiftByKeyOrFallback(
                        cycle[i % cycle.length], customs),
                  ),
                ),
                if (i != 6) const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewCell extends StatelessWidget {
  const _PreviewCell({required this.date, required this.shift});
  final DateTime date;
  final Shift shift;

  @override
  Widget build(BuildContext context) {
    final dow = date.weekday % 7;
    final dowColor = dow == 0
        ? AppColors.red
        : dow == 6
            ? AppColors.blue
            : AppColors.text5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _weekdayShort[dow],
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: dowColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${date.day}',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.text3,
            letterSpacing: -0.1,
            fontFeatures: tabularNumbers,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: shift.solid,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            shift.short,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dow = date.weekday % 7;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${date.month}월 ${date.day}일 (${_weekdayShort[dow]})',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontFeatures: tabularNumbers,
                ),
              ),
              const TextSpan(text: ' 부터 시작'),
            ],
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }
}
