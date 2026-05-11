import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const bg = Color(0xFFF2F4F6);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFE5E8EB);
  static const lineSoft = Color(0xFFEEF0F2);

  static const text1 = Color(0xFF191F28);
  static const text2 = Color(0xFF333D4B);
  static const text3 = Color(0xFF4E5968);
  static const text4 = Color(0xFF6B7684);
  static const text5 = Color(0xFF8B95A1);
  static const textDisabled = Color(0xFFB0B8C1);

  static const blue = Color(0xFF3182F6);
  static const blueHover = Color(0xFF1B64DA);
  static const blueSoft = Color(0xFFE8F2FE);
  static const blueSoft2 = Color(0xFFDCEAFD);

  static const red = Color(0xFFF04452);
  static const green = Color(0xFF2DAA67);
}

class AppShadows {
  const AppShadows._();

  static const card = [
    BoxShadow(color: Color(0x0A0F172A), offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(color: Color(0x0A0F172A), offset: Offset(0, 4), blurRadius: 16),
  ];
  static const sheet = [
    BoxShadow(color: Color(0x140F172A), offset: Offset(0, -8), blurRadius: 24),
  ];
}

const tabularNumbers = [FontFeature.tabularFigures()];
