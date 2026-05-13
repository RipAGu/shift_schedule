import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../core/date_key.dart';
import '../../../core/shift.dart';
import 'shift_types_storage.dart';

// 단일 마이그레이션 — idempotent. 다음을 한 번에 처리:
//
//  1) 구버전 한글 enum.name ('주간', '야간', '비번', '휴무') 가 저장된
//     cycle/overrides 를 새 string-key 체계로 변환.
//  2) 구버전 '연차'/'대체휴무' 는 CustomShift 로 보존 (id='c_xxx').
//  3) v1 에서 'c_' prefix 없이 저장된 CustomShift id 를 'c_' 형식으로 정규화.
//  4) 기본 5종 근무 ('day','night','duty','off','holiday') 가 ShiftTypes
//     저장소에 없으면 시드.
//
// '__shift_types_migrated_v2' 플래그로 1회만 실행.
Future<void> migrateLegacyShiftNames({
  required Box<dynamic> cycleBox,
  required Box<String> overridesBox,
  required ShiftTypesStorage shiftTypesStorage,
}) async {
  const flagKey = '__shift_types_migrated_v2';
  if (shiftTypesStorage.box.get(flagKey) == true) return;

  const baseKoreanToKey = <String, String>{
    '주간': 'day',
    '야간': 'night',
    '비번': 'off',
    '휴무': 'holiday',
  };
  const legacyCustomColors = <String, int>{
    '연차': 0xFF1FAD6A,
    '대체휴무': 0xFF14B5C6,
  };

  var customs = shiftTypesStorage.readAll();

  // ── Step A: v1 의 bare id 를 'c_' prefix 로 정규화 ─────────────────
  final idRenames = <String, String>{}; // oldKey -> newKey
  customs = customs.map((c) {
    final isBaseId = Shift.baseShiftKeys.contains(c.id);
    final hasPrefix = c.id.startsWith('c_');
    if (isBaseId || hasPrefix) return c;
    final newId = 'c_${c.id}';
    idRenames['c_${c.id}'] = newId; // v1 key 'c_<id>' → v2 key newId (same)
    // v1 key 와 v2 key 는 사실 동일 ('c_xxx') 이므로 cycle 재작성 불필요.
    return CustomShift(
      id: newId,
      name: c.name,
      colorHex: c.colorHex,
      isOff: c.isOff,
      startMinutes: c.startMinutes,
      endMinutes: c.endMinutes,
    );
  }).toList();

  // ── Step B: 추가될 한글-only legacy 커스텀 추적용 ───────────────────
  final addedByKorean = <String, CustomShift>{};

  CustomShift ensureKoreanCustom(String koreanName) {
    for (final c in customs) {
      if (c.name == koreanName) return c;
    }
    final existing = addedByKorean[koreanName];
    if (existing != null) return existing;
    final created = CustomShift(
      id: ShiftTypesStorage.genId(),
      name: koreanName,
      colorHex: legacyCustomColors[koreanName] ?? 0xFF8B95A1,
      isOff: false,
      startMinutes: 540,
      endMinutes: 1080,
    );
    addedByKorean[koreanName] = created;
    return created;
  }

  String? convert(String legacy) {
    if (legacy.isEmpty) return null;
    final baseKey = baseKoreanToKey[legacy];
    if (baseKey != null) return baseKey;
    if (legacyCustomColors.containsKey(legacy)) {
      return ensureKoreanCustom(legacy).key;
    }
    // 'c_xxx' (v1) 또는 'day'/'night'/...(v2 신규) 등 이미 새 키 체계.
    return idRenames[legacy] ?? legacy;
  }

  // Cycle 변환
  final rawCycle = cycleBox.get('current');
  if (rawCycle is List) {
    final converted = <String>[];
    for (final e in rawCycle) {
      final v = convert(e?.toString() ?? '');
      if (v != null) converted.add(v);
    }
    if (converted.isNotEmpty) {
      await cycleBox.put('current', converted);
    }
  }

  // Overrides 변환
  final overrideUpdates = <DateKey, String>{};
  for (final key in overridesBox.keys) {
    final v = overridesBox.get(key);
    if (v == null) continue;
    final next = convert(v);
    if (next != null && next != v) {
      overrideUpdates[key as DateKey] = next;
    }
  }
  for (final entry in overrideUpdates.entries) {
    await overridesBox.put(entry.key, entry.value);
  }

  // ── Step C: 기본 5종 seed (없으면 추가) ─────────────────────────────
  final existingIds = customs.map((c) => c.id).toSet()
    ..addAll(addedByKorean.values.map((c) => c.id));
  final seeds = defaultSeedShifts();
  final toSeed = <CustomShift>[];
  for (final s in seeds) {
    if (!existingIds.contains(s.id)) toSeed.add(s);
  }

  // 최종 쓰기: seed 가 앞쪽(주/야/당/비/휴 순)에 오도록 정렬.
  final finalList = <CustomShift>[
    ...toSeed,
    ...customs,
    ...addedByKorean.values,
  ];
  await shiftTypesStorage.writeAll(finalList);
  await shiftTypesStorage.box.put(flagKey, true);

  // v1 플래그가 있다면 정리 (이후엔 v2 가 진실).
  await shiftTypesStorage.box.delete('__legacy_migrated_v1');
}
