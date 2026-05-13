import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tokens.dart';
import '../../../core/shift.dart';
import '../../calendar/view_model/calendar_view_model.dart';
import '../../shift_types/view_model/shift_types_view_model.dart';
import 'phase_picker.dart';
import 'start_date_picker.dart';

class PatternPage extends ConsumerStatefulWidget {
  const PatternPage({super.key});

  @override
  ConsumerState<PatternPage> createState() => _PatternPageState();
}

class _PatternPageState extends ConsumerState<PatternPage> {
  late List<String> _draft;
  late List<String> _saved;

  @override
  void initState() {
    super.initState();
    final cycle = ref.read(calendarViewModelProvider).cycle;
    _saved = List<String>.from(cycle);
    _draft = List<String>.from(cycle);
  }

  bool get _isDirty =>
      _draft.length != _saved.length ||
      List.generate(_draft.length, (i) => _draft[i] != _saved[i]).any((b) => b);

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _draft.removeAt(oldIndex);
      _draft.insert(newIndex, item);
    });
  }

  void _removeAt(int i) {
    if (_draft.length <= 1) return;
    setState(() => _draft.removeAt(i));
  }

  Future<void> _addPhase() async {
    final picked = await showPhasePicker(context);
    if (!mounted || picked == null) return;
    setState(() => _draft.add(picked.key));
  }

  Future<void> _editStartDate() async {
    final s = ref.read(calendarViewModelProvider);
    final picked = await showStartDatePicker(
      context,
      initial: s.anchorDate,
      cycle: _draft,
    );
    if (!mounted || picked == null) return;
    await ref.read(calendarViewModelProvider.notifier).saveAnchorDate(picked);
  }

  Future<void> _apply() async {
    await ref.read(calendarViewModelProvider.notifier).savePattern(_draft);
    if (!mounted) return;
    setState(() => _saved = List<String>.from(_draft));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('패턴이 적용됐어요',
            style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700)),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchorDate = ref.watch(
      calendarViewModelProvider.select((s) => s.anchorDate),
    );
    final customs = ref.watch(shiftTypesViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ReorderableListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                buildDefaultDragHandles: false,
                header: const _Heading(),
                footer: _Footer(
                  cycleLength: _draft.length,
                  anchorDate: anchorDate,
                  onEditStart: _editStartDate,
                  onAddPhase: _addPhase,
                ),
                onReorder: _onReorder,
                proxyDecorator: (child, index, animation) {
                  return _DragProxy(animation: animation, child: child);
                },
                children: [
                  for (var i = 0; i < _draft.length; i++)
                    Padding(
                      key: ValueKey('phase-$i-${_draft[i]}'),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PhaseRow(
                        index: i,
                        total: _draft.length,
                        shift: shiftByKeyOrFallback(_draft[i], customs),
                        canRemove: _draft.length > 1,
                        onRemove: () => _removeAt(i),
                      ),
                    ),
                ],
              ),
            ),
            _BottomAction(
              enabled: _isDirty,
              onTap: _apply,
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '반복할 패턴을\n만들어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
              letterSpacing: -0.6,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '순서는 길게 눌러 옮기고,\n옆의 − 버튼으로 지울 수 있어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.text4,
              letterSpacing: -0.2,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.cycleLength,
    required this.anchorDate,
    required this.onEditStart,
    required this.onAddPhase,
  });

  final int cycleLength;
  final DateTime anchorDate;
  final VoidCallback onEditStart;
  final VoidCallback onAddPhase;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 2),
        _AddPhaseButton(onTap: onAddPhase),
        const SizedBox(height: 18),
        _CycleSummary(length: cycleLength),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '적용 범위',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text4,
              letterSpacing: -0.2,
            ),
          ),
        ),
        _RangeCard(anchorDate: anchorDate, onEditStart: onEditStart),
      ],
    );
  }
}

class _PhaseRow extends StatelessWidget {
  const _PhaseRow({
    required this.index,
    required this.total,
    required this.shift,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final int total;
  final Shift shift;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.only(left: 0, right: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          _LongPressDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Icon(Icons.drag_indicator,
                  size: 20, color: AppColors.text5),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: shift.solid,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              shift.short,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  shift.name,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  shift.time,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${index + 1}',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontFeatures: tabularNumbers,
                    ),
                  ),
                  TextSpan(text: ' / $total'),
                ],
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text5,
                ),
              ),
            ),
          ),
          InkResponse(
            onTap: canRemove ? onRemove : null,
            radius: 18,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                Icons.remove,
                size: 18,
                color: canRemove ? AppColors.text4 : AppColors.textDisabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhaseButton extends StatelessWidget {
  const _AddPhaseButton({required this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: disabled ? AppColors.line : AppColors.blue.withValues(alpha: 0.45),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add,
                size: 18,
                color: disabled ? AppColors.text5 : AppColors.blue),
            const SizedBox(width: 4),
            Text(
              '페이즈 추가',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: disabled ? AppColors.text5 : AppColors.blue,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CycleSummary extends StatelessWidget {
  const _CycleSummary({required this.length});
  final int length;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.blue,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$length',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFeatures: tabularNumbers,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$length',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontFeatures: tabularNumbers,
                        ),
                      ),
                      const TextSpan(text: '일마다 반복돼요'),
                    ],
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '한 사이클이 끝나면 자동으로 다시 시작해요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeCard extends StatelessWidget {
  const _RangeCard({required this.anchorDate, required this.onEditStart});
  final DateTime anchorDate;
  final VoidCallback onEditStart;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: AppColors.card,
        child: _RangeRow(
          label: '시작일',
          value: '${anchorDate.year}년 ${anchorDate.month}월 ${anchorDate.day}일',
          onTap: onEditStart,
        ),
      ),
    );
  }
}

class _RangeRow extends StatelessWidget {
  const _RangeRow({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text2,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text1,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.text5,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 102),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.bg,
            AppColors.bg.withValues(alpha: 0.0),
          ],
          stops: const [0.6, 1.0],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            disabledBackgroundColor: AppColors.line,
            foregroundColor: Colors.white,
            disabledForegroundColor: AppColors.textDisabled,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text(
            '이 패턴으로 적용',
            style: TextStyle(
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

class _DragProxy extends StatefulWidget {
  const _DragProxy({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  State<_DragProxy> createState() => _DragProxyState();
}

class _DragProxyState extends State<_DragProxy> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) {
        final t = Curves.easeOut.transform(widget.animation.value);
        return Transform.scale(
          scale: 1 + 0.03 * t,
          child: Material(
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.18 * t),
                    offset: Offset(0, 8 * t),
                    blurRadius: 24 * t,
                  ),
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.10 * t),
                    offset: Offset(0, 2 * t),
                    blurRadius: 6 * t,
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class _LongPressDragStartListener extends ReorderableDragStartListener {
  const _LongPressDragStartListener({
    required super.index,
    required super.child,
  }) : super(enabled: true);

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(
      delay: const Duration(milliseconds: 300),
      debugOwner: this,
    );
  }
}
