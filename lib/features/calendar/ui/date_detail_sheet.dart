import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tokens.dart';
import '../../../core/date_key.dart';
import '../../../core/shift.dart';
import '../domain/shift_calculator.dart';
import '../view_model/calendar_view_model.dart';

const _emojis = ['😴', '💪', '🎉', '☕', '🏃', '🍙', '💊', '📚', '✈️', '🩺', '🍻', '⛅'];
const _weekdayFull = [
  '',
  '월요일',
  '화요일',
  '수요일',
  '목요일',
  '금요일',
  '토요일',
  '일요일',
];

Future<void> showDateDetailSheet(BuildContext context, DateTime day) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x520F172A),
    builder: (_) => DateDetailSheet(day: day),
  );
}

class DateDetailSheet extends ConsumerStatefulWidget {
  const DateDetailSheet({super.key, required this.day});

  final DateTime day;

  @override
  ConsumerState<DateDetailSheet> createState() => _DateDetailSheetState();
}

class _DateDetailSheetState extends ConsumerState<DateDetailSheet> {
  late ShiftKind _appliedShift;
  late ShiftKind _pickerSelection;
  late ShiftKind _patternShift;
  String? _emoji;
  bool _pickerOpen = false;
  final _memoCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(calendarViewModelProvider);
    final key = toDateKey(widget.day);
    final note = state.notes[key];
    final override = state.overrides[key];
    _patternShift = shiftFor(
      date: widget.day,
      cycle: state.cycle,
      anchorDate: state.anchorDate,
    );
    _appliedShift = override ?? _patternShift;
    _pickerSelection = _appliedShift;
    _emoji = note?.emoji;
    _memoCtl.text = note?.memo ?? '';
  }

  @override
  void dispose() {
    _memoCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(calendarViewModelProvider.notifier).saveDayDetail(
          day: widget.day,
          emoji: _emoji,
          memo: _memoCtl.text,
          shift: _appliedShift,
        );
    if (mounted) Navigator.of(context).pop();
  }

  void _openPicker() {
    setState(() {
      _pickerOpen = true;
      _pickerSelection = _appliedShift;
    });
  }

  void _closePicker() => setState(() => _pickerOpen = false);

  void _applyPicker() {
    setState(() {
      _appliedShift = _pickerSelection;
      _pickerOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.85;
    final isOverridden = _appliedShift != _patternShift;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: AppShadows.sheet,
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 24 + media.viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dragHandle(),
              const SizedBox(height: 10),
              _DateHeader(day: widget.day, onClose: () => Navigator.of(context).pop()),
              const SizedBox(height: 14),
              _ShiftCard(
                appliedShift: _appliedShift,
                isOverridden: isOverridden,
                pickerOpen: _pickerOpen,
                pickerSelection: _pickerSelection,
                patternShift: _patternShift,
                onOpenPicker: _openPicker,
                onClosePicker: _closePicker,
                onPick: (s) => setState(() => _pickerSelection = s),
                onApply: _applyPicker,
                onResetToPattern: () => setState(() => _appliedShift = _patternShift),
              ),
              const SizedBox(height: 18),
              _SectionLabel('스티커'),
              const SizedBox(height: 8),
              _StickerGrid(
                selected: _emoji,
                onPick: (e) => setState(() => _emoji = (_emoji == e) ? null : e),
              ),
              const SizedBox(height: 18),
              _SectionLabel('메모'),
              const SizedBox(height: 8),
              _MemoField(controller: _memoCtl),
              const SizedBox(height: 16),
              _PrimaryButton(label: '저장하기', onPressed: _save),
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
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.day, required this.onClose});
  final DateTime day;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final dayColor = day.weekday == DateTime.sunday
        ? AppColors.red
        : day.weekday == DateTime.saturday
            ? AppColors.blue
            : AppColors.text1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${day.year}년 ${day.month}월',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text4,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${day.day}일',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                      color: dayColor,
                      fontFeatures: tabularNumbers,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _weekdayFull[day.weekday],
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        InkResponse(
          onTap: onClose,
          radius: 22,
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.bg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 18, color: AppColors.text2),
          ),
        ),
      ],
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.appliedShift,
    required this.isOverridden,
    required this.pickerOpen,
    required this.pickerSelection,
    required this.patternShift,
    required this.onOpenPicker,
    required this.onClosePicker,
    required this.onPick,
    required this.onApply,
    required this.onResetToPattern,
  });

  final ShiftKind appliedShift;
  final bool isOverridden;
  final bool pickerOpen;
  final ShiftKind pickerSelection;
  final ShiftKind patternShift;
  final VoidCallback onOpenPicker;
  final VoidCallback onClosePicker;
  final ValueChanged<ShiftKind> onPick;
  final VoidCallback onApply;
  final VoidCallback onResetToPattern;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: appliedShift.soft,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _topRow(),
          if (pickerOpen) ...[
            const SizedBox(height: 14),
            const Text(
              '어떤 근무로 바꿀까요?',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text3,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            _PickerList(selected: pickerSelection, onPick: onPick),
            const SizedBox(height: 12),
            _ConfirmRow(picked: pickerSelection, onApply: onApply),
          ],
          if (isOverridden && !pickerOpen) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: onResetToPattern,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xB3FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '패턴 근무(${patternShift.name})로 되돌리기',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text3,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _topRow() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: appliedShift.solid,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            appliedShift.short,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    appliedShift.name,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (isOverridden) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xB3FFFFFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '변경됨',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: appliedShift.solid,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                appliedShift.time,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text4,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: pickerOpen ? onClosePicker : onOpenPicker,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pickerOpen ? appliedShift.solid : const Color(0xB3FFFFFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              pickerOpen ? '닫기' : '변경',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: pickerOpen ? Colors.white : appliedShift.solid,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerList extends StatelessWidget {
  const _PickerList({required this.selected, required this.onPick});
  final ShiftKind selected;
  final ValueChanged<ShiftKind> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in ShiftKind.values) ...[
          _PickerItem(
            shift: s,
            selected: s == selected,
            onTap: () => onPick(s),
          ),
          if (s != ShiftKind.values.last) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _PickerItem extends StatelessWidget {
  const _PickerItem({
    required this.shift,
    required this.selected,
    required this.onTap,
  });

  final ShiftKind shift;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xE6FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? shift.solid : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                shift.name,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 18, color: shift.solid),
          ],
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({required this.picked, required this.onApply});
  final ShiftKind picked;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            '선택',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.text4,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  picked.name,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  picked.time,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text4,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onApply,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: picked.solid,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '적용',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.text4,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _StickerGrid extends StatelessWidget {
  const _StickerGrid({required this.selected, required this.onPick});
  final String? selected;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      children: [
        for (final e in _emojis)
          InkWell(
            onTap: () => onPick(e),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: selected == e ? AppColors.blueSoft : AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected == e ? AppColors.blue : Colors.transparent,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(e, style: const TextStyle(fontSize: 22)),
            ),
          ),
      ],
    );
  }
}

class _MemoField extends StatelessWidget {
  const _MemoField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 4,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.text1,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: '오늘의 메모를 남겨봐요',
        hintStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.text5,
        ),
        filled: true,
        fillColor: AppColors.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
