import 'package:flutter/material.dart';

enum ShiftKind {
  day(
    code: 'D',
    short: '주',
    name: '주간',
    time: '07:00 – 19:00',
    solid: Color(0xFF3182F6),
    soft: Color(0xFFE8F2FE),
  ),
  night(
    code: 'N',
    short: '야',
    name: '야간',
    time: '19:00 – 07:00',
    solid: Color(0xFF5A4FCF),
    soft: Color(0xFFEDEBFB),
  ),
  off(
    code: 'O',
    short: '비',
    name: '비번',
    time: '—',
    solid: Color(0xFF8B95A1),
    soft: Color(0xFFECEEF1),
  ),
  holiday(
    code: 'H',
    short: '휴',
    name: '휴무',
    time: '—',
    solid: Color(0xFFF77F36),
    soft: Color(0xFFFEEEDF),
  ),
  vacation(
    code: 'V',
    short: '연',
    name: '연차',
    time: '종일',
    solid: Color(0xFF1FAD6A),
    soft: Color(0xFFDFF2E6),
  ),
  compOff(
    code: 'C',
    short: '대',
    name: '대체휴무',
    time: '—',
    solid: Color(0xFF14B5C6),
    soft: Color(0xFFD6F0F4),
  );

  const ShiftKind({
    required this.code,
    required this.short,
    required this.name,
    required this.time,
    required this.solid,
    required this.soft,
  });

  final String code;
  final String short;
  final String name;
  final String time;
  final Color solid;
  final Color soft;
}
