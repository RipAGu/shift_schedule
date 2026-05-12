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

  Future<void> _applyPicker() async {
    final picked = _pickerSelection;
    setState(() {
      _appliedShift = picked;
      _pickerOpen = false;
    });
    await ref.read(calendarViewModelProvider.notifier).saveShiftOverride(
          day: widget.day,
          shift: picked,
        );
  }

  Future<void> _resetToPattern() async {
    setState(() {
      _appliedShift = _patternShift;
      _pickerSelection = _patternShift;
    });
    await ref.read(calendarViewModelProvider.notifier).saveShiftOverride(
          day: widget.day,
          shift: _patternShift,
        );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardHeight = mq.viewInsets.bottom;
    final maxHeight = (mq.size.height - keyboardHeight) * 0.9;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: AppShadows.sheet,
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
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
                pickerOpen: _pickerOpen,
                pickerSelection: _pickerSelection,
                patternShift: _patternShift,
                onOpenPicker: _openPicker,
                onClosePicker: _closePicker,
                onPick: (s) => setState(() => _pickerSelection = s),
                onApply: _applyPicker,
                onResetToPattern: _resetToPattern,
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
    final displayShift = pickerOpen ? pickerSelection : appliedShift;
    final displayOverridden = displayShift != patternShift;
    final showResetButton = !pickerOpen && appliedShift != patternShift;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: displayShift.soft,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _topRow(displayShift, displayOverridden),
          if (pickerOpen) ...[
            const SizedBox(height: 14),
            const Text(
              '어떤 근무로 바꿀까요?',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.text4,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            _PickerGrid(selected: pickerSelection, onPick: onPick),
            const SizedBox(height: 10),
            _SelectedDetailRow(picked: pickerSelection),
            const SizedBox(height: 8),
            _ApplyButton(shift: pickerSelection, onTap: onApply),
          ],
          if (showResetButton) ...[
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

  Widget _topRow(ShiftKind shift, bool overridden) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: shift.solid,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            shift.short,
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
                    shift.name,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (overridden) ...[
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
                          color: shift.solid,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                shift.time,
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pickerOpen ? shift.solid : const Color(0xB3FFFFFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              pickerOpen ? '닫기' : '변경',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: pickerOpen ? Colors.white : shift.solid,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerGrid extends StatelessWidget {
  const _PickerGrid({required this.selected, required this.onPick});
  final ShiftKind selected;
  final ValueChanged<ShiftKind> onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final s in ShiftKind.values) ...[
          Expanded(
            child: _PickerCard(
              shift: s,
              selected: s == selected,
              onTap: () => onPick(s),
            ),
          ),
          if (s != ShiftKind.values.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _PickerCard extends StatelessWidget {
  const _PickerCard({
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
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 76,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? shift.solid : const Color(0xEBFFFFFF),
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: shift.solid.withValues(alpha: 0.33),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : null,
          border: selected
              ? null
              : Border.all(color: const Color(0x0F0F172A), width: 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0x38FFFFFF) : shift.solid,
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
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    shift.name,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.text1,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            if (selected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 14,
                  height: 14,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, size: 10, color: shift.solid),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectedDetailRow extends StatelessWidget {
  const _SelectedDetailRow({required this.picked});
  final ShiftKind picked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xB3FFFFFF),
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
          const SizedBox(width: 10),
          Text(
            picked.name,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: picked.solid,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Text(
            picked.time,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.shift, required this.onTap});
  final ShiftKind shift;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: shift.solid,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '적용',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
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
