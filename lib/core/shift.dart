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
  });

  final String id;
  String name;
  int colorHex;

  String get key => 'c_$id';

  Shift toShift() {
    final solid = Color(colorHex);
    final firstChar =
    name.isEmpty ? '?' : String.fromCharCode(name.runes.first);
    return Shift(
      key: key,
      name: name,
      short: firstChar,
      code: firstChar,
      time: '—',
      solid: solid,
      soft: softColorFromSolid(solid),
      isBase: false,
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'color': colorHex,
      };

  factory CustomShift.fromJson(Map<String, dynamic> j) =>
      CustomShift(
        id: j['id'] as String,
        name: j['name'] as String,
        colorHex: (j['color'] as num).toInt(),
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
  0xFFEC4899, // pink
  0xFF6B7684, // slate
];

Shift? shiftByKey(String key, Iterable<CustomShift> customs) {
  for (final s in Shift.baseShifts) {
    if (s.key == key) return s;
  }
  for (final c in customs) {
    if (c.key == key) return c.toShift();
  }
  return null;
}

Shift shiftByKeyOrFallback(String key, Iterable<CustomShift> customs) {
  return shiftByKey(key, customs) ?? Shift.off;
}

List<Shift> allShifts(Iterable<CustomShift> customs) =>
    [
      ...Shift.baseShifts,
      ...customs.map((c) => c.toShift()),
    ];
