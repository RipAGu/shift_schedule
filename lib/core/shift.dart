import 'package:flutter/material.dart';

class Shift {
  const Shift({
    required this.key,
    required this.name,
    required this.short,
    required this.code,
    required this.time,
    required this.solid,
    required this.soft,
    this.isBase = false,
    this.isOff = false,
  });

  final String key;
  final String name;
  final String short;
  final String code;
  final String time;
  final Color solid;
  final Color soft;
  final bool isBase;
  final bool isOff;

  // 정적 기본 5종 — fallback 용도. 사용자가 첫 실행 시 이 값으로 시드되고
  // 이후엔 CustomShift 로 저장되어 편집 가능해짐.
  static const day = Shift(
    key: 'day',
    name: '주간',
    short: '주',
    code: 'D',
    time: '07:00 – 19:00',
    solid: Color(0xFF3182F6),
    soft: Color(0xFFE8F2FE),
    isBase: true,
  );
  static const night = Shift(
    key: 'night',
    name: '야간',
    short: '야',
    code: 'N',
    time: '19:00 – 07:00',
    solid: Color(0xFF5A4FCF),
    soft: Color(0xFFEDEBFB),
    isBase: true,
  );
  static const duty = Shift(
    key: 'duty',
    name: '당직',
    short: '당',
    code: 'DU',
    time: '종일',
    solid: Color(0xFFF04452),
    soft: Color(0xFFFCE4E6),
    isBase: true,
  );
  static const off = Shift(
    key: 'off',
    name: '비번',
    short: '비',
    code: 'O',
    time: '—',
    solid: Color(0xFF8B95A1),
    soft: Color(0xFFECEEF1),
    isBase: true,
    isOff: true,
  );
  static const holiday = Shift(
    key: 'holiday',
    name: '휴무',
    short: '휴',
    code: 'H',
    time: '—',
    solid: Color(0xFFF77F36),
    soft: Color(0xFFFEEEDF),
    isBase: true,
    isOff: true,
  );

  static const baseShifts = <Shift>[day, night, duty, off, holiday];
  static const baseShiftKeys = <String>[
    'day',
    'night',
    'duty',
    'off',
    'holiday'
  ];

  @override
  bool operator ==(Object other) => other is Shift && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

class CustomShift {
  CustomShift({
    required this.id,
    required this.name,
    required this.colorHex,
    this.isOff = false,
    this.startMinutes = 540, // 09:00
    this.endMinutes = 1080, // 18:00
  });

  final String id;
  String name;
  int colorHex;
  bool isOff;
  int startMinutes;
  int endMinutes;

  // 'day' 같은 base 키 ID 는 그대로, 그 외엔 prefix 없이 ID 자체가 키.
  // (이전 v1 에서는 'c_xxxx' 형태였지만 v2 에선 base 도 동일 리스트라
  // ID 자체를 key 로 쓰는 게 더 일관적. 마이그레이션 코드에서 통일.)
  String get key => id;

  String get _firstChar =>
      name.isEmpty
          ? '?'
          : String.fromCharCode(name.runes.first);

  String get _timeLabel {
    if (isOff) return '—';
    return '${_fmtHM(startMinutes)} – ${_fmtHM(endMinutes)}';
  }

  Shift toShift() {
    final solid = Color(colorHex);
    return Shift(
      key: key,
      name: name,
      short: _firstChar,
      code: _firstChar,
      time: _timeLabel,
      solid: solid,
      soft: softColorFromSolid(solid),
      isBase: Shift.baseShiftKeys.contains(id),
      isOff: isOff,
    );
  }

  CustomShift copyWith({
    String? name,
    int? colorHex,
    bool? isOff,
    int? startMinutes,
    int? endMinutes,
  }) {
    return CustomShift(
      id: id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isOff: isOff ?? this.isOff,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'color': colorHex,
        'isOff': isOff,
        'start': startMinutes,
        'end': endMinutes,
      };

  factory CustomShift.fromJson(Map<String, dynamic> j) =>
      CustomShift(
        id: j['id'] as String,
        name: j['name'] as String,
        colorHex: (j['color'] as num).toInt(),
        isOff: (j['isOff'] as bool?) ?? false,
        startMinutes: (j['start'] as num?)?.toInt() ?? 540,
        endMinutes: (j['end'] as num?)?.toInt() ?? 1080,
      );
}

Color softColorFromSolid(Color solid) =>
    Color.lerp(solid, Colors.white, 0.88)!;

// 9가지 프리셋 — 디자인 합의된 팔레트. 중복 허용.
const shiftColorPresets = <int>[
  0xFF3182F6, // blue
  0xFF5A4FCF, // purple
  0xFFF04452, // red
  0xFFF77F36, // orange
  0xFFF2B233, // yellow
  0xFF2DAA67, // green
  0xFF14B8A6, // teal
  0xFFEC4899, // p  ink
  0xFF8B95A1, // slate (비번 회색과 동일)
];

// 첫 설치 시 시드되는 5종 기본 근무 (이후 사용자가 편집/삭제 가능).
List<CustomShift> defaultSeedShifts() =>
    [
      CustomShift(
        id: 'day',
        name: '주간',
        colorHex: 0xFF3182F6,
        startMinutes: 420,
        endMinutes: 1140, // 07:00 – 19:00
      ),
      CustomShift(
        id: 'night',
        name: '야간',
        colorHex: 0xFF5A4FCF,
        startMinutes: 1140,
        endMinutes: 420, // 19:00 – 07:00 (자정 넘김)
      ),
      CustomShift(
        id: 'duty',
        name: '당직',
        colorHex: 0xFFF04452,
        startMinutes: 540,
        endMinutes: 540, // 24시간
      ),
      CustomShift(
        id: 'off', name: '비번', colorHex: 0xFF8B95A1,
        isOff: true,
      ),
      CustomShift(
        id: 'holiday', name: '휴무', colorHex: 0xFFF77F36,
        isOff: true,
      ),
    ];

Shift? shiftByKey(String key, Iterable<CustomShift> shifts) {
  for (final c in shifts) {
    if (c.key == key) return c.toShift();
  }
  // 저장소에 없을 경우 정적 fallback (마이그레이션 직후 또는 데이터 누락).
  for (final s in Shift.baseShifts) {
    if (s.key == key) return s;
  }
  return null;
}

Shift shiftByKeyOrFallback(String key, Iterable<CustomShift> shifts) {
  final found = shiftByKey(key, shifts);
  if (found != null) return found;
  // 마지막 fallback: 저장된 첫 근무 (혹은 정적 off)
  for (final c in shifts) {
    return c.toShift();
  }
  return Shift.off;
}

List<Shift> allShifts(Iterable<CustomShift> shifts) =>
    shifts.map((c) => c.toShift()).toList();

// ────────────────────────────────────────────────────────────────────────
// Time helpers — minute-of-day 기반.
// ────────────────────────────────────────────────────────────────────────

String _fmtHM(int minutes) {
  final h = (minutes ~/ 60) % 24;
  final m = minutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

String formatHM(int minutes) => _fmtHM(minutes);

bool isOvernight(int startMinutes, int endMinutes) =>
    endMinutes <= startMinutes;

int durationMinutes(int startMinutes, int endMinutes) {
  var d = endMinutes - startMinutes;
  if (d <= 0) d += 24 * 60;
  return d;
}

String formatDuration(int minutes) {
  if (minutes >= 24 * 60) return '24시간';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '$h시간';
  return '$h시간 $m분';
}
