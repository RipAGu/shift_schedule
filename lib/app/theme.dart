import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData get lightTheme {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      surface: AppColors.card,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: base.textTheme.apply(
      fontFamily: 'Pretendard',
      bodyColor: AppColors.text1,
      displayColor: AppColors.text1,
    ),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'Pretendard'),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.text1,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
