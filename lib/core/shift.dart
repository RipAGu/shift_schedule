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
  duty(
    code: 'DU',
    short: '당',
    name: '당직',
    time: '종일',
    solid: Color(0xFFF04452),
    soft: Color(0xFFFCE4E6),
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
