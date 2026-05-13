import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tokens.dart';
import '../../../core/shift.dart';
import '../view_model/shift_types_view_model.dart';

class ShiftTypesPage extends ConsumerStatefulWidget {
  const ShiftTypesPage({super.key});

  @override
  ConsumerState<ShiftTypesPage> createState() => _ShiftTypesPageState();
}

class _ShiftTypesPageState extends ConsumerState<ShiftTypesPage> {
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    final customs = ref.watch(shiftTypesViewModelProvider);
    final canDelete = customs.length > 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(
              editMode: _editMode,
              onToggleEdit: () => setState(() => _editMode = !_editMode),
            ),
            const _Heading(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.paddingOf(context).bottom + 24,
                ),
                children: [
                  _CountRow(count: customs.length, editMode: _editMode),
                  const SizedBox(height: 8),
                  for (final c in customs) ...[
                    _ShiftCard(
                      shift: c,
                      editMode: _editMode,
                      canDelete: canDelete,
                      onTap: () => _openEditSheet(c),
                      onDelete: () => _confirmDelete(c),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (!_editMode) ...[
                    _AddButton(onTap: _openAddSheet),
                    const SizedBox(height: 18),
                    const _Notice(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x610F172A),
      builder: (_) => _ShiftEditSheet(
        existing: null,
        onSave: (draft) async {
          await ref
              .read(shiftTypesViewModelProvider.notifier)
              .add(
                name: draft.name,
                colorHex: draft.colorHex,
                isOff: draft.isOff,
                startMinutes: draft.startMinutes,
                endMinutes: draft.endMinutes,
              );
        },
      ),
    );
  }

  void _openEditSheet(CustomShift custom) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x610F172A),
      builder: (_) => _ShiftEditSheet(
        existing: custom,
        onSave: (draft) async {
          await ref
              .read(shiftTypesViewModelProvider.notifier)
              .update(
                id: custom.id,
                name: draft.name,
                colorHex: draft.colorHex,
                isOff: draft.isOff,
                startMinutes: draft.startMinutes,
                endMinutes: draft.endMinutes,
              );
        },
        onDelete: () => _confirmDelete(custom),
      ),
    );
  }

  Future<void> _confirmDelete(CustomShift custom) async {
    final customs = ref.read(shiftTypesViewModelProvider);
    if (customs.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '근무는 최소 1개가 필요해요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(shift: custom),
    );
    if (confirmed == true && mounted) {
      await ref.read(shiftTypesViewModelProvider.notifier).remove(custom.id);
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.editMode, required this.onToggleEdit});

  final bool editMode;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
      child: Row(
        children: [
          const SizedBox(width: 36, height: 36),
          const Expanded(child: SizedBox.shrink()),
          InkResponse(
            onTap: onToggleEdit,
            radius: 22,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              child: Text(
                editMode ? '완료' : '편집',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: editMode ? AppColors.blue : AppColors.text3,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '근무종류 관리',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '이름·색상·시간을 자유롭게 설정해요\n기본 근무도 편집할 수 있어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.text4,
              letterSpacing: -0.2,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.count, required this.editMode});

  final int count;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            '$count개 근무',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text4,
              letterSpacing: -0.2,
              fontFeatures: tabularNumbers,
            ),
          ),
          if (editMode) ...[
            const Spacer(),
            const Text(
              '빨간 − 버튼으로 삭제',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.text5,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.shift,
    required this.editMode,
    required this.canDelete,
    required this.onTap,
    required this.onDelete,
  });

  final CustomShift shift;
  final bool editMode;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final resolved = shift.toShift();
    final overnight =
        !shift.isOff && isOvernight(shift.startMinutes, shift.endMinutes);
    final dur = shift.isOff
        ? 0
        : durationMinutes(shift.startMinutes, shift.endMinutes);

    return Row(
      children: [
        if (editMode) ...[
          _DeleteMinusButton(
            enabled: canDelete,
            onTap: canDelete ? onDelete : null,
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: InkWell(
            onTap: editMode ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: resolved.solid,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          resolved.short,
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
                              resolved.name,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text1,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            shift.isOff
                                ? const Text(
                                    '하루 종일 휴식',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text5,
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Text(
                                        formatHM(shift.startMinutes),
                                        style: const TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.text3,
                                          fontFeatures: tabularNumbers,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_right_alt,
                                        size: 14,
                                        color: AppColors.text5,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        formatHM(shift.endMinutes),
                                        style: const TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.text3,
                                          fontFeatures: tabularNumbers,
                                        ),
                                      ),
                                      if (overnight) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.bg,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: const Text(
                                            '+1일',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.text5,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      if (!shift.isOff) ...[
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatDuration(dur),
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: resolved.solid,
                                letterSpacing: -0.3,
                                fontFeatures: tabularNumbers,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              '총 근무',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text5,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!editMode) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.text5,
                        ),
                      ],
                    ],
                  ),
                  if (!shift.isOff) ...[
                    const SizedBox(height: 12),
                    _DayBar(
                      startMinutes: shift.startMinutes,
                      endMinutes: shift.endMinutes,
                      color: resolved.solid,
                      compact: true,
                      height: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeleteMinusButton extends StatelessWidget {
  const _DeleteMinusButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.red : AppColors.line,
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.red.withValues(alpha: 0.32),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: const Icon(Icons.remove, size: 16, color: Colors.white),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.blue.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, size: 18, color: AppColors.blue),
            SizedBox(width: 6),
            Text(
              '새 근무 추가',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.blue,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.blue,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'i',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '야간처럼 자정을 넘는 근무는 자동으로 다음날까지 이어진 것으로 처리돼요.\n'
              '색상은 여러 근무에 중복으로 쓸 수 있어요.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.text3,
                letterSpacing: -0.2,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// 편집/추가 sheet
// ────────────────────────────────────────────────────────────────────────

class _ShiftDraft {
  _ShiftDraft({
    required this.name,
    required this.colorHex,
    required this.isOff,
    required this.startMinutes,
    required this.endMinutes,
  });

  String name;
  int colorHex;
  bool isOff;
  int startMinutes;
  int endMinutes;
}

class _ShiftEditSheet extends StatefulWidget {
  const _ShiftEditSheet({
    required this.existing,
    required this.onSave,
    this.onDelete,
  });

  final CustomShift? existing;
  final Future<void> Function(_ShiftDraft draft) onSave;
  final VoidCallback? onDelete;

  @override
  State<_ShiftEditSheet> createState() => _ShiftEditSheetState();
}

enum _TimeTab { start, end }

class _ShiftEditSheetState extends State<_ShiftEditSheet> {
  late TextEditingController _nameCtl;
  late _ShiftDraft _draft;
  _TimeTab _tab = _TimeTab.start;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _draft = _ShiftDraft(
      name: e?.name ?? '',
      colorHex: e?.colorHex ?? shiftColorPresets.first,
      isOff: e?.isOff ?? false,
      startMinutes: e?.startMinutes ?? 540,
      endMinutes: e?.endMinutes ?? 1080,
    );
    _nameCtl = TextEditingController(text: _draft.name);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    super.dispose();
  }

  bool get _canSave => _nameCtl.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_canSave) return;
    _draft.name = _nameCtl.text.trim();
    await widget.onSave(_draft);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final mq = MediaQuery.of(context);
    final solid = Color(_draft.colorHex);
    final overnight =
        !_draft.isOff && isOvernight(_draft.startMinutes, _draft.endMinutes);
    final dur = _draft.isOff
        ? 0
        : durationMinutes(_draft.startMinutes, _draft.endMinutes);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.94),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: AppShadows.sheet,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: solid,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _firstChar(_nameCtl.text),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEdit ? '근무 편집' : '새 근무 추가',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text1,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '이름·색상·시간을 정해주세요',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text4,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkResponse(
                    onTap: () => Navigator.of(context).pop(),
                    radius: 18,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.text2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _Label('이름'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtl,
                maxLength: 8,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1,
                  letterSpacing: -0.3,
                ),
                decoration: InputDecoration(
                  hintText: '예) 오후, 데이, 이브닝',
                  hintStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text5,
                  ),
                  filled: true,
                  fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: solid, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '첫 글자가 캘린더 셀에 표시돼요',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text5,
                        ),
                      ),
                    ),
                    Text(
                      '${_runeCount(_nameCtl.text)}/8',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text5,
                        fontFeatures: tabularNumbers,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _Label('색상'),
              const SizedBox(height: 8),
              _ColorPalette(
                selected: _draft.colorHex,
                onChange: (c) => setState(() => _draft.colorHex = c),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '다른 근무와 같은 색상도 사용할 수 있어요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const _Label('시간'),
                  const Spacer(),
                  InkWell(
                    onTap: () => setState(() => _draft.isOff = !_draft.isOff),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '근무 없음 (휴무)',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text3,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _MiniToggle(on: _draft.isOff, color: solid),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_draft.isOff)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '이 근무는 시간을 사용하지 않아요',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text2,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '휴무·비번처럼 하루 종일 쉬는 날에 사용해요',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text5,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _DayBar(
                  startMinutes: _draft.startMinutes,
                  endMinutes: _draft.endMinutes,
                  color: solid,
                  height: 20,
                  showTicks: true,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _TimeTapCard(
                        label: '시작',
                        timeMinutes: _draft.startMinutes,
                        active: _tab == _TimeTab.start,
                        color: solid,
                        onTap: () => setState(() => _tab = _TimeTab.start),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_right_alt,
                      size: 20,
                      color: AppColors.text5,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TimeTapCard(
                        label: '종료',
                        timeMinutes: _draft.endMinutes,
                        active: _tab == _TimeTab.end,
                        color: solid,
                        badge: overnight ? '+1일' : null,
                        onTap: () => setState(() => _tab = _TimeTab.end),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TimeWheel(
                  minutes: _tab == _TimeTab.start
                      ? _draft.startMinutes
                      : _draft.endMinutes,
                  onChanged: (v) => setState(() {
                    if (_tab == _TimeTab.start) {
                      _draft.startMinutes = v;
                    } else {
                      _draft.endMinutes = v;
                    }
                  }),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.lineSoft),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '근무 시간',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text5,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatDuration(dur) + (overnight ? ' · 자정 넘김' : ''),
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: solid,
                          letterSpacing: -0.4,
                          fontFeatures: tabularNumbers,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  if (isEdit && widget.onDelete != null) ...[
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDelete?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDE7E9),
                          foregroundColor: AppColors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.delete_outline, size: 22),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _canSave ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          disabledBackgroundColor: AppColors.line,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: AppColors.textDisabled,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isEdit ? '저장' : '추가하기',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _firstChar(String s) {
  if (s.isEmpty) return '+';
  return String.fromCharCode(s.runes.first);
}

int _runeCount(String s) => s.runes.length;

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.text4,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _ColorPalette extends StatelessWidget {
  const _ColorPalette({required this.selected, required this.onChange});

  final int selected;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: GridView.count(
        crossAxisCount: 9,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.0,
        children: [
          for (final c in shiftColorPresets)
            _ColorDot(
              color: Color(c),
              selected: c == selected,
              onTap: () => onChange(c),
            ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: AppColors.card, width: 2.5)
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 0,
                    spreadRadius: 2.5,
                  ),
                ]
              : null,
        ),
        transform: Matrix4.identity()
          ..scaleByDouble(selected ? 0.9 : 1.0, selected ? 0.9 : 1.0, 1, 1),
        transformAlignment: Alignment.center,
        child: selected
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}

class _MiniToggle extends StatelessWidget {
  const _MiniToggle({required this.on, required this.color});

  final bool on;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 36,
      height: 22,
      decoration: BoxDecoration(
        color: on ? color : AppColors.line,
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 150),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeTapCard extends StatelessWidget {
  const _TimeTapCard({
    required this.label,
    required this.timeMinutes,
    required this.active,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final String label;
  final int timeMinutes;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: active ? AppColors.card : AppColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.13),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: active ? color : AppColors.text5,
                    letterSpacing: -0.2,
                  ),
                ),
                if (badge != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blueSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.blue,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              formatHM(timeMinutes),
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: active ? AppColors.text1 : AppColors.text3,
                letterSpacing: -0.7,
                fontFeatures: tabularNumbers,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeWheel extends StatefulWidget {
  const _TimeWheel({required this.minutes, required this.onChanged});

  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  State<_TimeWheel> createState() => _TimeWheelState();
}

class _TimeWheelState extends State<_TimeWheel> {
  late FixedExtentScrollController _hourCtl;
  late FixedExtentScrollController _minCtl;

  @override
  void initState() {
    super.initState();
    _hourCtl = FixedExtentScrollController(initialItem: widget.minutes ~/ 60);
    _minCtl = FixedExtentScrollController(
      initialItem: (widget.minutes % 60) ~/ 5,
    );
  }

  @override
  void didUpdateWidget(covariant _TimeWheel old) {
    super.didUpdateWidget(old);
    final h = widget.minutes ~/ 60;
    final mIdx = (widget.minutes % 60) ~/ 5;
    if (_hourCtl.selectedItem != h) {
      _hourCtl.animateToItem(
        h,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    if (_minCtl.selectedItem != mIdx) {
      _minCtl.animateToItem(
        mIdx,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _hourCtl.dispose();
    _minCtl.dispose();
    super.dispose();
  }

  void _emit() {
    final h = _hourCtl.selectedItem % 24;
    final m = (_minCtl.selectedItem % 12) * 5;
    widget.onChanged(h * 60 + m);
  }

  @override
  Widget build(BuildContext context) {
    const wheelHeight = 160.0;
    const itemExtent = 36.0;
    return Container(
      height: wheelHeight,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: itemExtent + 4,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F0F172A),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _WheelColumn(
                  controller: _hourCtl,
                  itemCount: 24,
                  itemExtent: itemExtent,
                  suffix: '시',
                  onSelectedItemChanged: (_) => _emit(),
                  formatter: (i) => i.toString().padLeft(2, '0'),
                ),
              ),
              const SizedBox(
                width: 12,
                child: Text(
                  ':',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text2,
                  ),
                ),
              ),
              Expanded(
                child: _WheelColumn(
                  controller: _minCtl,
                  itemCount: 12,
                  // 0,5,...,55 (5분 단위)
                  itemExtent: itemExtent,
                  suffix: '분',
                  onSelectedItemChanged: (_) => _emit(),
                  formatter: (i) => (i * 5).toString().padLeft(2, '0'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WheelColumn extends StatelessWidget {
  const _WheelColumn({
    required this.controller,
    required this.itemCount,
    required this.itemExtent,
    required this.suffix,
    required this.onSelectedItemChanged,
    required this.formatter,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final double itemExtent;
  final String suffix;
  final ValueChanged<int> onSelectedItemChanged;
  final String Function(int) formatter;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: itemExtent,
      looping: true,
      useMagnifier: false,
      selectionOverlay: const SizedBox.shrink(),
      onSelectedItemChanged: onSelectedItemChanged,
      children: [
        for (var index = 0; index < itemCount; index++)
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  formatter(index),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1,
                    letterSpacing: -0.5,
                    fontFeatures: tabularNumbers,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  suffix,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text5,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// 24h horizontal bar (시작→종료, 자정 넘김 시 두 세그먼트로 분할)
// ────────────────────────────────────────────────────────────────────────

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.startMinutes,
    required this.endMinutes,
    required this.color,
    this.height = 20,
    this.showTicks = false,
    this.compact = false,
  });

  final int startMinutes;
  final int endMinutes;
  final Color color;
  final double height;
  final bool showTicks;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    const total = 24 * 60;
    final overnight = endMinutes <= startMinutes;
    final segments = overnight
        ? <List<int>>[
            [startMinutes, total],
            [0, endMinutes],
          ]
        : <List<int>>[
            [startMinutes, endMinutes],
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, c) {
                final width = c.maxWidth;
                return Stack(
                  children: [
                    Container(
                      color: compact ? AppColors.lineSoft : AppColors.bg,
                    ),
                    if (!compact)
                      for (final h in [6, 12, 18])
                        Positioned(
                          left: width * (h / 24),
                          top: 4,
                          bottom: 4,
                          child: Container(
                            width: 1,
                            color: const Color(0x2E8B95A1),
                          ),
                        ),
                    for (final seg in segments)
                      Positioned(
                        left: width * (seg[0] / total),
                        width: width * ((seg[1] - seg[0]) / total),
                        top: 0,
                        bottom: 0,
                        child: Container(color: color),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        if (showTicks) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final t in [0, 6, 12, 18, 24])
                Text(
                  t.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text5,
                    letterSpacing: 0.2,
                    fontFeatures: tabularNumbers,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// 삭제 확인 다이얼로그
// ────────────────────────────────────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({required this.shift});

  final CustomShift shift;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(shift.colorHex),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _firstChar(shift.name),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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
                        "'${shift.name}' 삭제할까요?",
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '패턴에서 이 근무가 빠지고\n지난 기록은 그대로 남아요',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text4,
                          height: 1.45,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bg,
                        foregroundColor: AppColors.text2,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '삭제',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
