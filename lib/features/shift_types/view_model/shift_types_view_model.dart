import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/shift.dart';
import '../../calendar/view_model/calendar_view_model.dart';
import '../data/shift_types_repository.dart';

part 'shift_types_view_model.g.dart';

@Riverpod(keepAlive: true)
class ShiftTypesViewModel extends _$ShiftTypesViewModel {
  @override
  List<CustomShift> build() {
    final repo = ref.watch(shiftTypesRepositoryProvider);
    return List.unmodifiable(repo.getAll());
  }

  Future<CustomShift> add({
    required String name,
    required int colorHex,
    bool isOff = false,
    int startMinutes = 540,
    int endMinutes = 1080,
  }) async {
    final repo = ref.read(shiftTypesRepositoryProvider);
    final created = CustomShift(
      id: repo.genId(),
      name: name,
      colorHex: colorHex,
      isOff: isOff,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    );
    final next = [...state, created];
    await repo.putAll(next);
    state = List.unmodifiable(next);
    return created;
  }

  Future<void> update({
    required String id,
    required String name,
    required int colorHex,
    required bool isOff,
    required int startMinutes,
    required int endMinutes,
  }) async {
    final repo = ref.read(shiftTypesRepositoryProvider);
    final next = [
      for (final c in state)
        if (c.id == id)
          CustomShift(
            id: id,
            name: name,
            colorHex: colorHex,
            isOff: isOff,
            startMinutes: startMinutes,
            endMinutes: endMinutes,
          )
        else
          c,
    ];
    await repo.putAll(next);
    state = List.unmodifiable(next);
  }

  // 삭제 — 마지막 1개 남았으면 거부. cycle 에 포함돼 있으면 자동 제거.
  // 반환: true=성공, false=마지막 근무라 거부.
  Future<bool> remove(String id) async {
    if (state.length <= 1) return false;
    final repo = ref.read(shiftTypesRepositoryProvider);
    final next = state.where((c) => c.id != id).toList();
    await repo.putAll(next);
    state = List.unmodifiable(next);

    // Cycle 에서 해당 키 제거 (overrides 는 fallback 으로 자연 처리).
    final calVm = ref.read(calendarViewModelProvider.notifier);
    final calState = ref.read(calendarViewModelProvider);
    if (calState.cycle.contains(id)) {
      final cleaned = calState.cycle.where((k) => k != id).toList();
      // 비면 첫 근무로 채움.
      if (cleaned.isEmpty) cleaned.add(next.first.id);
      await calVm.savePattern(cleaned);
    }
    return true;
  }
}
